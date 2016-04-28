//
//  MyWriteUtils.m
//  Tanker
//
//  Created by 贾  on 15/12/9.
//  Copyright © 2015年 Tanker. All rights reserved.
//

#import "MyWriteUtils.h"
#import "NSTextAttachmentURL.h"

@implementation MyWriteUtils

/**
 *  MARK:--------------------提取NSTextAttachmentURL数组中的图片数组--------------------
 */
+(NSMutableArray*) convertAttachmentURLArr2ImgArr:(NSMutableArray*)attachmentURLArr{
    NSMutableArray *imgArr = [[NSMutableArray alloc]init];
    if(attachmentURLArr!= nil){
        for (int i = 0; i< attachmentURLArr.count; i++) {
            NSObject *itemObj = attachmentURLArr[i];
            if([itemObj isKindOfClass:[NSTextAttachmentURL class]]){
                NSTextAttachmentURL *itemAtt = (NSTextAttachmentURL*)itemObj;
                [imgArr addObject:itemAtt.image];
            }
        }
    }
    return imgArr;
}




@end
