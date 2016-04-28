//
//  XGUtils.m
//  XG_Notes
//
//  Created by 贾  on 16/4/28.
//  Copyright © 2016年 XiaoGang. All rights reserved.
//

#import "XGUtils.h"


@implementation XGUtils

//取时间戳如:1234567891000(毫秒后三位精度去除)
+ (long long)systemNowTimeSecondPlusThreeZero
{
    NSTimeInterval nowTime =[[NSDate date] timeIntervalSince1970];
    long long time = (long long) nowTime *1000;
    return time;
}

+ (UIFont *) defaultFontOfSize:(CGFloat)fontsize
{
    //return [UIFont fontWithName:@"FZLTHJW--GB1-0" size:fontsize];
    if (IOSVERSION_9) {
        return [UIFont fontWithName:@"PingFangSC-Regular" size:fontsize];
    }else{
        return [UIFont fontWithName:@"STHeitiSC-Light" size:fontsize];
    }
}

+ (UIFont *) defaultBoldFontOfSize:(CGFloat)fontsize
{
    if (IOSVERSION_9) {
        return [UIFont fontWithName:@"PingFangSC-Medium" size:fontsize];
    }else{
        return [UIFont fontWithName:@"STHeitiSC-Medium" size:fontsize];
    }
}
/**
 *  MARK:--------------------截取字符串&并且检查出界--------------------
 */
+(NSString*) subStringWithRangeAndCheckOut:(NSRange)range withOldStr:(NSString*)oldStr{
    if (NSSTRINGISVALID(oldStr) && range.location != NSNotFound && range.location + range.length <= oldStr.length) {
        return [oldStr substringWithRange:range];
    }
    return nil;
}

+ (UIImage *)imageByScalingToSize:(CGSize)targetSize withOldImg:(UIImage*)oldImg{
    
    UIImage *sourceImage = oldImg;
    UIImage *newImage = nil;
    
    //   CGSize imageSize = sourceImage.size;
    //   CGFloat width = imageSize.width;
    //   CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    //   CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    // this is actually the interesting part:
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"could not scale image");
    
    
    return newImage ;
}


@end
