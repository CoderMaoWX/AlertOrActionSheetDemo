//
//  ThirdViewController.m
//  AlertOrActionSheetDemo
//
//  Created by Luke on 2017/1/3.
//  Copyright © 2017年 okdeer. All rights reserved.
//

#import "ThirdViewController.h"
#import "OKAlertController.h"

@interface ThirdViewController ()

@end

@implementation ThirdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [OKAlertController alertWithCallBackBlock:^(NSInteger buttonIndex) {
        //这里直接调用self，不会对当前对象造成循环应用，因为弹框用的方法为类方法
        [self showToast:buttonIndex];
        
    } title:@"温馨提示" message:@"显示两个以上按钮" cancelButtonName:nil otherButtonTitles:nil];
}

- (void)showToast:(NSInteger)buttonIndex
{
    NSString *tip = [NSString stringWithFormat:@"点击了第%zd个按钮",buttonIndex];
    ShowAlertToast(tip);
}

- (void)dealloc
{
    NSLog(@"释放当前控制器，ThirdViewController");
}

@end
