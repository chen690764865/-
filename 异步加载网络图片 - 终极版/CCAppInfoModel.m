//
//  CCAppInfoModel.m
//  异步加载网络图片 - 终极版
//
//  Created by chenchen on 16/7/31.
//  Copyright © 2016年 chenchen. All rights reserved.
//

#import "CCAppInfoModel.h"

@implementation CCAppInfoModel
+(instancetype)appInfoWithDict:(NSDictionary *)dict{
    //模型对象
    CCAppInfoModel *info = [[CCAppInfoModel alloc] init];
    
    //KVC
    [info setValuesForKeysWithDictionary:dict];
    
    //返回实例对象
    return info;
}

/**
 *  从数据中遍历出的属性模型中没有的话会调用这个方法
 *
 *  @param value <#value description#>
 *  @param key   <#key description#>
 */
-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}
@end
