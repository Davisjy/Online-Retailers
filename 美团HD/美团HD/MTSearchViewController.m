//
//  MTSearchViewController.m
//  美团HD
//
//  Created by qingyun on 15/12/4.
//  Copyright © 2015年 qingyun. All rights reserved.
//

#import "MTSearchViewController.h"
#import "UIBarButtonItem+Extension.h"
#import "UIView+Extension.h"
#import "UIView+AutoLayout.h"
#import "Common.h"
#import "MJRefresh.h"

@interface MTSearchViewController ()<UISearchBarDelegate>
// 搜索栏
@property (nonatomic, strong) UISearchBar *searchBar;
@end

@implementation MTSearchViewController

static NSString * const reuseIdentifier = @"Cell";

- (instancetype)init
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(305, 305);
    return [self initWithCollectionViewLayout:layout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1. 设置导航栏内容
    [self setupNav];
    
    self.collectionView.backgroundColor = MTGlobalBg;
    
}


- (void)setupNav
{
    // 左边的返回
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(back) image:@"icon_back" highImage:@"icon_back_highlighted"];
    
    // 中间的搜索
    UIView *titleView = [[UIView alloc] init];
    titleView.height = 30;
    titleView.width = 400;
    self.navigationItem.titleView = titleView;
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.placeholder = @"请输入关键字";
    searchBar.backgroundImage = [UIImage imageNamed:@"bg_login_textfield"];
    [titleView addSubview:searchBar];
    searchBar.delegate = self;
    searchBar.tintColor = MTColor(32, 191, 179);
    [searchBar setShowsCancelButton:YES animated:YES];
    [searchBar autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    self.searchBar = searchBar;
}

- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 搜索框代理
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // 发送请求(调用下拉刷新状态)
    [self.collectionView headerBeginRefreshing];
    
    // 退出键盘
    [searchBar resignFirstResponder];
}

#pragma mark - 实现父类拼接参数
- (void)setupParams:(NSMutableDictionary *)params
{
    params[@"city"] = @"北京";
    params[@"keyword"] = self.searchBar.text;
}

@end
