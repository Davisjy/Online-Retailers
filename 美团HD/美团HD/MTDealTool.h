//
//  MTDealTool.h
//  美团HD
//
//  Created by qingyun on 15/12/6.
//  Copyright © 2015年 qingyun. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MTDeal;
@interface MTDealTool : NSObject

/**
 *  返回第page页的收藏团购数据page 从1开始
 */
+ (NSArray *)collectDeals:(int)page;
+ (int)collectDealsCount;
/**
 *  收藏一个团购
 */
+ (void)addCollectDeal:(MTDeal *)deal;

/**
 *  取消收藏一个团购
 */
+ (void)removeCollectDeal:(MTDeal *)deal;

/**
 *  判断团购是否收藏
 */
+ (BOOL)isCollected:(MTDeal *)deal;

@end
