//
//  SIShowImageView.m
//  InfoShare
//
//  Created by xjw03 on 15/8/17.
//  Copyright (c) 2015年 xjw03. All rights reserved.
//

#import "SIShowImageView.h"
#import "Tools.h"
#import "UIImageView+WebCache.h"
#import "Tools.h"

@implementation SIShowImageView{
    UIScrollView* scrollView;
    CGRect selfFrame;
    NSInteger page;
    BOOL doubleClick;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)fillInitParam :(CGRect)frame{
    selfFrame = frame;
    self.backgroundColor = [UIColor blackColor];
    self.alpha = 0;
    page = 0;
    doubleClick = YES;
    
    UITapGestureRecognizer *tapGser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disappear)];
    tapGser.numberOfTouchesRequired = 1;
    tapGser.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapGser];
    
    UITapGestureRecognizer *doubleTapGser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeBig:)];
    doubleTapGser.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTapGser];
    [tapGser requireGestureRecognizerToFail:doubleTapGser];
}

- (id)initWithFrame:(CGRect)frame byClick:(NSInteger) clickTag imgUrlArray:(NSArray*) imgUrlArray{
    self = [super initWithFrame:frame];
    if (self) {
        [self fillInitParam:frame];
        [self configScrollViewWith:clickTag andimgUrlArray:imgUrlArray];
    }
    return self;
}

-(id) initWithFrame:(CGRect)frame byClick:(NSInteger)clickTag infoArray:(NSArray *)infoArray{
    self = [super initWithFrame:frame];
    if (self) {
        [self fillInitParam:frame];
        [self configScrollViewWith:clickTag andInfoArray:infoArray];
    }
    return self;
}

-(void)configScrollViewWith:(NSInteger)clickTag andimgArray:(NSArray*)imgArray{
    scrollView = [[UIScrollView alloc] initWithFrame:selfFrame];
    scrollView.backgroundColor = [UIColor blackColor];
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.contentSize = CGSizeMake(self.frame.size.width * imgArray.count, 0);
    [self addSubview:scrollView];
    
    int nIndex = 0;
    for (id img in imgArray) {
        UIScrollView* imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.frame.size.width * nIndex,
                                                                                       0,
                                                                                       self.frame.size.width,
                                                                                       self.frame.size.height)];
        imageScrollView.backgroundColor = [UIColor blackColor];
        imageScrollView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
        imageScrollView.delegate = self;
        imageScrollView.maximumZoomScale = 4;
        imageScrollView.minimumZoomScale = 1;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        //判断是否为NSStirng,如果是便是URL。反之就是img（来源于相册所以不用缓存）
        if ([img isKindOfClass:[NSString class]]){
            NSURL* urlImg = [NSURL URLWithString:img];
            [imageView sd_setImageWithURL:urlImg placeholderImage:[Tools GetLoadingImg]];
        }
        else{
            imageView = [[UIImageView alloc] initWithFrame:self.bounds];
            imageView.image = img;
            imageView.contentMode = UIViewContentModeScaleToFill;
        }
        [imageScrollView addSubview:imageView];
        imageView.tag = nIndex;
        [scrollView addSubview:imageScrollView];
        imageScrollView.tag = nIndex + 100;
        nIndex++;
    }
    [scrollView setContentOffset:CGPointMake(self.frame.size.width * clickTag, 0) animated:YES];
    page = clickTag;
}

-(void)configScrollViewWith:(NSInteger)clickTag andInfoArray:(NSArray*)infoArray{
    NSMutableArray* imgArray = [NSMutableArray new];
    for (id info in infoArray) {
        if ([info isKindOfClass:[UIImage class]]) {
            [imgArray addObject:info];
        }
        else
            [imgArray addObject:[Tools fullResolutionImageFromALAsset:info]];
    }
    [self configScrollViewWith:clickTag andimgArray:imgArray];
}

-(void)configScrollViewWith:(NSInteger)clickTag andimgUrlArray:(NSArray*)imgUrlArray{
    /*NSMutableArray* imgArray = [NSMutableArray new];
    for (id imgUrl in imgUrlArray) {
        UIImage * img = [Tools fullResolutionImageFromUrl:imgUrl];
        if (nil != img) {
            [imgArray addObject:img];
        }
        else
            [imgArray addObject:[NSNull null]];
    }*/
    [self configScrollViewWith:clickTag andimgArray:imgUrlArray];
}


- (void)disappear{
    self.removeFunc();
}

- (void)changeBig:(UITapGestureRecognizer *)tapGes{
    
    CGFloat newscale = 1.9;
    UIScrollView *currentScrollView = (UIScrollView *)[self viewWithTag:page + 100];
    CGRect zoomRect = [self zoomRectForScale:newscale withCenter:[tapGes locationInView:tapGes.view] andScrollView:currentScrollView];
    
    if (doubleClick == YES)  {
        [currentScrollView zoomToRect:zoomRect animated:YES];
        
    }else {
        [currentScrollView zoomToRect:currentScrollView.frame animated:YES];
    }
    doubleClick = !doubleClick;
}


- (CGRect)zoomRectForScale:(CGFloat)newscale withCenter:(CGPoint)center andScrollView:(UIScrollView *)scrollV{
    
    CGRect zoomRect = CGRectZero;
    
    zoomRect.size.height = scrollV.frame.size.height / newscale;
    zoomRect.size.width = scrollV.frame.size.width  / newscale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    // NSLog(@" === %f",zoomRect.origin.x);
    return zoomRect;
    
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)ScrollView{
    
    UIImageView *imageView = (UIImageView *)[self viewWithTag:ScrollView.tag - 100];
    return imageView;
    
}


- (void)show:(UIView *)baseView doFinish:(doRemoveImage)tempBlock{
    
    [baseView addSubview:self];
    
    self.removeFunc = tempBlock;
    
    [UIView animateWithDuration:.4f animations:^(){
        
        self.alpha = 1.0f;
        
    } completion:^(BOOL finished) {
        
    }];
}


@end
