//
//  ArticleDraftStore.h
//  Tanker
//
//  Created by 贾  on 15/8/5.
//  Copyright (c) 2015年 Tanker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDArticleDraftDataModel.h"

@interface ArticleDraftStore : NSObject

-(id) init;

//获得目录
-(NSArray*) draftArr;

/**
 *  MARK:--------------------获取本地未同步过文章数--------------------
 */
-(NSMutableArray*) getLocalDraftNotSync;
-(NSMutableArray*) getLocalDraftDidSync;

//更新目录
-(void) updateDraftArrStore:(NSMutableArray*)newSimpleArr;

/**
 *  MARK:--------------------Delete--------------------
 */
-(void) deleteDraftAtArrByCreateTime:(NSString*)time;

/**
 *  MARK:--------------------Add--------------------
 */
-(void) addDraftWithDraftDataModel:(MDArticleDraftDataModel*)dataModel
               withNewOnlineImgDic:(NSDictionary*)newOnlineImgDic
                withNewLocalImgArr:(NSMutableArray*)newLocalImgArr
              withDelOnlineImgKeys:(NSArray*)delOnlineImgKeys;

/**
 *  MARK:--------------------未同步草稿使用createTime,已同步使用addTime--------------------
 *  返回字典不包括图片数组;图片在解析htmlContent时自动取;
 */
-(MDArticleDraftDataModel*) getDraftDataModelWithTime:(NSString*)time;
-(MDArticleDraftDataModel*) getDraftDataModelWithArticleId:(NSString*)artId;

/**
 *  MARK:--------------------更新一条草稿中的数据--------------------
 *  1,更新目录数据,
 *  2,更新持久化数据,
 *  3,暂无图片更新功能,
 *  4,一般用于文本数据更改,或者文章状态更改,以使图片不动来省流量;
 */
- (void)updateDraftAtArrByCreateTime:(NSString*)time withUpdateDic:(NSDictionary *)updateDic;

@end
