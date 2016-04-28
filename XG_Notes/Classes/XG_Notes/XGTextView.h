//
//  XGTextView.h
//  XG_Notes
//
//  Created by 贾  on 16/4/28.
//  Copyright © 2016年 XiaoGang. All rights reserved.
//  github: https://github.com/jiaxiaogang/XG_Notes
//

#import <UIKit/UIKit.h>

@protocol XGTextViewDelegate <NSObject>

//保存草稿
-(void) xgTextViewSaveDraftToLocalTMCache;

//开始编辑
-(void) xgTextViewBeginEditing;

//是否需要自动保存;
-(BOOL) xgTextViewNeedAutoSave;

@end

@interface XGTextView : UITextView

@property (assign, nonatomic) BOOL waitEndEditCheckRect;    //等待键盘落下后,检查光标位置
@property (weak, nonatomic) id<XGTextViewDelegate> xgTextDelegate;

-(id) initWithCoder:(NSCoder *)aDecoder;
-(void) initDisplay;
//一键自动排版
-(void) onekeyLayoutAllText;

/**
 *  MARK:--------------------插入图片--------------------
 */
-(void) addAttachmentWithImg:(UIImage*)img;

/**
 *  MARK:--------------------记录位置恢复--------------------
 */
- (void) recordPosYWithSelectedRange:(NSRange)range;

@end
