//
//  ViewController.m
//  异步加载网络图片 - 终极版
//
//  Created by chenchen on 16/7/31.
//  Copyright © 2016年 chenchen. All rights reserved.
// https://raw.githubusercontent.com/yinqiaoyin/SimpleDemo/master/apps.json

#import "AFHTTPSessionManager.h"
#import "CCAppCell.h"
#import "CCAppInfoModel.h"
#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) NSMutableArray* infoData;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //    self.view.backgroundColor = [UIColor redColor];

    [self loadData];
}

/**
 *  获取网络数据
 */
- (void)loadData
{

    //网络数据的url字符串地址
    NSString* urlString = @"https://raw.githubusercontent.com/yinqiaoyin/SimpleDemo/master/apps.json";

    //初始化一个请求网络数据的管理器
    AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];

    //获取网络数据
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask* _Nonnull task, id _Nullable responseObject) {
        //网络请求数据成功的回调
        NSLog(@"网络数据请求成功!");
        //其中responseObject就是从网络上获取到的数据 打印可以知道它是一个数组
        NSLog(@"%@", responseObject);
        //1.初始化临时数组来接收从网络上获取到的数据,以便下一步做字典转模型的处理
        NSArray* tempArray = responseObject;
        //2.遍历临时数组获取字典数据
        for (NSDictionary* dict in tempArray) {
            //3.字典转模型
            CCAppInfoModel* info = [CCAppInfoModel appInfoWithDict:dict];
            //4.把模型添加到全局的数组中
            [self.infoData addObject:info];
        }

        NSLog(@"%@", self.infoData);
        //从网络上正确获取数据以后,刷新数据源
        [self.tableView reloadData];

    }
        failure:^(NSURLSessionDataTask* _Nullable task, NSError* _Nonnull error) {
            //网络请求数据失败的回调 在公司项目开发中,请求失败的事件一定要处理
            NSLog(@"网络数据请求失败,请做相应的处理.");
        }];
}

#pragma mark - 全局属性的懒加载的方法
- (NSMutableArray*)infoData
{
    if (_infoData == nil) {
        _infoData = [NSMutableArray array];
    }
    return _infoData;
}
@end
