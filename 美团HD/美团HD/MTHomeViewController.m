//
//  MTHomeViewController.m
//  美团HD
//
//  Created by qingyun on 15/12/1.
//  Copyright © 2015年 qingyun. All rights reserved.
//

#import "MTHomeViewController.h"
#import "Common.h"
#import "UIBarButtonItem+Extension.h"
#import "UIView+Extension.h"
#import "MTHomeTopItem.h"
#import "MTCategoryViewController.h"
#import "MTDistrictController.h"
#import "MTMetaTool.h"
#import "MTCity.h"
#import "MTSortController.h"
#import "MTSort.h"
#import "MTCategory.h"
#import "MTRegion.h"
#import "MTDeal.h"
#import "MJExtension.h"
#import "MBProgressHUD+MJ.h"
#import "UIView+AutoLayout.h"
#import "MTSearchViewController.h"
#import "MTNavigationController.h"
#import "MJRefresh.h"
#import "AwesomeMenu.h"
#import "MTCollectViewController.h"
#import "MTRecentViewController.h"
#import "MTMapViewController.h"

@interface MTHomeViewController ()<AwesomeMenuDelegate>
//分类item
@property (nonatomic, strong) UIBarButtonItem *categoryItem;
//区域item
@property (nonatomic, strong) UIBarButtonItem *districtItem;
//排序item
@property (nonatomic, strong) UIBarButtonItem *sortItem;
//当前选中的城市名字
@property (nonatomic, strong) NSString *seletedCityName;
//当前选中的分类名字
@property (nonatomic, strong) NSString *seletedCategoryName;
//当前选中的区域名字
@property (nonatomic, strong) NSString *seletedDistrictName;
//当前选中的排序
@property (nonatomic, strong) MTSort *seletedSort;

// 分类poperVer
@property (nonatomic, strong) UIPopoverController *categoryPopoVer;
// 区域poperVer
@property (nonatomic, strong) UIPopoverController *districtPopoVer;
// 排序poperVer
@property (nonatomic, strong) UIPopoverController *sortPopoVer;

@end

@implementation MTHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupNotifications];
    //设置导航栏内容
    [self setupLeftNav];
    [self setupRightNav];
    
    // 创建awesomeMenu
    [self setupAwesomeMenu];

}

- (void)setupAwesomeMenu
{
    // 1.中间的item
    AwesomeMenuItem *startItem = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"icon_pathMenu_background_highlighted"] highlightedImage:nil ContentImage:[UIImage imageNamed:@"icon_pathMenu_mainMine_normal"] highlightedContentImage:nil];
    
    // 2.周边的item
    AwesomeMenuItem *item0 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg_pathMenu_black_normal"] highlightedImage:nil ContentImage:[UIImage imageNamed:@"icon_pathMenu_collect_normal"] highlightedContentImage:[UIImage imageNamed:@"icon_pathMenu_collect_highlighted"]];
    AwesomeMenuItem *item1 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg_pathMenu_black_normal"] highlightedImage:nil ContentImage:[UIImage imageNamed:@"icon_pathMenu_scan_normal"] highlightedContentImage:[UIImage imageNamed:@"icon_pathMenu_scan_highlighted"]];
    AwesomeMenuItem *item2 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg_pathMenu_black_normal"] highlightedImage:nil ContentImage:[UIImage imageNamed:@"icon_pathMenu_mainMine_normal"] highlightedContentImage:[UIImage imageNamed:@"icon_pathMenu_mainMine_highlighted"]];
    AwesomeMenuItem *item3 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg_pathMenu_black_normal"] highlightedImage:nil ContentImage:[UIImage imageNamed:@"icon_pathMenu_more_normal"] highlightedContentImage:[UIImage imageNamed:@"icon_pathMenu_more_highlighted"]];
    
    NSArray *items = @[item0, item1, item2, item3];
    
    CGRect menuFrame = CGRectMake(0, 0, 200, 200);
    AwesomeMenu *menu = [[AwesomeMenu alloc] initWithFrame:menuFrame startItem:startItem optionMenus:items];
    menu.alpha = 0.5;
    // 设置菜单的活动范围
    menu.menuWholeAngle = M_PI_2;
    // 设置开始按钮的位置
    menu.startPoint = CGPointMake(50, 150);
    // 设置代理
    menu.delegate = self;
    // 不要旋转中间按钮
    menu.rotateAddButton = NO;
    
    [self.view addSubview:menu];
    
    // 设置菜单永远在左下角
    [menu autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [menu autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [menu autoSetDimensionsToSize:CGSizeMake(200, 200)];
}

#pragma mark - AwesomeMenu delegate
- (void)awesomeMenuWillAnimateOpen:(AwesomeMenu *)menu
{
    // 替换菜单的图片
    menu.contentImage = [UIImage imageNamed:@"icon_pathMenu_cross_normal"];
    
    // 完全显示
    menu.alpha = 1.0;
}

- (void)awesomeMenuWillAnimateClose:(AwesomeMenu *)menu
{
    // 替换菜单的图片
    menu.contentImage = [UIImage imageNamed:@"icon_pathMenu_mainMine_normal"];
    // 半透明显示
    menu.alpha = 0.5;
}

- (void)awesomeMenu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx
{
    
    // 半透明显示
    menu.alpha = 0.5;
    
    // 替换菜单的图片
    menu.contentImage = [UIImage imageNamed:@"icon_pathMenu_mainMine_normal"];
    switch (idx) {
        case 0: {// 收藏
            MTNavigationController *nav = [[MTNavigationController alloc] initWithRootViewController:[[MTCollectViewController alloc] init]];
            [self presentViewController:nav animated:YES completion:nil];
            break;
        }
        case 1: {// 最近访问记录
            MTNavigationController *nav = [[MTNavigationController alloc] initWithRootViewController:[[MTRecentViewController alloc] init]];
            [self presentViewController:nav animated:YES completion:nil];
            break;
        }
        default:
            break;
    }
}

- (void)setupNotifications
{
    // 监听城市改变
    [MTNotificationCenter addObserver:self selector:@selector(cityChange:) name:MTCityDidSelectNotification object:nil];
    // 监听排序改变
    [MTNotificationCenter addObserver:self selector:@selector(sortDidChange:) name:MTSortNotification object:nil];
    // 监听排序改变
    [MTNotificationCenter addObserver:self selector:@selector(categoryDidChange:) name:MTCategoryDidChangeNotification object:nil];
    // 监听区域改变
    [MTNotificationCenter addObserver:self selector:@selector(districtDidChange:) name:MTDistrictDidChangeNotification object:nil];
}


- (void)dealloc
{
    [MTNotificationCenter removeObserver:self];
}

#pragma mark - 监听通知
- (void)cityChange:(NSNotification *)notification
{
    self.seletedCityName = notification.userInfo[MTSelectedCityName];
    
    // 1.更换顶部区域的文字
    MTHomeTopItem *districtTopItem = (MTHomeTopItem *)self.districtItem.customView;
    [districtTopItem setTitle:[NSString stringWithFormat:@"%@ - 全部", self.seletedCityName]];
    [districtTopItem setSubtitle:nil];

    // 2. 刷新数据
    //[self loadNewDeals];
    [self.collectionView headerBeginRefreshing];
}

- (void)sortDidChange:(NSNotification *)notification
{
    MTSort *sort = notification.userInfo[MTSortModel];
    self.seletedSort = sort;
    // 1.更换顶部排序的文字
    MTHomeTopItem *sortTopItem = (MTHomeTopItem *)self.sortItem.customView;
    
    [sortTopItem setSubtitle:sort.label];
    
    // 2.关闭poperVer
    [self.sortPopoVer dismissPopoverAnimated:YES];
    
    // 3. 刷新数据
    [self.collectionView headerBeginRefreshing];
}

- (void)categoryDidChange:(NSNotification *)notification
{
    MTCategory *category = notification.userInfo[MTSelectCategory];
    NSString *subCategoryName = notification.userInfo[MTSelectSubCategoryName];
    if (subCategoryName == nil || [subCategoryName isEqualToString:@"全部"]) { // 点击了没有子分类
        self.seletedCategoryName = category.name;
    } else {
        self.seletedCategoryName = subCategoryName;
    }
    if ([self.seletedCategoryName isEqualToString:@"全部分类"]) {
        self.seletedCategoryName = nil;
    }
    
    // 1.更换顶部item文字
    MTHomeTopItem *categoryItem = (MTHomeTopItem *)self.categoryItem.customView;
    [categoryItem setIcon:category.icon highIcon:category.highlighted_icon];
    [categoryItem setTitle:category.name];
    [categoryItem setSubtitle:subCategoryName?subCategoryName:@"全部"];
    
    // 2.关闭poperVer
    [self.categoryPopoVer dismissPopoverAnimated:YES];
    
    // 3. 刷新数据
    [self.collectionView headerBeginRefreshing];
}

- (void)districtDidChange:(NSNotification *)notification
{
    MTRegion *region = notification.userInfo[MTSelectDistrict];
    NSString *subDistrictName = notification.userInfo[MTSelectSubDistrictName];
    
    if (subDistrictName == nil || [subDistrictName isEqualToString:@"全部"]) {
        self.seletedDistrictName = region.name;
    } else {
        self.seletedDistrictName = subDistrictName;
    }
    if ([self.seletedDistrictName isEqualToString:@"全部"]) {
        self.seletedDistrictName = nil;
    }
    
    // 1.更换顶部item文字
    MTHomeTopItem *districtItem = (MTHomeTopItem *)self.districtItem.customView;
    [districtItem setTitle:[NSString stringWithFormat:@"%@ - %@",self.seletedCityName, region.name]];
    [districtItem setSubtitle:subDistrictName?subDistrictName:@"全部"];
    
    // 2.关闭poperVer
    [self.districtPopoVer dismissPopoverAnimated:YES];
    
    // 3. 刷新数据
    [self.collectionView headerBeginRefreshing];
}

#pragma mark - 实现父类的方法
- (void)setupParams:(NSMutableDictionary *)params
{
    // 城市
    params[@"city"] = self.seletedCityName;
    // 分类
    if (self.seletedCategoryName) {
        params[@"category"] = self.seletedCategoryName;
        //NSLog(@"category%@",params[@"category"] );
    }
    // 排序
    if (self.seletedSort) {
        params[@"sort"] = @(self.seletedSort.value);
    }
    // 区域
    if (self.seletedDistrictName) {
        params[@"region"] = self.seletedDistrictName;
    }
}

#pragma mark - 设置导航栏内容
- (void)setupLeftNav
{
    // 1.logo
    UIBarButtonItem *logoItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_meituan_logo"] style:UIBarButtonItemStylePlain target:nil action:nil];
    logoItem.enabled = NO;
    
    // 2.类别
    MTHomeTopItem *categoryTopItem = [MTHomeTopItem item];
    [categoryTopItem addTarget:self action:@selector(categoryClick)];
    UIBarButtonItem *categoryItem = [[UIBarButtonItem alloc] initWithCustomView:categoryTopItem];
    self.categoryItem = categoryItem;
    
    // 3.地区
    MTHomeTopItem *districtTopItem = [MTHomeTopItem item];
    [districtTopItem addTarget:self action:@selector(districtClick)];
    UIBarButtonItem *districtItem = [[UIBarButtonItem alloc] initWithCustomView:districtTopItem];
    self.districtItem = districtItem;
    
    // 4.排序
    MTHomeTopItem *sortTopItem = [MTHomeTopItem item];
    [sortTopItem setTitle:@"排序"];
    [sortTopItem setIcon:@"icon_sort" highIcon:@"icon_sort_highlighted"];
    [sortTopItem addTarget:self action:@selector(sortClick)];
    UIBarButtonItem *sortItem = [[UIBarButtonItem alloc] initWithCustomView:sortTopItem];
    self.sortItem = sortItem;
    
    self.navigationItem.leftBarButtonItems = @[logoItem, categoryItem, districtItem, sortItem];
}

- (void)setupRightNav
{
    UIBarButtonItem *mapItem = [UIBarButtonItem itemWithTarget:self action:@selector(map) image:@"icon_map" highImage:@"icon_map_highlighted"];
    mapItem.customView.width = 60;
    UIBarButtonItem *searchItem = [UIBarButtonItem itemWithTarget:self action:@selector(search) image:@"icon_search" highImage:@"icon_search_highlighted"];
    searchItem.customView.width = 60;
    self.navigationItem.rightBarButtonItems = @[mapItem, searchItem];
}
#pragma mark - 顶部item点击实现

- (void)map
{
    MTNavigationController *nav = [[MTNavigationController alloc] initWithRootViewController:[[MTMapViewController alloc] init]];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)search
{
    if (self.seletedCityName) {
        MTSearchViewController *searchVC = [[MTSearchViewController alloc] init];
        searchVC.cityName = self.seletedCityName;
        MTNavigationController *nav = [[MTNavigationController alloc] initWithRootViewController:searchVC];
        [self presentViewController:nav animated:YES completion:nil];
    } else {
        [MBProgressHUD showError:@"请选择城市后在搜索" toView:self.view];
    }
    
    
}


- (void)categoryClick
{
    // 显示分类菜单
    self.categoryPopoVer = [[UIPopoverController alloc] initWithContentViewController:[[MTCategoryViewController alloc] init] ];
    [self.categoryPopoVer presentPopoverFromBarButtonItem:self.categoryItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}

- (void)districtClick
{
    MTDistrictController *district = [[MTDistrictController alloc] init];
    if (self.seletedCityName) {
    // 显示区域菜单
    MTCity *city = [[[MTMetaTool cities] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name = %@", self.seletedCityName]]firstObject];
        district.regions = city.regions;
    }
    
    self.districtPopoVer = [[UIPopoverController alloc] initWithContentViewController:district];
    [self.districtPopoVer presentPopoverFromBarButtonItem:self.districtItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    district.popover = self.districtPopoVer;
}

- (void)sortClick
{
    // 显示排序菜单
    self.sortPopoVer = [[UIPopoverController alloc] initWithContentViewController:[[MTSortController alloc] init] ];
    [self.sortPopoVer presentPopoverFromBarButtonItem:self.sortItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}



@end
