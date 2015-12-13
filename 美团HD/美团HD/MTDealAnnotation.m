//
//  MTDealAnnotation.m
//  美团HD
//
//  Created by qingyun on 15/12/6.
//  Copyright © 2015年 qingyun. All rights reserved.
//

#import "MTDealAnnotation.h"

@implementation MTDealAnnotation
- (BOOL)isEqual:(MTDealAnnotation *)other
{
    return [self.title isEqualToString:other.title];
}
@end
