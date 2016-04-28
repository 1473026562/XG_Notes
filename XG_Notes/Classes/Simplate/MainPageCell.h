//
//  MainPageCell.h
//  XG_Notes
//
//  Created by 贾  on 16/4/28.
//  Copyright © 2016年 XiaoGang. All rights reserved.
//  github: https://github.com/jiaxiaogang/XG_Notes
//

#import <UIKit/UIKit.h>
#import "XGNotesDataModel.h"

@interface MainPageCell : UITableViewCell

+ (NSString*)reuseIdentifier;
-(void) setData:(XGNotesDataModel*)dataModel;



@end
