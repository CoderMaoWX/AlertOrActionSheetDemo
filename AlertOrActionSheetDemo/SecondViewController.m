//
//  SecondViewController.m
//  AlertOrActionSheetDemo
//
//  Created by mao wangxin on 2016/12/29.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import "SecondViewController.h"
#import "OKAlertView.h"

@implementation SecondViewController

/**
 * 可以在程序启动后,初始化OKAlertView单个控件的主题色, App设置一次全局生效
 */
+ (void)initialize {
    //设置全局标题主题色
//    NSMutableDictionary *dict0 = [NSMutableDictionary dictionary];
//    dict0[NSForegroundColorAttributeName] = [UIColor redColor];
//    [OKAlertView appearance].titleTextAttributes = dict0;

    //设置全局信息主题色
//    NSMutableDictionary *dict1 = [NSMutableDictionary dictionary];
//    dict1[NSFontAttributeName] = [UIFont systemFontOfSize:20];
//    dict1[NSForegroundColorAttributeName] = [UIColor greenColor];
//    [OKAlertView appearance].messageTextAttributes = dict1;

//    //设置全局其他按钮主题色
//    NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
//    dict2[NSForegroundColorAttributeName] = [UIColor purpleColor];
//    [OKAlertView appearance].otherBtnTitleAttributes = dict2;

    //设置全局取消按钮主题色
//    NSMutableDictionary *dict3 = [NSMutableDictionary dictionary];
//    dict3[NSForegroundColorAttributeName] = [UIColor redColor];
//    [OKAlertView appearance].themeColorBtnTitleAttributes = dict3;
}


/**
 * 测试同时弹多个提示框
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self styleAction0:nil];
    [self styleAction0:[UIButton new]];
}

/**
 * 普通弹框
 */
- (IBAction)styleAction0:(UIButton *)sender
{
    NSString *tipStr = sender ? @"第2个弹框标题" : @"第1个弹框标题";
    
    [OKAlertView alertWithCallBlock:^(NSInteger buttonIndex, id title) {
        ShowAlertToast(title);

    } title:@"温馨提示" message:tipStr cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
}

/**
 * 弹框显示三个按钮
 */
- (IBAction)styleAction1:(UIButton *)sender
{
    NSString *titleStr = @"温馨提示";
    NSString *msgStr = @"显示两个以上按钮";
    
    NSMutableAttributedString *titleAttr = [[NSMutableAttributedString alloc] initWithString:titleStr];
    [titleAttr setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:22],NSForegroundColorAttributeName:[UIColor yellowColor]} range:NSMakeRange(0, 2)];
    
    NSMutableAttributedString *msgAttr = [[NSMutableAttributedString alloc] initWithString:msgStr];
    [msgAttr setAttributes:@{NSForegroundColorAttributeName:[UIColor cyanColor], NSFontAttributeName:[UIFont systemFontOfSize:30]} range:NSMakeRange(2, 2)];

    NSMutableAttributedString *buttonTitleAttr = [[NSMutableAttributedString alloc] initWithString:@"确定测试一下"];
    [buttonTitleAttr setAttributes:@{NSForegroundColorAttributeName:[UIColor redColor], NSFontAttributeName:[UIFont systemFontOfSize:30]} range:NSMakeRange(2, 2)];
    
    [OKAlertView alertWithCallBlock:^(NSInteger buttonIndex, id title) {
		if ([buttonTitleAttr isEqual:title]) {
			NSLog(@"两个标题一直");
		}
        ShowAlertToast(title);

    } title:titleAttr message:msgAttr cancelButtonTitle:@"取消" otherButtonTitles:@"确定1",buttonTitleAttr,@"确定3", nil];
}

/**
 * 输入弹框
 */
- (IBAction)styleAction2:(UIButton *)sender
{
    [OKAlertView inputAlertWithTitle:@"请输入"
                         placeholder:@"输入弹框控件"
                         cancelTitle:@"取消"
                          otherTitle:@"确定"
                        keyboardType:UIKeyboardTypeDefault
                         buttonBlock:^(NSString *inputText) {
                             ShowAlertToast([NSString stringWithFormat:@"您输入了:\n%@",inputText]);
                         } cancelBlock:^{
                             ShowAlertToast(@"点击了取消按钮");
                         }];
}

@end
