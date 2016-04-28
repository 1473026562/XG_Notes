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

@end
