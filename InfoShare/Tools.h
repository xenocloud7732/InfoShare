//
//  Tools.h
//  InfoShare
//
//  Created by xjw03 on 15/8/6.
//  Copyright (c) 2015年 xjw03. All rights reserved.
//
#define NEW

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

extern NSString* Act_Login;
extern NSString* Act_Register;
extern NSString* Act_Upload;
extern NSString* Act_GetMsg;
extern NSString* Act_GetMsgSpc;
extern const int MaxUploadCount;


typedef void(^doFinish)(NSData *data, NSURLResponse *response, NSError *error);

@interface Tools : NSObject

#pragma mark RequestByUrl
+(NSDictionary*)RequestByUrl:(NSString*) url;

#pragma mark MakePostRequest
+(NSMutableURLRequest*)MakePostRequest:(NSString*) urlStr withBody:(NSString*) bodyStr;

#pragma mark MakeGetRequest
+(NSMutableURLRequest*)MakeGetRequest:(NSString*) urlStr withBody:(NSString*) bodyStr;

#pragma mark SendAsyRequest
+(void)SendAsynRequest:(NSMutableURLRequest*) requestM andDofinish:(doFinish) finishFunc
           AndDelegate:(id <NSURLSessionDelegate>) delegate;

#pragma mark SendSynRequest
+(NSDictionary*)SendSynRequest:(NSMutableURLRequest*) requestM;

/*(+(NSMutableURLRequest*)MakeUploadRequest:(NSString*) urlStr withPhoto:(ALAsset*) asset
                             withTitle:(NSString*)Title withComment:(NSString*) Comment;*/

+(NSMutableURLRequest*)MakeUploadRequest:(NSString*) urlStr withPhotoArray:(NSArray*) assets
                               withTitle:(NSString*)Title withComment:(NSString*) Comment;

+(NSDictionary*)DealData:(NSData*) data andResponse:(NSURLResponse*) Res;

+(UIImage *)fullResolutionImageFromALAsset:(ALAsset *)asset;

+(UIImage *)fullResolutionImageFromUrl:(NSString*)imgUrl;

+(NSString*) md5:(NSString*) str;

+(NSString*) GetSystemTime;

+(void) TransTimeInterval:(NSTimeInterval) interval andDay:(int*) day andHour:(int*) hour
                   andMin:(int*) min andSec:(int*) sec;

+(UIImage*) GetLoadingImg;

+(UIImage*) GetAddImg;

+(UIImage *) imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size;

+(UIImage *) imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth;

+(void)TakePhoto:(UIViewController*)uc;

+(void)LocalPhoto:(UIViewController*)uc andMaxSelect:(int)MaxSelectd;
@end
