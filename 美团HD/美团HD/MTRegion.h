//
//  MTRegion.h
//  美团HD
//
//  Created by qingyun on 15/12/2.
//  Copyright © 2015年 qingyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTRegion : NSObject
//区域名字
@property (nonatomic, strong) NSString *name;
//子区域
@property (nonatomic, strong) NSArray *subregions;
@end
