//
//  ArchiveManager.m
//  解压压缩
//
//  Created by BmMac on 2017/4/28.
//  Copyright © 2017年 BmMac. All rights reserved.
//

#import "ArchiveManager.h"

typedef void (^ManagerStringBlock)(NSString *string);

@implementation ArchiveManager

/* 单例控制器 */
+ (instancetype)manager {
    return [[self alloc] init];
}

static ArchiveManager *instance = nil;
static dispatch_once_t onceToken;
- (instancetype)init {
    dispatch_once(&onceToken, ^{
        instance = [super init];
        
        _cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        _fileManager = [NSFileManager defaultManager];
    });
    return instance;
}

#pragma mark - 从Url获取对应文件
- (void)startRequest:(NSString *)urlString
{
    __weak __typeof(self)weakSelf = self;
    // 定义文件夹名称。压缩包名为文件夹名称
    NSString *folderName = [[urlString lastPathComponent] stringByDeletingPathExtension];
    // 文件夹路径
    NSString *folderPath = [_cachesPath stringByAppendingPathComponent:folderName];
    
    if ([self directoryExists:folderPath]) {
        // 存在文件夹则之间返回
        if (self.arrayBlock) {
            self.arrayBlock(folderPath, [self fileList:folderPath]);
        }
    }else{
        // 不存在文件夹则下载、创建、解压
        [self downloadField:urlString block:^(NSString *filePath) {
            if (filePath) {
                NSString *resultPath = [_cachesPath stringByAppendingPathComponent:folderName];
                if ([weakSelf createFolderWithPath:resultPath]) {
                    [weakSelf releaseZipFiles:filePath unzipPath:resultPath];
                }else{
                    // 创建文件夹失败
                }
            }else{
                // 下载文件失败
            }
        }];
    }
}

#pragma mark - 文件处理
#pragma mark 检测目录文件夹是否存在
/**
 检测目录文件夹是否存在
 
 @param directoryPath 目录路径
 @return 是否存在
 */
- (BOOL)directoryExists:(NSString *)directoryPath
{
    BOOL isDir = NO;
    BOOL isDirExist = [_fileManager fileExistsAtPath:directoryPath isDirectory:&isDir];
    if (isDir && isDirExist) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark 获取文件夹下所有文件列表。
- (NSArray *)fileList:(NSString *)directoryPath
{
    return [[_fileManager contentsOfDirectoryAtPath:directoryPath error:nil] mutableCopy];
}

#pragma mark 下载文件。目录文件夹不存在，那么这步
- (void)downloadField:(NSString *)urlString block:(ManagerStringBlock)block
{
    // 创建会话管理者
    AFHTTPSessionManager *manager =[AFHTTPSessionManager manager];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    // 下载文件
    [[manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        NSString *fullPath = [_cachesPath stringByAppendingPathComponent:response.suggestedFilename];
        
        // 返回一个URL, 返回的这个URL就是文件的位置的完整路径
        return [NSURL fileURLWithPath:fullPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (block) {
            block([filePath path]);
        }
    }] resume];
}


#pragma mark 创建文件夹。下载完文件，文件需要解压到这个文件夹
- (BOOL)createFolderWithPath:(NSString *)folderPath
{
    // 在路径下创建文件夹
    return [_fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
}

#pragma mark - SSZipArchive
#pragma mark 解压
- (void)releaseZipFiles:(NSString *)zipPath unzipPath:(NSString *)unzipPath{
    if ([SSZipArchive unzipFileAtPath:zipPath toDestination:unzipPath delegate:self]) {
    }else {
        // NSLog(@"解压失败");
    }
}

#pragma mark SSZipArchiveDelegate
- (void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath
{
    // 解压会出现多余的文件夹__MACOSX，删除掉吧
    NSString *invalidFolder = [unzippedPath stringByAppendingPathComponent:@"__MACOSX"];
    [_fileManager removeItemAtPath:invalidFolder error:nil];
    /*
    // 或者过滤数组，只取所需要的png文件名
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF ENDSWITH %@", @".png"];
    NSArray *reslutFilteredArray = [fileList filteredArrayUsingPredicate:predicate];
    */
    NSArray *fileList = [self fileList:unzippedPath];
    if (self.arrayBlock) {
        self.arrayBlock(unzippedPath, fileList);
    }
}

@end
