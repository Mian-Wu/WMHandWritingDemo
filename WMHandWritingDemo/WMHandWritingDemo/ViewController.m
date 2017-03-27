//
//  ViewController.m
//  WMHandWritingDemo
//
//  Created by 吴冕 on 2017/3/27.
//  Copyright © 2017年 wumian. All rights reserved.
//

#import "ViewController.h"
#import "WMView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    imageView.image = [UIImage imageNamed:@"bg-1"];
    [self.view insertSubview:imageView atIndex:0];
    
    
    WMView *viewPoem = [[WMView alloc]initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 50) message:@"大家好"];
    
    [self.view addSubview:viewPoem];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
