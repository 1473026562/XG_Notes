//
//  MyWriteTextView.h
//  Tanker
//
//  Created by 贾  on 16/2/27.
//  Copyright © 2016年 Tanker. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyWriteTextViewDelegate <NSObject>

//保存草稿
-(void) myWriteTextViewSaveDraftToLocalTMCache;

//开始编辑
-(void) myWriteTextViewBeginEditing;

//是否需要自动保存;
-(BOOL) myWriteTextViewNeedAutoSave;

@end

@interface MyWriteTextView : UITextView

@property (assign, nonatomic) int kMaxContentLength;
@property (assign, nonatomic) BOOL waitEndEditCheckRect;    //等待键盘落下后,检查光标位置
@property (weak, nonatomic) id<MyWriteTextViewDelegate> myWriteTextDelegate;

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


//
//
////
////  MyWriteViewController.m
////  Tanker
////
////  Created by echo on 6/26/15.
////  Copyright (c) 2015 zhao jun. All rights reserved.
////
//#import "MyWriteViewController.h"
//#import "MyWriteToolbar.h"
//#import "ENUntil.h"
//#import "MobileVerifyViewController.h"
//#import <MobileCoreServices/MobileCoreServices.h>
//#import "MD5.h"
//#import "NSAttributedString+HTML.h"
//#import "DTCoreTextConstants.h"
//#import "DTCoreText.h"
//#import "UITextField+Extension.h"
//#import "DTHTMLWriter_Simple.h"
//#import "Article_CreateService.h"
//#import "ArticleDraftStore.h"
//#import "ArticleDraftHtmlParser.h"
//#import "MDArticleDraftDataModel.h"
//#import "MBProgressHUD+Add.h"
//#import "NSString+HTML.h"
//#import "NSTextAttachmentURL.h"
//#import "MyWriteSubmitViewController.h"
//#import "MyArticleViewController.h"
//#import "SDWebImageCompat.h"
//#import "AuthorAgreementViewController.h"
//#import "SmallEditorContractViewController.h"
//#import <CoreLocation/CoreLocation.h>
//#import <CoreLocation/CLLocationManagerDelegate.h>
//#import "MyWriteUtils.h"
//#import "ThemeManager.h"
//#import "AppConfigManager.h"
//#import "UINavigationController+FDFullscreenPopGesture.h"
//#import "MyWritePhotoPickerView.h"
//#import "MyWriteTextView.h"
//
//#define TOOLBAR_HEIGHT ScreenWidth/10
//#define kTipToMyArticles 101
//
//@interface MyWriteViewController () < MyWriteToolbarDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, wgDataSourceFinish, UINavigationControllerDelegate,UIScrollViewDelegate,UIAlertViewDelegate,AuthorAgreenmentViewControllerDelegate,MobileVerifyViewControllerDelegate,SmallEditorContractViewControllerDelegate,CLLocationManagerDelegate,MyWritePhotoPickerViewDelegate,MyWriteTextViewDelegate>
//
//@property (weak, nonatomic) IBOutlet UITextField *titleTF;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tvBottomSpaConstraints;
//@property (weak, nonatomic) IBOutlet MyWriteTextView *textView;
//@property (nonatomic, strong) MyWriteToolbar *toolbar;
//@property (nonatomic, strong) UIBarButtonItem *publisBtn;
//@property (nonatomic, strong) UIBarButtonItem *saveBtn;
//@property (nonatomic, strong) UIBarButtonItem *oneKeyLayoutBtn;
//@property (strong, nonatomic) WGDataSource *articleCreateDataSource;
//
//@property (strong,nonatomic) NSMutableArray *imgAttachmentArr;
//
//@property (strong,nonatomic) MDArticleDraftDataModel *draftData;    //草稿数据模型;每次编辑或新建草稿都有一个模型实例;
//@property (assign, nonatomic) BOOL isNewDraft;                      //新文章
////当次提交需要response中使用的数据;
//@property (assign, nonatomic) BOOL curRequestIsDraft;
//
//@property (assign, nonatomic) BOOL isRequesting;
//@property (assign, nonatomic) BOOL isLoaded;
//
//@property(nonatomic, strong) CLLocationManager *locationManager;
//@property (assign, nonatomic) double locationLatitude;  //纬
//@property (assign, nonatomic) double locationLongitude; //经
//@property (assign, nonatomic) double locationAltitude;  //高
//@property (weak, nonatomic) IBOutlet UIView *mediumLine;
//@property (assign, nonatomic) int kMaxTitleLength;
//@property (strong,nonatomic) ArticleDraftStore *draftStore;
//@property (assign, nonatomic) CGFloat keyboardH;            //记录键盘高度;创建相册选图时使用;
//
////@property (assign, nonatomic) BOOL waitEndEditCheckRange;
////模型实例每操作30次持久化一次;
////保存到网络后,如果addTime发生变化;先删掉模型实例的本地数据;再保存网络的dic;
////发布后,删除本地数据;根本模型的addTime;
//@end
//
//@implementation MyWriteViewController
//
//-(id) initWithMDDraft:(MDArticleDraftDataModel*)md{
//    self = [super init];
//    if(self){
//        [self initData:md];
//    }
//    return self;
//}
//
//-(id) init{
//    self = [super init];
//    if(self){
//        [self initData:nil];
//    }
//    return self;
//}
///**
// *  MARK:--------------------所有init入口--------------------
// */
//-(void) initData:(MDArticleDraftDataModel *)draftData{
//    self.draftStore = [[ArticleDraftStore alloc]init];
//    //1,草稿数据
//    if(draftData==nil){
//        _draftData = [[MDArticleDraftDataModel alloc]init];
//        _draftData.addTime = [NSString stringWithFormat:@"%lld",[ENUntil systemNowTimeSecondPlusThreeZero]];
//        self.isNewDraft = true;
//    }else{
//        _draftData = draftData;
//    }
//    //2,config数据
//    AppConfigManager *configM = [[AppConfigManager alloc]init];
//    self.kMaxTitleLength = [configM getChapterTitleMax];
//    self.textView.kMaxContentLength = [configM getChapterContentMax];
//}
//
//- (void)viewDidLoad{
//    [super viewDidLoad];
//    
//    [self setupNavBar];
//    [self setupTextView];
//    [self setupToolbar];
//    [self setupTextField];
//}
//-(void) setupLocation{
//    _locationManager = [[CLLocationManager alloc] init];
//    _locationManager.delegate = self;
//    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//    _locationManager.distanceFilter = 1000.0f;
//    if ([[[UIDevice currentDevice] systemVersion] doubleValue] > 8.0){
//        [self.locationManager requestWhenInUseAuthorization];// 前台定位
//    }
//    [_locationManager startUpdatingLocation];
//}
//-(void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    [self.toolbar setNeedsLayout];
//    self.isRequesting = false;
//    self.fd_interactivePopDisabled = YES;
//}
//
//- (void)setupToolbar{
//    self.toolbar = [[MyWriteToolbar alloc] init];
//    self.toolbar.frame = CGRectMake(0, SCREEN_HEIGHT-64, ScreenWidth, TOOLBAR_HEIGHT);
//    self.toolbar.delegate = self;
//    [self.view addSubview:self.toolbar];
//}
//- (void)setupTextField{
//    self.titleTF.delegate = self;
//    [self.titleTF setValue:@(self.kMaxTitleLength) forKey:@"limit"];
//}
//- (void)setupTextView{
//    self.isLoaded = false;
//    [self.textView initDisplay];
//    self.textView.myWriteTextDelegate = self;
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
//    
//    if(!self.isNewDraft){
//        if(!self.isLoaded){
//            MBProgressHUD *hub = [MBProgressHUD showMessag:@"正在加载" toView:self.view];
//            hub.dimBackground = NO;
//        }
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            dispatch_main_sync_safe(^{
//                [ArticleDraftHtmlParser convertHtml:self.draftData.articleContent
//                                     withImgMaxSize:CGSizeMake(ScreenWidth - 32, MAXFLOAT)
//                                     withCreateTime:self.draftData.addTime
//                                       withComplete:^(NSMutableAttributedString* mStr) {
//                                           [self.textView setAttributedText:mStr];
//                                           [self.textView onekeyLayoutAllText];
//                                           [self.titleTF setText:self.draftData.title];
//                                           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                                               [self.textView becomeFirstResponder];
//                                           });
//                                           self.isLoaded = true;
//                                           [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                                       }];
//            });
//        });
//    }else{
//        [self.titleTF becomeFirstResponder];
//    }
//    if([self.draftData.status intValue] == MyArticleStatusWaitForReview){
//        [self.textView setEditable:NO];
//        [self.titleTF setEnabled:NO];
//    }
//}
//
//
//
///**
// *  MARK:-----------------------------Navi----------------------------------
// */
//- (void)setupNavBar{
//    if([self.draftData.status intValue] != MyArticleStatusWaitForReview){
//        self.oneKeyLayoutBtn = [[UIBarButtonItem alloc] initWithTitle:@"    " style:UIBarButtonItemStyleDone target:self action:@selector(onekeyLayoutAllText)];
//        [self.oneKeyLayoutBtn setTintColor:[[ThemeManager shareInstance] getColorWithName:@"navigation_bar_title"]];
//        
//        self.publisBtn = [[UIBarButtonItem alloc] initWithTitle:@"发布故事  " style:UIBarButtonItemStyleDone target:self action:@selector(publishBtnOnClick)];
//        [self.publisBtn setTintColor:[[ThemeManager shareInstance] getColorWithName:@"navigation_bar_title"]];
//        
//        self.saveBtn = [[UIBarButtonItem alloc] initWithTitle:@"保存草稿" style:UIBarButtonItemStyleDone target:self action:@selector(saveBtnOnClick)];
//        [self.saveBtn setTintColor:[[ThemeManager shareInstance] getColorWithName:@"navigation_bar_title"]];
//        
//        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: self.publisBtn, self.saveBtn, self.oneKeyLayoutBtn , nil];
//    }
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_nav_return_gray"] style:UIBarButtonItemStyleDone target:self action:@selector(goBack)];
//    [backItem setTintColor:[[ThemeManager shareInstance] getColorWithName:@"navigation_bar_title"]];
//    [self.navigationItem setLeftBarButtonItem:backItem];
//    
//    [self.navigationController.navigationBar setBarTintColor:[[ThemeManager shareInstance] getColorWithName:@"navigation_bar_ground"]];
//}
//
//-(void) goBack{
//    if ([self.draftData.status intValue] != MyArticleStatusWaitForReview && (self.textView.text.length > 0 || self.titleTF.text.length > 0)) {
//        [self saveDraftToLocalTMCache];
//    }
//    [self.navigationController popViewControllerAnimated:YES];
//}
//
///**
// *  MARK:--------------------发布流程--------------------
// */
//- (void)publishBtnOnClick{
//    [self registerFirstResponser];
//    if(![self checkContentIsOk] || self.isRequesting){
//        return;
//    }
//    self.isRequesting = true;
//    [self setupLocation];
//    [self publishOfAuthorContract];
//}
//
////发布_1,判断作者协议
//-(void) publishOfAuthorContract{
//    BOOL agreenAuthorContract = [[[TankerUserManager userManager] authorAgree] boolValue];
//    if(agreenAuthorContract){
//        [self publishOfBindingMobile];
//    }else{
//        AuthorAgreementViewController *page = [[AuthorAgreementViewController alloc] init];
//        page.agreementUrl = @"http://m.dudiangushi.com/author_agreement.html";
//        page.delegate = self;
//        [self.navigationController pushViewController:page animated:YES];
//    }
//}
////发布_2,判断绑定手机号 或 邮箱号
//-(void) publishOfBindingMobile{
//    if(NSSTRINGISVALID([TankerUserManager userManager].mobilePhone)||NSSTRINGISVALID([TankerUserManager userManager].email)){
//        [self publishOfSmallEditor];
//    }else{
//        MobileVerifyViewController *page = [[MobileVerifyViewController alloc] init];
//        page.title = @"绑定手机号/邮箱";
//        page.mobileVerifyFor = ForBindingMobilePhoneOrEmailViewController;
//        page.nextStepBtnTitle = @"提交";
//        page.delegate = self;
//        page.isForPublishDraft = YES;
//        [self.navigationController pushViewController:page animated:YES];
//    }
//}
////发布_3,选择编辑权限
//-(void) publishOfSmallEditor{
//    SmallEditorContractViewController *page = [[SmallEditorContractViewController alloc]init];
//    page.isForPublishDraft = YES;
//    [page setDelegate:self];
//    [self.navigationController pushViewController:page animated:YES];
//}
////发布_4,提交请求
//-(void) publishOfRequestWithCanEditTitle:(BOOL)canEditTitle withCanEditPhoto:(BOOL)canEditPhoto withCanEditContent:(BOOL)canEditContent{
//    MBProgressHUD *hub = [MBProgressHUD showMessag:@"正在提交" toView:self.view];
//    hub.dimBackground = NO;
//    DTHTMLWriter_Simple *parserToHtml = [[DTHTMLWriter_Simple alloc]initWithAttributedString:self.textView.attributedText];
//    NSString *content = parserToHtml.HTMLString;
//    self.imgAttachmentArr = [parserToHtml imgAttachmentArr];
//    [self articleCreateRequestWithTitle:self.titleTF.text
//                            withContent:content
//                            withIsDraft:false
//                       withImageDataArr:parserToHtml.imgDataArr
//                          withArticleId:self.draftData.articleid
//                       withCanEditTitle:canEditTitle
//                       withCanEditPhoto:canEditPhoto
//                     withCanEditContent:canEditContent];
//}
//
///**
// *  MARK:--------------------AuthorAgreenmentViewControllerDelegate--------------------
// */
//-(void) authorAgreementViewControllerConfirmBtnOnClick{
//    [self publishOfBindingMobile];
//}
///**
// *  MARK:--------------------MobileVerifyViewControllerDelegate--------------------
// */
//-(void) mobileVerifyViewControllerBindingMobileCallBack{
//    [self publishOfSmallEditor];
//}
///**
// *  MARK:--------------------SmallEditorContractViewControllerDelegate--------------------
// */
//-(void) smallEditorContractViewControllerConfirmWithCanEditTitle:(BOOL)canEditTitle withCanEditPhoto:(BOOL)canEditPhoto withCanEditContent:(BOOL)canEditContent{
//    [self publishOfRequestWithCanEditTitle:canEditTitle withCanEditPhoto:canEditPhoto withCanEditContent:canEditContent];
//}
//
///**
// *  MARK:--------------------CLLocationManagerDelegate--------------------
// */
//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
//    CLLocation * currLocation = [locations lastObject];
//    self.locationAltitude = currLocation.altitude;
//    self.locationLatitude = currLocation.coordinate.latitude;
//    self.locationLongitude = currLocation.coordinate.longitude;
//    [_locationManager stopUpdatingLocation];
//}
//
//- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
//    [_locationManager stopUpdatingLocation];
//}
//
///**
// *  MARK:--------------------保存流程--------------------
// */
//-(BOOL) checkContentIsOk{
//    if (_textView.attributedText.length == 0){
//        [MBProgressHUD showError:@"正文为空!" toView:self.view];
//        return NO;
//    }
//    if(self.titleTF.text.length ==0){
//        [MBProgressHUD showError:@"标题为空！" toView:self.view];
//        return NO;
//    }
//    return YES;
//}
//- (void)saveBtnOnClick{
//    [self registerFirstResponser];
//    if(![self checkContentIsOk] || self.isRequesting){
//        return;
//    }
//    self.isRequesting = true;
//    MBProgressHUD *hub = [MBProgressHUD showMessag:@"正在保存" toView:self.view];
//    [hub setDimBackground:NO];
//    DTHTMLWriter_Simple *parserToHtml = [[DTHTMLWriter_Simple alloc]initWithAttributedString:self.textView.attributedText];
//    NSString *content = parserToHtml.HTMLString;
//    self.imgAttachmentArr = [parserToHtml imgAttachmentArr];
//    [self articleCreateRequestWithTitle:self.titleTF.text
//                            withContent:content
//                            withIsDraft:true
//                       withImageDataArr:parserToHtml.imgDataArr
//                          withArticleId:self.draftData.articleid
//                       withCanEditTitle:NO
//                       withCanEditPhoto:NO
//                     withCanEditContent:NO];
//}
//-(void) saveDraftToLocalTMCache{
//    if(self.draftData==nil) return;
//    
//    //转为html代码
//    DTHTMLWriter_Simple *parserToHtml = [[DTHTMLWriter_Simple alloc]initWithAttributedString:self.textView.attributedText];
//    
//    //收集数据
//    self.draftData.title = self.titleTF.text;
//    self.draftData.articleContent = parserToHtml.HTMLString;
//    
//    //除了本地图(这里要收集一下最新的src情况;随后再写)
//    self.imgAttachmentArr = [parserToHtml imgAttachmentArr];
//    NSMutableArray *imgArr = [MyWriteUtils convertAttachmentURLArr2ImgArr:self.imgAttachmentArr];
//    
//    //生成草稿字典
//    [self.draftStore addDraftWithDraftDataModel:self.draftData withNewOnlineImgDic:nil withNewLocalImgArr:imgArr withDelOnlineImgKeys:nil];
//    TKLog(@"____________________草稿保存成功____________________");
//}
///**
// *  MARK:-----------------------键盘通知--------------------------
// */
//- (void)keyboardWillShow:(NSNotification *)notification{
//    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
//    CGRect keyboardF = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    CGFloat keyboardH = keyboardF.size.height;
//    self.keyboardH = keyboardH;
//    
//    CGFloat tvHeightForToolBar = self.toolbar.hidden?0:TOOLBAR_HEIGHT;
//    [self.tvBottomSpaConstraints setConstant:keyboardH + tvHeightForToolBar];
//    
//    [UIView animateWithDuration:duration animations:^{
//        self.toolbar.transform = CGAffineTransformMakeTranslation(0, - keyboardH - TOOLBAR_HEIGHT);
//        [self.textView layoutIfNeeded];
//    } completion:^(BOOL finish){
//    }];
//    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:duration];
//    [UIView commitAnimations];
//}
//
//- (void)keyboardWillHide:(NSNotification *)notification{
//    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
//    [self.tvBottomSpaConstraints setConstant:0];
//    [UIView animateWithDuration:duration animations:^{
//        self.toolbar.transform = CGAffineTransformIdentity;
//        [self.textView layoutIfNeeded];
//    }completion:^(BOOL finish){
//    }];
//}
//
///**
// *  MARK:--------------------用于插入图片,收降键盘,一键排版,粘贴文本时,将textView显示到合适位置--------------------
// */
//-(void) registerFirstResponser{
//    [self.titleTF resignFirstResponder];
//    [self.textView resignFirstResponder];
//}
//
///**
// *  MARK:-------------------- UITextFieldDelegate --------------------
// */
//-(void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    [self.toolbar stopSomeBtnWithType:MyWriteToolbarButtonTypeAdd withToStop:YES];
//}
//-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    if([string isEqualToString:@"\n"])
//    {
//        return YES;
//    }
//    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
//    
//    if(toBeString.length>=self.kMaxTitleLength)
//    {
//        [UIUtil showMsgAlertWithTitle:@"提示" message:[NSString stringWithFormat:@"标题最多%d个字.",self.kMaxTitleLength]];
//    }
//    if ([toBeString length] > self.kMaxTitleLength) {
//        textField.text = [toBeString substringToIndex:self.kMaxTitleLength];
//        return NO;
//    }
//    return YES;
//}
//
///**
// *  MARK:-------------------------MyWriteToolbarDelegate-----------------------
// */
//-(void)writeToolbar:(MyWriteToolbar *)toolbar didClickedButton:(MyWriteToolbarButtonType)buttonType
//{
//    switch (buttonType) {
//        case MyWriteToolbarButtonTypeKeyboard:
//            [self closeKeyboardByToolBar];
//            break;
//        case MyWriteTooToolbarButtonTypeLeft:
//            [self moveCursorByToolBar:buttonType];
//            break;
//        case MyWriteTooToolbarButtonTypeRight:
//            [self moveCursorByToolBar:buttonType];
//            break;
//        case MyWriteToolbarButtonTypeAdd:
//            [self addImgByToolBar];
//            break;
//        default:
//            [self addFuhaoByToolBar:buttonType];
//            break;
//    }
//}
//
//- (void)closeKeyboardByToolBar{
//    [self.textView recordPosYWithSelectedRange:self.textView.selectedRange];
//    [self registerFirstResponser];
//    self.textView.waitEndEditCheckRect = true;
//}
//
//- (void)addFuhaoByToolBar:(MyWriteToolbarButtonType)buttonType
//{
//    NSString *selectedStr = @"，";
//    switch (buttonType) {
//        case MyWriteTooToolbarButtonTypeJu:
//            selectedStr = @"。";
//            break;
//        case MyWriteTooToolbarButtonTypeGan:
//            selectedStr = @"！";
//            break;
//        case MyWriteTooToolbarButtonTypeWen:
//            selectedStr = @"？";
//            break;
//        case MyWriteTooToolbarButtonTypeMao:
//            selectedStr = @"：";
//            break;
//        case MyWriteTooToolbarButtonTypeYin:
//            selectedStr = @"“”";
//            break;
//        default:
//            break;
//    }
//    NSRange selectedRange;
//    if(self.textView.isFirstResponder)
//    {
//        selectedRange = self.textView.selectedRange;
//        [self.textView replaceRange:_textView.selectedTextRange withText:selectedStr];
//        [self.textView setSelectedRange:NSMakeRange(selectedRange.location+1, 0)];//光标放"标点"后;
//    }else
//    {
//        selectedRange = self.titleTF.selectedRange;
//        [self.titleTF replaceRange:self.titleTF.selectedTextRange withText:selectedStr];
//        [self.titleTF setSelectedRange:NSMakeRange(selectedRange.location+1, 0)];
//    }
//}
//
//- (void)moveCursorByToolBar:(MyWriteToolbarButtonType)buttonType
//{
//    NSRange selectedRange ;
//    if(self.titleTF.isFirstResponder)
//    {
//        selectedRange = self.titleTF.selectedRange;
//    }
//    else if(self.textView .isFirstResponder)
//    {
//        selectedRange = self.textView.selectedRange;
//    }
//    switch (buttonType) {
//        case MyWriteTooToolbarButtonTypeLeft:
//            if (selectedRange.length) {
//                selectedRange.length = 0;
//            }else{
//                //if左边是图片直接跳过两个\n
//                selectedRange.location -= 1;
//            }
//            break;
//        case MyWriteTooToolbarButtonTypeRight:
//            if (selectedRange.length) {
//                selectedRange.location += selectedRange.length;
//                selectedRange.length = 0;
//            } else{
//                //假如右边是图片直接跳过两个\n(图片右边必须有个\n
//                selectedRange.location += 1;
//            }
//            break;
//        default:
//            break;
//    }
//    if(self.textView.isFirstResponder)
//    {
//        [self.textView setSelectedRange:selectedRange];
//    }
//    else if (self .titleTF.isFirstResponder)
//    {
//        [self.titleTF setSelectedRange:selectedRange];
//    }
//}
//
//- (void)addImgByToolBar
//{
//    MyWritePhotoPickerView *pickerView = [[MyWritePhotoPickerView alloc]initWithViewController:self];
//    [pickerView setData:self.keyboardH + TOOLBAR_HEIGHT];
//    pickerView.delegate = self;
//    [self.view addSubview:pickerView];
//    [pickerView animationIn];
//    [self registerFirstResponser];
//    
//    
//}
//
///**
// *  MARK:------------------MyWritePhotoPickerViewDelegate-------------------------
// */
//- (void)photoPickerPhotoOnSelect:(UIImage*)img withPickerView:(MyWritePhotoPickerView *)picker{
//    if (img == nil) {
//        return;
//    }
//    //2.图片切割尺寸
//    CGFloat oriWidth = img.size.width;
//    CGFloat oriHeight = img.size.height;
//    CGFloat maxWidth = 1242;
//    //CGFloat maxHeight = 2208;
//    CGFloat cutWidth = oriWidth;
//    CGFloat cutHeight = oriHeight;
//    if(oriWidth > maxWidth )//&& oriHeight > maxHeight)
//    {
//        //        if((oriWidth/ oriHeight) > (maxWidth/maxHeight))
//        //        {
//        //            CGFloat ratioH = maxHeight / oriHeight;
//        //            cutHeight = maxHeight;
//        //            cutWidth *= ratioH;
//        //        }
//        //        else
//        //        {
//        CGFloat ratioW = maxWidth / oriWidth;
//        cutWidth = maxWidth;
//        cutHeight *= ratioW;
//        //        }
//    }
//    //3.切割图片
//    //UIImage *cutImg = [img imageByScalingToSize:CGSizeMake(cutWidth, cutHeight)];
//    UIGraphicsBeginImageContext(CGSizeMake((int)cutWidth, (int)cutHeight));
//    [img drawInRect:CGRectMake(0, 0, ((int)cutWidth+1), ((int)cutHeight)+1)];
//    UIImage *cutImg = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    //4.判断大小越界
//    AppConfigManager *configM = [[AppConfigManager alloc]init];
//    CGFloat imageCompressionQuality = [configM getImageCompressionQuality] * 0.01;
//    NSData *comData = UIImageJPEGRepresentation(cutImg, imageCompressionQuality);
//    cutImg = [UIImage imageWithData:comData];
//    DTHTMLWriter_Simple *parserToHtml = [[DTHTMLWriter_Simple alloc]initWithAttributedString:self.textView.attributedText];
//    NSInteger imgDataSize = [parserToHtml getAllImgDataSize];//bytes
//    NSInteger imageSizeLimit = [configM getImageSizeLimit];
//    if(imgDataSize + comData.length > 1024*1024*imageSizeLimit)
//    {
//        [UIUtil showMsgAlertWithTitle:@"插入失败" message:@"您插入了过多的图片;"];
//        return;
//    }
//    //5,显示创建图片附件
//    [self.textView addAttachmentWithImg:cutImg];
//    
//}
//
///**
// *  MARK:--------------------MyWriteTextViewDelegate--------------------
// */
//-(void) myWriteTextViewSaveDraftToLocalTMCache{
//    [self saveDraftToLocalTMCache];
//}
//-(void) myWriteTextViewBeginEditing{
//    [self.toolbar stopSomeBtnWithType:MyWriteToolbarButtonTypeAdd withToStop:NO];
//}
//-(BOOL) myWriteTextViewNeedAutoSave{
//    return [self.draftData.status intValue] != MyArticleStatusWaitForReview;
//}
///**
// *  MARK:-----------------------------------发表接口-----------------------------------
// */
//- (WGDataSource*)articleCreateRequestWithTitle:(NSString*)title withContent:(NSString*)content withIsDraft:(BOOL)isDraft withImageDataArr:(NSMutableArray*)imgDataArr withArticleId:(NSString*)articleId withCanEditTitle:(BOOL)canEditTitle withCanEditPhoto:(BOOL)canEditPhoto withCanEditContent:(BOOL)canEditContent
//{
//    self.curRequestIsDraft = isDraft;
//    self.articleCreateDataSource = [WGDataSource dataSource];
//    NSMutableDictionary *parms = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                  title, @"title",
//                                  content, @"content",
//                                  @(isDraft), @"isDraft",nil];
//    if(imgDataArr!=nil)
//    {
//        [parms setObject:imgDataArr forKey:@"imgArr"];
//    }
//    if(articleId)
//    {
//        articleId = [NSString stringWithFormat:@"%@",articleId];
//    }
//    if(NSSTRINGISVALID(articleId))
//    {
//        [parms setObject:articleId forKey:@"articleId"];
//    }
//    if(!isDraft)
//    {
//        [parms setObject:canEditTitle?@"1":@"0" forKey:@"canEditTitle"];
//        [parms setObject:canEditPhoto?@"1":@"0" forKey:@"canEditPhoto"];
//        [parms setObject:canEditContent?@"1":@"0" forKey:@"canEditContent"];
//        [parms setObject:[[NSNumber numberWithDouble:self.locationLatitude] stringValue] forKey:@"latitude"];
//        [parms setObject:[[NSNumber numberWithDouble:self.locationLongitude] stringValue] forKey:@"longitude"];
//        [parms setObject:[[NSNumber numberWithDouble:self.locationAltitude] stringValue] forKey:@"altitude"];
//    }
//    [[[Article_CreateService alloc] init] callBySelectorName:ArticleCreate withDataSource:self.articleCreateDataSource andDelegate:self withCache:YES andParams:parms];
//    return self.articleCreateDataSource;
//}
//-(void)dataSourceFinishDo:(WGDataSource *)dataSource andService:(WGSuperService *)wgService
//{
//    if(dataSource.fetched)
//    {
//        if ([wgService isResultBySelectorName:ArticleCreate])
//        {
//            if(wgService.success)
//            {
//                //1:取新的在线草稿数据及图片
//                NSDictionary *artDic = [dataSource.entityData objectForKey:@"article"];
//                MDArticleDraftDataModel *newDataModel = [[MDArticleDraftDataModel alloc]initWithDraftDic:artDic];
//                NSDictionary *imgUrlDic = [dataSource.entityData objectForKey:@"picArray"];                             //url字典和本地data图片字典(应一一对应)
//                NSMutableDictionary *successImgDic = [[NSMutableDictionary alloc]initWithCapacity:self.imgAttachmentArr.count];   //用此字典取图片data及url
//                
//                for (int i = 0; i<self.imgAttachmentArr.count; i++) {
//                    NSString *url =  [imgUrlDic objectForKey:[NSString stringWithFormat:@"%d",i]];
//                    if(NSSTRINGISVALID(url))
//                    {
//                        NSObject *itemObj = self.imgAttachmentArr[i];
//                        if([itemObj isKindOfClass:[NSTextAttachmentURL class]]){
//                            NSTextAttachmentURL *itemAtt = (NSTextAttachmentURL*)itemObj;
//                            [successImgDic setObject:itemAtt.image forKey:url];
//                            itemAtt.contentUrl = url;
//                        }
//                    }
//                }
//                
//                //2:先删掉本地未同步的草稿
//                NSString *localTime = self.draftData.addTime;
//                NSString *onlineTime = [artDic objectForKey:@"addTime"];
//                //if(![localTime isEqualToString:onlineTime] && NSSTRINGISVALID(localTime))//time相同;也应替换本地数据;
//                [self.draftStore deleteDraftAtArrByCreateTime:localTime];
//                self.draftData.addTime = newDataModel.addTime;
//                self.draftData.articleid = newDataModel.articleid;
//                
//                //3:再存新的在线草稿
//                [self.draftStore addDraftWithDraftDataModel:newDataModel withNewOnlineImgDic:successImgDic withNewLocalImgArr:nil withDelOnlineImgKeys:nil];
//                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                if(self.curRequestIsDraft)
//                {
//                    [MBProgressHUD showSuccess:@"保存成功！" toView:self.view];
//                    self.curRequestIsDraft = false;
//                    //[self GoMyArticlePage];
//                }
//                else
//                {
//                    //4:正式提交审核
//                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"投稿成功" message:@"你的故事已经提交成功，请耐心等待，编辑将在24小时内完成审稿，届时会发送相应通知给你。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//                    alert.tag = kTipToMyArticles;
//                    [alert show];
//                }
//                
//                //5:存新的文章总数到user
//                int publishNum = [[wgService.webClient.data objectForKey:@"publishNum"]intValue];
//                if(publishNum < 0) publishNum = 0;
//                int localDraftNum = (int)[self.draftStore getLocalDraftNotSync].count;
//                [[TankerUserManager userManager] saveUserParms:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",publishNum + localDraftNum],@"articlecount", nil]];
//            }
//            else
//            {
//                [self saveDraftToLocalTMCache];
//                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                if([wgService.webClient.data objectForKey:@"error"]){
//                    NSString *errorCode = [NSString stringWithFormat:@"%@",[[wgService.webClient.data objectForKey:@"error"] objectForKey:@"code"]];
//                    if ([errorCode isEqualToString:TOKEN_INVALID]){
//                        if(![[wgService.params objectForKey:@"isDraft"] boolValue]){
//                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提交失败" message:@"你的登录已过期,你的故事已保存到作品中,请重新登录后再次发布." delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//                            [alert show];
//                        }
//                    }else if ([errorCode isEqualToString:ARTICLE_NOT_MODIFY]){
//                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提交失败" message:@"这篇故事已提交过!请等待审核通过." delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//                        [alert show];
//                    }else{
//                        if(![[wgService.params objectForKey:@"isDraft"] boolValue])
//                        {
//                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提交失败" message:@"你的故事已保存到作品中,请稍候发布." delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//                            [alert show];
//                        }
//                    }
//                }else{
//                    if(![[wgService.params objectForKey:@"isDraft"] boolValue]){
//                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提交失败" message:@"你的故事已保存在作品中,请稍候发布." delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//                        [alert show];
//                    }
//                }
//            }
//        }
//    }else{
//        [self saveDraftToLocalTMCache];
//        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//        if(![[wgService.params objectForKey:@"isDraft"] boolValue]){
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提交失败" message:@"你的故事已经保存到作品中,请稍候发布." delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            [alert show];
//        }
//        else{
//            [MBProgressHUD showSuccess:@"已保存到本地。" toView:self.view];
//            self.curRequestIsDraft = false;
//        }
//    }
//    self.isRequesting = false;
//}
//
///**
// *  MARK:--------------------UIAlertViewDelegate--------------------
// */
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    if(alertView.tag == kTipToMyArticles){
//        if(buttonIndex == 0){
//            [self GoMyArticlePage];
//        }
//    }
//}
//-(void) GoMyArticlePage
//{
//    BOOL find = false;
//    for (UIViewController *controller in self.navigationController.viewControllers) {
//        if ([controller isKindOfClass:[MyArticleViewController class]]) {
//            find = true;
//            MyArticleViewController *myArt = (MyArticleViewController*)controller;
//            myArt.needRefreshForPopBackHere = TRUE;
//            [self.navigationController popToViewController:myArt animated:YES];
//        }
//    }
//    if(!find)
//    {
//        MyArticleViewController *page = [[MyArticleViewController alloc]init];
//        page.articlePageType = ArticlePageTypeMyArticle;
//        [page setTitle:@"作品"];
//        [self.navigationController pushViewController:page animated:YES];
//    }
//}
//
//-(void)dealloc{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
//}
//
//-(void) setColor {
//    
//    [self.mediumLine setBackgroundColor:[[ThemeManager shareInstance] getColorWithName:@"writepage_mediumline"]];
//    [self.textView setBackgroundColor:[[ThemeManager shareInstance] getColorWithName:@"general_page_ground_ff2b"]];
//    [self.view setBackgroundColor:[[ThemeManager shareInstance] getColorWithName:@"general_page_ground_ff2b"]];
//    [self.toolbar setColor];
//    
//    [self.titleTF setAttributedPlaceholder: [[NSAttributedString alloc] initWithString:@"标题" attributes:@{NSForegroundColorAttributeName: [[ThemeManager shareInstance] getColorWithName:@"general_placeholder"]}]];
//    [self.textView setTextColor:[[ThemeManager shareInstance] getColorWithName:@"writepage_title"]];
//    
//    [self.titleTF setTextColor:[[ThemeManager shareInstance] getColorWithName:@"writepage_desc"]];
//    [self.publisBtn setTintColor:[[ThemeManager shareInstance] getColorWithName:@"navigation_bar_title"]];
//    [self.saveBtn setTintColor:[[ThemeManager shareInstance] getColorWithName:@"navigation_bar_title"]];
//    
//    UIKeyboardAppearance keyboardAppearance = (UIKeyboardAppearance)[[[ThemeManager shareInstance] getStringWithName:@"keyboard_appearance"] intValue];
//    [self.titleTF setKeyboardAppearance:keyboardAppearance];
//    [self.textView setKeyboardAppearance:keyboardAppearance];
//}
//
//@end
//
//
//
//
//
