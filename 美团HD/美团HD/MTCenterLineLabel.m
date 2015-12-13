//
//  MTCenterLineLabel.m
//  美团HD
//
//  Created by qingyun on 15/12/4.
//  Copyright © 2015年 qingyun. All rights reserved.
//

#import "MTCenterLineLabel.h"

@implementation MTCenterLineLabel

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    // 画矩形
    UIRectFill(CGRectMake(0, rect.size.height * 0.5, rect.size.width, 1));
    
    /**
     *  画线
     */
    //CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 设置线的颜色
    //[[UIColor redColor]setStroke];
    
    //设置线宽
    //CGContextSetLineWidth(CGContextRef  _Nullable c, CGFloat width)
    
    // 画线 设置起点
    //CGContextMoveToPoint(ctx, 0, rect.size.height * 0.5);
    
    // 设置终点
    //CGContextAddLineToPoint(ctx, rect.size.width, rect.size.height * 0.5);
    
    // 渲染
    //CGContextStrokePath(ctx);
}

@end
