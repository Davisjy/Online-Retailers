//
//  MTSortController.m
//  美团HD
//
//  Created by qingyun on 15/12/2.
//  Copyright © 2015年 qingyun. All rights reserved.
//

#import "MTSortController.h"
#import "MTMetaTool.h"
#import "MTSort.h"
#import "UIView+Extension.h"
#import "Common.h"

@interface MTSortButton : UIButton
@property (nonatomic, strong) MTSort *sort;
@end

@implementation MTSortButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        
        [self setBackgroundImage:[UIImage imageNamed:@"btn_filter_normal"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"btn_filter_selected"] forState:UIControlStateHighlighted];
    }
    return self;
}

- (void)setSort:(MTSort *)sort
{
    _sort = sort;
    [self setTitle:sort.label forState:UIControlStateNormal];
}

@end

@interface MTSortController ()

@end

@implementation MTSortController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSArray *sorts = [MTMetaTool sorts];
    NSUInteger count = sorts.count;
    CGFloat btnW = 100;
    CGFloat btnH = 30;
    CGFloat btnX = 15;
    CGFloat btnStartY = 15;
    CGFloat btnMargin = 15;
    CGFloat height = 0;
    for ( int i = 0; i < count; i ++) {
        MTSortButton *btn = [[MTSortButton alloc] init];
        btn.sort = sorts[i];
        // 传递模型
        btn.width = btnW;
        btn.height = btnH;
        btn.x = btnX;
        btn.y = btnStartY + i*(btnH + btnMargin);
        
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        
        height = CGRectGetMaxY(btn.frame);
    }
    
    CGFloat width = btnW + 2 * btnX;
    height += btnMargin;
    self.preferredContentSize = CGSizeMake(width, height);
}

- (void)btnClick:(MTSortButton *)sender
{
    [MTNotificationCenter postNotificationName:MTSortNotification object:nil userInfo:@{MTSortModel : sender.sort}];
}


@end
