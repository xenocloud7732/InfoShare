//
//  ViewController.h
//  InfoShare
//
//  Created by xjw03 on 15/8/6.
//  Copyright (c) 2015年 xjw03. All rights reserved.
//

#import <UIKit/UIKit.h>
extern NSString* strUserInfoUrl;
extern NSString* strGetInfoUrl;
extern NSString* strBaseUrl;

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *edtUserName;
@property (weak, nonatomic) IBOutlet UITextField *edtPassword;
@property (weak, nonatomic) IBOutlet UIButton *BtnLogin;

- (IBAction)DoLogin:(UIButton *)sender;
- (IBAction)ToRegister:(id)sender;

@end

