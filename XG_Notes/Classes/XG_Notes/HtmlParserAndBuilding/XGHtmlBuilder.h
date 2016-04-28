//
//  XGHtmlBuilder.h
//  XG_Notes
//
//  Created by 贾  on 16/4/28.
//  Copyright © 2016年 XiaoGang. All rights reserved.
//  github: https://github.com/jiaxiaogang/XG_Notes
//

#import <Foundation/Foundation.h>

@interface XGHtmlBuilder : NSObject

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