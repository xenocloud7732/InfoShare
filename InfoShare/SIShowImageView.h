//
//  SIShowImageView.h
//  InfoShare
//
//  Created by xjw03 on 15/8/17.
//  Copyright (c) 2015年 xjw03. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^doRemoveImage)(void);

@interface SIShowImageView : UIView<UIScrollViewDelegate>
{
    UIImageView *showImage;
}
@property (nonatomic,copy) doRemoveImage removeFunc;

- (void)show:(UIView*) baseView doFinish:(doRemoveImage)tmpBlock;

- (id)initWithFrame:(CGRect)frame byClick:(NSInteger) clickTag infoArray:(NSArray*) infoArray;

- (id)initWithFrame:(CGRect)frame byClick:(NSInteger) clickTag imgUrlArray:(NSArray*) imgUrlArray;
@end
