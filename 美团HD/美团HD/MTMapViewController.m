//
//  MTMapViewController.m
//  美团HD
//
//  Created by qingyun on 15/12/6.
//  Copyright © 2015年 qingyun. All rights reserved.
//

#import "MTMapViewController.h"
#import "UIBarButtonItem+Extension.h"
#import <MapKit/MapKit.h>
#import "DPAPI.h"
#import "MTBusiness.h"
#import "MTDeal.h"
#import "MTDealAnnotation.h"
#import "MJExtension.h"
#import "MTCategory.h"
#import "MTHomeTopItem.h"
#import "MTCategoryViewController.h"
#import "Common.h"
#import "MTMetaTool.h"

@interface MTMapViewController ()<MKMapViewDelegate, DPRequestDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager *manager;
@property (nonatomic, strong) CLGeocoder *coder;

@property (nonatomic, copy) NSString *city;
/** 分类item */
@property (nonatomic, weak) UIBarButtonItem *categoryItem;
/** 分类popover */
@property (nonatomic, strong) UIPopoverController *categoryPopover;
@property (nonatomic, copy) NSString *selectedCategoryName;
@property (nonatomic, strong) DPRequest *lastRequest;
@end

@implementation MTMapViewController

- (CLGeocoder *)coder
{
    if (_coder == nil) {
        _coder = [[CLGeocoder alloc] init];
    }
    return _coder;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 左边的返回
    UIBarButtonItem *backItem = [UIBarButtonItem itemWithTarget:self action:@selector(back) image:@"icon_back" highImage:@"icon_back_highlighted"];
    
    // 标题
    self.title = @"地图";
    
    [self setupLocationManager];
    
    // 设置地图跟踪用户位置
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    
    // 设置左上角的分类菜单
    MTHomeTopItem *categoryTopItem = [MTHomeTopItem item];
    [categoryTopItem addTarget:self action:@selector(categoryClick)];
    UIBarButtonItem *categoryItem = [[UIBarButtonItem alloc] initWithCustomView:categoryTopItem];
    self.categoryItem = categoryItem;
    self.navigationItem.leftBarButtonItems = @[backItem, categoryItem];
    
    // 监听分类改变
    [MTNotificationCenter addObserver:self selector:@selector(categoryDidChange:) name:MTCategoryDidChangeNotification object:nil];
}

- (void)categoryClick
{
    // 显示分类菜单
    self.categoryPopover = [[UIPopoverController alloc] initWithContentViewController:[[MTCategoryViewController alloc] init]];
    [self.categoryPopover presentPopoverFromBarButtonItem:self.categoryItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)categoryDidChange:(NSNotification *)notification
{
    // 1.关闭popover
    [self.categoryPopover dismissPopoverAnimated:YES];
    
    // 2.获得要发送给服务器的类型名称
    MTCategory *category = notification.userInfo[MTSelectCategory];
    NSString *subcategoryName = notification.userInfo[MTSelectSubCategoryName];
    if (subcategoryName == nil || [subcategoryName isEqualToString:@"全部"]) { // 点击的数据没有子分类
        self.selectedCategoryName = category.name;
    } else {
        self.selectedCategoryName = subcategoryName;
    }
    if ([self.selectedCategoryName isEqualToString:@"全部分类"]) {
        self.selectedCategoryName = nil;
    }
    
    // 3.删除之前所有大头针
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    // 4.重新发送请求给服务器
    [self mapView:self.mapView regionDidChangeAnimated:YES];
    
    // 5.更换顶部item文字
    MTHomeTopItem *topItem = (MTHomeTopItem *)self.categoryItem.customView;
    [topItem setIcon:category.icon highIcon:category.highlighted_icon];
    [topItem setTitle:category.name];
    [topItem setSubtitle:subcategoryName];
}

- (void)setupLocationManager
{
    self.manager = [[CLLocationManager alloc] init];
    if ([[UIDevice currentDevice].systemVersion doubleValue] > 8.0) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            // 如果状态未授权，
            [self.manager requestAlwaysAuthorization];
        }
    }
    
    self.manager.desiredAccuracy = kCLLocationAccuracyBest;
    self.manager.distanceFilter = 15.f;
    
    if ([CLLocationManager locationServicesEnabled]) {
        [self.manager startUpdatingLocation];
    }else{
        NSLog(@"没有开启定位服务");
    }
}

- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
    [MTNotificationCenter removeObserver:self];
}

/**
 *  当用户的位置更新了就会调用一次
 */
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    // 让地图显示到用户所在位置
    MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.location.coordinate, MKCoordinateSpanMake(0.25, 0.25));
    [mapView setRegion:region animated:YES];
    
    // 知道经纬度--> 城市名 : 反地理编码
    // 城市名--> 经纬度: 地理编码
    [self.coder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error || placemarks.count == 0) return ;
        CLPlacemark *mark = [placemarks firstObject];
        // 城市名称mark.locality
        // 详细坐标名mark.addressDictionary;
        
        NSString *city = mark.locality ? mark.locality : mark.addressDictionary[@"State"];
        self.city = [city substringToIndex:city.length - 1];
        // 城市
        
        // 第一次发送请求给服务器
        [self mapView:self.mapView regionDidChangeAnimated:YES];
    }];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (self.city == nil) {
        return;
    }
    
    DPAPI *api = [[DPAPI alloc] init];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"city"] = self.city;
    // 类别
    if (self.selectedCategoryName) {
        params[@"category"] = self.selectedCategoryName;
    }
    params[@"latitude"] = @(mapView.region.center.latitude);
    params[@"longitude"] = @(mapView.region.center.longitude);
    params[@"radius"] = @(5000);
    
    NSLog(@"%@",params);
    // 保存最后一次请求
    self.lastRequest = [api requestWithURL:@"v1/deal/find_deals" params:params delegate:self];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(MTDealAnnotation *)annotation
{
    // 返回nil， 交给系统处理
    if (![annotation isKindOfClass:[MTDealAnnotation class]]) {
        return nil;
    }
    
    // 创建大头针
    static NSString *ID = @"deal";
    MKAnnotationView *annoView = [mapView dequeueReusableAnnotationViewWithIdentifier:ID];
    if (annotation == nil) {
        annoView = [[MKAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:ID];
        annoView.canShowCallout = YES;
    }
    
    // 设置模型(位置、标题、子标题)
    annoView.annotation = annotation;
    
    // 设置图片
    annoView.image = [UIImage imageNamed:annotation.icon];
    return annoView;
}

- (void)request:(DPRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"请求失败%@", error);
}

- (void)request:(DPRequest *)request didFinishLoadingWithResult:(id)result
{
    if (request != self.lastRequest) {
        return;
    }
    NSArray *deals = [MTDeal mj_objectArrayWithKeyValuesArray:result[@"deals"]];
    for (MTDeal *deal in deals) {
        // 获得团购所属类型
        MTCategory *category = [MTMetaTool categoryWithDeal:deal];
        for (MTBusiness *bussiness in deal.businesses) {
            MTDealAnnotation *anno = [[MTDealAnnotation alloc] init];
            anno.coordinate = CLLocationCoordinate2DMake(bussiness.latitude, bussiness.longitude);
            anno.title = bussiness.name;
            anno.subtitle = deal.title;
            anno.icon = category.map_icon;
            
            if ([self.mapView.annotations containsObject:anno]) {
                break;
            }
            [self.mapView addAnnotation:anno];
        }
    }
}


@end
