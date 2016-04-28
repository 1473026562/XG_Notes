//
//  MainPageCell.h
//  XG_Notes
//
//  Created by 贾  on 16/4/28.
//  Copyright © 2016年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataModel.h"

@interface MainPageCell : UITableViewCell

+ (NSString*)reuseIdentifier;
-(void) setData:(DataModel*)dataModel;



@end
