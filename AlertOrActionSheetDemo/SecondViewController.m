//
//  SecondViewController.m
//  AlertOrActionSheetDemo
//
//  Created by mao wangxin on 2016/12/29.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import "SecondViewController.h"
#import "OKAlertController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController



/**
 * 普通弹框
 */
- (IBAction)styleAction0:(UIButton *)sender
{
    [OKAlertController alertWithCallBackBlock:^(NSInteger buttonIndex) {
        NSString *tip = [NSString stringWithFormat:@"点击了第%zd个按钮",buttonIndex];
        ShowAlertToast(tip);
        
    } title:nil message:@"普通弹框" cancelButtonName:@"取消" otherButtonTitles:@"确定1",@"确定2", nil];
}


/**
 * 普通弹框
 */
- (IBAction)styleAction1:(UIButton *)sender
{
    [OKAlertController alertWithCallBackBlock:^(NSInteger buttonIndex) {
        NSString *tip = [NSString stringWithFormat:@"点击了第%zd个按钮",buttonIndex];
        ShowAlertToast(tip);
        
    } title:@"温馨提示" message:@"显示两个以上按钮" cancelButtonName:@"取消" otherButtonTitles:@"确定1",@"确定2",@"确定3", nil];
}



/**
 * 输入弹框
 */
- (IBAction)styleAction2:(UIButton *)sender
{
    [OKAlertController inputAlertWithTitle:@"请输入" placeholder:@"输入弹框控件" cancelTitle:@"取消" otherTitle:@"确定" buttonBlock:^(NSString *inputText) {
        NSString *tip = [NSString stringWithFormat:@"您输入了:\n%@",inputText];
        ShowAlertToast(tip);
        
    } cancelBlock:^{
        ShowAlertToast(@"点击了取消按钮");
    }];
}

@end
