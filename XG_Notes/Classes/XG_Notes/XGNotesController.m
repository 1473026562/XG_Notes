//
//  XG_NotesController.m
//  XG_Notes
//
//  Created by 贾  on 16/4/28.
//  Copyright © 2016年 XiaoGang. All rights reserved.
//  github: https://github.com/jiaxiaogang/XG_Notes
//

#import "XGNotesController.h"
#import "XGUtils.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "XGHtmlBuilder.h"
#import "XGNotesStore.h"
#import "XGHtmlParser.h"
#import "XGNotesDataModel.h"
#import "MBProgressHUD+Add.h"
#import "NSTextAttachmentURL.h"
#import "SDWebImageCompat.h"
#import "XGTextView.h"

#define kTipToMyArticles 101

@interface XGNotesController () < UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIScrollViewDelegate,UIAlertViewDelegate,XGTextViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tvBottomSpaConstraints;
@property (weak, nonatomic) IBOutlet XGTextView *textView;
@property (nonatomic, strong) UIBarButtonItem *saveBtn;
@property (nonatomic, strong) UIBarButtonItem *addImgBtn;
@property (strong,nonatomic) NSMutableArray *imgAttachmentArr;
@property (strong,nonatomic) XGNotesDataModel *draftData;    //草稿数据模型;每次编辑或新建草稿都有一个模型实例;
@property (assign, nonatomic) BOOL isNewDraft;                      //新文章
//当次提交需要response中使用的数据;
@property (assign, nonatomic) BOOL isLoaded;
@property (strong,nonatomic) XGNotesStore *draftStore;

@end

@implementation XGNotesController

-(id) initWithMDDraft:(XGNotesDataModel*)md{
    self = [super init];
    if(self){
        [self initWithData:md];
    }
    return self;
}

-(id) init{
    self = [super init];
    if(self){
        [self initWithData:nil];
    }
    return self;
}
/**
 *  MARK:--------------------所有init入口--------------------
 */
-(void) initWithData:(XGNotesDataModel *)draftData{
    self.draftStore = [[XGNotesStore alloc]init];
    //1,草稿数据
    if(draftData==nil || ![draftData isKindOfClass:[XGNotesDataModel class]]){
        _draftData = [[XGNotesDataModel alloc]init];
        _draftData.addTime = [NSString stringWithFormat:@"%lld",[XGUtils systemNowTimeSecondPlusThreeZero]];
        self.isNewDraft = true;
    }else{
        _draftData = draftData;
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self initData];
    [self setupNavBar];
    [self setupTextView];
}

-(void) initData{
}

- (void)setupTextView{
    self.isLoaded = false;
    [self.textView initDisplay];
    self.textView.xgTextDelegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    if(!self.isNewDraft){
        if(!self.isLoaded){
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_main_sync_safe(^{
                [XGHtmlParser convertHtml:self.draftData.articleContent
                                     withImgMaxSize:CGSizeMake(ScreenWidth - 32, MAXFLOAT)
                                     withCreateTime:self.draftData.addTime
                                       withComplete:^(NSMutableAttributedString* mStr) {
                                           [self.textView setAttributedText:mStr];
                                           [self.textView onekeyLayoutAllText];
                                           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                               [self.textView becomeFirstResponder];
                                           });
                                           self.isLoaded = true;
                                           [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                       }];
            });
        });
    }else{
    }
}

/**
 *  MARK:-----------------------------Navi----------------------------------
 */
- (void)setupNavBar{
    self.saveBtn = [[UIBarButtonItem alloc] initWithTitle:@"保存草稿" style:UIBarButtonItemStyleDone target:self action:@selector(saveBtnOnClick)];
    [self.saveBtn setTintColor:[UIColor blackColor]];
    
    self.addImgBtn = [[UIBarButtonItem alloc] initWithTitle:@"插入图片" style:UIBarButtonItemStyleDone target:self action:@selector(addImgBtnOnClick)];
    [self.addImgBtn setTintColor:[UIColor blackColor]];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.addImgBtn,self.saveBtn , nil];
}

-(void) goBack{
    if (self.textView.text.length > 0) {
        [self saveDraftToLocalTMCache];
    }
    [self.navigationController popViewControllerAnimated:YES];
}



/**
 *  MARK:--------------------保存流程--------------------
 */
-(BOOL) checkContentIsOk{
    if (_textView.attributedText.length == 0){
        [MBProgressHUD showError:@"正文为空!" toView:self.view];
        return NO;
    }
    return YES;
}
- (void)saveBtnOnClick{
    [self.textView resignFirstResponder];
    if(![self checkContentIsOk] ){
        return;
    }
    [self saveDraftToLocalTMCache];
    [MBProgressHUD showSuccess:@"保存成功" toView:self.view];
}

-(void)addImgBtnOnClick{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    UIActionSheet *sheet;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        sheet  = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选择", nil];
    }else {
        sheet = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选择", nil];
    }
    sheet.tag = 255;
    [sheet showInView:self.view];
}



-(void) saveDraftToLocalTMCache{
    if(self.draftData==nil) return;
    
    //转为html代码
    XGHtmlBuilder *parserToHtml = [[XGHtmlBuilder alloc]initWithAttributedString:self.textView.attributedText];
    
    //收集数据
    self.draftData.articleContent = parserToHtml.HTMLString;
    
    //除了本地图(这里要收集一下最新的src情况;随后再写)
    self.imgAttachmentArr = [parserToHtml imgAttachmentArr];
    NSMutableArray *imgArr = [XGUtils convertAttachmentURLArr2ImgArr:self.imgAttachmentArr];
    
    //生成草稿字典
    [self.draftStore addDraftWithDraftDataModel:self.draftData withNewOnlineImgDic:nil withNewLocalImgArr:imgArr withDelOnlineImgKeys:nil];
    NSLog(@"____________________草稿保存成功____________________");
}
/**
 *  MARK:-----------------------键盘通知--------------------------
 */
- (void)keyboardWillShow:(NSNotification *)notification{
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        CGRect keyboardF = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat keyboardH = keyboardF.size.height;
        [self.tvBottomSpaConstraints setConstant:keyboardH];
        
        [UIView animateWithDuration:duration animations:^{
            [self.textView layoutIfNeeded];
        } completion:^(BOOL finish){
        }];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:duration];
        [UIView commitAnimations];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification{
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [self.tvBottomSpaConstraints setConstant:0];
    [UIView animateWithDuration:duration animations:^{
        [self.textView layoutIfNeeded];
    }completion:^(BOOL finish){
    }];
}


/**
 *  MARK:------------------ActionSheetDelegate-------------------------
 */
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        switch (buttonIndex) {
            case 1: //相机
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                break;
            case 2: //相册
                return;
                break;
            default:
                sourceType = UIImagePickerControllerSourceTypeCamera;
                break;
        }
    }
    else {
        if (buttonIndex == 1) {
            return;
        } else {
            sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        }
    }
    //创建图像选取控制器
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    
    //设置委托对象
    imagePickerController.delegate = self;
    
    //允许用户进行编辑
    imagePickerController.allowsEditing = NO;
    
    //设置图像选取控制器的来源模式为  相机 或 相册 模式
    imagePickerController.sourceType = sourceType;
    
    //设置图像选取控制器的类型为静态图像
    imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeImage, nil];
    
    //以模视图控制器的形式显示
    [self presentViewController:imagePickerController animated:YES completion:^(){
        imagePickerController.delegate = self;
    }];
}

/**
 *  MARK:------------------UIImagePickerControllerDelegate-------------------------
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        UIImage* original_image = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImageWriteToSavedPhotosAlbum(original_image, self, nil, nil);
    }
    NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    //判断是静态图像还是视频
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage* editedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        [self _addAttachmentImage:editedImage];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_addAttachmentImage:(UIImage*)img{
    if (img == nil) {
        return;
    }
    //2.图片切割尺寸
    CGFloat oriWidth = img.size.width;
    CGFloat oriHeight = img.size.height;
    CGFloat maxWidth = 1242;
    //CGFloat maxHeight = 2208;
    CGFloat cutWidth = oriWidth;
    CGFloat cutHeight = oriHeight;
    if(oriWidth > maxWidth )//&& oriHeight > maxHeight)
    {
        CGFloat ratioW = maxWidth / oriWidth;
        cutWidth = maxWidth;
        cutHeight *= ratioW;
    }
    //3.切割图片
    //UIImage *cutImg = [img imageByScalingToSize:CGSizeMake(cutWidth, cutHeight)];
    UIGraphicsBeginImageContext(CGSizeMake((int)cutWidth, (int)cutHeight));
    [img drawInRect:CGRectMake(0, 0, ((int)cutWidth+1), ((int)cutHeight)+1)];
    UIImage *cutImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //4.判断大小越界
    CGFloat imageCompressionQuality = 0.8f;
    NSData *comData = UIImageJPEGRepresentation(cutImg, imageCompressionQuality);
    cutImg = [UIImage imageWithData:comData];
    XGHtmlBuilder *parserToHtml = [[XGHtmlBuilder alloc]initWithAttributedString:self.textView.attributedText];
    NSInteger imgDataSize = [parserToHtml getAllImgDataSize];//bytes
    NSInteger imageSizeLimit = 100;
    if(imgDataSize + comData.length > 1024*1024*imageSizeLimit)
    {
        [[[UIAlertView alloc] initWithTitle:@"插入失败" message:@"您插入了过多的图片;"  delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil] show];
    }
    //5,显示创建图片附件
    [self.textView addAttachmentWithImg:cutImg];
}

/**
 *  MARK:--------------------XGTextViewDelegate--------------------
 */
-(void) xgTextViewSaveDraftToLocalTMCache{
    [self saveDraftToLocalTMCache];
}
-(void) xgTextViewBeginEditing{
}
-(BOOL) xgTextViewNeedAutoSave{
    return true;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

@end





