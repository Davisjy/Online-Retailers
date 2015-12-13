//
//  MTCollectViewController.m
//  美团HD
//
//  Created by qingyun on 15/12/4.
//  Copyright © 2015年 qingyun. All rights reserved.
//

#import "MTCollectViewController.h"
#import "Common.h"
#import "UIBarButtonItem+Extension.h"
#import "MTDealTool.h"
#import "MTDealCell.h"
#import "UIView+Extension.h"
#import "UIView+AutoLayout.h"
#import "MTDetailViewController.h"
#import "MJRefresh.h"
#import "MTDeal.h"

#define MTString(str)    [NSString stringWithFormat:@"  %@  ", str]

@interface MTCollectViewController ()<MTDealCellDelegate>
@property (nonatomic, weak) UIImageView *noDataView;
@property (nonatomic, strong) NSMutableArray *deals;
@property (nonatomic, assign) int currentPage;
@property (nonatomic, strong) UIBarButtonItem *backItem;
@property (nonatomic, strong) UIBarButtonItem *selectAllItem;
@property (nonatomic, strong) UIBarButtonItem *unSelelctAllItem;
@property (nonatomic, strong) UIBarButtonItem *removeItem;
@end

@implementation MTCollectViewController

static NSString * const reuseIdentifier = @"deal";

- (UIBarButtonItem *)backItem
{
    if (_backItem == nil) {
        _backItem = [UIBarButtonItem itemWithTarget:self action:@selector(back) image:@"icon_back" highImage:@"icon_back_highlighted"];
    }
    return _backItem;
}

- (UIBarButtonItem *)selectAllItem
{
    if (_selectAllItem == nil) {
        _selectAllItem = [[UIBarButtonItem alloc] initWithTitle:MTString(@"全选") style:UIBarButtonItemStyleDone target:self action:@selector(selectAll)];
    }
    return _selectAllItem;
}

- (UIBarButtonItem *)unSelelctAllItem
{
    if (_unSelelctAllItem == nil) {
        _unSelelctAllItem = [[UIBarButtonItem alloc] initWithTitle:MTString(@"全不选") style:UIBarButtonItemStyleDone target:self action:@selector(unselectAll)];
    }
    return _unSelelctAllItem;
}

- (UIBarButtonItem *)removeItem
{
    if (_removeItem == nil) {
        _removeItem = [[UIBarButtonItem alloc] initWithTitle:MTString(@"删除") style:UIBarButtonItemStyleDone target:self action:@selector(remove)];
        self.removeItem.enabled = NO;
    }
    return _removeItem;
}

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
        UIImageView *noDataView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_collects_empty"]];
        
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
    
    self.title = @"收藏的团购";
    self.collectionView.backgroundColor = MTGlobalBg;
    
    // Register cell classes
    [self.collectionView registerNib:[UINib nibWithNibName:@"MTDealCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    
    self.collectionView.alwaysBounceVertical = YES;
    
    // 左边的返回
    self.navigationItem.leftBarButtonItems = @[self.backItem];
    
    // 加载第一页的数据
    [self loadMoreDeals];
    
    // 监听收藏状态改变的通知
    [MTNotificationCenter addObserver:self selector:@selector(collectStateChange:) name:MTCollectStateDidChangeNotification object:nil];
    
    // 添加上拉加载更多
    [self.collectionView addFooterWithTarget:self action:@selector(loadMoreDeals)];
    
    // 设置导航栏内容
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStyleDone target:self action:@selector(edit:)];
}

- (void)edit:(UIBarButtonItem *)item
{
    if ([item.title isEqualToString:@"编辑"]) {
        item.title = @"完成";
        self.navigationItem.leftBarButtonItems = @[self.backItem, self.selectAllItem, self.unSelelctAllItem, self.removeItem];
        
        // 进入编辑状态
        for (MTDeal *deal in self.deals) {
            deal.editing = YES;
        }
    } else {
        item.title = @"编辑";
        
        self.navigationItem.leftBarButtonItems = @[self.backItem];
        
        // 结束编辑状态
        for (MTDeal *deal in self.deals) {
            deal.editing = NO;
        }
    }
    // 刷新表格
    [self.collectionView reloadData];
}

- (void)selectAll
{
    for (MTDeal *deal in self.deals) {
        deal.checking = YES;
    }
    [self.collectionView reloadData];
    self.removeItem.enabled = YES;
}

- (void)unselectAll
{
    for (MTDeal *deal in self.deals) {
        deal.checking = NO;
    }
    [self.collectionView reloadData];
    self.removeItem.enabled = NO;
}

- (void)remove
{
    NSMutableArray *tempArr = [NSMutableArray array];
    for (MTDeal *deal in self.deals) {
        if (deal.isChecking) {
            [MTDealTool removeCollectDeal:deal];
            
            [tempArr addObject:deal];
        }
    }
    // 删除所有打钩的模型（在内存中）
    [self.deals removeObjectsInArray:tempArr];
    [self.collectionView reloadData];
    self.removeItem.enabled = NO;
}

- (void)loadMoreDeals
{
    // 1.增加页码
    self.currentPage ++;
    
    // 2.增加数据
    [self.deals addObjectsFromArray:[MTDealTool collectDeals:self.currentPage]];
    
    // 3.刷新表格
    [self.collectionView reloadData];
    
    // 4.结束刷新
    [self.collectionView footerEndRefreshing];
}

- (void)collectStateChange:(NSNotification *)notification
{
//    if ([notification.userInfo[MTIscollectKey] boolValue]) {
//        // 收藏成功
//        [self.deals insertObject:notification.userInfo[MTCollectDealKey] atIndex:0];
//    } else {
//        // 取消收藏成功
//        [self.deals removeObject:notification.userInfo[MTCollectDealKey]];
//    }
//    [self.collectionView reloadData];
    
    [self.deals removeAllObjects];
    self.currentPage = 0;
    [self loadMoreDeals];
}

- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

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

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    // 1. 计算一遍内边距
    [self viewWillTransitionToSize:CGSizeMake(collectionView.width, 0) withTransitionCoordinator:nil];
    
    // 控制尾部刷新控件的显示与隐藏
    self.collectionView.footerHidden = self.deals.count == [MTDealTool collectDealsCount];
    
    // 2. 控制没有数据提醒
    self.noDataView.hidden = self.deals.count != 0;
    
    return self.deals.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MTDealCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    cell.delegate = self;
    cell.deal = self.deals[indexPath.item];
    
    return cell;
}

#pragma mark - MTDealCellDelegate
- (void)dealCellCheckingStateDidChange:(MTDealCell *)cell
{
    BOOL hasChecking = NO;
    for (MTDeal *deal in self.deals) {
        if (deal.isChecking) {
            hasChecking = YES;
            break;
        }
    }
    // 根据有没有打钩的情况，决定删除按钮的是否可用
    self.removeItem.enabled = hasChecking;
}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MTDetailViewController *detailVC = [[MTDetailViewController alloc] init];
    detailVC.deal = self.deals[indexPath.item];
    [self presentViewController:detailVC animated:YES completion:nil];
}
@end
