//
//  MTHomeTopItem.h
//  美团HD
//
//  Created by qingyun on 15/12/1.
//  Copyright © 2015年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTHomeTopItem : UIView

+ (instancetype)item;
- (void)addTarget:(id)target action:(nonnull SEL)action;
- (void)setTitle:(NSString * _Nullable)title;
- (void)setSubtitle:(NSString * _Nullable)subtitle;
- (void)setIcon:(NSString * _Nullable)icon highIcon:(NSString * _Nullable)highIcon;

@end
