//
//  MTCitySearchResultController.m
//  美团HD
//
//  Created by qingyun on 15/12/2.
//  Copyright © 2015年 qingyun. All rights reserved.
//

#import "MTCitySearchResultController.h"
#import "Common.h"
#import "MTCity.h"
#import "MTMetaTool.h"

@interface MTCitySearchResultController ()
@property (nonatomic, strong) NSArray *resultCities;
@end

@implementation MTCitySearchResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)setSearchText:(NSString *)searchText
{
    _searchText = searchText;
    searchText = searchText.lowercaseString;
    
//    self.resultCities = [NSMutableArray array];
//    //根据关键字搜索想要的数据
//    for (MTCity *city in self.cities) {
//        if ([city.name containsString:searchText] || [city.pinYin.uppercaseString containsString:searchText] || [city.pinYinHead.uppercaseString containsString:searchText]) {
//            [self.resultCities addObject:city];
//        }
//    }
    
    // 谓词
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains %@ or pinYin contains %@ or pinYinHead contains %@", searchText, searchText, searchText];
    self.resultCities = [[MTMetaTool cities] filteredArrayUsingPredicate:predicate];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.resultCities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"result";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    MTCity *city = self.resultCities[indexPath.row];
    cell.textLabel.text = city.name;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"共有%d个搜索结果", self.resultCities.count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MTCity *city = self.resultCities[indexPath.row];
    // 发出通知
    [MTNotificationCenter postNotificationName:MTCityDidSelectNotification object:nil userInfo:@{MTSelectedCityName : city.name}];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
