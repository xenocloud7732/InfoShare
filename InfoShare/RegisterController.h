//
//  RegisterController.h
//  InfoShare
//
//  Created by xjw03 on 15/8/7.
//  Copyright (c) 2015年 xjw03. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *edtUserName;
@property (weak, nonatomic) IBOutlet UITextField *edtPassword;
@property (weak, nonatomic) IBOutlet UITextField *edtPasswordConfirm;

- (IBAction)DoRegister:(id)sender;

- (IBAction)Doreturn:(id)sender;

@end
