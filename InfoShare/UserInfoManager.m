//
//  UserInfoManager.m
//  InfoShare
//
//  Created by xjw03 on 15/8/6.
//  Copyright (c) 2015年 xjw03. All rights reserved.
//

#import "UserInfoManager.h"
#import "Tools.h"
static UserInfoManager*  userinfo_manager = nil;

@implementation UserInfoManager

+(UserInfoManager *)GetUserInfoManger{
    @synchronized(self){
        if (!userinfo_manager) {
            [[self alloc] init];
        }
    }
    return userinfo_manager;
}

+(id)allocWithZone:(struct _NSZone *)zone{
    @synchronized(self){
        if (!userinfo_manager) {
            userinfo_manager = [super allocWithZone:zone];
            return userinfo_manager;
        }
    }
    return nil;
}

-(id)copyWithZone:(NSZone *)zone{
    return self;
}

#ifdef NEW
-(UserInfo*) GetUserInfoByName:(NSString*) UserName andPassword:(NSString*) Password{
    UserInfo* info = nil;
    NSString* UrlwithAction = [[NSString alloc] initWithFormat: @"%@", self.UserInfoUrl];
    NSString* bodyStr = [NSString stringWithFormat:@"username=%@&password=%@",UserName, Password];
    NSMutableURLRequest* request = [Tools MakePostRequest:UrlwithAction
                                                 withBody:bodyStr];
    
    NSDictionary* JsonDic = [Tools SendSynRequest:request];
    if (nil != JsonDic) {
        NSString* UserName = [JsonDic objectForKey:@"username"];
        NSString* UserId = [JsonDic objectForKey:@"uid"];
        info = [[UserInfo alloc] initWithName:UserName andPassword:Password];
        info.ID = [UserId intValue];
    }
    return info;
}

-(NSString*) RegisterUserByInfo:(UserInfo*) Info{
    NSString* Url = [[NSString alloc] initWithFormat: @"%@", self.UserRegUrl];
    NSString* bodyStr = [NSString stringWithFormat:@"username=%@&password=%@",Info.Name, Info.Password];
    NSMutableURLRequest* request = [Tools MakePostRequest:Url
                                                 withBody:bodyStr];
    NSString* Msg = nil;
    NSDictionary* JsonDic = [Tools SendSynRequest:request];
    if (nil != JsonDic) {
        id uid = [JsonDic objectForKey:@"uid"];
        Info.ID = [uid intValue];
    }
    else
        Msg = @"注册失败";
    return Msg;
}

#else
-(UserInfo*) GetUserInfoByName:(NSString*) UserName andPassword:(NSString*) Password{
    UserInfo* info = nil;
    BOOL bRet = NO;
    NSString* UrlwithAction = [[NSString alloc] initWithFormat: @"%@?a=%@", self.UserInfoUrl, Act_Login];
    NSString* bodyStr = [NSString stringWithFormat:@"UserName=%@&PassWord=%@",UserName, Password];
    NSMutableURLRequest* request = [Tools MakePostRequest:UrlwithAction
                                                 withBody:bodyStr];
    
    NSDictionary* JsonDic = [Tools SendSynRequest:request];
    if (nil != JsonDic) {
        NSString* value = [JsonDic objectForKey:@"Result"];
        if (![value isKindOfClass:[NSNull class]]) {
            bRet = [value boolValue];
            if (bRet) {
                NSDictionary* UserDataDic = [JsonDic objectForKey:@"UserData"];
                NSString* UserName = [UserDataDic objectForKey:@"name"];
                NSString* UserId = [UserDataDic objectForKey:@"uid"];
                info = [[UserInfo alloc] initWithName:UserName andPassword:Password];
                info.ID = [UserId intValue];
            }
        }
    }
    return info;
}


-(NSString*) RegisterUserByInfo:(UserInfo*) Info{
    BOOL bRet = NO;
    NSString* UrlwithAction = [[NSString alloc] initWithFormat: @"%@?a=%@", self.UserInfoUrl, Act_Register];
    NSString* bodyStr = [NSString stringWithFormat:@"UserName=%@&PassWord=%@",Info.Name, Info.Password];
    NSMutableURLRequest* request = [Tools MakePostRequest:UrlwithAction
                                                 withBody:bodyStr];
    NSString* Msg = nil;
    NSDictionary* JsonDic = [Tools SendSynRequest:request];
    if (nil != JsonDic) {
        Msg = [JsonDic objectForKey:@"Msg"];
        NSString* value = [JsonDic objectForKey:@"Result"];
        if (![value isKindOfClass:[NSNull class]]) {
            bRet = [value boolValue];
        }
    }
    if(!bRet)
        return Msg;
    else
        return nil;
}
#endif




-(BOOL) LoginByName:(NSString*) Username{
    return YES;
}
@end
