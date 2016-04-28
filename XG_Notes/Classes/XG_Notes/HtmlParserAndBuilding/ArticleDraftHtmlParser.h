//
//  HtmlParserAndBuilding.h
//  Tanker
//
//  Created by 贾  on 15/8/5.
//  Copyright (c) 2015年 Tanker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XGUtils.h"
#define KEY_ARTICLEDRAFTLOCALIMG_TMCACHE(createTime,imgIndex) [NSString stringWithFormat:@"ArticleDraftLocalImg_%@_%@",createTime,imgIndex]
@interface ArticleDraftHtmlParser : NSObject

+(void) convertHtml:(NSString *)html withImgMaxSize:(CGSize)imgMaxSize withCreateTime:(NSString*)createTime withComplete:(Action_OnePram)completeBlock;

@end
