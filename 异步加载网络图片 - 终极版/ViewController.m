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
#import "NSString+path.h"
#import "ViewController.h"

@interface ViewController ()
/**
 *  网络加载获取数据的数组
 */
@property (nonatomic, strong) NSMutableArray* infoData;
/**
 *  图片的缓存
 */
@property (nonatomic, strong) NSMutableDictionary* cacheImage;
/**
 *  全局队列
 */
@property (nonatomic, strong) NSOperationQueue* queue;
/**
 *  操作的缓存
 */
@property (nonatomic, strong) NSMutableDictionary* operationCache;
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

#pragma mark - 数据源方法
//有多少cell
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.infoData.count;
}

//cell内容
- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    //1.从缓存池找cell
    CCAppCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cellid" forIndexPath:indexPath];

    //2.注册单元格 通过sb注册

    //3.设置cell子控件的属性
    //获取对应cell的模型数据
    CCAppInfoModel* info = self.infoData[indexPath.row];
    //设置属性
    cell.nameLabel.text = info.name;
    cell.saleCountLabel.text = info.download;
    cell.iconView.image = nil;

    //判断图片缓存中是否有图片
    UIImage* cacheImage = self.cacheImage[info.icon];
    if (cacheImage != nil) {
        NSLog(@"从内存缓存中加载图片");
        cell.iconView.image = cacheImage;
        return cell;
    }

    //判断沙盒中是否有图片
    //获取沙盒路径
    NSString* cachePath = [info.icon appendCachePath];
    //获取沙盒中的图片
    cacheImage = [UIImage imageWithContentsOfFile:cachePath];
    if (cacheImage != nil) {
        NSLog(@"从沙盒中取图片");
        //缓存到内存中一份
        [self.cacheImage setObject:cacheImage forKey:info.icon];
        cell.iconView.image = cacheImage;
        return cell;
    }

    //判断全局缓存中是否有当前cell的操作在下载图片
    if (self.operationCache[info.icon] != nil) {
        NSLog(@"有操作在下载图片,请稍等");
        return cell;
    }

    //从网络上下载图片是耗时操作,应该放在子线程里面执行
    //初始化一个操作
    NSBlockOperation* op = [NSBlockOperation blockOperationWithBlock:^{
        //1.获取data数据
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:info.icon]];
        //2.把data数据转换为image数据
        UIImage* image = [UIImage imageWithData:data];

        //获取到图片以后,把图片保存到沙盒中
        //获取沙盒缓存路径
        NSString* cachePath = [info.icon appendCachePath];
        //图片存入沙盒中
        [data writeToFile:cachePath atomically:YES];

        //正确获取数据以后,回到主线程刷新对应indexPath的cell
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{

            //图片缓存到内存中
            if (image != nil) {
                [self.cacheImage setObject:image forKey:info.icon];
            }
            
            //图片下载完成以后,操作需要移除掉
            [self.operationCache removeObjectForKey:info.icon];

            //刷新对应indexPath的cell 防止cell图片错乱的问题
            [self.tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:(UITableViewRowAnimationLeft)];

        }];
    }];

    //图片下载完成之前要缓存当前的操作,在添加操作下载图片之前要判断操作缓存中是否已经有缓存,如果有的话直接返回,没有的话才新创建一个操作去下载图片
    [self.operationCache setObject:op forKey:info.icon];

    //把操作添加到全局队列中
    [self.queue addOperation:op];

    //4.返回cell
    return cell;
}

#pragma mark - 内存警告
/**
 * 收到内存警告:
 1. 将保存到内存中的图片清空
 - 如果图片保存到模型中的话,需要遍历模型数组,去给模型的image属性设置nil
 2. 将队列中的操作全部取消
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // 1. 清除掉内存中的image
    //    for (int i=0; i<self.appInfos.count; i++) {
    //        HMAppInfo *info = self.appInfos[i];
    //        info.image = nil;
    //    }
    [self.cacheImage removeAllObjects];
    
    // 2. 取消掉队列中的所有操作
    [self.queue cancelAllOperations];
    // 3. 移除所有的操作
    [self.operationCache removeAllObjects];
}


#pragma mark - 全局属性的懒加载的方法
- (NSMutableArray*)infoData
{
    if (_infoData == nil) {
        _infoData = [NSMutableArray array];
    }
    return _infoData;
}

- (NSMutableDictionary*)cacheImage
{
    if (_cacheImage == nil) {
        _cacheImage = [NSMutableDictionary dictionary];
    }
    return _cacheImage;
}

- (NSOperationQueue*)queue
{
    if (_queue == nil) {
        _queue = [NSOperationQueue new];
    }
    return _queue;
}

- (NSMutableDictionary*)operationCache
{
    if (_operationCache == nil) {
        _operationCache = [NSMutableDictionary new];
    }
    return _operationCache;
}
@end
