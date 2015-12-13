//
//  MTRestrictions.h
//  美团HD
//
//  Created by qingyun on 15/12/5.
//  Copyright © 2015年 qingyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTRestrictions : NSObject
/** 是否需要预约*/
@property (nonatomic, assign) int is_reservation_required;
/** 是否支持随时退款*/
@property (nonatomic, assign) int is_refundable;
/** 附加信息*/
@property (nonatomic, strong) NSString *special_tips;
@end
