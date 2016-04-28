//
//  MainPageController.m
//  XG_Notes
//
//  Created by 贾  on 16/4/28.
//  Copyright © 2016年 XiaoGang. All rights reserved.
//  github: @https://www.github.com/jiaxiaogang
//

#import "MainPageController.h"
#import "MainPageCell.h"
#import "XGUtils.h"

@interface MainPageController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSMutableArray *datas;

@end

@implementation MainPageController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initData];
    [self initDisplay];
}

-(void)initView{
    UINib *nib = [UINib nibWithNibName:[MainPageCell reuseIdentifier] bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:[MainPageCell reuseIdentifier]];
}
-(void) initData{
    self.datas = [[NSMutableArray alloc]init];
    NSMutableArray *tempArr = [[NSMutableArray alloc]initWithObjects:@"QQ:283636001",@"QQ交流群:193069075",@"微信:jia2764894",@"3",@"4", nil];
    for (int i = 0; i < tempArr.count; i++) {
        DataModel *dataModel = [[DataModel alloc]init];
        dataModel.content = [tempArr objectAtIndex:i];
        dataModel.brief = [tempArr objectAtIndex:i];
        dataModel.createTime = [NSString stringWithFormat:@"%lld",[XGUtils systemNowTimeSecondPlusThreeZero]];
        [self.datas addObject:dataModel];
    }
}
-(void)initDisplay{
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
}




/**
 *  MARK:--------------------onclick--------------------
 */
- (IBAction)newNoteBtnOnClick:(UIButton *)sender {
    
}

/**
 *  MARK:--------------------UITableViewDelegate--------------------
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.datas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MainPageCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[MainPageCell reuseIdentifier]];
    [cell setData:[self.datas objectAtIndex:indexPath.row]];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

/**
 *  MARK:--------------------selectRowAtIndexPath事件--------------------
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsMake(0,15,0,15)];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsMake(0,15,0,15)];
    }
}







@end
