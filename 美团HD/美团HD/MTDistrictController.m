//
//  MTDistrictController.m
//  美团HD
//
//  Created by qingyun on 15/12/1.
//  Copyright © 2015年 qingyun. All rights reserved.
//

#import "MTDistrictController.h"
#import "MTHomeDropDown.h"
#import "Masonry.h"
#import "UIView+Extension.h"
#import "MTCityViewController.h"
#import "MTNavigationController.h"
#import "MTMetaTool.h"
#import "MTRegion.h"
#import "Common.h"


@interface MTDistrictController ()<MTHomeDropDownDataSource, MTHomeDropDownDelegate>

@end

@implementation MTDistrictController

- (void)viewDidLoad {
    [super viewDidLoad];
    //创建下拉菜单
    UIView *title = [self.view.subviews firstObject];
    MTHomeDropDown *dropDown = [MTHomeDropDown dropDown];
    dropDown.y = title.height;
    dropDown.dataSource = self;
    dropDown.delegate = self;
    [self.view addSubview:dropDown];
    
    //设置控制器在popover中的尺寸
    self.preferredContentSize = CGSizeMake(dropDown.width, CGRectGetMaxY(dropDown.frame));
}

// 切换城市
- (IBAction)changeCity:(UIButton *)sender {
    [self.popover dismissPopoverAnimated:YES];
    
    MTCityViewController *city = [[MTCityViewController alloc] init];
    MTNavigationController *navCity = [[MTNavigationController alloc] initWithRootViewController:city];
    navCity.modalPresentationStyle = UIModalPresentationFormSheet;
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:navCity animated:YES completion:nil];
    
//    self.presentedViewController会引用着被modal出来的控制器
}

#pragma mark - MTHomeDropDownDataSource
- (NSInteger)numberOfRowsInMainTable:(MTHomeDropDown *)homeDropDown
{
    return self.regions.count;
}

- (NSString *)homeDropDown:(MTHomeDropDown *)homeDropDown titleForRowInMainTable:(int)row
{
    MTRegion *region = self.regions[row];
    return region.name;
}

- (NSArray *)homeDropDown:(MTHomeDropDown *)homeDropDown subdataForRowInMainTable:(int)row
{
    MTRegion *region = self.regions[row];
    return region.subregions;
}

#pragma mark - MTHomeDropDownDelegate
- (void)homeDropDown:(MTHomeDropDown *)homeDropDown didSelectRowInMainTable:(int)row
{
    MTRegion *region = self.regions[row];
    if (region.subregions.count == 0) {
        [MTNotificationCenter postNotificationName:MTDistrictDidChangeNotification object:nil userInfo:@{MTSelectDistrict : region}];
    }
}

- (void)homeDropDown:(MTHomeDropDown *)homeDropDown didSelectRowInSubTable:(int)subrow inMainTable:(int)mainrow
{
    MTRegion *region = self.regions[mainrow];
    
    // 发出通知
    [MTNotificationCenter postNotificationName:MTDistrictDidChangeNotification object:nil userInfo:@{MTSelectDistrict : region, MTSelectSubDistrictName : region.subregions[subrow]}];
}

@end
