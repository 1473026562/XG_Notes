//
//  XGUtils.h
//  XG_Notes
//
//  Created by 贾  on 16/4/28.
//  Copyright © 2016年 XiaoGang. All rights reserved.
//  github: https://github.com/jiaxiaogang/XG_Notes
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define SYSTEM_VERSION   [[[UIDevice currentDevice] systemVersion] floatValue]
#define IOSVERSION_9 SYSTEM_VERSION >= 9.0
#define NSSTRINGISVALID(a) (a  && ![a isKindOfClass:[NSNull class]] && [a isKindOfClass:[NSString class]] && ![a isEqualToString:@""])
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height
#define ScreenWidth [[UIScreen mainScreen] bounds].size.width

typedef void (^Action)();
typedef void (^Action_OnePram)(id);
typedef void (^Action_TwoPram)(id,id);
typedef void (^Action_ThreePram)(id,id,id);
typedef void (^Action_FourPram)(id,id,id,id);
typedef void (^Action_FivePram)(id,id,id,id,id);
typedef void (^Action_SixPram)(id,id,id,id,id,id);
typedef void (^Action_SevenPram)(id,id,id,id,id,id,id);
typedef void (^Action_EightPram)(id,id,id,id,id,id,id,id);
typedef void (^Action_NinePram)(id,id,id,id,id,id,id,id,id);

typedef id (^Func)();
typedef id (^Func_OnePram)(id);
typedef id (^Func_TwoPram)(id,id);
typedef id (^Func_ThreePram)(id,id,id);
typedef id (^Func_FourPram)(id,id,id,id);
typedef id (^Func_FivePram)(id,id,id,id,id);
typedef id (^Func_SixPram)(id,id,id,id,id,id);
typedef id (^Func_SevenPram)(id,id,id,id,id,id,id);
typedef id (^Func_EightPram)(id,id,id,id,id,id,id,id);
typedef id (^Func_NinePram)(id,id,id,id,id,id,id,id,id);


@interface XGUtils : NSObject
+ (long long)systemNowTimeSecondPlusThreeZero;
+ (UIFont *) defaultFontOfSize:(CGFloat)fontsize;
+ (UIFont *) defaultBoldFontOfSize:(CGFloat)fontsize;
+(NSString*) subStringWithRangeAndCheckOut:(NSRange)range withOldStr:(NSString*)oldStr;
+ (UIImage *)imageByScalingToSize:(CGSize)targetSize withOldImg:(UIImage*)oldImg;
+(NSMutableArray*) convertAttachmentURLArr2ImgArr:(NSMutableArray*)attachmentURLArr;

@end
