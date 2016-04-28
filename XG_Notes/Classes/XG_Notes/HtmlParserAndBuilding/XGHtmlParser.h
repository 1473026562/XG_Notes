//
//  XGHtmlParser.h
//  XG_Notes
//
//  Created by 贾  on 16/4/28.
//  Copyright © 2016年 XiaoGang. All rights reserved.
//  github: https://github.com/jiaxiaogang/XG_Notes
//

#import <Foundation/Foundation.h>
#import "XGUtils.h"
#define KEY_ARTICLEDRAFTLOCALIMG_TMCACHE(createTime,imgIndex) [NSString stringWithFormat:@"ArticleDraftLocalImg_%@_%@",createTime,imgIndex]
@interface XGHtmlParser : NSObject

+(void) convertHtml:(NSString *)html withImgMaxSize:(CGSize)imgMaxSize withCreateTime:(NSString*)createTime withComplete:(Action_OnePram)completeBlock;

@end
