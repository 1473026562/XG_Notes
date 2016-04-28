//
//  DTHTMLWriter_Simple.h
//  Tanker
//
//  Created by 贾  on 15/8/1.
//  Copyright (c) 2015年 Tanker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTHTMLWriter_Simple : NSObject

- (id)initWithAttributedString:(NSAttributedString *)attributedString;
- (NSString *)HTMLString;
//发送时生成的图片nsdata
-(NSMutableArray*) imgDataArr;
//未处理过的原图imgAttachment
-(NSMutableArray*) imgAttachmentArr;

@property (nonatomic, readonly) NSAttributedString *attributedString;
//计算图片数据大小
- (NSInteger)getAllImgDataSize;
@end
