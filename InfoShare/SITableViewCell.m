//
//  SITableViewCell.m
//  InfoShare
//
//  Created by xjw03 on 15/8/18.
//  Copyright (c) 2015年 xjw03. All rights reserved.
//

#import "SITableViewCell.h"
#import "SIShowImageView.h"
#import "SICollectionViewCell.h"
#import "Tools.h"
#import "InfoManager.h"
#import "UIImageView+WebCache.h"

const int vertical_gap              = 20;
const int herizon_gap               = 20;

const int userImage_left            = 20;
const int userImage_top             = 5;
const int userImage_width           = 50;
const int userImage_high            = 50;

const int userImage_Border_Red      = 63;
const int userImage_Border_Green    = 107;
const int userImage_Border_Blue     = 252;
const int userImage_Border_Max      = 255;

const int userLabel_Red             = 104;
const int userLabel_Green           = 109;
const int userLabel_Blue            = 248;

const int userLabel_width           = 50;
const int userLabel_high            = 30;

const int commentTV_left            = 30;
const int commentTV_width           = 200;
const int commentTV_high            = 50;

const int previweCV_left            = 10;
const int previweCV_width           = 300;
const int previweCV_high            = 200;

const int LineSpacing               = 3;
const int ItemInteritemSpacing      = 3;

const int timeLabel_left            = 20;
const int timeLabel_width           = 100;
const int timeLabel_high            = 20;

@interface SITableViewCell ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@end

@implementation SITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        #pragma mark - aera 1
        //userHeaderImage
        self.userHeaderImage = [[UIImageView alloc] initWithFrame:CGRectMake(
                userImage_left, userImage_top, userImage_width, userImage_high)];
        self.userHeaderImage.backgroundColor = [UIColor clearColor];
        CALayer* layer = [self.userHeaderImage layer];
        [layer setMasksToBounds:YES];
        [layer setCornerRadius:10.0];
        [layer setBorderWidth:1];
        [layer setBorderColor:[[UIColor colorWithRed:userImage_Border_Red/userImage_Border_Max
                                               green:userImage_Border_Green/userImage_Border_Max
                                                blue:userImage_Border_Blue/userImage_Border_Max
                                               alpha:1.0] CGColor]];
        [self.contentView addSubview:self.userHeaderImage];
        
        //userName
        self.userNameLbl = [[UILabel alloc] initWithFrame:CGRectMake(userImage_left + userImage_width + herizon_gap,
                                                                     userImage_top,userLabel_width,userLabel_high)];
        self.userNameLbl.textAlignment = NSTextAlignmentLeft;
        self.userNameLbl.font = [UIFont systemFontOfSize:15.0];
        self.userNameLbl.textColor = [UIColor colorWithRed:userLabel_Red/userImage_Border_Max
                                                     green:userLabel_Green/userImage_Border_Max
                                                      blue:userLabel_Blue/userImage_Border_Max
                                                     alpha:1.0];
        [self.contentView addSubview:self.userNameLbl];
        
        #pragma mark - aera 2
        //commentTextView
        self.commentTextView = [[UITextView alloc] initWithFrame:CGRectMake(commentTV_left,
                                                                            userImage_top + userImage_high,
                                                                            commentTV_width, commentTV_high)];
        self.commentTextView.textColor = [UIColor grayColor];
        self.commentTextView.backgroundColor = [UIColor clearColor];
        self.commentTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.commentTextView.editable = NO;
        [self.contentView addSubview:self.commentTextView];
        

        #pragma mark - aera 3
        UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = LineSpacing;
        layout.minimumInteritemSpacing = ItemInteritemSpacing;
        self.previewCollView = [[UICollectionView alloc] initWithFrame:CGRectMake(previweCV_left,
                                                                                  userImage_top + userImage_high + vertical_gap +
                                                                                  commentTV_high + vertical_gap,
                                                                                  previweCV_width, previweCV_high)
                                                  collectionViewLayout:layout];
        [self.previewCollView registerClass:[SICollectionViewCell class]
                forCellWithReuseIdentifier:@"MyCell"];
        self.previewCollView.backgroundColor = [UIColor clearColor];
        self.previewCollView.delegate = self;
        self.previewCollView.dataSource = self;
        [self.contentView addSubview:self.previewCollView];
        self.previewArray = [NSMutableArray new];
        self.srcArray = [NSMutableArray new];
        
        #pragma mark - aera 4
        self.TimeLbl = [[UILabel alloc] initWithFrame:CGRectMake(timeLabel_left,
                                                                 userImage_top + userImage_high + vertical_gap +
                                                                 commentTV_high + vertical_gap + previweCV_high ,
                                                                 timeLabel_width,timeLabel_high)];
        self.TimeLbl.textAlignment = NSTextAlignmentLeft;
        self.TimeLbl.font = [UIFont systemFontOfSize:12.0];
        self.TimeLbl.textColor = [UIColor grayColor];
        [self.contentView addSubview:self.TimeLbl];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(int) getPreviweCvHigh:(Info*)info{
    int ImgCount = [info getImgCount];
    switch (ImgCount) {
        case 0:
        {
            return 0;
            break;
        }
        case 1:
        {
            return previweCV_high;
            break;
        }
        default:
        {
            int rowHigh = previweCV_high / 3;
            int rowCount = (int)ceil(ImgCount / 3.0f);
            return rowCount * rowHigh;
            break;
        }
    }
}

-(void) setInfo:(Info*)info{
    CGRect rtPreCV;
    CGRect rtTimeLbl;
/*    if ([info getImgCount] == 0) {
        rtPreCV = CGRectMake (0, 0, 0, 0);
        rtTimeLbl = CGRectMake(timeLabel_left,
                               userImage_top + userImage_high + vertical_gap +
                               commentTV_high ,
                               timeLabel_width,timeLabel_high);
    }
    else{*/
        rtPreCV = CGRectMake(previweCV_left,
                             userImage_top + userImage_high + vertical_gap +
                             commentTV_high + vertical_gap,
                             previweCV_width, [SITableViewCell getPreviweCvHigh:info]);
        rtTimeLbl = CGRectMake(timeLabel_left,
                               userImage_top + userImage_high + vertical_gap +
                               commentTV_high + vertical_gap + [SITableViewCell getPreviweCvHigh:info] ,
                               timeLabel_width,timeLabel_high);
    //}
    self.previewCollView.frame = rtPreCV;
    self.TimeLbl.frame = rtTimeLbl;
        
    NSURL* urlImg = [NSURL URLWithString:info.authorPic];
    [self.userHeaderImage sd_setImageWithURL:urlImg placeholderImage:[Tools GetLoadingImg] options:SDWebImageCacheMemoryOnly];
    self.userNameLbl.text = info.author;
    self.commentTextView.text = info.comment;
    [self.previewArray removeAllObjects];
    [self.previewArray addObjectsFromArray:[info.imgPvurl componentsSeparatedByString:@";"]];
    //delete @""
    [self.previewArray removeLastObject];
    
    [self.srcArray removeAllObjects];
    [self.srcArray addObjectsFromArray:[info.imgurl componentsSeparatedByString:@";"]];
    //delete @""
    [self.srcArray removeLastObject];
    [self.previewCollView reloadData];

    //time
    NSDate*	now = [NSDate date];
    NSDate* sendTime = [NSDate dateWithTimeIntervalSince1970:info.dateline];
    NSTimeInterval between = [now timeIntervalSinceDate:sendTime];
    int day = 0;
    int hour = 0;
    int min = 0;
    int sec = 0;
    [Tools TransTimeInterval:between andDay:&day andHour:&hour
                      andMin:&min andSec:&sec];
    NSString* timeTip = nil;
    if (day > 0)
        timeTip = [[NSString alloc] initWithFormat:@"%d天前", day];
    else if(hour > 0)
        timeTip = [[NSString alloc] initWithFormat:@"%d小时前", hour];
    else if (min > 0)
        timeTip = [[NSString alloc] initWithFormat:@"%d分钟前", min];
    else
        timeTip = [[NSString alloc] initWithFormat:@"刚刚"];
    self.TimeLbl.text = timeTip;
    
    
}

+(CGFloat) CalCellHeigh:(Info*)info{
    int total_high = userImage_top + userImage_high + vertical_gap + commentTV_high
    + timeLabel_high + [self getPreviweCvHigh:info] + vertical_gap;
    return total_high;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.previewArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:
                                  @"MyCell" forIndexPath:indexPath];
    
     NSString* strImg = self.previewArray[indexPath.row];
     NSURL* urlImg = [NSURL URLWithString:strImg];
     UIImageView *imageView = [UIImageView new];
     [imageView sd_setImageWithURL:urlImg placeholderImage:[Tools GetLoadingImg]];
     [cell setBackgroundView:imageView];
     return  cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = collectionView.frame.size.width;
    CGFloat high  = collectionView.frame.size.height;
    if (self.previewArray.count == 1)
        return  CGSizeMake(width, high);
    else{
        int rowCount = (int)ceil(self.previewArray.count / 3.0f);
        return  CGSizeMake(width / 3 - ItemInteritemSpacing, high / rowCount - LineSpacing);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UIView *maskview = [[UIView alloc] initWithFrame:[ UIScreen mainScreen ].applicationFrame];
    maskview.backgroundColor = [UIColor blackColor];
    UIView *showview = self.superview.superview.superview;
    //通过向上求索目前显示的界面
    [showview addSubview:maskview];
    
    SIShowImageView *SIImageView = [[SIShowImageView alloc] initWithFrame:[ UIScreen mainScreen ].applicationFrame
                                                                  byClick: indexPath.row
                                                                imgUrlArray: self.srcArray];
    [SIImageView show:maskview doFinish:^(void){
        
        [UIView animateWithDuration:0.5f animations:^{
            
            SIImageView.alpha = 0.0f;
            maskview.alpha = 0.0f;
            
        } completion:^(BOOL finished) {
            [SIImageView removeFromSuperview];
            [maskview removeFromSuperview];
        }];
        
    }];
}

@end
