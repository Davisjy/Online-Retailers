//
//  MTHomeDropDown.h
//  美团HD
//
//  Created by qingyun on 15/12/1.
//  Copyright © 2015年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MTHomeDropDown;

//@protocol MTHomeDropDownData <NSObject>
//- (NSString *)title;
//- (NSString *)icon;
//- (NSString *)selectedIcon;
//- (NSArray *)subdata;
//@end

@protocol MTHomeDropDownDataSource <NSObject>
// 左边的表格一共有多少行
- (NSInteger)numberOfRowsInMainTable:(MTHomeDropDown *)homeDropDown;
- (NSString *)homeDropDown:(MTHomeDropDown *)homeDropDown titleForRowInMainTable:(int)row;
- (NSArray *)homeDropDown:(MTHomeDropDown *)homeDropDown subdataForRowInMainTable:(int)row;

@optional
- (NSString *)homeDropDown:(MTHomeDropDown *)homeDropDown iconForRowInMainTable:(int)row;
- (NSString *)homeDropDown:(MTHomeDropDown *)homeDropDown selectedIconForRowInMainTable:(int)row;

@end

@protocol MTHomeDropDownDelegate <NSObject>

@optional
- (void)homeDropDown:(MTHomeDropDown *)homeDropDown didSelectRowInMainTable:(int)row;
- (void)homeDropDown:(MTHomeDropDown *)homeDropDown didSelectRowInSubTable:(int)subrow inMainTable:(int)mainrow;

@end

@interface MTHomeDropDown : UIView
+ (instancetype)dropDown;

@property (nonatomic, weak) id<MTHomeDropDownDataSource> dataSource;
@property (nonatomic, weak) id<MTHomeDropDownDelegate> delegate;

@end
