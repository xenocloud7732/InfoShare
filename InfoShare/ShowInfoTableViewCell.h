//
//  ShowInfoTableViewCell.h
//  InfoShare
//
//  Created by xjw03 on 15/8/14.
//  Copyright (c) 2015年 xjw03. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Info.h"

@interface ShowInfoTableViewCell : UITableViewCell
#pragma mark 微博对象
@property (nonatomic,strong) Info* info;

#pragma mark 单元格高度
@property (assign,nonatomic) CGFloat height;

@end
