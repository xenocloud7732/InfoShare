//
//  UploadInfoController.m
//  InfoShare
//
//  Created by xjw03 on 15/8/14.
//  Copyright (c) 2015年 xjw03. All rights reserved.
//

#import "UploadInfoController.h"
#import "SITapGestureRecognizer.h"
#import "SIShowImageView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "CTAssetsPickerController/CTAssetsPickerController.h"
#import "UploadManager.h"
#import "Tools.h"


const int showImage_H           = 80;
const int showImage_W           = 80;
const int leftMargin            = 20;
const int topMargin             = 80;
const int verticalGap           = 20;
const int horizonGap            = 20;

const int titleLabelHigh        = 0;
const int titleLabelWidth       = 0;
const int titleEditHigh         = 0;
const int titleEditWidth        = 0;
NSString* c_titleLabel          = @"请输入标题";

const int commentLabelHigh      = 30;
const int commentLabelWidth     = 100;
const int commentEditHigh       = 50;
const int commentEditWidth      = 250;
NSString* c_commentLabel        = @"请输入内容";


NSString* c_Notify_finish       = @"数据传输完成";
NSString* c_Notify_fail         = @"数据传输失败";

@interface UploadInfoController ()<UIAlertViewDelegate,UIActionSheetDelegate,
UIImagePickerControllerDelegate,CTAssetsPickerControllerDelegate,NSURLSessionDataDelegate>
{
    UILabel* labTitle;
    UITextField* edtTitle;
    UILabel* labComment;
    UITextView* edtComment;
}
@end


@implementation UploadInfoController

-(void) layoutTitle{
    //Title
    CGRect rtLabTitle = CGRectMake(leftMargin, topMargin, titleLabelWidth, titleLabelHigh);
    labTitle =[[UILabel alloc] initWithFrame:rtLabTitle];
    labTitle.text = c_titleLabel;
    [self.view addSubview:labTitle];
    
    CGRect rtEdtTitle = rtLabTitle;
    rtEdtTitle.origin.x += (titleLabelWidth +  verticalGap);
    rtEdtTitle.size.width = titleEditWidth;
    edtTitle = [[UITextField alloc] initWithFrame:rtEdtTitle];
    edtTitle.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:edtTitle];
    [edtTitle addTarget:self action:@selector(GetTitle) forControlEvents:UIControlEventEditingDidEnd];
}

-(void) layoutComment{
    //Coment
    CGRect rtLabComment = CGRectMake(leftMargin + titleLabelWidth, topMargin,
                                     commentLabelWidth, commentLabelHigh);
    labComment = [[UILabel alloc] initWithFrame:rtLabComment];
    labComment.text = c_commentLabel;
    [self.view addSubview:labComment];
    
    CGRect rtEdtComment = rtLabComment;
    rtEdtComment.origin.x = leftMargin;
    rtEdtComment.origin.y += commentLabelHigh;
    rtEdtComment.size.width = commentEditWidth;
    rtEdtComment.size.height = commentEditHigh;
    edtComment = [[UITextView alloc] initWithFrame:rtEdtComment];
    edtComment.backgroundColor = [UIColor whiteColor];
    edtComment.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    edtComment.font = [UIFont fontWithName:@"Arial" size:18.0];
    [self.view addSubview:edtComment];
}

- (void) layoutImage{
    //在图片数组的最后将增加的图片添加上
    if ([Tools GetAddImg] != [self.imageArray lastObject]) {
        [self.imageArray addObject:[Tools GetAddImg]];
    }
    
    int screenWidth = [UIScreen mainScreen].bounds.size.width;
    for (int  nIndex = 0; nIndex < [self.imageArray count]; nIndex++) {
        //最多只显示9张图
        if (9 == nIndex) {
            break;
        }
        float left = (screenWidth - 240)/4*(nIndex%3 + 1) + 80*(nIndex%3);
        float top  = 10 * ((nIndex/3) + 1) + (nIndex/3) *  showImage_H + topMargin + commentEditHigh + verticalGap + commentLabelHigh;
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(left,top,showImage_W,showImage_H)];
        
        //CGRect rt = CGRectMake(left,top,showImage_H,showImage_H);
        image.userInteractionEnabled = YES;
        
        SITapGestureRecognizer* tap = [[SITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
        [image addGestureRecognizer:tap];
        tap.infoArray = self.imageArray;
        image.backgroundColor = [UIColor clearColor];
        image.tag =  nIndex;
        
        id item = self.imageArray[nIndex];
        if ([item isKindOfClass:[ALAsset class]]) {
                image.image = [Tools fullResolutionImageFromALAsset:item];
        }
        else if([item isKindOfClass:[UIImage class]]){
            image.image = item;
        }
        [self.view addSubview:image];
    }
}


-(void)openMenu
{
    //在这里呼出下方菜单按钮项
    PicActionSheet = [[UIActionSheet alloc]
                     initWithTitle:nil
                     delegate:self
                     cancelButtonTitle:@"取消"
                     destructiveButtonTitle:nil
                     otherButtonTitles: @"打开照相机", @"从手机相册获取",nil];
    
    [PicActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    //呼出的菜单按钮点击后的响应
    if (buttonIndex == PicActionSheet.cancelButtonIndex)
    {
        NSLog(@"取消");
    }
    switch (buttonIndex)
    {
        case 0:  //打开照相机拍照
            [Tools TakePhoto:self];
            break;
            
        case 1:  //打开本地相册
        {
            int nCount = MaxUploadCount - (int)self.imageArray.count + 1;
            [Tools LocalPhoto:self andMaxSelect: nCount];
            break;
        }
    }
}


- (UploadInfoController*) init{
    if (self = [super init]) {
        self.imageArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];

    //[self layoutTitle];
    [self layoutComment];
    [self layoutImage];
    
    //在子视图中（或者根视图）有一个navigationItem用于访问其导航信息
    self.navigationItem.title=@"编辑";//或者直接设置控制器title
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"发帖" style:UIBarButtonItemStyleDone target:self action:@selector(Post)];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(DataTransFinish) name:c_Notify_finish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(DataTransFail) name:c_Notify_fail object:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)GetTitle{
    
}


- (void)showProgressAlert:(NSString*)title withMessage:(NSString*)message {
    self.alertView = [[CustomIOSAlertView alloc]init];
    self.baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 100)];
    self.tipView = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, 200, 40)];
    self.tipView.textAlignment = NSTextAlignmentCenter;
    self.tipView.text = @"数据传输中请等待";
    [self.baseView addSubview:self.tipView];
    
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    self.progressView.frame = CGRectMake(10, 60, 280, 30);
    [self.baseView addSubview:self.progressView];
    
    [self.alertView setContainerView:self.baseView];
    [self.alertView setButtonTitles:NULL];
    [self.alertView show];
}

- (void)updateProgress:(NSNumber*)progress {
    self.progressView.progress = [progress floatValue];
}

- (void)dismissProgressAlert {
    if (self.progressView == nil) {
        return;
    }
    [self.alertView close];
    self.progressView = nil;
}


-(void)Post{
    if (edtComment.text.length < 8) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"评论不能少于8个字符" message:nil delegate:self
                                              cancelButtonTitle:@"知道了" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    [self.view endEditing:YES];
    UploadManager* manager = [UploadManager GetUploadManager];
    NSString* strSystime = [Tools GetSystemTime];
    [Tools md5:strSystime];
    NSString* strTitle = [Tools md5:strSystime];//edtTitle.text;
    NSString* strComment = edtComment.text;


    [self showProgressAlert:@"数据提交中" withMessage:@"请等待"];
    [self.imageArray removeObject:[Tools GetAddImg]];
    [manager UploadMul:self.imageArray withTitle:strTitle withComment:strComment
            withFinish:^(NSData *data, NSURLResponse *response, NSError *error) {
                [self performSelectorOnMainThread:@selector(dismissProgressAlert)
                                       withObject:nil
                                    waitUntilDone:YES];
                if (nil == error) {
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:c_Notify_finish object:Nil userInfo:@{}];
                }
                else{
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:c_Notify_fail object:Nil userInfo:@{}];
                }
    } AndDelegate:self];
}



-(void)DataTransFinish{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES]; });

}

-(void)DataTransFail{
    dispatch_sync(dispatch_get_main_queue(), ^{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"数据提交失败" message:nil delegate:self
                                          cancelButtonTitle:@"知道了" otherButtonTitles: nil];
            [alert show];
    });
}

#pragma mark - 点击action
- (void)tapImageView:(SITapGestureRecognizer *)tapGes{
    if (tapGes.view.tag == tapGes.infoArray.count - 1) {
        [self openMenu];
    }
    else{
        UIView *maskview = [[UIView alloc] initWithFrame:self.view.bounds];
        maskview.backgroundColor = [UIColor blackColor];
        [self.view addSubview:maskview];
        
        NSMutableArray* showArray = [[NSMutableArray alloc] initWithArray:tapGes.infoArray];
        [showArray removeLastObject];
        SIShowImageView *SIImageView = [[SIShowImageView alloc] initWithFrame:self.view.bounds
                                                                      byClick:tapGes.view.tag
                                                                    infoArray:showArray];
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
}


//当选择照片后进入这里
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"])
    {
        UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        if (self.imageArray.count > 0) {
            [self.imageArray insertObject:image atIndex:self.imageArray.count - 1];
        }
        else{
            [self.imageArray addObject:image];
        }

        [self layoutImage];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Assets Picker Delegate

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    if (self.imageArray.count > 0) {
        for (int nIndex = 0; nIndex < (int)assets.count; ++nIndex) {
            [self.imageArray insertObject:assets[nIndex] atIndex:self.imageArray.count - 1];
        }
    }
    else
        [self.imageArray addObjectsFromArray:assets];
    [self layoutImage];
}


-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    float progress = (float)totalBytesSent / (float)totalBytesExpectedToSend;
    NSNumber* progressNumber = [NSNumber numberWithFloat:progress];
    [self performSelectorOnMainThread:@selector(updateProgress:)
                               withObject:progressNumber
                            waitUntilDone:NO];
}

@end
