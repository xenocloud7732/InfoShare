//
//  UserInfo.m
//  InfoShare
//
//  Created by xjw03 on 15/8/6.
//  Copyright (c) 2015年 xjw03. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

-(UserInfo*)initWithName:(NSString*)Name
           andPassword:(NSString*)Password{
    if (self = [super init]) {
        self.ID = -1;
        self.Name = Name;
        self.Password = Password;
    }
    return self;
}

+(UserInfo*)initWithName:(NSString*)Name
           andPassword:(NSString*)Password{
    UserInfo* info = [[UserInfo alloc] initWithName:Name andPassword:Password];
    return info;
}
@end
