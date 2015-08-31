//
//  UserInfoManager.h
//  InfoShare
//
//  Created by xjw03 on 15/8/6.
//  Copyright (c) 2015年 xjw03. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfo.h"

@interface UserInfoManager : NSObject

@property (nonatomic, copy) NSString* UserInfoUrl;
@property (nonatomic, copy) NSString* UserRegUrl;

@property (nonatomic, retain) UserInfo* CurUserInfo;

#pragma mark GetUserInfoManger
+(UserInfoManager *)GetUserInfoManger;

#pragma mark Login
-(BOOL) LoginByName:(NSString*) Username;

#pragma mark GetUserInfofromJson
-(UserInfo*) GetUserInfoByName:(NSString*) UserName andPassword:(NSString*) Password;

#pragma mark RegisterUserByInfo
-(NSString*) RegisterUserByInfo:(UserInfo*) Info;
@end
