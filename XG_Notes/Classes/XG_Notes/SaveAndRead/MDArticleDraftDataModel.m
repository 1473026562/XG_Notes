//
//  MDArticleDraftDataModel.m
//  Tanker
//
//  Created by 贾  on 16/1/15.
//  Copyright © 2016年 Tanker. All rights reserved.
//

#import "MDArticleDraftDataModel.h"
#import "ArticleDraftStore.h"

/**
 *  MARK:--------------------单篇草稿的数据模型--------------------
 *
 *  读:建议从本类读取单篇草稿数据(只读)
 *  存:建议从ArticleDraftStore类作增,删,改等持久化操作(因本类只管理草稿内容,像插图及目录内容本类无法管理和存储)
 */
@implementation MDArticleDraftDataModel


/**
 *  MARK:--------------------已同步草稿用addTime,未同步草稿用createTime;--------------------
 */
-(id) initWithDraftDic:(NSDictionary*)dic
{
    self = [super init];
    if(self)
    {
        [self setTitle:[dic objectForKey:@"title"]];
        [self setArticleContent:[dic objectForKey:@"articleContent"]];
        [self setAddTime:[NSString stringWithFormat:@"%@",[dic objectForKey:@"addTime"]]];
        [self setArticleid:[NSString stringWithFormat:@"%@",[dic objectForKey:@"articleid"]]];
        [self setBrief:[dic objectForKey:@"brief"]];
        [self setLastUpdateTime:[NSString stringWithFormat:@"%@",[dic objectForKey:@"lastUpdateTime"]]];
    }
    return self;
}

/**
 *  MARK:--------------------Property--------------------
 */
-(NSString*) title{
    if(!NSSTRINGISVALID(_title)){
        _title = @"";
    }
    return _title;
}
-(NSString*) articleContent{
    if(!NSSTRINGISVALID(_articleContent)){
        _articleContent = @"";
    }
    return _articleContent;
}
-(NSString*) addTime{
    if(!NSSTRINGISVALID(_addTime)){
        _addTime = @"0";
    }
    return _addTime;
}
-(NSString*) articleid{
    if(!NSSTRINGISVALID(_articleid)){
        _articleid = @"0";
    }
    return _articleid;
}
-(NSString*) brief{
    if(!NSSTRINGISVALID(_brief)){
        _brief = @"";
    }
    return _brief;
}
-(NSString*) lastUpdateTime{
    if(!NSSTRINGISVALID(_lastUpdateTime)){
        _lastUpdateTime = @"0";
    }
    return _lastUpdateTime;
}

/**
 *  MARK:--------------------持久化(!未完善)--------------------
 */
-(void)saveToDisk
{
    [[[ArticleDraftStore alloc] init] addDraftWithDraftDataModel:self withNewOnlineImgDic:nil withNewLocalImgArr:nil withDelOnlineImgKeys:nil];
}





@end
