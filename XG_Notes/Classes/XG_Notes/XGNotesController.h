//
//  XG_NotesController.h
//  XG_Notes
//
//  Created by 贾  on 16/4/28.
//  Copyright © 2016年 XiaoGang. All rights reserved.
//  github: https://github.com/jiaxiaogang/XG_Notes
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreText/CoreText.h>

@class XGNotesDataModel;
@interface XGNotesController : UIViewController

@property (nonatomic) NSString *articleId;

-(id) initWithMDDraft:(XGNotesDataModel*)md;

@end
