//
//  CCAppInfoModel.h
//  异步加载网络图片 - 终极版
//
//  Created by chenchen on 16/7/31.
//  Copyright © 2016年 chenchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCAppInfoModel : NSObject
/**
 *  下载量
 */
@property(nonatomic,copy)NSString * download;
/**
 *  名字
 */
@property(nonatomic,copy)NSString * name;
/**
 *  图片地址
 */
@property(nonatomic,copy)NSString * icon;

+(instancetype)appInfoWithDict:(NSDictionary *)dict;

@end
