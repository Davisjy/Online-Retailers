//
//  MTDealsViewController.m
//  美团HD
//
//  Created by qingyun on 15/12/4.
//  Copyright © 2015年 qingyun. All rights reserved.
//

#import "MTDealsViewController.h"
#import "MTDealCell.h"
#import "MJRefresh.h"
#import "DPAPI.h"
#import "UIView+AutoLayout.h"
#import "Common.h"
#import "MJExtension.h"
#import "MTDeal.h"
#import "UIView+Extension.h"
#import "MBProgressHUD+MJ.h"
#import "MTDetailViewController.h"

@interface MTDealsViewController ()<DPRequestDelegate>
// 所有的团购数据
@property (nonatomic, strong) NSMutableArray *deals;

@property (nonatomic, weak) UIImageView *noDataView;
// 记录当前的页码
@property (nonatomic, assign) int currentPage;
//请求数据的总数
@property (nonatomic, assign) int totalCount;
// 保存最后一个请求
@property (nonatomic, strong) DPRequest *lastRequest;
@end

@implementation MTDealsViewController

static NSString * const reuseIdentifier = @"deal";

- (NSMutableArray *)deals
{
    if (_deals == nil) {
        _deals = [NSMutableArray array];
    }
    return _deals;
}

- (UIImageView *)noDataView
{
    if (_noDataView == nil) {
        // 添加一个没有数据的提醒
        UIImageView *noDataView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_deals_empty"]];
        
        [self.view addSubview:noDataView];
        [noDataView autoCenterInSuperview];
        self.noDataView = noDataView;
    }
    return _noDataView;
}

- (instancetype)init
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    // cell的大小
    layout.itemSize = CGSizeMake(305, 305);
    // 设置上下左右的间距
    //CGFloat inset = 15;
    //    layout.sectionInset = UIEdgeInsetsMake(inset, inset, inset, inset);
    return [self initWithCollectionViewLayout:layout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置背景色
    self.collectionView.backgroundColor = MTGlobalBg;
    
    // Register cell classes
    [self.collectionView registerNib:[UINib nibWithNibName:@"MTDealCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    
    // 垂直方向上永远有弹簧效果
    self.collectionView.alwaysBounceVertical = YES;

    
    // 添加刷新控件
    [self.collectionView addFooterWithTarget:self action:@selector(loadMoreDeals)];
    [self.collectionView addHeaderWithTarget:self action:@selector(loadNewDeals)];
}

// 7.0的方法
//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
/**
 *  当屏幕旋转，控制器的尺寸发生改变
 *
 *  @param size        改变后的尺寸
 *  @param coordinator 旋转方向
 */
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    // 根据屏幕宽度决定列数
    int cols = (size.width == 1024) ? 3 : 2;
   
    // 流水布局
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    // 根据列数计算内间距
    CGFloat inset = (size.width - cols * layout.itemSize.width) / (cols + 1);
    layout.sectionInset = UIEdgeInsetsMake(inset, inset, inset, inset);
    
    // 设置每行之间的间距
    layout.minimumLineSpacing = inset;
}

#pragma mark - 跟服务器交互
- (void)loadDeals
{
    DPAPI *api = [[DPAPI alloc] init];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [self setupParams:params];
    
    // 每页的条数
    params[@"limit"] = @30;
    
    // 页码
    params[@"page"] = @(self.currentPage);
    // 保存最后一次请求
    self.lastRequest = [api requestWithURL:@"v1/deal/find_deals" params:params delegate:self];
}

- (void)loadMoreDeals
{
    self.currentPage++;
    
    [self loadDeals];
}

- (void)loadNewDeals
{
    self.currentPage = 1;
    
    [self loadDeals];
}

- (void)request:(DPRequest *)request didFinishLoadingWithResult:(id)result
{
    if (request != self.lastRequest) {
        return;
    }
    
    self.totalCount = [result[@"total_count"] intValue];
    
    // 1.取出团购的字典数组
    NSArray *deals = [MTDeal objectArrayWithKeyValuesArray:result[@"deals"]];
    if (self.currentPage == 1) { // 加载第一次数据，清楚之前的旧数据
        [self.deals removeAllObjects];
    }
    
    [self.deals addObjectsFromArray:deals];
    
    // 2.刷新表格
    [self.collectionView reloadData];
    
    // 3. 结束上拉加载
    [self.collectionView footerEndRefreshing];
    [self.collectionView headerEndRefreshing];
}

- (void)request:(DPRequest *)request didFailWithError:(NSError *)error
{
    if (request != self.lastRequest) {
        return;
    }
    
    // 1. 提醒失败  如果toView不传值会添加到window上
    [MBProgressHUD showError:@"网络繁忙,请稍后再试" toView:self.view];
    
    NSLog(@"error %@",error);
    
    // 2. 结束刷新
    [self.collectionView footerEndRefreshing];
    [self.collectionView headerEndRefreshing];
    
    // 3. 如果上拉加载失败了
    if (self.currentPage > 1) {
        self.currentPage --;
    }
}



#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    // 1. 计算一遍内边距
    [self viewWillTransitionToSize:CGSizeMake(collectionView.width, 0) withTransitionCoordinator:nil];
    
    // 2. 控制没有数据提醒
    self.noDataView.hidden = self.deals.count != 0;
    
    // 3. 控制尾部刷新控件的显示和隐藏
    self.collectionView.footerHidden = self.totalCount == self.deals.count;
    
    return self.deals.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MTDealCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    cell.deal = self.deals[indexPath.item];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MTDetailViewController *detailVC = [[MTDetailViewController alloc] init];
    detailVC.deal = self.deals[indexPath.item];
    [self presentViewController:detailVC animated:YES completion:nil];
}

@end
