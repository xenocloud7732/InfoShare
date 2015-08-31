//
//  SITableViewCell.h
//  InfoShare
//
//  Created by xjw03 on 15/8/18.
//  Copyright (c) 2015年 xjw03. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Info.h"

@interface SITableViewCell : UITableViewCell

//用户信息
@property (nonatomic,strong) UIImageView *userHeaderImage;
@property (nonatomic,strong) UILabel* userNameLbl;
//帖子内容
@property (nonatomic,strong) UITextView* commentTextView;
//帖子附图
@property (nonatomic,strong) UICollectionView* previewCollView;
@property (nonatomic,strong) NSMutableArray* previewArray;
@property (nonatomic,strong) NSMutableArray* srcArray;
//发帖时间
@property (nonatomic,strong) UILabel* TimeLbl;

-(void) setInfo:(Info*)info;

+(CGFloat) CalCellHeigh:(Info*)info;
@end
