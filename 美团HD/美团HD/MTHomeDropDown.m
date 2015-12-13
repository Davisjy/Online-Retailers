//
//  MTHomeDropDown.m
//  美团HD
//
//  Created by qingyun on 15/12/1.
//  Copyright © 2015年 qingyun. All rights reserved.
//

#import "MTHomeDropDown.h"
#import "MTCategory.h"
#import "MTHomeDropDownMainCell.h"
#import "MTHomeDropDownSubCell.h"

@interface MTHomeDropDown ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (weak, nonatomic) IBOutlet UITableView *subTableView;

// 左边主表选中的行号
@property (nonatomic, assign) NSInteger selectedMainRow;
@end

@implementation MTHomeDropDown

+ (instancetype)dropDown
{
    return [[NSBundle mainBundle] loadNibNamed:@"MTHomeDropDown" owner:nil options:0][0];
}

- (void)awakeFromNib
{
    // 不要跟着父控件的尺寸而伸缩
    self.autoresizingMask = UIViewAutoresizingNone;
}

#pragma mark - 数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.mainTableView) {
        return [self.dataSource numberOfRowsInMainTable:self];
    } else {
        return [self.dataSource homeDropDown:self subdataForRowInMainTable:self.selectedMainRow].count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (tableView == self.mainTableView) {
        cell = [MTHomeDropDownMainCell cellWithTabelView:tableView];
        
        // 取出数据源
        cell.textLabel.text = [self.dataSource homeDropDown:self titleForRowInMainTable:indexPath.row];
        if ([self.dataSource respondsToSelector:@selector(homeDropDown:iconForRowInMainTable:)]) {
            cell.imageView.image = [UIImage imageNamed:[self.dataSource homeDropDown:self iconForRowInMainTable:indexPath.row]];
        }
        if ([self.dataSource respondsToSelector:@selector(homeDropDown:selectedIconForRowInMainTable:)]) {
            cell.imageView.highlightedImage = [UIImage imageNamed:[self.dataSource homeDropDown:self selectedIconForRowInMainTable:indexPath.row]];
        }
        
        NSArray *subData = [self.dataSource homeDropDown:self subdataForRowInMainTable:indexPath.row];
        if (subData.count) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else { //从表
        cell = [MTHomeDropDownSubCell cellWithTabelView:tableView];
        NSArray *subData = [self.dataSource homeDropDown:self subdataForRowInMainTable:self.selectedMainRow];
        cell.textLabel.text = subData[indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.mainTableView) {
        // 被点击的分类
        self.selectedMainRow = indexPath.row;
        //刷新右边的数据
        [self.subTableView reloadData];
        
        // 通知代理
        if ([self.delegate respondsToSelector:@selector(homeDropDown:didSelectRowInMainTable:)]) {
            [self.delegate homeDropDown:self didSelectRowInMainTable:indexPath.row];
        }
    } else {
        // 通知代理
        if ([self.delegate respondsToSelector:@selector(homeDropDown:didSelectRowInSubTable:inMainTable:)]) {
            [self.delegate homeDropDown:self didSelectRowInSubTable:indexPath.row inMainTable:self.selectedMainRow];
        }
    }
}

@end
