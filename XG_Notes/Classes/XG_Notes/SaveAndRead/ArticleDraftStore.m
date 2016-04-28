//
//  ArticleDraftStore.m
//  Tanker
//
//  Created by 贾  on 15/8/5.
//  Copyright (c) 2015年 Tanker. All rights reserved.
//


/**
 *  MARK:用于存储我的草稿的目录;
 *  //存储:
 */
#import "ArticleDraftStore.h"
#import "TMDiskCache.h"
#import "SDImageCache.h"
#import "ArticleDraftHtmlParser.h"
#import "XGUtils.h"

//用户的草稿目录
#define KEY_ARTICLEDRAFTS_NSUSERDEFAULTS [NSString stringWithFormat:@"%@_ArticleDraftArr",@"jxgID"]
//TMCache中用time取草稿
#define KEY_ARTICLEDRAFT_TMCACHE(time) [NSString stringWithFormat:@"%@_%@_ArticleDraft",@"jxgID",time]

@interface ArticleDraftStore()


@end


@implementation ArticleDraftStore


/**
 *  MARK:--------------------init--------------------
 */
-(id) init{
    self = [super init];
    if(self != nil){
    }
    return self;
}



/**
 *  MARK:--------------------获取草稿简介目录表--------------------
 */
-(NSArray*) draftArr
{
    NSArray *draftArr = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_ARTICLEDRAFTS_NSUSERDEFAULTS];
    if(draftArr==nil)
    {
        draftArr = [[NSArray alloc]init];
    }
    return draftArr;
}

/**
 *  MARK:--------------------获取本地未同步过的文章 与 已同步过的文章--------------------
 */
-(NSMutableArray*) getLocalDraftNotSync
{
    return [self getLocalDraftWithSyncType:TRUE];
}
-(NSMutableArray*) getLocalDraftDidSync
{
    return [self getLocalDraftWithSyncType:FALSE];
}
-(NSMutableArray*) getLocalDraftWithSyncType:(BOOL)notSync
{
    NSMutableArray *draftSimpleArr = [NSMutableArray arrayWithArray:[self draftArr]];
    NSMutableArray *tmpArr = [[NSMutableArray alloc]init];
    for (int i = 0; i < draftSimpleArr.count; i++) {
        NSDictionary *dic = [draftSimpleArr objectAtIndex:i];
        if([@"0" isEqualToString:[dic objectForKey:@"articleid"]] == notSync)
        {
            [tmpArr addObject:dic];
        }
    }
    return tmpArr;
}
/**
 *  MARK:--------------------更新目录表--------------------
 */
-(void) updateDraftArrStore:(NSMutableArray*)newSimpleArr
{
    [[NSUserDefaults standardUserDefaults] setObject:newSimpleArr forKey:KEY_ARTICLEDRAFTS_NSUSERDEFAULTS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 *  MARK:--------------------清理TM缓冲中的图片,根据草稿addTime--------------------
 */
-(void) deleteLocalImgFromTMCacheWithAddTime:(NSString*)time
{
    UIImage *localWillDelImg = nil;
    int localWillDelIndex = 0;
    do
    {
        localWillDelImg = nil;
        NSString *index = [NSString stringWithFormat:@"%d",localWillDelIndex];
        NSString *key = KEY_ARTICLEDRAFTLOCALIMG_TMCACHE(time,index);
        localWillDelImg = [[TMDiskCache sharedCache] objectForKey:key];
        if(localWillDelImg!=nil)
        {
            [[TMDiskCache sharedCache] removeObjectForKey:key];
        }
        localWillDelIndex++;
    }
    while (localWillDelImg!=nil);
}
/**
 *  MARK:--------------------添加一条已同步的草稿(1:添加简介 2:添加草稿到TMDiskCache 3:添加图片到SDImageCache)--------------------
 *
 *  已同步;则imgDic为新同步的图片字典;
 *  未同步;新的本地图片数组;TMCache中清除掉这篇草稿的所有图;换成新的;
 *  未同步;则删掉已经删掉的在线缓冲图;
 */
-(void) addDraftWithDraftDataModel:(MDArticleDraftDataModel*)dataModel
               withNewOnlineImgDic:(NSDictionary*)newOnlineImgDic
                withNewLocalImgArr:(NSMutableArray*)newLocalImgArr
              withDelOnlineImgKeys:(NSArray*)delOnlineImgKeys{
    if (dataModel != nil) {
        //生成简介;
        NSDictionary *draftSimple = [NSDictionary dictionaryWithObjectsAndKeys:
                                     dataModel.title,@"title",
                                     dataModel.addTime,@"addTime",
                                     dataModel.brief,@"brief",
                                     dataModel.articleid,@"articleid",
                                     dataModel.lastUpdateTime,@"lastUpdateTime",
                                     nil];
        
        //存储简介
        NSMutableArray *draftSimpleArr = [NSMutableArray arrayWithArray:[self draftArr]];
        for (int i = 0; i < draftSimpleArr.count; i++) {
            NSDictionary *dic = [draftSimpleArr objectAtIndex:i];
            if(dic&&[dic objectForKey:@"addTime"])
            {
                if([dataModel.addTime isEqualToString:[dic objectForKey:@"addTime"]])
                {
                    [draftSimpleArr removeObjectAtIndex:i];
                    break;
                }
            }
        }
        [draftSimpleArr insertObject:draftSimple atIndex:0];
        [self updateDraftArrStore:draftSimpleArr];
        
        //生成草稿
        NSDictionary *draftNormal = [NSDictionary dictionaryWithObjectsAndKeys:
                                     dataModel.title,@"title",
                                     dataModel.articleContent,@"articleContent",
                                     dataModel.addTime,@"addTime",
                                     dataModel.articleid,@"articleid",
                                     dataModel.brief,@"brief",
                                     dataModel.lastUpdateTime,@"lastUpdateTime",
                                     nil];
        
        //存储草稿
        [[TMDiskCache sharedCache] setObject:draftNormal forKey:KEY_ARTICLEDRAFT_TMCACHE(dataModel.addTime)];
        
        //存储新同步图片字典
        NSArray *imgKeyArr = [newOnlineImgDic allKeys];
        for (int i = 0; i<imgKeyArr.count; i++) {
            NSString *urlKey = imgKeyArr[i];
            UIImage *img = [newOnlineImgDic objectForKey:urlKey];
            if(img)
            {
                [[SDImageCache sharedImageCache] storeImage:img forKey:urlKey];
            }
        }
        
        //更新本地图片字典
        [self deleteLocalImgFromTMCacheWithAddTime:[NSString stringWithFormat:@"%@" ,dataModel.addTime]];
        if(newLocalImgArr != nil)
        {
            for (int i = 0; i < newLocalImgArr.count; i++) {
                NSString *index = [NSString stringWithFormat:@"%d",i];
                [[TMDiskCache sharedCache] setObject:newLocalImgArr[i] forKey:KEY_ARTICLEDRAFTLOCALIMG_TMCACHE(dataModel.addTime, index)];
            }
        }
    }
}


/**
 *  MARK:--------------------获得一篇草稿(本地)--------------------
 */
-(MDArticleDraftDataModel*) getDraftDataModelWithTime:(NSString*)time
{
    NSDictionary *draft = [[TMDiskCache sharedCache] objectForKey:KEY_ARTICLEDRAFT_TMCACHE(time)];
    if (draft != nil) {
        return [[MDArticleDraftDataModel alloc]initWithDraftDic:draft];
    }
    return nil;
}
-(MDArticleDraftDataModel*) getDraftDataModelWithArticleId:(NSString*)artId
{
    if(NSSTRINGISVALID(artId))
    {
        NSArray *draftArr = [self draftArr];
        for (NSDictionary *item in draftArr) {
            if([artId isEqualToString:[item objectForKey:@"articleid"]])
            {
                return [self getDraftDataModelWithTime:[item objectForKey:@"addTime"]];
            }
        }
    }
    return nil;
}

/**
 *  MARK:--------------------   删除一条草稿(本地)(简介及TMCache中的数据及关联的本地图片)!此处用于同步成功的文章删掉草稿,所以不能删src图片    --------------------
 */
-(void) deleteDraftAtArrByCreateTime:(NSString*)time
{
    if(NSSTRINGISVALID(time))
    {
        NSMutableArray *mArr = [NSMutableArray arrayWithArray:[self draftArr]];
        for (int i = 0; i< mArr.count; i++) {
            NSDictionary *sampleDic = mArr[i];
            NSString *sampleTime = [NSString stringWithFormat:@"%@",[sampleDic objectForKey:@"addTime"]];
            if([sampleTime isEqualToString:time])
            {
                [mArr removeObjectAtIndex:i];
                [self updateDraftArrStore:mArr];
                [[TMDiskCache sharedCache] removeObjectForKey:KEY_ARTICLEDRAFT_TMCACHE(time)];
                [self deleteLocalImgFromTMCacheWithAddTime:time];
                //[SDImageCache sharedImageCache] removeImageForKey:<#(NSString *)#>//此处imageKeyArr要从文章存储的时候
                return;
            }
        }
    }
}

/**
 *  MARK:--------------------更新一条草稿中的数据--------------------
 *  1,更新目录数据,
 *  2,更新持久化数据,
 *  3,暂无图片更新功能,
 *  4,一般用于文本数据更改,或者文章状态更改,以使图片不动来省流量;
 */
- (void)updateDraftAtArrByCreateTime:(NSString*)time withUpdateDic:(NSDictionary *)updateDic
{
    if(updateDic)
    {
        //1,更新目录数据;
        NSMutableArray *mArr = [NSMutableArray arrayWithArray:[self draftArr]];
        for (int i = 0; i< mArr.count; i++) {
            NSDictionary *oldDic = mArr[i];
            NSString *oldTime = [NSString stringWithFormat:@"%@",[oldDic objectForKey:@"addTime"]];
            if([oldTime isEqualToString:time])
            {
                NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithDictionary:oldDic];
                for (NSString *updateKey in [updateDic allKeys]) {
                    if([newDic objectForKey:updateKey])
                    {
                        [newDic setObject:[updateDic objectForKey:updateKey] forKey:updateKey];
                    }
                }
                mArr[i] = newDic;
                break;
            }
        }
        [self updateDraftArrStore:mArr];
        //2,更新持久化数据;
        NSDictionary *oldDic = [[TMDiskCache sharedCache] objectForKey:KEY_ARTICLEDRAFT_TMCACHE(time)];
        if(oldDic)
        {
            NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithDictionary:oldDic];
            for (NSString *updateKey in [updateDic allKeys]) {
                if([newDic objectForKey:updateKey])
                {
                    [newDic setObject:[updateDic objectForKey:updateKey] forKey:updateKey];
                }
            }
            [[TMDiskCache sharedCache] setObject:newDic forKey:KEY_ARTICLEDRAFT_TMCACHE(time)];
        }
    }
}

@end