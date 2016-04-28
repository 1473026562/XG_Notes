//
//  UIImageView+MJWebCache.m
//  FingerNews
//
//  Created by mj on 13-10-2.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "UIImageView+MJWebCache.h"

@implementation UIImageView (MJWebCache)
- (void)setImageWithURLStr:(NSString*)urlStr{
    [self setImageURLStr:urlStr placeholder:nil];
}

- (void)setImageURL:(NSURL *)url placeholder:(UIImage *)placeholder
{
    [self setImageWithURL:url placeholderImage:placeholder options:SDWebImageRetryFailed | SDWebImageLowPriority];
}

- (void)setImageURLStr:(NSString *)urlStr placeholder:(UIImage *)placeholder
{
    [self setImageURL:[NSURL URLWithString:urlStr] placeholder:placeholder];
}

- (void)setImageURLStr:(NSString *)urlStr placeholderByLocalImgName:(NSString *)imgName
{
    [self setImageURL:[NSURL URLWithString:urlStr] placeholder:[UIImage imageNamed:imgName]];
}
@end
