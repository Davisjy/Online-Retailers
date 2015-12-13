//
//  MTDealsViewController.h
//  美团HD
//
//  Created by qingyun on 15/12/4.
//  Copyright © 2015年 qingyun. All rights reserved.
//  团购列表控制器

#import <UIKit/UIKit.h>

@interface MTDealsViewController : UICollectionViewController
/**
 *  设置请求参数，子类实现
 *
 */
- (void)setupParams:(NSMutableDictionary *)params;

@end
