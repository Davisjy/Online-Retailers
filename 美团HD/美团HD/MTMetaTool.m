//
//  MTMetaTool.m
//  美团HD
//
//  Created by qingyun on 15/12/2.
//  Copyright © 2015年 qingyun. All rights reserved.
//

#import "MTMetaTool.h"
#import "MTCity.h"
#import "MJExtension.h"
#import "MTCategory.h"
#import "MTSort.h"
#import "MTDeal.h"

@implementation MTMetaTool

static NSArray *_cities;
static NSArray *_categories;

+ (NSArray *)cities
{
    if (_cities == nil) {
        _cities = [MTCity objectArrayWithFilename:@"cities.plist"];
    }
    return _cities;
}

+ (NSArray *)categories
{
    if (_categories == nil) {
        _categories = [MTCategory objectArrayWithFilename:@"categories.plist"];
    }
    return _categories;
}

+ (MTCategory *)categoryWithDeal:(MTDeal *)deal
{
    NSArray *cs = [self categories];
    NSString *name = [deal.categories firstObject];
    for (MTCategory *c  in cs) {
        if ([c.name isEqualToString:name]) {
            return c;
        }
        if ([c.subcategories containsObject:name]) {
            return c;
        }
    }
    return nil;
}

static NSArray *_sorts;
+ (NSArray *)sorts
{
    if (_sorts == nil) {
        _sorts = [MTSort objectArrayWithFilename:@"sorts.plist"];
    }
    return _sorts;
}

@end
