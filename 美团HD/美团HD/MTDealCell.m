//
//  MTDealCell.m
//  黑团HD
//
//  Created by apple on 14-8-19.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "MTDealCell.h"
#import "MTDeal.h"
#import "UIImageView+WebCache.h"

@interface MTDealCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *listPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *purchaseCountLabel;
/**
 属性名不能以new开头
 */
@property (weak, nonatomic) IBOutlet UIImageView *dealNewView;
@property (weak, nonatomic) IBOutlet UIButton *coverBtn;
@property (weak, nonatomic) IBOutlet UIImageView *checView;


@end

@implementation MTDealCell

- (void)awakeFromNib
{
    // 拉伸
    //[self setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_dealcell"]]];
    
    // 平铺
    //self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_dealcell"]];

}

// 背景图片
- (void)drawRect:(CGRect)rect
{
    // 拉伸
    [[UIImage imageNamed:@"bg_dealcell"] drawInRect:rect];
    
    // 平铺
//    [[UIImage imageNamed:@"bg_dealcell"] drawAsPatternInRect:<#(CGRect)#>]
}

- (void)setDeal:(MTDeal *)deal
{
    _deal = deal;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:deal.s_image_url] placeholderImage:[UIImage imageNamed:@"placeholder_deal"]];
    self.titleLabel.text = deal.title;
    self.descLabel.text = deal.desc;
    
    // 购买数
    self.purchaseCountLabel.text = [NSString stringWithFormat:@"已售%d", deal.purchase_count];
    
    // 现价
    self.currentPriceLabel.text = [NSString stringWithFormat:@"￥ %@",deal.current_price];
    
    NSUInteger dotLoc = [self.currentPriceLabel.text rangeOfString:@"."].location;
    if (dotLoc != NSNotFound) {
        // 超过两位小数
        self.currentPriceLabel.text = [self.currentPriceLabel.text substringToIndex:dotLoc + 2];
    }
    
    // 原价
    self.listPriceLabel.text = [NSString stringWithFormat:@"￥ %@",deal.list_price];
    
    // 是否显示新单
    
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *nowStr = [formatter stringFromDate:now];
    
    // 隐藏：发布日期小于今天
    self.dealNewView.hidden = ([deal.publish_date compare:nowStr] == NSOrderedAscending);
    
    // 根据模型属性来控制cover的显示和隐藏
    self.coverBtn.hidden = !deal.isEditting;
    
    // 根据模型属性来控制打钩的显示与隐藏
    self.checView.hidden = !deal.isChecking;
}

- (IBAction)coverClick:(UIButton *)sender {
    // 设置模型
    self.deal.checking = !self.deal.isChecking;
    // 直接修改状态
    self.checView.hidden = !self.checView.isHidden;
    
    if ([self.delegate respondsToSelector:@selector(dealCellCheckingStateDidChange:)]) {
        [self.delegate dealCellCheckingStateDidChange:self];
    }
}
@end
