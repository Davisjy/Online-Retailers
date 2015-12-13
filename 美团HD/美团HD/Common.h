//
//  Common.h
//  美团HD
//
//  Created by qingyun on 15/12/1.
//  Copyright © 2015年 qingyun. All rights reserved.
//

#ifndef Common_h
#define Common_h

#ifdef DEBUG
#define MTLog(...) NSLog(__VA_ARGS__)
#else
#define MTLog(...)
#endif

#define MTColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define MTGlobalBg MTColor(230, 230, 230)

#define MTNotificationCenter    [NSNotificationCenter defaultCenter]

#define MTCityDidSelectNotification     @"CityDidSelectNotification"
#define MTSelectedCityName              @"SelectedCityName"

#define MTSortNotification              @"MTSortNotification"
#define MTSortModel                     @"MTSortModel"

#define MTCategoryDidChangeNotification @"CategoryDidChangeNotification"
#define MTSelectCategory                @"SelectCategory"
#define MTSelectSubCategoryName         @"SelectSubCategoryName"

#define MTDistrictDidChangeNotification @"DistrictDidChangeNotification"
#define MTSelectDistrict                @"SelectDistrict"
#define MTSelectSubDistrictName         @"SelectSubDistrictName"

#define MTCollectStateDidChangeNotification  @"CollectStateDidChangeNotification"
#define MTIscollectKey                       @"IscollectKey"
#define MTCollectDealKey                     @"CollectDealKey"

#endif /* Common_h */
