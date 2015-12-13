//
//  MTHomeTopItem.m
//  美团HD
//
//  Created by qingyun on 15/12/1.
//  Copyright © 2015年 qingyun. All rights reserved.
//

#import "MTHomeTopItem.h"

@interface MTHomeTopItem ()
@property (weak, nonatomic) IBOutlet UIButton *iconClick;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@end

@implementation MTHomeTopItem

+ (instancetype)item
{
    return [[NSBundle mainBundle]loadNibNamed:@"MTHomeTopItem" owner:self options:0][0];
}

- (void)awakeFromNib
{
    self.autoresizingMask = UIViewAutoresizingNone;
}

- (void)addTarget:(id)target action:(SEL)action
{
    [self.iconClick addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)setIcon:(NSString *)icon highIcon:(NSString *)highIcon
{
    [self.iconClick setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    [self.iconClick setImage:[UIImage imageNamed:highIcon] forState:UIControlStateHighlighted];
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (void)setSubtitle:(NSString *)subtitle
{
    self.subtitleLabel.text = subtitle;
}

@end
