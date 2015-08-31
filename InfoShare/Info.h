//
//  Info.h
//  InfoShare
//
//  Created by xjw03 on 15/8/14.
//  Copyright (c) 2015年 xjw03. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDate+TimeInterval.h"

@interface Info : NSObject

@property   (assign) int tid;//帖子编号
@property   (nonatomic, copy)NSString* author;//发帖人
@property   (assign) int authorid;//发帖人id
@property   (nonatomic, copy)NSString* authorPic;//发帖人头像
@property   (nonatomic, copy)NSString*  subject;//标题
@property   (nonatomic, copy)NSString*  comment;//内容
@property   (nonatomic, assign)NSTimeInterval dateline;//发帖时间
@property   (nonatomic, copy)NSString*  imgPvurl;//预览图地址，多个时用’;’分隔
@property   (nonatomic, copy)NSString*  imgurl;//原图地址，多个时用’;’分隔

-(Info*) initWithTid:(int) tid withAuthor:(NSString*) author
            withAuthorid:(int) authorid withAuthorPic:(NSString*) authorPic
            withSubject:(NSString*) subject withComment:(NSString*) comment
            withData:(NSTimeInterval) dataline
            withImgUrl:(NSString*) imgurl withImgPvUrl:(NSString*) imgPvurl;


+(Info*) initWithTid:(int) tid withAuthor:(NSString*) author
         withAuthorid:(int) authorid withAuthorPic:(NSString*) authorPic
         withSubject:(NSString*) subject withComment:(NSString*)
        comment withData:(NSTimeInterval) dataline
          withImgUrl:(NSString*) imgurl withImgPvUrl:(NSString*) imgPvurl;

-(int) getImgCount;
@end


