//
//  InfoManager.h
//  InfoShare
//
//  Created by xjw03 on 15/8/14.
//  Copyright (c) 2015年 xjw03. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Info.h"
typedef void(^doFinishAddinfo)(void);

@interface InfoManager : NSObject

@property (strong) NSMutableArray* InfoArray;//Info数组

@property (strong) NSMutableDictionary* ImgCacheDic;//Img缓存
+(InfoManager*) GetInfoManager;

-(BOOL) GetInfoByPage:(int) page;

-(void) AddInfo:(BOOL)bforword andCount:(int) count andFinish:(doFinishAddinfo) doFinish;

-(UIImage*) GetImgByUrl:(NSString*) Url;

@end
