//
//  MainPageCell.m
//  XG_Notes
//
//  Created by 贾  on 16/4/28.
//  Copyright © 2016年 XiaoGang. All rights reserved.
//

#import "MainPageCell.h"

@interface MainPageCell ()

@property (weak, nonatomic) IBOutlet UILabel *descLab;
@property (strong,nonatomic) DataModel *dataModel;

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
-(void) setData:(DataModel*)dataModel{
    self.dataModel = dataModel;
}

-(void) refreshDisplay{
    if (self.dataModel) {
        [self.descLab setText:self.dataModel.brief];
    }
}

@end
