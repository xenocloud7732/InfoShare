//
//  UserInfo.h
//  InfoShare
//
//  Created by xjw03 on 15/8/6.
//  Copyright (c) 2015年 xjw03. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

#pragma mark UserId
@property (assign) int ID;

#pragma mark UserName
@property (nonatomic,copy) NSString* Name;

#pragma mark Password
@property (nonatomic,copy) NSString* Password;

#pragma mark Constractor
-(UserInfo*)initWithName:(NSString*)Name
           andPassword:(NSString*)Password;


#pragma mark Constractor
+(UserInfo*)initWithName:(NSString*)Name
           andPassword:(NSString*)Password;

@end
