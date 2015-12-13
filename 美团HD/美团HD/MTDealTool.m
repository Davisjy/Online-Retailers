//
//  MTDealTool.m
//  美团HD
//
//  Created by qingyun on 15/12/6.
//  Copyright © 2015年 qingyun. All rights reserved.
//

#import "MTDealTool.h"
#import "FMDB.h"
#import "MTDeal.h"

@implementation MTDealTool

static FMDatabase *_db;

+ (void)initialize
{
    // 1.打开数据库
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"deal.sqlite"];
    _db = [FMDatabase databaseWithPath:filePath];
    if (![_db open]) {
        return;
    }
    
    // 2.创表
    [_db executeUpdateWithFormat:@"create table IF NOT EXISTS t_collect_deal(id integer PRIMARY KEY, deal blob NOT NULL, deal_id text NOT NULL);"];
    [_db executeUpdateWithFormat:@"create table IF NOT EXISTS t_recent_deal(id integer PRIMARY KEY, deal blob NOT NULL, deal_id text NOT NULL);"];
}
// LIMIT %d,%d从第几条数据取多少条数据
+ (NSArray *)collectDeals:(int)page
{
    int size = 10;
    int pos = (page - 1) * size;
    
    FMResultSet *set = [_db executeQueryWithFormat:@"SELECT * FROM t_collect_deal ORDER BY id DESC LIMIT %d,%d;", pos, size];
    NSMutableArray *deals = [NSMutableArray array];
    while ([set next]) {
        MTDeal *deal = [NSKeyedUnarchiver unarchiveObjectWithData:[set objectForColumnName:@"deal"]];
        [deals addObject:deal];
    }
    return deals;
}

+ (void)addCollectDeal:(MTDeal *)deal
{
    NSData *date = [NSKeyedArchiver archivedDataWithRootObject:deal];
    [_db executeUpdateWithFormat:@"insert into t_collect_deal(deal, deal_id) values(%@, %@);",date, deal.deal_id];
}

+ (void)removeCollectDeal:(MTDeal *)deal
{
    [_db executeUpdateWithFormat:@"delete from t_collect_deal where deal_id = %@;", deal.deal_id];
}

+ (BOOL)isCollected:(MTDeal *)deal
{
    FMResultSet *set = [_db executeQueryWithFormat:@"select count(*) AS deal_count from t_collect_deal where deal_id = %@;", deal.deal_id];
    [set next];
    
    // 索引从1开始
    return [set intForColumn:@"deal_count"] == 1;
}

+ (int)collectDealsCount
{
    FMResultSet *set = [_db executeQueryWithFormat:@"select count(*) AS deal_count from t_collect_deal "];
    [set next];
    
    return [set intForColumn:@"deal_count"];
}

@end
