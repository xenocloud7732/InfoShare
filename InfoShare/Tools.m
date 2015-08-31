//
//  Tools.m
//  InfoShare
//
//  Created by xjw03 on 15/8/6.
//  Copyright (c) 2015年 xjw03. All rights reserved.
//

#import "Tools.h"
#import "InfoManager.h"
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import <ImageIO/ImageIO.h>
#import "CTAssetsPickerController/CTAssetsPickerController.h"


NSString* Act_Login = @"Login_BBS";
NSString* Act_Register = @"Register_BBS";
NSString* Act_Upload = @"Upload";
NSString* Act_GetMsg = @"GetMessageList";
NSString* Act_GetMsgSpc= @"PageDown";
UIImage* imgLoadImg = nil;
UIImage* imgAddImg = nil;
const int MaxUploadCount = 9;


//使用类别
@implementation NSOutputStream(NSOutputStreamWriteData)

- (NSUInteger) writeData:(NSData *)data{
    return [self write:data.bytes maxLength:data.length];
}

@end

@implementation Tools

+(NSDictionary*)RequestByUrl:(NSString*) url{
    NSError *error;
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:url]];
    NSData* response = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:nil error:nil];
    NSDictionary* DevDic = [NSJSONSerialization JSONObjectWithData:response
                                                           options:NSJSONReadingMutableLeaves
                                                             error:&error];
    return DevDic;
}

+(NSMutableURLRequest*)MakePostRequest:(NSString*) urlStr withBody:(NSString*) bodyStr{
    urlStr=[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlStr];
    NSMutableURLRequest *requestM=[NSMutableURLRequest requestWithURL:url cachePolicy:0 timeoutInterval:10.0];
    [requestM setHTTPMethod:@"POST"];
    NSData *Body=[bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    [requestM setHTTPBody:Body];
    return requestM;
}

#ifdef NEW
+(NSMutableURLRequest*)MakeGetRequest:(NSString*) urlStr withBody:(NSString*) bodyStr{
    NSString* Requesturl = [[NSString alloc] initWithFormat:@"%@?%@", urlStr,bodyStr];
    Requesturl=[Requesturl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:Requesturl];
    NSMutableURLRequest *requestM=[NSMutableURLRequest requestWithURL:url cachePolicy:0 timeoutInterval:10.0];
    [requestM setHTTPMethod:@"GET"];
    return requestM;
}
#else
+(NSMutableURLRequest*)MakeGetRequest:(NSString*) urlStr withBody:(NSString*) bodyStr{
    NSString* Requesturl = [[NSString alloc] initWithFormat:@"%@&%@", urlStr,bodyStr];
    Requesturl=[Requesturl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:Requesturl];
    NSMutableURLRequest *requestM=[NSMutableURLRequest requestWithURL:url cachePolicy:0 timeoutInterval:10.0];
    [requestM setHTTPMethod:@"GET"];
    return requestM;
}
#endif

+(void)SendAsynRequest:(NSMutableURLRequest*) requestM  andDofinish:(doFinish) finishFunc
              AndDelegate:(id <NSURLSessionDelegate>) delegate{
    NSURLSessionConfiguration *sessionConfig=[NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.timeoutIntervalForRequest=5.0f;
    sessionConfig.allowsCellularAccess=true;
    NSURLSession *session=[NSURLSession sessionWithConfiguration:sessionConfig delegate:delegate delegateQueue:nil];//指
    
    NSURLSessionDataTask *dataTask = nil;
    if (nil !=  finishFunc) {
        dataTask = [session dataTaskWithRequest:requestM completionHandler:finishFunc];
    }
    else{
        dataTask = [session dataTaskWithRequest:requestM completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                NSLog(@"Send failure,error is :%@",error.localizedDescription);
            }else{
                NSLog(@"Send Success!");
            }
            
        }];
    }
    [dataTask resume];
}



+(NSDictionary*)DealData:(NSData*) data andResponse:(NSURLResponse*) Res{
    NSHTTPURLResponse* HttpRes = (NSHTTPURLResponse*)Res;
    NSError* error = nil;
    switch (HttpRes.statusCode) {
        case 200:
            
        {
            NSDictionary* DevDic = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:NSJSONReadingMutableLeaves
                                                                     error:&error];
            
            return DevDic;
        }
            break;
        case 400:
            break;
        case 403:
            break;
        default:
            break;
    }
    return nil;
}

#ifdef NEW
+(NSDictionary*)SendSynRequest:(NSMutableURLRequest*) requestM{
    NSHTTPURLResponse* HttpRes = nil;
    NSError* error = nil;
    NSData* response = [NSURLConnection sendSynchronousRequest:requestM
                          returningResponse:&HttpRes
                                      error:&error];
    if (error) {
        NSLog(@"Send failure,error is :%@",error.localizedDescription);
        return nil;
    }
    else{
        //int ncode = HttpRes.statusCode;
        return [self DealData:response andResponse:HttpRes];
    }
}
#else
+(NSDictionary*)SendSynRequest:(NSMutableURLRequest*) requestM{
    NSError* error = nil;
    NSHTTPURLResponse* HttpRes = nil;
    NSData* response = [NSURLConnection sendSynchronousRequest:requestM
                                             returningResponse:&HttpRes
                                                         error:&error];
    if (error) {
        NSLog(@"Send failure,error is :%@",error.localizedDescription);
        return nil;
    }
    else{
        NSDictionary* DevDic = [NSJSONSerialization JSONObjectWithData:response
                                                            options:NSJSONReadingMutableLeaves
                                                                error:&error];
        return DevDic;
    }
}
#endif

+(NSMutableURLRequest*)MakeUploadRequest:(NSString*) urlStr withPhotoArray:(NSArray*) assets
                               withTitle:(NSString*)Title withComment:(NSString*) Comment{
    //打开临时上传文件流
    NSMutableString *tmpUploadBodyPath=[NSMutableString stringWithString:NSTemporaryDirectory()];
    [tmpUploadBodyPath appendFormat:@"upbdy%f.tmp",[[NSDate date] timeIntervalSince1970]];
    NSOutputStream *tmpUploadBodyStream=[[NSOutputStream alloc] initToFileAtPath:tmpUploadBodyPath append:FALSE];
    [tmpUploadBodyStream open];
    
    //创建Request设置基本信息
    NSInteger uploadContentLength=0;
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    NSString *boundary=@"xeno_boundary";
    [request setURL:[NSURL URLWithString: urlStr]];
    [request setHTTPMethod:@"POST"];
    
    uploadContentLength+=[tmpUploadBodyStream writeData: [[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
#ifdef NEW
    uploadContentLength+=[tmpUploadBodyStream writeData:[[NSString stringWithFormat:
                                                          @"Content-Disposition: form-data; name=\"content\"\r\n\r\n%@",Comment] dataUsingEncoding:NSUTF8StringEncoding]];
#else
    uploadContentLength+=[tmpUploadBodyStream writeData:[[NSString stringWithFormat:
                                                          @"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    uploadContentLength+=[tmpUploadBodyStream writeData:[[NSString stringWithFormat:
                                                          @"Content-Disposition:form-data; name=\"machine_hash\"\r\n\r\n%@",[[UIDevice alloc]init].identifierForVendor.UUIDString] dataUsingEncoding:NSUTF8StringEncoding]];
    
    uploadContentLength+=[tmpUploadBodyStream writeData:[[NSString stringWithFormat:
                                                          @"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    uploadContentLength+=[tmpUploadBodyStream writeData:[[NSString stringWithFormat:@"Content-Disposition:form-data; name=\"title\"\r\n\r\n%@",Title] dataUsingEncoding:NSUTF8StringEncoding]];
    
    uploadContentLength+=[tmpUploadBodyStream writeData:[[NSString stringWithFormat:
                                                          @"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    uploadContentLength+=[tmpUploadBodyStream writeData:[[NSString stringWithFormat:
                                                          @"Content-Disposition:form-data; name=\"text\"\r\n\r\n%@",Comment] dataUsingEncoding:NSUTF8StringEncoding]];
#endif
    int nIndex = 1;
    for (id Item in assets) {
        //向输出流写入
        BOOL bAsset = YES;
        NSString* fileName = nil;
        if ([Item isKindOfClass:[ALAsset class]]) {
            ALAsset* asset = (ALAsset*)Item;
            fileName = asset.defaultRepresentation.filename;
        }else{
            fileName = [[NSString alloc] initWithFormat:@"Photo_%d",nIndex];
            bAsset = NO;
        }
        
        uploadContentLength+=[tmpUploadBodyStream writeData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        //写入文件名和响应的二进制
        #ifdef NEW
            uploadContentLength+=[tmpUploadBodyStream writeData:[[NSString stringWithFormat:@"Content-Disposition:form-data; name=\"files[]\";filename=\"%@\"\r\nContent-Type: image/jpeg\r\n\r\n",fileName] dataUsingEncoding:NSUTF8StringEncoding]];
        #else
        if(bAsset)
        {
            uploadContentLength+=[tmpUploadBodyStream writeData:[[NSString stringWithFormat:@"Content-Disposition:form-data; name=\"file_hash_%d\"\r\n\r\n%@\r\n--%@\r\n",nIndex,[Item valueForProperty:ALAssetPropertyAssetURL],boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            uploadContentLength+=[tmpUploadBodyStream writeData:[[NSString stringWithFormat:@"Content-Disposition:form-data; name=\"orientation_%d\"\r\n\r\n%@\r\n--%@\r\n",nIndex,[Item valueForProperty:ALAssetPropertyOrientation],boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        uploadContentLength+=[tmpUploadBodyStream writeData:[[NSString stringWithFormat:@"Content-Disposition:form-data; name=\"files_%d\";filename=\"%@\";\r\nContent-Type:application/octet-stream\r\nContent-Transfer-Encoding:binary\r\n\r\n",nIndex, fileName]dataUsingEncoding:NSUTF8StringEncoding]];
        #endif
        {
            UIImage* thumbnail = nil;
            if (bAsset)
                thumbnail = [Tools thumbnailForAsset:Item maxPixelSize:1280];
            else{
                UIImage* img = (UIImage*)Item;
                int nTargetWidth = 0;
                if (img.size.width > img.size.height) {
                    nTargetWidth = 1280;
                }
                else{
                    nTargetWidth = (img.size.width / img.size.height) * 1280;
                }
                
                thumbnail = [Tools imageCompressForWidth:img targetWidth:nTargetWidth];
            }
            
            NSData *dataObj = UIImageJPEGRepresentation(thumbnail, 0.75);
            [tmpUploadBodyStream write:dataObj.bytes maxLength:dataObj.length];
            uploadContentLength += dataObj.length;
        }
        ++nIndex;
    }
    uploadContentLength+=[tmpUploadBodyStream writeData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [tmpUploadBodyStream close];
    NSInputStream* uploadBodyStream=[[NSInputStream alloc] initWithFileAtPath:tmpUploadBodyPath];
    [request setHTTPBodyStream:uploadBodyStream];
    [request addValue:[NSString stringWithFormat:@"%lu",(long)uploadContentLength] forHTTPHeaderField:@"Content-Length"];
    //[request addValue:@"Time Cap Client5" forHTTPHeaderField:@"User-Agent"];
    [request addValue:[NSString stringWithFormat:@"multipart/form-data;boundary=%@",boundary ] forHTTPHeaderField:@"Content-Type"];
    return request;
}

/*+(NSMutableURLRequest*)MakeUploadRequest:(NSString*) urlStr withPhoto:(ALAsset*) asset
                               withTitle:(NSString*) Title withComment:(NSString*) Comment{
    //打开临时上传文件流
    NSMutableString *tmpUploadBodyPath=[NSMutableString stringWithString:NSTemporaryDirectory()];
    [tmpUploadBodyPath appendFormat:@"upbdy%f.tmp",[[NSDate date] timeIntervalSince1970]];
    NSOutputStream *tmpUploadBodyStream=[[NSOutputStream alloc] initToFileAtPath:tmpUploadBodyPath append:FALSE];
    [tmpUploadBodyStream open];
    
    //创建Request设置基本信息
    NSInteger uploadContentLength=0;
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    NSString *boundary=@"xeno_boundary";
    [request setURL:[NSURL URLWithString: urlStr]];
    [request setHTTPMethod:@"POST"];
    
    //向输出流写入
    ALAssetRepresentation* rep = asset.defaultRepresentation;
    uploadContentLength+=[tmpUploadBodyStream writeData: [[NSString stringWithFormat:@"\r\n\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    uploadContentLength+=[tmpUploadBodyStream writeData:[[NSString stringWithFormat:@"Content-Disposition:form-data; name=\"machine_hash\"\r\n\r\n%@\r\n--%@\r\n",[[UIDevice alloc]init].identifierForVendor.UUIDString,boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    uploadContentLength+=[tmpUploadBodyStream writeData:[[NSString stringWithFormat:@"Content-Disposition:form-data; name=\"file_hash\"\r\n\r\n%@\r\n--%@\r\n",[asset valueForProperty:ALAssetPropertyAssetURL],boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    uploadContentLength+=[tmpUploadBodyStream writeData:[[NSString stringWithFormat:@"Content-Disposition:form-data; name=\"orientation\"\r\n\r\n%@\r\n--%@\r\n",[asset valueForProperty:ALAssetPropertyOrientation],boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    uploadContentLength+=[tmpUploadBodyStream writeData:[[NSString stringWithFormat:@"Content-Disposition:form-data; name=\"title\"\r\n\r\n%@\r\n--%@\r\n",Title,boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    uploadContentLength+=[tmpUploadBodyStream writeData:[[NSString stringWithFormat:@"Content-Disposition:form-data; name=\"text\"\r\n\r\n%@\r\n--%@\r\n",Comment,boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    //写入文件名和响应的二进制
    uploadContentLength+=[tmpUploadBodyStream writeData:[[NSString stringWithFormat:@"Content-Disposition:form-data; name=\"imgdata\";filename=\"%@\";\r\nContent-Type:application/octet-stream\r\nContent-Transfer-Encoding:binary\r\n\r\n",rep.filename] dataUsingEncoding:NSUTF8StringEncoding]];
    {
        
        long long bytes_remain=rep.size;
        long long read_offset=0;
        const unsigned long read_buffer_size=10240;
        void *buffer=malloc(read_buffer_size);
        while(bytes_remain>0){
            NSError *errGetBytes=nil;
            NSUInteger bytes_readed=[rep getBytes:(uint8_t*)(buffer) fromOffset:read_offset length:(NSUInteger)(read_buffer_size>bytes_remain?bytes_remain:read_buffer_size) error:&errGetBytes];
            NSUInteger bytes_writed=[tmpUploadBodyStream write:buffer maxLength:bytes_readed];
            NSAssert(bytes_writed==bytes_readed,@"Write content failed writed:%lud ,expected:%lud",(unsigned long)bytes_writed,(unsigned long)bytes_readed);
            bytes_remain-=bytes_readed;
            read_offset+=bytes_readed;
            uploadContentLength+=bytes_readed;
        }
        free(buffer);
    }
    uploadContentLength+=[tmpUploadBodyStream writeData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    //写入其他信息,时间，地理位置等信息
    NSDate *photoDate=[asset valueForProperty:ALAssetPropertyDate];
    if(nil!=photoDate){
        uploadContentLength+=[tmpUploadBodyStream writeData:[[NSString stringWithFormat:@"Content-Disposition:form-data; name=\"file_date\"\r\n\r\n%u\r\n--%@\r\n",(unsigned int)(NSTimeInterval)[photoDate timeIntervalSince1970],boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }else{
        uploadContentLength+=[tmpUploadBodyStream writeData:[[NSString stringWithFormat:@"Content-Disposition:form-data; name=\"file_date\"\r\n\r\n%u\r\n--%@\r\n",(unsigned int)(NSTimeInterval)[[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970],boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    CLLocation *locData=[asset valueForProperty:ALAssetPropertyLocation];
    if(nil!=locData){
        uploadContentLength+=[tmpUploadBodyStream writeData:[[NSString stringWithFormat:@"Content-Disposition:form-data; name=\"lat\"\r\n\r\n%f\r\n--%@\r\n",locData.coordinate.latitude,boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        uploadContentLength+=[tmpUploadBodyStream writeData:[[NSString stringWithFormat:@"Content-Disposition:form-data; name=\"lng\"\r\n\r\n%f\r\n--%@\r\n",locData.coordinate.latitude,boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }else{
        uploadContentLength+=[tmpUploadBodyStream writeData:[[NSString stringWithFormat:@"Content-Disposition:form-data; name=\"lat\"\r\n\r\n0\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        uploadContentLength+=[tmpUploadBodyStream writeData:[[NSString stringWithFormat:@"Content-Disposition:form-data; name=\"lng\"\r\n\r\n0\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    uploadContentLength+=[tmpUploadBodyStream writeData:[[NSString stringWithFormat:@"Content-Disposition:form-data; name=\"thumbdata\";filename=\"thumb\";\r\nContent-Type:application/octet-stream\r\nContent-Transfer-Encoding:binary\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    {
        NSData *thumbdata=UIImageJPEGRepresentation([UIImage imageWithCGImage:asset.thumbnail], 1);
        uploadContentLength+=[tmpUploadBodyStream write:thumbdata.bytes maxLength:thumbdata.length];
    }
    uploadContentLength+=[tmpUploadBodyStream writeData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [tmpUploadBodyStream close];
    
    NSInputStream* uploadBodyStream=[[NSInputStream alloc] initWithFileAtPath:tmpUploadBodyPath];
    [request setHTTPBodyStream:uploadBodyStream];
    [request addValue:[NSString stringWithFormat:@"%lu",(long)uploadContentLength] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"Time Cap Client5" forHTTPHeaderField:@"User-Agent"];
    [request addValue:[NSString stringWithFormat:@"multipart/form-data;boundary=%@",boundary ] forHTTPHeaderField:@"Content-Type"];
    return request;
}*/

+ (UIImage *)fullResolutionImageFromALAsset:(ALAsset *)asset{
    ALAssetRepresentation *assetRep = [asset defaultRepresentation];
    CGImageRef imgRef = [assetRep fullResolutionImage];
    UIImage *img = [UIImage imageWithCGImage:imgRef
                                       scale:assetRep.scale
                                 orientation:(UIImageOrientation)assetRep.orientation];
    return img;
}

+ (UIImage *)fullResolutionImageFromUrl:(NSString*)imgUrl{
    InfoManager* infomanager = [InfoManager GetInfoManager];
    UIImage *img = [infomanager GetImgByUrl:imgUrl];
    return img;
}

+(NSString*) md5:(NSString*) str{
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (uint)strlen(cStr), result);
    
    NSMutableString *hash = [NSMutableString string];
    for(int i=0;i<CC_MD5_DIGEST_LENGTH;i++)
    {
        [hash appendFormat:@"%02X",result[i]];
    }
    return [hash lowercaseString];
}

+(NSString*) GetSystemTime{
    NSDate *  senddate = [NSDate date];
    NSDateFormatter  *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *  locationString = [dateformatter stringFromDate:senddate];
    return locationString;
}







static size_t getAssetBytesCallback(void *info, void *buffer, off_t position, size_t count) {
    ALAssetRepresentation *rep = (__bridge id)info;
    
    NSError *error = nil;
    size_t countRead = [rep getBytes:(uint8_t *)buffer fromOffset:position length:count error:&error];
    
    if (countRead == 0 && error) {
        // We have no way of passing this info back to the caller, so we log it, at least.
        NSLog(@"thumbnailForAsset:maxPixelSize: got an error reading an asset: %@", error);
    }
    
    return countRead;
}
static void releaseAssetCallback(void *info) {
    // The info here is an ALAssetRepresentation which we CFRetain in thumbnailForAsset:maxPixelSize:.
    // This release balances that retain.
    CFRelease(info);
}

//压缩图片
+ (UIImage *)thumbnailForAsset:(ALAsset *)asset maxPixelSize:(NSUInteger)size
{
    NSParameterAssert(asset != nil);
    NSParameterAssert(size > 0);
    
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    
    CGDataProviderDirectCallbacks callbacks =
    {
        .version = 0,
        .getBytePointer = NULL,
        .releaseBytePointer = NULL,
        .getBytesAtPosition = getAssetBytesCallback,
        .releaseInfo = releaseAssetCallback,
    };
    
    CGDataProviderRef provider = CGDataProviderCreateDirect((void *)CFBridgingRetain(rep), [rep size], &callbacks);
    
    CGImageSourceRef source = CGImageSourceCreateWithDataProvider(provider, NULL);
    
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef)
                                                              @{   (NSString *)kCGImageSourceCreateThumbnailFromImageAlways: @YES,
                                                                   (NSString *)kCGImageSourceThumbnailMaxPixelSize : [NSNumber numberWithUnsignedInteger:size],
                                                                   (NSString *)kCGImageSourceCreateThumbnailWithTransform :@YES,
                                                                   });
    
    CFRelease(source);
    CFRelease(provider);
    
    if (!imageRef) {
        return nil;
    }

    UIImage *toReturn = [UIImage imageWithCGImage:imageRef];
    
    CFRelease(imageRef);
    
    return toReturn;
}



+(void) TransTimeInterval:(NSTimeInterval) interval andDay:(int*) day andHour:(int*) hour
                   andMin:(int*) min andSec:(int*) sec{
    int time = interval;
    *day = floor(time / (60 * 60 * 24));
    *hour = floor(time / (60 * 60));
    *hour -= *day * 24;
    *min = floor(time / 60);
    *min -= *hour * 60;
    *sec = time % 60;
}

+(UIImage*) GetLoadingImg{
    if (nil == imgLoadImg) {
        imgLoadImg = [UIImage imageNamed:@"Loading.jpg"];
    }
    return imgLoadImg;
}

+(UIImage*) GetAddImg{
    if (nil == imgAddImg) {
        imgAddImg = [UIImage imageNamed:@"add.jpg"];
    }
    return imgAddImg;
}



+(UIImage *) imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    if(CGSizeEqualToSize(imageSize, size) == NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

+(UIImage *) imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = height / (width / targetWidth);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    if(CGSizeEqualToSize(imageSize, size) == NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(size);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    
    UIGraphicsEndImageContext();
    return newImage;
}



//打开照相机
+(void)TakePhoto:(UIViewController*)uc
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = (id)uc;
        //设置拍照后的图片可被编辑
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [uc presentViewController:picker animated:YES completion:nil];
    }else
    {
        NSLog(@"模拟其中无法打开照相机,请在真机中使用");
    }
}


//打开本地相册
+(void)LocalPhoto:(UIViewController*)uc andMaxSelect:(int)MaxSelectd
{
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.maximumNumberOfSelection = MaxSelectd;
    picker.assetsFilter = [ALAssetsFilter allAssets];
    picker.delegate = (id)uc;
    [uc presentViewController:picker animated:YES completion:NULL];
}

@end
