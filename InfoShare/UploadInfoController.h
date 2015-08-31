//
//  UploadInfoController.h
//  InfoShare
//
//  Created by xjw03 on 15/8/14.
//  Copyright (c) 2015年 xjw03. All rights reserved.
//
#import "CustomIOSAlertView.h"
#import <UIKit/UIKit.h>




@protocol imageDelegate <NSObject>
- (void)showImageViewWithImageViews:(NSArray *)imageViews byClickWhich:(NSInteger)clickTag;
@end


@interface UploadInfoController : UIViewController{
    //下拉菜单
    UIActionSheet *PicActionSheet;
}
@property (nonatomic,strong) CustomIOSAlertView* alertView;
@property (nonatomic,strong) UIView* baseView;
@property (nonatomic,strong) UILabel* tipView;
@property (nonatomic,strong) UIProgressView* progressView;
@property (nonatomic,strong) NSMutableArray *imageArray;
@property (nonatomic,strong) UIAlertView *LoadTip;
@property UINavigationController* nav;


- (UploadInfoController*) init;
@end
