//
//  MTCity.m
//  美团HD
//
//  Created by qingyun on 15/12/2.
//  Copyright © 2015年 qingyun. All rights reserved.
//

#import "MTCity.h"
#import "MJExtension.h"
#import "MTRegion.h"

@implementation MTCity

- (NSDictionary *)objectClassInArray
{
    return @{@"regions" : [MTRegion class]};
}

@end
