//
//  MTCategoryViewController.m
//  美团HD
//
//  Created by qingyun on 15/12/1.
//  Copyright © 2015年 qingyun. All rights reserved.
//

#import "MTCategoryViewController.h"
#import "MTHomeDropDown.h"
#import "UIView+Extension.h"
#import "MTCategory.h"
#import "MJExtension.h"
#import "Masonry.h"
#import "MTMetaTool.h"
#import "Common.h"

@interface MTCategoryViewController ()<MTHomeDropDownDataSource, MTHomeDropDownDelegate>

@end

@implementation MTCategoryViewController

- (void)loadView
{
    MTHomeDropDown *dropDown = [MTHomeDropDown dropDown];
    dropDown.dataSource = self;
    dropDown.delegate = self;
    self.view = dropDown;
    self.preferredContentSize = dropDown.size;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 加载分类数据
    //NSArray *dictArr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"categories.plist" ofType:nil]];
    //NSArray *categoriesArr = [MTCategory objectArrayWithKeyValuesArray:dictArr];

    //MTHomeDropDown *dropDown = [MTHomeDropDown dropDown];
//    [dropDown mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(300);
//        make.height.mas_equalTo(360);
//    }];
    
    
    
    //self.preferredContentSize = dropDown.size;
}

#pragma mark - MTHomeDropDownDataSource
- (NSInteger)numberOfRowsInMainTable:(MTHomeDropDown *)homeDropDown
{
    return [MTMetaTool categories].count;
}

- (NSString *)homeDropDown:(MTHomeDropDown *)homeDropDown titleForRowInMainTable:(int)row
{
    MTCategory *category = [MTMetaTool categories][row];
    return category.name;
}

- (NSString *)homeDropDown:(MTHomeDropDown *)homeDropDown iconForRowInMainTable:(int)row
{
    MTCategory *category = [MTMetaTool categories][row];
    return category.small_icon;
}

- (NSString *)homeDropDown:(MTHomeDropDown *)homeDropDown selectedIconForRowInMainTable:(int)row
{
    MTCategory *category = [MTMetaTool categories][row];
    return category.small_highlighted_icon;
}

- (NSArray *)homeDropDown:(MTHomeDropDown *)homeDropDown subdataForRowInMainTable:(int)row
{
    MTCategory *category = [MTMetaTool categories][row];
    return category.subcategories;
}

#pragma mark - MTHomeDropDownDelegate
- (void)homeDropDown:(MTHomeDropDown *)homeDropDown didSelectRowInMainTable:(int)row
{
    MTCategory *category = [MTMetaTool categories][row];
    if (category.subcategories.count == 0) {
        [MTNotificationCenter postNotificationName:MTCategoryDidChangeNotification object:nil userInfo:@{MTSelectCategory : category}];
    }
}

- (void)homeDropDown:(MTHomeDropDown *)homeDropDown didSelectRowInSubTable:(int)subrow inMainTable:(int)mainrow
{
    MTCategory *category = [MTMetaTool categories][mainrow];
    
    // 发出通知
    [MTNotificationCenter postNotificationName:MTCategoryDidChangeNotification object:nil userInfo:@{MTSelectCategory : category, MTSelectSubCategoryName : category.subcategories[subrow]}];
}


@end
