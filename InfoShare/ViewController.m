//
//  ViewController.m
//  InfoShare
//
//  Created by xjw03 on 15/8/6.
//  Copyright (c) 2015年 xjw03. All rights reserved.
//

#import "ViewController.h"
#import "UserInfoManager.h"
#import "UploadManager.h"
#import "Tools.h"

#ifdef NEW
    NSString* strBaseUrl = @"http://erer.me";
    NSString* strUserInfoUrl = @"http://erer.me/mobimg/mobjsonint/login";
    NSString* strUserRegUrl = @"http://erer.me/mobimg/mobjsonint/register";
    NSString* strGetInfoUrl = @"http://erer.me/mobimg/mobjsonint/list";
    NSString* strPostInfoUrl = @"http://erer.me/mobimg/mobjsonint/post";


    /*NSString* strBaseUrl = @"http://192.168.18.33";
    NSString* strUserInfoUrl = @"http://192.168.18.33/mobimg/mobjsonint/login";
    NSString* strUserRegUrl = @"http://192.168.18.33/mobimg/mobjsonint/register";
    NSString* strGetInfoUrl = @"http://192.168.18.33/mobimg/mobjsonint/list";
    NSString* strPostInfoUrl = @"http://192.168.18.33/mobimg/mobjsonint/post";*/
#else
    NSString* strUserInfoUrl = @"http://192.168.18.21/bbs/bbs.php";
#endif



@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UserInfoManager* UserMansger = [UserInfoManager GetUserInfoManger];
    UserMansger.UserInfoUrl = strUserInfoUrl;
    UserMansger.UserRegUrl = strUserRegUrl;
    UploadManager* uploadmanager = [UploadManager GetUploadManager];
    #ifdef NEW
        uploadmanager.UploadUrl = strPostInfoUrl;
    #else
        uploadmanager.UploadUrl = [[NSString alloc] initWithFormat: @"%@?a=%@", strUserInfoUrl, Act_Upload];
    #endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)DoLogin:(UIButton *)sender {
    
    NSString* Username = self.edtUserName.text;
    NSString* Password = self.edtPassword.text;
    //NSString* Username = @"admin";
    //NSString* Password = @"start";
    UserInfoManager* UserMansger = [UserInfoManager GetUserInfoManger];

    UserInfo* info = [UserMansger GetUserInfoByName:Username andPassword:Password];
    if (nil != info) {
        UserMansger.CurUserInfo = info;
        [self performSegueWithIdentifier:@"Segue_L2S" sender:self];
        }
    else
    {
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"用户名或密码错误" message:nil
                                                        delegate:nil cancelButtonTitle:@"请重新登录"otherButtonTitles:nil,nil];
        [alert show];
    }
}

- (IBAction)ToRegister:(id)sender {
    [self performSegueWithIdentifier:@"Segue_L2R" sender:self];
}


/*- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:{
        
        }
        break;
        case 1:{
            
        }
        break;
    }
}*/

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

@end
