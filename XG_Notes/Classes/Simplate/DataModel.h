//
//  DataModel.h
//  XG_Notes
//
//  Created by 贾  on 16/4/28.
//  Copyright © 2016年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataModel : NSObject

@property (strong,nonatomic) NSString *content;     //内容,存为html
@property (strong,nonatomic) NSString *createTime;  //创建时间,精度毫秒;
@property (strong,nonatomic) NSString *brief;       //简介,用于mainPageCell的显示

@end
