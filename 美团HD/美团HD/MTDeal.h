//
//  MTDeal.h
//  美团HD
//
//  Created by qingyun on 15/12/3.
//  Copyright © 2015年 qingyun. All rights reserved.
//  一个团购模型

#import <Foundation/Foundation.h>
@class MTRestrictions;
@interface MTDeal : NSObject
/** 团购单ID */
@property (copy, nonatomic) NSString *deal_id;
/** 团购标题 */
@property (copy, nonatomic) NSString *title;
/** 团购描述 */
@property (copy, nonatomic) NSString *desc;
/** 如果想完整地保留服务器返回数字的小数位数(没有小数\1位小数\2位小数等),那么就应该用NSNumber */
/** 团购包含商品原价值 */
@property (strong, nonatomic) NSNumber *list_price;
/** 团购价格 */
@property (strong, nonatomic) NSNumber *current_price;
/** 团购当前已购买数 */
@property (assign, nonatomic) int purchase_count;
/** 团购图片链接，最大图片尺寸450×280 */
@property (copy, nonatomic) NSString *image_url;
/** 小尺寸团购图片链接，最大图片尺寸160×100 */
@property (copy, nonatomic) NSString *s_image_url;
/** 团购发布上线日期*/
@property (nonatomic, strong) NSString *publish_date;
/** 团购过期日期*/
@property (nonatomic, strong) NSString *purchase_deadline;
/** 用于移动应用的html5页面链接*/
@property (nonatomic, strong) NSString *deal_h5_url;
@property (nonatomic, strong) NSString *deal_url;
/** 限制条件*/
@property (nonatomic, strong) MTRestrictions *restrictions;


/** 是否正在编辑 */
@property (nonatomic, assign, getter=isEditting) BOOL editing;
/** 是否被勾选了 */
@property (nonatomic, assign, getter=isChecking) BOOL checking;

@property (nonatomic, strong) NSArray *businesses;
@property (nonatomic, strong) NSArray *categories;
@end
