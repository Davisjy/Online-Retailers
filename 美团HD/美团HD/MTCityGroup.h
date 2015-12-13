//
//  MTCityGroup.h
//  美团HD
//
//  Created by qingyun on 15/12/2.
//  Copyright © 2015年 qingyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTCityGroup : NSObject
// 这组的标题
@property (nonatomic, strong) NSString *title;
// 这组的城市
@property (nonatomic, strong) NSArray *cities;
@end
