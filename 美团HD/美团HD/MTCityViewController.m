//
//  MTCityViewController.m
//  美团HD
//
//  Created by qingyun on 15/12/1.
//  Copyright © 2015年 qingyun. All rights reserved.
//

#import "MTCityViewController.h"
#import "UIBarButtonItem+Extension.h"
#import "MJExtension.h"
#import "MTCityGroup.h"
#import "Masonry.h"
#import "Common.h"
#import "MTCitySearchResultController.h"
#import "UIView+AutoLayout.h"

const int MTCoverTag = 555;

@interface MTCityViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (nonatomic, strong) NSArray *cityGroup;
@property (weak, nonatomic) IBOutlet UIButton *cover;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, weak) MTCitySearchResultController *citySearchResult;
@end

@implementation MTCityViewController

- (MTCitySearchResultController *)citySearchResult
{
    if (_citySearchResult == nil) {
        MTCitySearchResultController *citySearchResult = [[MTCitySearchResultController alloc] init];
        // 一定要父子关系，不然modal出来的会出现很多原因
        [self addChildViewController:citySearchResult];
        self.citySearchResult = citySearchResult;
        
        [self.view addSubview:self.citySearchResult.view];
        [self.citySearchResult.view autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        [self.citySearchResult.view autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.searchBar withOffset:5];
    }
    return _citySearchResult;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 基本数据
    self.title = @"切换城市";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(cancel) image:@"btn_navigation_close" highImage:@"btn_navigation_close_hl"];
//    self.tableView.sectionIndexBackgroundColor = [UIColor blackColor];
    self.tableView.sectionIndexColor = [UIColor blackColor];
    
    self.searchBar.tintColor = MTColor(32, 191, 179);
    
    // 加载城市数据
    self.cityGroup = [MTCityGroup objectArrayWithFilename:@"cityGroups.plist"];
    
}
- (IBAction)coverClick:(UIButton *)sender {
    [self.searchBar resignFirstResponder];
}

- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil]; 
}

#pragma mark - searchBar delegate
// 键盘弹出:搜索框开始编辑文字
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    // 1.隐藏导航栏
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    // 2.显示遮盖
//    UIView *cover = [[UIView alloc] init];
//    cover.backgroundColor = [UIColor blackColor];
//    cover.tag = MTCoverTag;
//    cover.alpha = 0.5;
//    [cover addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:searchBar action:@selector(resignFirstResponder)]];
//    [self.view addSubview:cover];
//    [cover mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.tableView.mas_left);
//        make.top.equalTo(self.tableView.mas_top);
//        make.right.equalTo(self.tableView.mas_right);
//        make.bottom.equalTo(self.tableView.mas_bottom);
//    }];
    
    // 2.设置searchBar背景
    [searchBar setBackgroundImage:[UIImage imageNamed:@"bg_login_textfield_hl"]];
    // 2.1显示搜索框右边取消按钮
    [searchBar setShowsCancelButton:YES animated:YES];
    
    // 3.显示遮盖
    [UIView animateWithDuration:0.5 animations:^{
        self.cover.alpha = 0.7;
    }];
}

// 结束编辑，键盘退出
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    // 1.显示导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    // 2.隐藏遮盖
    //[[self.view viewWithTag:MTCoverTag] removeFromSuperview];
    // 3.设置默认背景
    [searchBar setBackgroundImage:[UIImage imageNamed:@"bg_login_textfield"]];
    // 2.1取消搜索框右边取消按钮
    [searchBar setShowsCancelButton:NO animated:YES];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.cover.alpha = 0;
    }];
    
    // 4移除搜索结果
    self.citySearchResult.view.hidden = YES;
    searchBar.text = nil;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

// 搜索框文字变化
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length) {
        self.citySearchResult.view.hidden = NO;
        self.citySearchResult.searchText = searchText;
    } else {
        self.citySearchResult.view.hidden = YES;
    }
}

#pragma mark - 数据源方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.cityGroup.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    MTCityGroup *cityGroup = self.cityGroup[section];
    return cityGroup.cities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"city";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    MTCityGroup *cityGroup = self.cityGroup[indexPath.section];
    cell.textLabel.text = cityGroup.cities[indexPath.row];
    
    return cell;
}

#pragma mark - 代理
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    MTCityGroup *cityGroup = self.cityGroup[section];
    return cityGroup.title;
}

- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
//    NSMutableArray *titles = [NSMutableArray array];
//    for (MTCityGroup *group in self.cityGroup) {
//        [titles addObject:group.title];
//    }
//    return titles;
    return [self.cityGroup valueForKeyPath:@"title"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MTCityGroup *cityGroup = self.cityGroup[indexPath.section];
    // 发出通知
    [MTNotificationCenter postNotificationName:MTCityDidSelectNotification object:nil userInfo:@{MTSelectedCityName : cityGroup.cities[indexPath.row]}];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
