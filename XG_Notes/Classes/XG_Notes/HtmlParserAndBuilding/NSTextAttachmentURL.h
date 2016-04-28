//
//  NSTextAttachmentURL.h
//  Tanker
//
//  Created by 贾  on 15/8/7.
//  Copyright (c) 2015年 Tanker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSTextAttachmentURL : NSTextAttachment

-(id) init;
@property (strong,nonatomic) NSString *contentUrl;

@end
