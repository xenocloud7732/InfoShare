//
//  UploadManager.m
//  InfoShare
//
//  Created by xjw03 on 15/8/13.
//  Copyright (c) 2015年 xjw03. All rights reserved.
//

#import "UploadManager.h"
#import "Tools.h"
static UploadManager* upload_manager = nil;


@implementation UploadManager

+(UploadManager *)GetUploadManager{
    @synchronized(self){
        if(!upload_manager){
            [[self alloc]init];
        }
    }
    return upload_manager;
}

+(id)allocWithZone:(struct _NSZone *)zone{
    @synchronized(self){
        if (!upload_manager) {
            upload_manager = [super allocWithZone:zone];
            return upload_manager;
        }
    }
    return nil;
}

-(id)copyWithZone:(NSZone *)zone{
    return self;
}

/*-(void)Upload:(ALAsset*) asset withTitle:(NSString*) title withComment:(NSString*) comment{
    NSMutableURLRequest* request = [Tools MakeUploadRequest:self.UploadUrl withPhoto:asset
                                                      withTitle:title withComment:comment];
    [Tools SendSynRequest:request];
}*/

-(void)UploadMul:(NSArray*) assets withTitle:(NSString*) title withComment:(NSString*) comment{
    NSMutableURLRequest* request = [Tools MakeUploadRequest:self.UploadUrl withPhotoArray:assets
                                                  withTitle:title withComment:comment];
    [Tools SendSynRequest:request];
}

-(void)UploadMul:(NSArray*) assets withTitle:(NSString*) title withComment:(NSString*) comment
      withFinish:(doFinish) finishFunc AndDelegate:(id <NSURLSessionDelegate>) delegate{
    NSMutableURLRequest* request = [Tools MakeUploadRequest:self.UploadUrl withPhotoArray:assets
                                                  withTitle:title withComment:comment];
    [Tools SendAsynRequest:request andDofinish:finishFunc AndDelegate:delegate];
}
@end
