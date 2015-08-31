//
//  InfoManager.m
//  InfoShare
//
//  Created by xjw03 on 15/8/14.
//  Copyright (c) 2015年 xjw03. All rights reserved.
//

#import "ViewController.h"
#import "InfoManager.h"
#import "Tools.h"

static InfoManager* info_manger = nil;

@implementation InfoManager

+(InfoManager *)GetInfoManager{
    @synchronized(self){
        if (!info_manger) {
            [[self alloc] init];
        }
    }
    return info_manger;
}

+(id)allocWithZone:(struct _NSZone *)zone{
    @synchronized(self){
        if (!info_manger) {
            info_manger = [super allocWithZone:zone];
            info_manger.InfoArray = [NSMutableArray new];
            info_manger.ImgCacheDic = [NSMutableDictionary new];
            return info_manger;
        }
    }
    return nil;
}

-(id)copyWithZone:(NSZone *)zone{
    return self;
}



#ifdef NEW
-(BOOL) GetInfoByPage:(int) page{
    NSString* urlstr = [[NSString alloc] initWithFormat:@"%@", strGetInfoUrl];
    NSString* bodyStr = [NSString stringWithFormat:@"page=%d", page];
    NSMutableURLRequest* request = [Tools MakeGetRequest:urlstr withBody:bodyStr];
    NSDictionary* dicList = [Tools SendSynRequest:request];
    if (nil != dicList) {
        id topiclist = [dicList objectForKey:@"topics"];
        if (topiclist &&![topiclist isKindOfClass:[NSNull class]]) {
                InfoManager* manager = [InfoManager GetInfoManager];
                [manager.InfoArray removeAllObjects];
        for (id dicInfo in topiclist) {
                Info* info = [InfoManager Trans2Info:dicInfo];
                [manager.InfoArray addObject:info];
            }
            return YES;
        }
    }
    return NO;
}

+(Info*) Trans2Info:(NSDictionary*) dicInfo
{
    int tid = -1;
    NSString* author = nil;
    NSMutableString* authorPic = [NSMutableString new];
    int authorid = -1;
    NSString* subject = nil;
    NSTimeInterval data = 0;
    NSMutableString* imgurlpv = nil;
    NSMutableString* imgurl = nil;
    NSString* message = nil;
    NSMutableString* picUrl = [NSMutableString new];
    
    id Temp = [dicInfo objectForKey:@"tid"];
    if (Temp &&![Temp isKindOfClass:[NSNull class]]) {
        tid = [Temp intValue];
    }
    
    Temp = [dicInfo objectForKey:@"title"];
    if (Temp &&![Temp isKindOfClass:[NSNull class]]) {
        subject = Temp;
        message = Temp;
    }
    Temp = [dicInfo objectForKey:@"timestamp"];
    if (Temp &&![Temp isKindOfClass:[NSNull class]]) {
        data = [Temp doubleValue] / 1000;
    }
    Temp = [dicInfo objectForKey:@"attachments"];
    if (Temp &&![Temp isKindOfClass:[NSNull class]]) {
        [picUrl setString:@""];
        NSArray* picArray = Temp;
        for (id pic in picArray) {
            [picUrl appendString:strBaseUrl];
            [picUrl appendString:pic];
            [picUrl appendString:@";"];
        }
        imgurlpv = picUrl;
        imgurl = picUrl;
    }
    
    NSDictionary* userDic = [dicInfo objectForKey:@"user"];
    if (userDic && ![userDic isKindOfClass:[NSNull class]]) {
        Temp = [userDic objectForKey:@"username"];
        if (Temp &&![Temp isKindOfClass:[NSNull class]]) {
            author = Temp;
        }
        
        Temp = [userDic objectForKey:@"uid"];
        if (Temp &&![Temp isKindOfClass:[NSNull class]]) {
            authorid = [Temp intValue];
        }
        
        Temp = [userDic objectForKey:@"picture"];
        if (Temp &&![Temp isKindOfClass:[NSNull class]]) {
            [authorPic appendString:Temp];
        }
    }
    return  [Info initWithTid:tid withAuthor:author
                 withAuthorid:authorid withAuthorPic:authorPic
                  withSubject:subject withComment:message withData:data
                   withImgUrl:imgurl withImgPvUrl:imgurlpv];
}


-(void) AddInfo:(BOOL)bforword andCount:(int) count andFinish:(doFinishAddinfo) doFinish{
    int nTid = 0;
    InfoManager* manager = [InfoManager GetInfoManager];
    if (manager.InfoArray.count > 0) {
        Info* info = nil;
        if (bforword)
            info = manager.InfoArray[0];
        else
            info = manager.InfoArray[manager.InfoArray.count - 1];
        nTid = info.tid;
    }

    NSString* urlstr = [[NSString alloc] initWithFormat:@"%@", strGetInfoUrl];
    NSString* bodyStr = [NSString stringWithFormat:@"%@&offsetTid=%d",
                         bforword?@"getNewer":@"getOlder", nTid];
    NSMutableURLRequest* request = [Tools MakeGetRequest:urlstr withBody:bodyStr];
    
    [Tools SendAsynRequest:request andDofinish:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (nil == error) {
            NSDictionary* dicList = [Tools DealData:data andResponse:response];
            if (nil != dicList) {
                id topiclist = [dicList objectForKey:@"topics"];
                for (id dicInfo in topiclist) {
                    Info* info = [InfoManager Trans2Info:dicInfo];
                    if (bforword)
                        [manager.InfoArray insertObject:info atIndex:0];
                    else
                        [manager.InfoArray addObject:info];
                }
            }
            if (nil != doFinish){
                doFinish();
            }
        }
        else{
            NSLog(@"Send failure,error is :%@",error.localizedDescription);
        }
    } AndDelegate:nil];
}
#else
+(Info*) Trans2Info:(NSDictionary*) dicInfo
{
    int tid = -1;
    NSString* author = nil;
    int authorid = -1;
    NSString* subject = nil;
    NSTimeInterval data = 0;
    NSString* imgurlpv = nil;
    NSString* imgurl = nil;
    NSString* message = nil;
    
    id Temp = [dicInfo objectForKey:@"tid"];
    if (Temp &&![Temp isKindOfClass:[NSNull class]]) {
        tid = [Temp intValue];
    }
    
    Temp = [dicInfo objectForKey:@"author"];
    if (Temp &&![Temp isKindOfClass:[NSNull class]]) {
        author = Temp;
    }
    
    Temp = [dicInfo objectForKey:@"authorid"];
    if (Temp &&![Temp isKindOfClass:[NSNull class]]) {
        authorid = [Temp intValue];
    }
    
    Temp = [dicInfo objectForKey:@"subject"];
    if (Temp &&![Temp isKindOfClass:[NSNull class]]) {
        subject = Temp;
    }
    
    Temp = [dicInfo objectForKey:@"dateline"];
    if (Temp &&![Temp isKindOfClass:[NSNull class]]) {
        data = [Temp doubleValue];
    }
    
    Temp = [dicInfo objectForKey:@"imgurlpv"];
    if (Temp &&![Temp isKindOfClass:[NSNull class]]) {
        imgurlpv = Temp;
    }
    
    Temp = [dicInfo objectForKey:@"imgurl"];
    if (Temp &&![Temp isKindOfClass:[NSNull class]]) {
        imgurl = Temp;
    }
    
    Temp = [dicInfo objectForKey:@"message"];
    if (Temp && ![Temp isKindOfClass:[NSNull class]]) {
        message = Temp;
    }
    return  [Info initWithTid:tid withAuthor:author withAuthorid:authorid
                  withSubject:subject withComment:message withData:data
                   withImgUrl:imgurl withImgPvUrl:imgurlpv];
}

-(BOOL) GetInfoByPage:(int) page{
    NSString* urlstr = [[NSString alloc] initWithFormat:@"%@?a=%@", strUserInfoUrl, Act_GetMsg];
    NSString* bodyStr = [NSString stringWithFormat:@"page=%d", page];
    NSMutableURLRequest* request = [Tools MakeGetRequest:urlstr withBody:bodyStr];
    NSDictionary* dicList = [Tools SendSynRequest:request];
    if (nil != dicList) {
        InfoManager* manager = [InfoManager GetInfoManager];
        [manager.InfoArray removeAllObjects];
        
        for (id dicInfo in dicList) {
            Info* info = [InfoManager Trans2Info:dicInfo];
            [manager.InfoArray addObject:info];
        }
        return YES;
    }
    return NO;
}

-(BOOL) AddInfo:(BOOL)bforword andCount:(int) count{
    int nTid = 0;
    InfoManager* manager = [InfoManager GetInfoManager];
    if (manager.InfoArray.count > 0) {
        Info* info = nil;
        if (bforword)
            info = manager.InfoArray[0];
        else
            info = manager.InfoArray[manager.InfoArray.count - 1];
        nTid = info.tid;
    }
    
    NSString* urlstr = [[NSString alloc] initWithFormat:@"%@?a=%@", strUserInfoUrl, Act_GetMsgSpc];
    NSString* bodyStr = [NSString stringWithFormat:@"Down_Up=%@&tid=%d&num=%d",
                         bforword?@"Down":@"Up", nTid, count];
    NSMutableURLRequest* request = [Tools MakePostRequest:urlstr withBody:bodyStr];
    NSDictionary* dicList = [Tools SendSynRequest:request];
    if (nil != dicList) {
        for (id dicInfo in dicList) {
            Info* info = [InfoManager Trans2Info:dicInfo];
            if (bforword)
                [manager.InfoArray insertObject:info atIndex:0];
            else
                [manager.InfoArray addObject:info];
        }
        return YES;
    }
    return NO;
}
#endif




-(UIImage*) GetImgByUrl:(NSString*) Url{
    UIImage* image = nil;
    id Img = [self.ImgCacheDic valueForKey:Url];
    if (nil != Img) {
        image = Img;
    }
    else{
        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:Url]]];
        [self.ImgCacheDic setValue:image forKey:Url];
    }
    return image;
}

@end




