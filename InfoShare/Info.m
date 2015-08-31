//
//  Info.m
//  InfoShare
//
//  Created by xjw03 on 15/8/14.
//  Copyright (c) 2015年 xjw03. All rights reserved.
//

#import "Info.h"

@implementation Info

-(Info*) initWithTid:(int) tid withAuthor:(NSString*) author
        withAuthorid:(int) authorid withAuthorPic:(NSString*) authorPic
         withSubject:(NSString*) subject withComment:(NSString*) comment
        withData:(NSTimeInterval) dataline
        withImgUrl:(NSString*) imgurl withImgPvUrl:(NSString*) imgPvurl{
    if (self = [super init] ) {
        self.tid = tid;
        self.author = author;
        self.authorid = authorid;
        self.authorPic = authorPic;
        self.subject = subject;
        self.comment = comment;
        self.dateline = dataline;
        self.imgurl = imgurl;
        self.imgPvurl = imgPvurl;
    }
    return self;
}


+(Info*) initWithTid:(int) tid withAuthor:(NSString*) author
        withAuthorid:(int) authorid withAuthorPic:(NSString*) authorPic
         withSubject:(NSString*) subject
         withComment:(NSString*) comment withData:(NSTimeInterval) dataline
          withImgUrl:(NSString*) imgurl withImgPvUrl:(NSString*) imgPvurl{
    Info* info = [[Info alloc] initWithTid:tid withAuthor:(NSString*) author
                                withAuthorid:authorid withAuthorPic:authorPic
                               withSubject:subject withComment: comment
                                  withData: dataline
                                withImgUrl: imgurl withImgPvUrl: imgPvurl];
    return info;
}

-(int) getImgCount{
    NSArray* itemArray = [self.imgurl componentsSeparatedByString:@";"];
    int nCount = (int)itemArray.count;
    //不计算最后的空白
    return 0 == nCount? 0 :nCount - 1;
}

@end


