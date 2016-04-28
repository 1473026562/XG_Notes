//
//  XGHtmlParser.m
//  XG_Notes
//
//  Created by 贾  on 16/4/28.
//  Copyright © 2016年 XiaoGang. All rights reserved.
//  github: https://github.com/jiaxiaogang/XG_Notes
//

/**
 *  MARK:--------------------解析本地草稿为NSAttributed并返回给TextView等控件使用--------------------
 *  1:解析未同步草稿;
 *  2:解析已同步草稿;
 */
#import "XGHtmlParser.h"
#import "HTMLParser.h"
#import "TMDiskCache.h"
#import "SDImageCache.h"
#import "NSTextAttachmentURL.h"
#import "SDWebImageManager.h"
#import "XGUtils.h"

@implementation XGHtmlParser

/**
 *  MARK:--------------------解析本地html--------------------
 */
+(void) convertHtml:(NSString *)htmlBase withImgMaxSize:(CGSize)imgMaxSize withCreateTime:(NSString*)createTime withComplete:(Action_OnePram)completeBlock
{
    if (htmlBase == nil) {
        htmlBase = @"";
    }
    //1,添加<html><body></body></html>
    NSMutableString *html = [NSMutableString string];
    NSString *convertedSpaces = htmlBase;
    if(![htmlBase containsString:@"<html"] && ![htmlBase containsString:@"<body"]){
        [html appendFormat:@"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html40/strict.dtd\">\n<html>\n<head>\n<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />\n<meta http-equiv=\"Content-Style-Type\" content=\"text/css\" />\n<meta name=\"Generator\" content=\"HTMLWriteSimple\" />\n</head>\n<body>\n"];
        [html appendString:convertedSpaces];
        [html appendString:@"</body>\n</html>\n"];
    }else{
        [html appendString:convertedSpaces];
    }
    
    //2,解析
    NSError *error =nil;
    NSMutableAttributedString *mStr = [[NSMutableAttributedString alloc]init];
    HTMLParser *parser = [[HTMLParser alloc] initWithString:html error:&error];
    if(error){
        NSLog(@"解析错误:%@",error);
    }else{
        HTMLNode *bodyNode = [parser body];
        NSArray *pNodes = [bodyNode findChildTags:@"p"];
        for (NSInteger i = 0; i < pNodes.count; i++) {
            HTMLNode *pNode = [pNodes objectAtIndex:i];
            UIImage *pImg = nil;
            bool curPNodeHavImg = false;
            NSString *curImgSrc = nil;
            //在线图片
            NSArray *imgNodesSrc = [pNode findChildTags:@"img"];
            if([imgNodesSrc count]>0)
            {
                for (HTMLNode *imgNodeSrc in imgNodesSrc) {
                    curImgSrc = [imgNodeSrc getAttributeNamed:@"src"];
                    if (NSSTRINGISVALID(curImgSrc)) {
                        pImg = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:curImgSrc];
                        if(!pImg)
                        {
                            //                            NSURL *url = [NSURL URLWithString:curImgSrc];
                            //                            [[SDWebImageManager sharedManager]downloadWithURL:url options:0 progress:nil
                            //                                                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
                            //                             {
                            //                                 TKLog(@"下载完成");
                            //                             }];
                            
                            pImg = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:curImgSrc]]];
                            [[SDImageCache sharedImageCache] storeImage:pImg forKey:curImgSrc];
                        }
                        curPNodeHavImg = true;
                        break;
                    }
                }
            }
            else
            {
                //搜索本地图片
                NSArray *childArr = pNode.children;
                for (HTMLNode *imgNode in childArr)
                {
                    NSRange startRangeForImg = [imgNode.tagName rangeOfString:@"img"];
                    if(startRangeForImg.location!=NSNotFound)
                    {
                        NSString *imgIndex = [XGUtils subStringWithRangeAndCheckOut:NSMakeRange(3, imgNode.tagName.length-3) withOldStr:imgNode.tagName];
                        NSString *imgLocalKey = KEY_ARTICLEDRAFTLOCALIMG_TMCACHE(createTime, imgIndex);
                        pImg = [[TMDiskCache sharedCache] objectForKey:imgLocalKey];
                        curPNodeHavImg = true;
                        break;
                    }
                }
            }
            //搜图成功
            if(curPNodeHavImg)
            {
                if(pImg)
                {
                    NSTextAttachmentURL *att = [[NSTextAttachmentURL alloc] initWithData:nil ofType:nil];
                    CGFloat scale = [[UIScreen mainScreen] scale];
                    
                    CGFloat width = pImg.size.width;
                    CGFloat height = pImg.size.height;
                    if (pImg.size.width > imgMaxSize.width*scale)
                    {
                        width = imgMaxSize.width*scale;
                        height = pImg.size.height/pImg.size.width*width;
                    }
                    
                    CGSize size = CGSizeMake(width, height);
                    UIImage *thumbimg=[XGUtils imageByScalingToSize:size withOldImg:pImg];
                    UIGraphicsBeginImageContext(size);
                    CGRect rect = CGRectMake(0, 0, size.width, size.height);
                    [thumbimg drawInRect:rect];
                    
                    thumbimg = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    att.image = thumbimg;
                    att.bounds = CGRectMake((imgMaxSize.width-(thumbimg.size.width/scale))/2, 0, thumbimg.size.width/scale, thumbimg.size.height/scale);
                    if(curImgSrc!=nil)
                    {
                        [att setContentUrl:curImgSrc];
                    }
                    NSAttributedString* imgAttachment = [NSAttributedString attributedStringWithAttachment:att] ;
                    if(i == 0)
                    {
                        [mStr appendAttributedString:[[NSAttributedString alloc]initWithString:@"\n"]];
                    }
                    [mStr appendAttributedString:imgAttachment];
                    if(i != pNodes.count-1)
                    {
                        [mStr appendAttributedString:[[NSAttributedString alloc]initWithString:@"\n"]];
                    }
                }
            }
            //搜图未成功
            else
            {
                NSString *text = [pNode contents];
                if(NSSTRINGISVALID(text))
                {
                    [mStr appendAttributedString:[[NSAttributedString alloc]initWithString:text]];
                }
                if(i != pNodes.count-1)
                {
                    [mStr appendAttributedString:[[NSAttributedString alloc]initWithString:@"\n"]];
                }
            }
        }
    }
    if(completeBlock)
    {
        completeBlock(mStr);
        completeBlock = nil;
    }
}








@end
