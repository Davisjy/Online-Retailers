//
//  MTCategory.h
//  美团HD
//
//  Created by qingyun on 15/12/1.
//  Copyright © 2015年 qingyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTCategory : NSObject

@property (nonatomic, strong) NSString *name;
//子类别，里面都是字符串(子类名称)
@property (nonatomic, strong) NSArray *subcategories;
//显示在下拉菜单中的小图标
@property (nonatomic, strong) NSString *small_highlighted_icon;
@property (nonatomic, strong) NSString *small_icon;

//导航栏顶部的大图标
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *highlighted_icon;

//地图上的图标
@property (nonatomic, strong) NSString *map_icon;

@end
