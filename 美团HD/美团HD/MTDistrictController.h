//
//  MTDistrictController.h
//  美团HD
//
//  Created by qingyun on 15/12/1.
//  Copyright © 2015年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTDistrictController : UIViewController

@property (nonatomic, strong) NSArray *regions;

// 必须用弱指针，防止强强引用谁都释放不了
@property (nonatomic, weak) UIPopoverController *popover;

@end
