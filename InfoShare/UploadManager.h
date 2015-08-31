//
//  UploadManager.h
//  InfoShare
//
//  Created by xjw03 on 15/8/13.
//  Copyright (c) 2015年 xjw03. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "Tools.h"

@interface UploadManager : NSObject

@property (nonatomic, copy) NSString* UploadUrl;
+(UploadManager *)GetUploadManager;
/*-(void)Upload:(ALAsset*) asset withTitle:(NSString*) title withComment:(NSString*) comment;*/
-(void)UploadMul:(NSArray*) assets withTitle:(NSString*) title withComment:(NSString*) comment;

-(void)UploadMul:(NSArray*) assets withTitle:(NSString*) title withComment:(NSString*) comment
      withFinish:(doFinish) finishFunc AndDelegate:(id <NSURLSessionDelegate>) delegate;
@end
