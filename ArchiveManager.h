//
//  ArchiveManager.h
//  解压压缩
//
//  Created by BmMac on 2017/4/28.
//  Copyright © 2017年 BmMac. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AFNetworking.h>
#import <SSZipArchive.h>

typedef void (^ManagerArrayBlock)(NSString *hostPath, NSArray *array);

@interface ArchiveManager : NSObject<SSZipArchiveDelegate>

@property (nonatomic, strong) NSString *cachesPath;

@property (nonatomic, strong) NSFileManager *fileManager;

@property (nonatomic, copy) ManagerArrayBlock arrayBlock;

+ (instancetype)manager;

- (void)startRequest:(NSString *)urlString;

@end
