//
//  MainPageCell.m
//  XG_Notes
//
//  Created by 贾  on 16/4/28.
//  Copyright © 2016年 XiaoGang. All rights reserved.
//  github: https://github.com/jiaxiaogang/XG_Notes
//

#import "MainPageCell.h"

@interface MainPageCell ()

@property (weak, nonatomic) IBOutlet UILabel *descLab;
@property (strong,nonatomic) XGNotesDataModel *dataModel;

@end
@implementation MainPageCell

/**
 *  MARK:--------------------init--------------------
 */
- (void)awakeFromNib {
    [super awakeFromNib];
    [self initView];
    [self initData];
}

+ (NSString*)reuseIdentifier{
    return @"MainPageCell";
}


-(void) initView{
    
}

-(void) initData{
    
}


/**
 *  MARK:--------------------setData--------------------
 */
-(void) setData:(XGNotesDataModel*)dataModel{
    self.dataModel = dataModel;
    [self refreshDisplay];
}

-(void) refreshDisplay{
    if (self.dataModel && [self.dataModel isKindOfClass:[XGNotesDataModel class]] && NSSTRINGISVALID(self.dataModel.brief)) {
        [self.descLab setText:self.dataModel.brief];
    }
}

@end
