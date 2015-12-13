//
//  MTDetailViewController.m
//  美团HD
//
//  Created by qingyun on 15/12/5.
//  Copyright © 2015年 qingyun. All rights reserved.
//

#import "MTDetailViewController.h"
#import "Common.h"
#import "MTDeal.h"
#import "MTCenterLineLabel.h"
#import "UIImageView+WebCache.h"
#import "DPAPI.h"
#import "MBProgressHUD+MJ.h"
#import "MJExtension.h"
#import "MTRestrictions.h"
#import "MTDealTool.h"
#import "AlixLibService.h"
#import "AlixPayOrder.h"
#import "DataSigner.h"
#import "PartnerConfig.h"

@interface MTDetailViewController ()<UIWebViewDelegate, DPRequestDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *iconImg;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *desLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet MTCenterLineLabel *oldPriceLabel;
@property (weak, nonatomic) IBOutlet UIButton *refundableAnytime;
@property (weak, nonatomic) IBOutlet UIButton *refundableExpire;
@property (weak, nonatomic) IBOutlet UIButton *publishBtn;
@property (weak, nonatomic) IBOutlet UIButton *purchaceCount;
@property (weak, nonatomic) IBOutlet UIButton *collectBtn;

@end

@implementation MTDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 基本设置
    self.view.backgroundColor = MTGlobalBg;
    
    // 加载网页
    self.webView.hidden = YES;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.deal.deal_h5_url]]];
    
    // 设置基本信息
    [self.iconImg sd_setImageWithURL:[NSURL URLWithString:self.deal.s_image_url] placeholderImage:[UIImage imageNamed:@"placeholder_deal"]];
    self.titleLabel.text = self.deal.title;
    self.desLabel.text = self.deal.desc;
    self.priceLabel.text = [NSString stringWithFormat:@"￥%@", self.deal.current_price];
    self.oldPriceLabel.text = [NSString stringWithFormat:@"门店价 ￥%@", self.deal.list_price];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSDate *deadTime = [formatter dateFromString:self.deal.purchase_deadline];
    // 由过期日期加上一天，求得正确的结束时间
    deadTime =  [deadTime dateByAddingTimeInterval:24 * 60 * 60];
    NSDate *now = [NSDate date];
    NSCalendarUnit unit = NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *cmps = [[NSCalendar currentCalendar] components:unit fromDate:now toDate:deadTime options:0];
    if (cmps.day > 365) {
        [self.publishBtn setTitle:@"一年内不过期" forState:UIControlStateNormal];
    } else {
        [self.publishBtn setTitle:[NSString stringWithFormat:@"%d天%d小时%d分钟", cmps.day, cmps.hour, cmps.minute] forState:UIControlStateNormal];
    }
    
    
    
    [self.purchaceCount setTitle:[NSString stringWithFormat:@"已售%d", self.deal.purchase_count] forState:UIControlStateNormal];
    // 发送请求，获得更详细的内容
    DPAPI *api = [[DPAPI alloc] init];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"deal_id"] = self.deal.deal_id;
    [api requestWithURL:@"v1/deal/get_single_deal" params:params delegate:self];
    
    // 设置收藏状态
    self.collectBtn.selected = [MTDealTool isCollected:self.deal];
}

#pragma mark - DPRequestDelegate

- (void)request:(DPRequest *)request didFinishLoadingWithResult:(id)result
{
    self.deal =  [MTDeal objectWithKeyValues:[result[@"deals"] firstObject]];
    
    // 设置退款信息
    self.refundableAnytime.selected = self.deal.restrictions.is_refundable;
    self.refundableExpire.selected = self.deal.restrictions.is_reservation_required;
}

- (void)request:(DPRequest *)request didFailWithError:(NSError *)error
{
    
    // 1. 提醒失败  如果toView不传值会添加到window上
    [MBProgressHUD showError:@"网络繁忙,请稍后再试" toView:self.view];
}


/**
 *  返回控制器返回的方向
 *
 */
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark - action

- (IBAction)back:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)buy:(UIButton *)sender {
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.deal.deal_url]];
    // 1.生成订单信息 order
    AlixPayOrder *order = [[AlixPayOrder alloc] init];
    order.productName = self.deal.title;
    order.productDescription = self.deal.desc;
    order.partner = PartnerID;
    order.seller = SellerID;
    order.amount = [self.deal.current_price description];
    
    // 2.签名加密
    id<DataSigner> signer = CreateRSADataSigner(PartnerPrivKey);
    // 签名信息
    NSString *signedString = [signer signString:[order description]];
    
    // 3.利用订单信息，签名信息，签名类型生成一个订单字符串
    NSString *orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",[order description], signedString, @"RSA"];
    
    // 4.打开客户端，进行支付(商品名称，商品价格，商户信息) // 后面的两个参数用于网页端
    [AlixLibService payOrder:orderString AndScheme:@"tuangou" seletor:@selector(getResult:) target:self];
}

// 网页端是从这个方法监听处理
- (void)getResult:(NSString *)result
{
    
}

- (IBAction)collection:(UIButton *)sender {
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[MTCollectDealKey] = self.deal;
    if (sender.selected) { // 取消收藏
        [MTDealTool removeCollectDeal:self.deal];
        [MBProgressHUD showSuccess:@"取消收藏成功!" toView:self.view];
        info[MTIscollectKey] = @NO;
    } else { // 收藏
        [MTDealTool addCollectDeal:self.deal];
        [MBProgressHUD showSuccess:@"收藏成功!" toView:self.view];
        info[MTIscollectKey] = @YES;
    }
    // 按钮的选中取反
    sender.selected = !sender.selected;
    
    // 发出通知
    [MTNotificationCenter postNotificationName:MTCollectStateDidChangeNotification object:nil userInfo:info];
    
}
- (IBAction)share:(UIButton *)sender {
}

#pragma mark -  UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ([webView.request.URL.absoluteString isEqualToString:self.deal.deal_h5_url]) {
        NSString *ID = [self.deal.deal_id substringFromIndex:[self.deal.deal_id rangeOfString:@"-"].location + 1];
        NSString *urlStr = [NSString stringWithFormat:@"http://lite.m.dianping.com/group/deal/moreinfo/%@", ID];
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
    } else { // 详情页面加载完毕，但是服务器加密了，现在这个url不能打开
        
//        <html>13</html>
//        outerHTML  所有html
//        interHTML   13
        // 利用webView执行js
        
        
        // 用来拼接所有js
        NSMutableString *js = [NSMutableString string];
        // 删除header
        [js appendString:@"var header = document.getElementsByTagName('header')[0];"];
        [js appendString:@"header.parentNode.removeChild(header);"];
        
        // 删除class=cost-box
        [js appendString:@"var box = document.getElementsByClassName('cost-box')[0];"];
        [js appendString:@"box.parentNode.removeChild(box);"];
        
        
        // 删除class=buy-now
        [js appendString:@"var buyNow = document.getElementsByClassName('buy-now')[0];"];
        [js appendString:@"buyNow.parentNode.removeChild(buyNow);"];
        
        //[js appendString:@"var html;"];
        //[js appendString:@"var infos = document.getElementsByClassName('detail-info');"];
        [webView stringByEvaluatingJavaScriptFromString:js];
        
//        NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('html')[0].outerHTML"];
//        NSLog(@"%@", html);
        
        self.webView.hidden = NO;
        [self.loadingView stopAnimating];

    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //NSLog(@"id=%@ url-%@",self.deal.deal_id, request.URL);
    return YES;
}


@end
