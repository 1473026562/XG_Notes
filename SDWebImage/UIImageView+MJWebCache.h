//
//  UIImageView+MJWebCache.h
//  FingerNews
//
//  Created by mj on 13-10-2.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "UIImageView+WebCache.h"

@interface UIImageView (MJWebCache)
//J
- (void)setImageWithURLStr:(NSString*)urlStr;
- (void)setImageURLStr:(NSString *)urlStr placeholder:(UIImage *)placeholder;
- (void)setImageURLStr:(NSString *)urlStr placeholderByLocalImgName:(NSString *)imgName;
//J
- (void)setImageURL:(NSURL *)url placeholder:(UIImage *)placeholder;
@end