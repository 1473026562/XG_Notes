//
//  XGTextView.m
//  XG_Notes
//
//  Created by 贾  on 16/4/28.
//  Copyright © 2016年 XiaoGang. All rights reserved.
//  github: https://github.com/jiaxiaogang/XG_Notes
//

#import "XGTextView.h"
#import "XGUtils.h"
#import "NSTextAttachmentURL.h"

#define kFirstLineHeadIndent 10.9

@interface XGTextView () <UITextViewDelegate>

@property (strong,nonatomic) NSMutableParagraphStyle *wordStyle;
@property (strong,nonatomic) NSMutableParagraphStyle *imgStyle;
@property (assign, nonatomic) BOOL lastInputFromKeyBoardForZnHansWithLetters;   //上次输入来源:键盘中文是否
@property (assign, nonatomic) NSRange recordRange;          //记录光标位置;(使用一次清理一次,只用于临时备忘)
@property (assign, nonatomic) CGRect recordRect;

@property (assign, nonatomic) BOOL lastInputFromPastedPad;                      //上次输入来源:粘贴板

@property (assign, nonatomic) int checkToAutoSaveTime;              //自动保存计数器

@end
@implementation XGTextView


-(id) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initView];
    }
    return self;
}


-(void) initView{
    
}

-(void) initDisplay{
    
    self.wordStyle = [self getDefaultStyle];
    self.imgStyle = [self getDefaultStyle];
    [self.imgStyle setFirstLineHeadIndent:11];
    
    self.alwaysBounceVertical = YES;
    self.delegate=self;
    [self setFont:[XGUtils defaultFontOfSize:18]];
    [self setTextColor:[UIColor redColor]];
    [self setContentInset:UIEdgeInsetsMake(0, 0, 15, 0)];
}

/**
 *  MARK:--------------------插入图片--------------------
 */
-(void) addAttachmentWithImg:(UIImage*)img{
    if (img == nil || ![img isKindOfClass:[UIImage class]]) {
        return;
    }
    //1,绘制尺寸
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat oriWidth = img.size.width;
    CGFloat oriHeight = img.size.height;
    CGFloat drawWidth = oriWidth;
    CGFloat drawHeight = oriHeight;
    if(oriWidth > (self.frame.size.width -32)*scale)
    {
        drawWidth = (self.frame.size.width - 32) * scale;
        drawHeight = oriHeight / oriWidth * drawWidth;
    }
    
    //5.显示创建图片附件
    NSTextAttachmentURL *att = [[NSTextAttachmentURL alloc] init];
    att.image = img;
    att.bounds = CGRectMake(self.frame.size.width - (drawWidth / scale) / 2, 0, drawWidth / scale, drawHeight / scale);
    NSAttributedString *imgAtt = [NSAttributedString attributedStringWithAttachment:att];
    NSMutableAttributedString *imgMAtt = [self getImgStyleWithString:imgAtt];
    
    NSAttributedString *oldAStr = self.attributedText;
    NSMutableAttributedString *newAtt = [[NSMutableAttributedString alloc] initWithAttributedString:oldAStr];
    
    //6.图前图后换行符
    NSRange cursorRange = self.selectedRange;
    [newAtt replaceCharactersInRange:cursorRange withAttributedString:[self getWordStyleWithString:@"\n\n"]];
    [newAtt insertAttributedString:imgMAtt atIndex:cursorRange.location+1];
    
    //7.恢复光标显示
    self.attributedText = newAtt;
    cursorRange.location+=imgAtt.length+2;
    cursorRange.length=0;
    [self setSelectedRange:cursorRange];
    [self scrollRangeToVisible:cursorRange];//光标定位到图片低部
}

/**
 *  MARK:-----------------------------段落样式----------------------------------
 */
//设置attachment的NSAttributedString为图片的段落样式;
-(NSMutableAttributedString*) getImgStyleWithString:(NSAttributedString*)imgAtt{
    NSMutableAttributedString *mStr = [[NSMutableAttributedString alloc]initWithAttributedString:imgAtt];
    NSRange range = {0,imgAtt.length};
    [mStr addAttribute:NSParagraphStyleAttributeName value:self.imgStyle range:range];
    return mStr;
}
//默认样式
-(NSMutableParagraphStyle*) getDefaultStyle{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
    style.headIndent = 10;
    style.tailIndent = -10;
    style.paragraphSpacing = 15;
    style.firstLineHeadIndent = kFirstLineHeadIndent;
    style.minimumLineHeight = 24;
    return style;
}

//设置某段文字为文字样式;
-(NSAttributedString*) getWordStyleWithString:(NSString*)str{
    NSMutableAttributedString *mStr = [[NSMutableAttributedString alloc]initWithString:str];
    return [self refreshMStrFontStyleWithMStr:mStr];
}
//设置某段富文本为文字样式;
-(NSAttributedString*) refreshMStrFontStyleWithMStr:(NSMutableAttributedString*)mStr{
    NSRange range = {0,mStr.length};
    [mStr addAttribute:NSParagraphStyleAttributeName value:self.wordStyle range:range];
    [mStr addAttribute:NSFontAttributeName value:[XGUtils defaultFontOfSize:18] range:range];
    [mStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
    return mStr;
}



/**
 *  MARK:--------------------排版--------------------
 */
//恢复排版某区间
-(void) resetLayoutWithRange:(NSRange)range
{
    NSRange realRange = NSIntersectionRange(range, NSMakeRange(0, self.attributedText.length));
    NSMutableAttributedString *allStr = [[NSMutableAttributedString alloc]initWithAttributedString:self.attributedText];
    
    [allStr addAttribute:NSParagraphStyleAttributeName value:self.wordStyle range:realRange];
    [self refreshMStrFontStyleWithMStr:allStr];
    
    NSAttributedString *curAStr;
    for (NSInteger i = realRange.location; i<realRange.location + realRange.length; i++)
    {
        curAStr = [self getRightWordWithIndex:(int)i];
        if([self isAttachmentWithAStr:curAStr])
        {
            [allStr addAttribute:NSParagraphStyleAttributeName value:self.imgStyle range:NSMakeRange(i, 1)];
        }
        curAStr = nil;
    }
    self.attributedText = allStr;
    [self setSelectedRange:NSMakeRange(realRange.location+realRange.length, 0)];
}

//一键自动排版
-(void) onekeyLayoutAllText
{
    [self resetLayoutWithRange:NSMakeRange(0, self.attributedText.length)];
    [self setFont:[XGUtils defaultFontOfSize:18]];
    [self setTextColor:[UIColor redColor]];
    //[self.textView resignFirstResponder];
}

//恢复排版当前index所在段落
-(void) resetLayoutWithIndex:(int)index
{
    int maxIndex = (int)self.attributedText.length;
    int startIndex=0;
    int endIndex = maxIndex;
    for (int i=index; i>-1; i--) {
        if([self isEnterKeyWithIndex:i])
        {
            startIndex = i;
            break;
        }
    }
    for (int i=index; i<maxIndex; i++) {
        if([self isEnterKeyWithIndex:i])
        {
            endIndex = i;
            break;
        }
    }
    NSRange range = self.selectedRange;
    
    NSMutableAttributedString *allStr = [[NSMutableAttributedString alloc]initWithAttributedString:self.attributedText];
    [allStr addAttribute:NSParagraphStyleAttributeName value:self.wordStyle range:NSMakeRange(startIndex, endIndex-startIndex)];
    self.attributedText = allStr;
    
    if(self.lastInputFromKeyBoardForZnHansWithLetters)
    {
        [self setSelectedRange:NSMakeRange(range.location-1, 1)];
        self.lastInputFromKeyBoardForZnHansWithLetters=false;
    }
    else
    {
        [self setSelectedRange:NSMakeRange(range.location, 0)];
    }
    range = self.selectedRange;
    [self scrollRangeToVisible:NSMakeRange(range.location+range.length, 0)];//光标定位解决图片后输入回到顶部的问题
}




/**
 *  MARK:--------------------字符串格式处理辅助方法--------------------
 */
//判断字符串是NSAttachment
-(BOOL) isAttachmentWithAStr:(NSAttributedString*)aStr
{
    if(aStr!=nil)
    {
        return ([aStr attribute:@"NSAttachment" atIndex:0 effectiveRange:nil] != nil);
    }
    return NO;
}
//判断index字符是否换行符
-(BOOL) isEnterKeyWithIndex:(int)index
{
    NSAttributedString *str = [self getRightWordWithIndex:index];
    if(str!=nil)
    {
        if([str.string isEqualToString:@"\n"])
        {
            return true;
        }
    }
    return false;
}
//获得Style
-(NSParagraphStyle*) getStyleWithAStr:(NSAttributedString*)aStr
{
    if(aStr !=nil)
    {
        return [aStr attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:nil];
    }
    return nil;
}
//判断index右边有没有字符
-(BOOL) rightHavWordWithIndex:(int)index
{
    return index < self.attributedText.length;
}
//判断index左边有没有字符
-(BOOL) leftHavWordWithIndex:(int)index
{
    return index>0 && self.attributedText.length >= index;
}
//取index左边字符
-(NSAttributedString*) getLeftWordWithIndex:(int)index
{
    if([self leftHavWordWithIndex:index])
    {
        NSRange wordRange = {index-1,1};
        return [self.attributedText attributedSubstringFromRange:wordRange];
    }
    return nil;
}
//取index右边字符
-(NSAttributedString*) getRightWordWithIndex:(int)index
{
    if([self rightHavWordWithIndex:index])
    {
        NSRange wordRange = {index,1};
        return [self.attributedText attributedSubstringFromRange:wordRange];
    }
    return nil;
}

/**
 *  MARK:--------------------用于插入图片,收降键盘,一键排版,粘贴文本时,将textView显示到合适位置--------------------
 */
- (void) recordPosYWithSelectedRange:(NSRange)range{
    self.recordRange = range;
    [self recordPosYWithSelectedTextRange:[self convertTextRangeFromRange:range]];
}

- (void) recordPosYWithSelectedTextRange:(UITextRange*)range{
    self.recordRect = [self caretRectForPosition:range.start];
}

//光标位置转光标坐标
-(UITextRange*) convertTextRangeFromRange:(NSRange) range{
    UITextPosition *beginning = self.beginningOfDocument;
    UITextPosition *start = [self positionFromPosition:beginning offset:range.location];
    UITextPosition *end = [self positionFromPosition:start offset:range.length];
    UITextRange *textRange = [self textRangeFromPosition:start toPosition:end];
    return textRange;
}

//退出键盘载入草稿时恢复坐标;
-(void) checkPosYByRange{
    if(self.recordRange.location>0){
        [self scrollRangeToVisible:self.recordRange];
        self.recordRange = NSMakeRange(0, 0);
    }
}

//输入时,改变光标时恢复坐标;
- (void) checkPosYByRect{
    if(self.recordRect.origin.y>0||self.recordRect.size.width>0){
        CGFloat overflow = self.recordRect.origin.y + self.recordRect.size.height- (self.contentOffset.y + self.bounds.size.height- self.contentInset.bottom - self.contentInset.top );
        if ( overflow > 0 ) {
            CGPoint offset = self.contentOffset;
            offset.y += overflow + 7;
            [UIView animateWithDuration:0.3 animations:^{
                [self setContentOffset:offset];
            }];
        }
    }
    self.recordRect = CGRectZero;
}


/**
 *  MARK:-----------------------ScrollViewDelegate---------------------------
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if([self isFirstResponder]){
        [self recordPosYWithSelectedRange:self.selectedRange];
        [self resignFirstResponder];
    }
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{}
/**
 *  MARK:--------------------TextViewDelegate--------------------
 *  1:shouldChange
 *      a,text.length == 0 (删除)
 *      b,text.length == 1 (键盘输入)
 *      c,text.length >  10 (粘贴板输入)
 *
 *  2:didChange
 *      a,内容改变时,检测是否在输入时:标记了需要重布局首行缩进;
 *
 *  3:didChangeSelection
 *      a,改变光标后，禁止光标选择到图片，左侧或右侧；
 *          -如果光标location为图片左侧;则将光标移至图片左侧的\n前;
 *          -如果光标location为图片右侧;则将光标移至图片右侧的\n后;
 *          -如果图片左侧或右侧缺失\n，则补齐；
 */
-(void)textViewDidBeginEditing:(UITextView *)textView{
    if (self.xgTextDelegate && [self.xgTextDelegate respondsToSelector:@selector(xgTextViewBeginEditing)]) {
        [self.xgTextDelegate xgTextViewBeginEditing];
    }
    
    [self recordPosYWithSelectedRange:self.selectedRange];
    [self checkPosYByRange];
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    if(self.waitEndEditCheckRect){
        [self checkPosYByRange];
        self.waitEndEditCheckRect = false;
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    //回退键时:删的是\n并且再左边是图片,则删图留\n;
    NSAttributedString *leftWord = [self getLeftWordWithIndex:(int)range.location];
    if(text.length==0){
        NSAttributedString *rightWord = [self getRightWordWithIndex:(int)range.location];
        
        if([rightWord.string isEqualToString:@"\n"]){
            if([self isAttachmentWithAStr:leftWord]){
                if(range.length>1){
                    NSLog(@"删除了选区中的N个文字,除了最左的换行符(但因为已经禁用了图片右边的选择，所以这里一般不会进来；如果进来了，检查禁用图片左右的逻辑；");
                    textView.selectedRange = NSMakeRange(range.location + 1, range.length - 1);
                }else if(range.length==1){
                    NSLog(@"删图片留下换行符;");
                    textView.selectedRange = NSMakeRange(range.location - 1, 1);
                }else{
                    NSLog(@"BUG,检查range长度");
                }
            }
        }
    }
    else if(text.length==1){
        int word = (int)[text characterAtIndex:0];
        if((word>64&&word<91)||(word>96&&word<123)){
            if ([[textView.textInputMode primaryLanguage] isEqualToString:@"zh-Hans"]){
                self.lastInputFromKeyBoardForZnHansWithLetters = true;
            }
        }else{
            self.lastInputFromKeyBoardForZnHansWithLetters = false;
        }
    }
    else if(text.length>10){
        self.lastInputFromPastedPad = true;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSRange curRange = textView.selectedRange;
    [self recordPosYWithSelectedRange:curRange];
    [self recordPosYWithSelectedTextRange:self.selectedTextRange];
    //格式检查
    NSAttributedString *curStr = [self getLeftWordWithIndex:(int)curRange.location];
    NSParagraphStyle *style = [self getStyleWithAStr:curStr];
    if(style)
    {
        if(style.firstLineHeadIndent<kFirstLineHeadIndent-1)
        {
            [self resetLayoutWithIndex:(int)self.selectedRange.location-1];//此处toolBarlocation在后面,而普通输入在前面;
        }
    }
    //粘贴操作
    if(self.lastInputFromPastedPad)
    {
        [self onekeyLayoutAllText];
        self.lastInputFromPastedPad = false;
        [self resignFirstResponder];
        self.waitEndEditCheckRect = true;
    }
    //每输入键盘40次;自动保存;
    if (self.xgTextDelegate && [self.xgTextDelegate respondsToSelector:@selector(xgTextViewNeedAutoSave)]) {
        self.checkToAutoSaveTime++;
        if(self.checkToAutoSaveTime>30)
        {
            self.checkToAutoSaveTime = 0;
            if (self.xgTextDelegate && [self.xgTextDelegate respondsToSelector:@selector(xgTextViewSaveDraftToLocalTMCache)]) {
                [self.xgTextDelegate xgTextViewSaveDraftToLocalTMCache];
            }
        }
    }
    //光标位置
    if(!self.waitEndEditCheckRect)
    {
        [self checkPosYByRect];
    }
}

-(void) textViewDidChangeSelection:(UITextView *)textView
{
    NSRange curRange = textView.selectedRange;
    NSAttributedString *leftStr = [self getLeftWordWithIndex:(int)curRange.location];
    NSAttributedString *rightStr = [self getRightWordWithIndex:(int)curRange.location];
    //1,左测是图片
    if([self isAttachmentWithAStr:leftStr])
    {
        if(![rightStr.string isEqualToString:@"\n"])
        {
            NSMutableAttributedString *mStr = [[NSMutableAttributedString alloc]initWithAttributedString:textView.attributedText];
            [mStr insertAttributedString:[[NSAttributedString alloc] initWithString:@"\n"] atIndex:curRange.location];
            [textView setAttributedText:mStr];
        }
        NSRange changeRange = {curRange.location+1,curRange.length<1?0:curRange.length-1};
        [textView setSelectedRange:changeRange];
    }
    //2,右侧是图片
    if([self isAttachmentWithAStr:rightStr])
    {
        if(![leftStr.string isEqualToString:@"\n"])
        {
            NSMutableAttributedString *mStr = [[NSMutableAttributedString alloc]initWithAttributedString:textView.attributedText];
            [mStr insertAttributedString:[[NSAttributedString alloc] initWithString:@"\n"] atIndex:curRange.location];
            [textView setAttributedText:mStr];
        }
        else
        {
            NSRange changeRange = {curRange.location+1,curRange.length==0?0:curRange.length+1};
            [textView setSelectedRange:changeRange];
        }
    }
}

-(void) setSelectedRange:(NSRange)selectedRange{
    if (self.text.length >= selectedRange.location + selectedRange.length) {
        [super setSelectedRange:selectedRange];
    }
}

@end






