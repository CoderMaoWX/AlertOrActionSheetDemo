//
//  ThirdViewController.m
//  AlertOrActionSheetDemo
//
//  Created by Luke on 2017/1/3.
//  Copyright © 2017年 okdeer. All rights reserved.
//

#import "ThirdViewController.h"
#import "OKAlertView.h"

@interface ThirdViewController ()

@end

@implementation ThirdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [OKAlertView alertWithCallBlock:^(NSInteger buttonIndex) {
        //这里直接调用self，不会对当前对象造成循环应用，因为弹框用的方法为类方法
        NSString *tip = [NSString stringWithFormat:@"点击了第%zd个按钮",buttonIndex];
        ShowAlertToast(tip);
        
    } title:@"温馨提示" message:@"显示两个以上按钮" cancelButtonTitle:nil otherButtonTitles:nil];
}

- (void)dealloc
{
    NSLog(@"释放当前控制器，ThirdViewController");
}

@end
