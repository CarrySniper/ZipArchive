//
//  ViewController.m
//  解压压缩
//
//  Created by BmMac on 2017/4/28.
//  Copyright © 2017年 BmMac. All rights reserved.
//

#import "ViewController.h"
#import "ArchiveManager.h"

@interface ViewController ()<SSZipArchiveDelegate>{
    UIImageView *imageView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    imageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:imageView];
    
    NSString *urlString = @"http://alcdn.img.xiaoka.tv/20160707/00d/09d/0/00d09db1a1bda19b6fa8fa0fd7d385ed.zip";
    
    [[ArchiveManager manager] setArrayBlock:^(NSString *hostPath, NSArray *nameArray){
        NSMutableArray *array = [NSMutableArray array];
        for (NSString *name in nameArray) {
            NSString *fullPath = [hostPath stringByAppendingPathComponent:name];
            UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
            if (savedImage) {
                [array addObject:savedImage];
            }
        }
        imageView.animationImages = array;
        imageView.animationDuration = array.count * 0.1f;   // 0.1秒一张
        imageView.animationRepeatCount = 10;
        [imageView startAnimating];
    }];
    [[ArchiveManager manager] startRequest:urlString];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
