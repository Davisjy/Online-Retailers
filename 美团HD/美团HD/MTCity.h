//
//  MTCity.h
//  美团HD
//
//  Created by qingyun on 15/12/2.
//  Copyright © 2015年 qingyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTCity : NSObject
//城市名字
@property (nonatomic, strong) NSString *name;
//城市拼音
@property (nonatomic, strong) NSString *pinYin;
//城市拼音声母
@property (nonatomic, strong) NSString *pinYinHead;
//区域(存放的都是MTRegion模型对象）
@property (nonatomic, strong) NSArray *regions;
@end
