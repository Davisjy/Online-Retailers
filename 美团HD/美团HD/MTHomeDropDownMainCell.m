//
//  MTHomeDropDownMainCell.m
//  美团HD
//
//  Created by qingyun on 15/12/1.
//  Copyright © 2015年 qingyun. All rights reserved.
//

#import "MTHomeDropDownMainCell.h"

@implementation MTHomeDropDownMainCell

+ (instancetype)cellWithTabelView:(UITableView *)tableView
{
    static NSString *mainID = @"sub";
    MTHomeDropDownMainCell *cell = [tableView dequeueReusableCellWithIdentifier:mainID];
    if (cell == nil) {
        cell = [[MTHomeDropDownMainCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:mainID];
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UIImageView *bg = [[UIImageView alloc] init];
        bg.image = [UIImage imageNamed:@"bg_dropdown_leftpart"];
        self.backgroundView = bg;
        
        UIImageView *selectBg = [[UIImageView alloc] init];
        selectBg.image = [UIImage imageNamed:@"bg_dropdown_left_selected"];
        self.selectedBackgroundView = selectBg;
    }
    return self;
}

@end
