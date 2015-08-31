//
//  RegisterController.m
//  InfoShare
//
//  Created by xjw03 on 15/8/7.
//  Copyright (c) 2015年 xjw03. All rights reserved.
//

#import "RegisterController.h"
#import "UserInfoManager.h"

@implementation RegisterController

- (IBAction)DoRegister:(id)sender {
    NSString* Username = self.edtUserName.text;
    NSString* Password = self.edtPassword.text;
    NSString* PasswordConfirm = self.edtPasswordConfirm.text;
    if ([Password compare:PasswordConfirm] != 0) {
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"两次密码输入不一致" message:nil
                                                    delegate:nil cancelButtonTitle:@"请重新输入"otherButtonTitles:nil,nil];
        [alert show];
    }
    else{
        UserInfoManager* UserManager = [UserInfoManager GetUserInfoManger];
        UserInfo* info = [[UserInfo alloc]initWithName:Username andPassword:Password];
        NSString* Msg = [UserManager RegisterUserByInfo:info];
        if (nil != Msg) {
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:Msg message:nil
                                                        delegate:nil cancelButtonTitle:@"请重新注册"otherButtonTitles:nil,nil];
            [alert show];
        }
        else
        {
            UserManager.CurUserInfo = info;
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"注册成功" message:nil
                                                        delegate:nil cancelButtonTitle:@"请继续使用"otherButtonTitles:nil,nil];
            [self performSegueWithIdentifier:@"Segue_R2S" sender:self];
            [alert show];
        }
    }
}

- (IBAction)Doreturn:(id)sender {
    [self performSegueWithIdentifier:@"Segue_R2L" sender:self];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
@end
