//
//  XGHtmlBuilder.m
//  XG_Notes
//
//  Created by 贾  on 16/4/28.
//  Copyright © 2016年 XiaoGang. All rights reserved.
//  github: https://github.com/jiaxiaogang/XG_Notes
//

#import "XGHtmlBuilder.h"
#import "NSTextAttachmentURL.h"
#import "XGUtils.h"

@implementation XGHtmlBuilder
{
    NSAttributedString *_attributedString;
    NSString *_HTMLString;
    NSMutableArray *imgAttachmentArr; //图片数组
}

- (id)initWithAttributedString:(NSAttributedString *)attributedString
{
    self = [super init];
    if (self)
    {
        _attributedString = attributedString;
    }
    return self;
}
/**
 *  MARK:转换attributedString为HTML;
 */
- (void)_buildOutput
{
    NSString *allString = [_attributedString string];
    allString = [allString stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
    NSArray *paragraphs = [allString componentsSeparatedByString:@"\n"];
    NSMutableString *retString = [NSMutableString string];
    NSInteger location = 0;
    int imgNum=0;
    NSTextAttachmentURL *findAtt;
    BOOL lastTwoParagraphIsImg = false;
    BOOL firstParagraphIsNilText = false;
    //遍历段落
    for (NSUInteger i=0; i<[paragraphs count]; i++)
    {
        NSString *oneParagraph = [paragraphs objectAtIndex:i];
        NSRange paragraphRange = NSMakeRange(location, [oneParagraph length]);
        findAtt = [self getAttachmentUrlAtParagraph:paragraphRange];
        if(findAtt)
        {
            //text---2:第一段如果为空;第二段如果为图,则去段第一段;
            if(i == 1 && firstParagraphIsNilText)
            {
                retString = [NSMutableString string];
                firstParagraphIsNilText = false;
            }
            if(NSSTRINGISVALID(findAtt.contentUrl))
            {
                [retString appendFormat:@"<p><img src=\"%@\"></p>",findAtt.contentUrl];
            }
            else
            {
                [retString appendFormat:@"<p><img%d></p>",imgNum];
                if(imgAttachmentArr==nil) imgAttachmentArr = [[NSMutableArray alloc]init];
                [imgAttachmentArr addObject:findAtt];
                imgNum++;
            }
            
            //img---1:倒数第二段为图片;则去掉最后一段(如果是空)
            if(i == paragraphs.count - 2)
            {
                lastTwoParagraphIsImg = true;
            }
        }
        else
        {
            //text---1:第一段如果为空;第二段如果为图,则去段第一段;
            if(i == 0 && paragraphRange.length == 0)
            {
                firstParagraphIsNilText = true;
            }
            //img---2:倒数第二段为图片;则去掉最后一段(如果是空)
            if(i == paragraphs.count - 1 && lastTwoParagraphIsImg && paragraphRange.length == 0)
            {
                lastTwoParagraphIsImg = false;
            }
            else
            {
                [retString appendFormat:@"<p>%@</p>",[allString substringWithRange:paragraphRange]];
            }
        }
        findAtt = nil;
        //开始下段
        location = location + paragraphRange.length + 1;
    }
    //转换html空格等;
    NSMutableString *output = [NSMutableString string];
    NSString *convertedSpaces = retString;
    [output appendString:convertedSpaces];
    _HTMLString = output;
    if(imgNum!=imgAttachmentArr.count)
    {
        NSLog(@"警告:图片数量不符!!!数:%d,图:%lu",imgNum,(unsigned long)imgAttachmentArr.count);
    }
}

#pragma mark - Public

- (NSString *)HTMLString
{
    if (!_HTMLString)
    {
        imgAttachmentArr = nil;
        [self _buildOutput];
    }
    return _HTMLString;
}
-(NSMutableArray*) imgAttachmentArr
{
    return imgAttachmentArr;
}
-(NSMutableArray*) imgDataArr
{
    NSMutableArray *tempArr = nil;
    if(imgAttachmentArr != nil)
    {
        tempArr = [[NSMutableArray alloc]init];
        for (int i = 0; i < imgAttachmentArr.count; i++) {
            NSObject *itemObj = imgAttachmentArr[i];
            if([itemObj isKindOfClass:[NSTextAttachmentURL class]]){
                NSTextAttachmentURL *itemAtt = (NSTextAttachmentURL*)itemObj;
                NSData *data = UIImageJPEGRepresentation(itemAtt.image, 1.0);
                [tempArr addObject:data];
            }
        }
    }
    return tempArr;
}
//当前段落是否图片段落;
-(UIImage*) getImgParagraph:(NSRange)paraRange
{
    NSRange realRange = NSIntersectionRange(paraRange, NSMakeRange(0, self.attributedString.length));
    NSAttributedString *curAStr;
    NSTextAttachmentURL *att;
    for (NSInteger i = realRange.location; i<realRange.location + realRange.length; i++)
    {
        curAStr = [self getRightWordWithIndex:(int)i];
        att = [self getAttachmentWithAStr:curAStr];
        if(att!=nil)
        {
            if(att.image!=nil)
            {
                if(NSSTRINGISVALID(att.contentUrl))
                {
                    return nil;
                }
                return att.image;
            }
            att = nil;
        }
        curAStr = nil;
    }
    return nil;
}
//当前段落是否附件段落;
-(NSTextAttachmentURL*) getAttachmentUrlAtParagraph:(NSRange)paraRange
{
    NSRange realRange = NSIntersectionRange(paraRange, NSMakeRange(0, self.attributedString.length));
    NSAttributedString *curAStr;
    NSTextAttachmentURL *att;
    for (NSInteger i = realRange.location; i<realRange.location + realRange.length; i++)
    {
        curAStr = [self getRightWordWithIndex:(int)i];
        att = [self getAttachmentWithAStr:curAStr];
        if(att!=nil)
        {
            return att;
        }
        curAStr = nil;
    }
    return nil;
}
//取index右边字符
-(NSAttributedString*) getRightWordWithIndex:(int)index
{
    if([self rightHavWordWithIndex:index])
    {
        NSRange wordRange = {index,1};
        return [self.attributedString attributedSubstringFromRange:wordRange];
    }
    return nil;
}
//判断字符串是NSAttachment
-(NSTextAttachmentURL*) getAttachmentWithAStr:(NSAttributedString*)aStr
{
    if(aStr!=nil)
    {
        return [aStr attribute:@"NSAttachment" atIndex:0 effectiveRange:nil];
    }
    return nil;
}
//判断index右边有没有字符
-(BOOL) rightHavWordWithIndex:(int)index
{
    return index < self.attributedString.length;
}

@synthesize attributedString = _attributedString;

/**
 *  MARK:--------------------获取所有图片大小--------------------
 */
- (NSInteger)getAllImgDataSize
{
    NSString *allString = [_attributedString string];
    NSArray *paragraphs = [allString componentsSeparatedByString:@"\n"];
    NSInteger sumSize = 0;
    NSInteger location = 0;
    NSTextAttachmentURL *findAtt;
    //遍历段落
    for (NSUInteger i=0; i<[paragraphs count]; i++)
    {
        NSString *oneParagraph = [paragraphs objectAtIndex:i];
        NSRange paragraphRange = NSMakeRange(location, [oneParagraph length]);
        findAtt = [self getAttachmentUrlAtParagraph:paragraphRange];
        if(findAtt)
        {
            if(findAtt.image){
                NSData *findImgData = UIImageJPEGRepresentation(findAtt.image, 1.0);
                sumSize += findImgData.length;
            }
        }
        findAtt = nil;
        location = location + paragraphRange.length + 1;
    }
    return sumSize;
}

/**
 *  MARK:--------------------获取所有图片NSTextAttanchmentURL--------------------
 */
- (NSMutableArray*)getAllImgAttachment
{
    NSMutableArray *allAttachment = nil;
    NSString *allString = [_attributedString string];
    NSArray *paragraphs = [allString componentsSeparatedByString:@"\n"];
    NSInteger location = 0;
    NSTextAttachmentURL *findAtt;
    //遍历段落
    for (NSUInteger i=0; i<[paragraphs count]; i++)
    {
        NSString *oneParagraph = [paragraphs objectAtIndex:i];
        NSRange paragraphRange = NSMakeRange(location, [oneParagraph length]);
        findAtt = [self getAttachmentUrlAtParagraph:paragraphRange];
        if(findAtt != nil){
            if(allAttachment == nil){
                allAttachment = [[NSMutableArray alloc]init];
            }
            [allAttachment addObject:findAtt];
        }
        findAtt = nil;
        location = location + paragraphRange.length + 1;
    }
    return allAttachment;
}

/**
 *  MARK:--------------------获取所有未同步图片NSTextAttanchmentURL--------------------
 */
- (NSMutableArray*)getAllImgAttachmentNotSync
{
    NSMutableArray *allAttachmentNotSync = nil;
    NSMutableArray *allAttachment = [self getAllImgAttachment];
    if(allAttachment != nil){
        for (int i = 0; i < allAttachment.count; i++) {
            NSTextAttachmentURL *findAtt = (NSTextAttachmentURL*)allAttachment[i];
            if(NSSTRINGISVALID(findAtt.contentUrl))
            {
                if(allAttachmentNotSync == nil){
                    allAttachmentNotSync = [[NSMutableArray alloc]init];
                }
                [allAttachmentNotSync addObject:findAtt];
            }
        }
    }
    return allAttachmentNotSync;
}

@end
