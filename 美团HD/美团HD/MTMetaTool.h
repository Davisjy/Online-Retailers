//
//  MTMetaTool.h
//  美团HD
//
//  Created by qingyun on 15/12/2.
//  Copyright © 2015年 qingyun. All rights reserved.
//  管理所有元数据(固定的数据)

#import <Foundation/Foundation.h>
@class MTCategory, MTDeal;
@interface MTMetaTool : NSObject


// 返回344个城市
+ (NSArray *)cities;

// 返回所有分类数据
+ (NSArray *)categories;
+ (MTCategory *)categoryWithDeal:(MTDeal *)deal;

// 返回所有排序数据
+ (NSArray *)sorts;
@end
