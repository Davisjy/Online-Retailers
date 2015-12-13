//
//  MTDeal.m
//  美团HD
//
//  Created by qingyun on 15/12/3.
//  Copyright © 2015年 qingyun. All rights reserved.
//

#import "MTDeal.h"
#import "MJExtension.h"
#import "MTBusiness.h"

@interface MTDeal ()<NSCoding>

@end

@implementation MTDeal

- (NSDictionary *)replacedKeyFromPropertyName
{
    return @{@"desc" : @"description"};
}

/**
 *  查看详情界面的id是否和数据库存储的id一样与否，才能删除
 *  如果两个的id一样，就说明是一样的模型对象
 */
- (BOOL)isEqual:(MTDeal *)other
{
    return [self.deal_id isEqualToString:other.deal_id];
}

+ (NSArray *)mj_ignoredPropertyNames
{
    return @[@"editing", @"checking"];
}

+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"businesses" : [MTBusiness class]};
}



/**
 *  MJ的偷懒归档解档
 */
MJCodingImplementation


@end
