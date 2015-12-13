//
//  MTSort.h
//  美团HD
//
//  Created by qingyun on 15/12/2.
//  Copyright © 2015年 qingyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTSort : NSObject
// 排序名称
@property (nonatomic, strong) NSString *label;
// 排序的值(发给服务器的)
@property (nonatomic, assign) int value;
@end
