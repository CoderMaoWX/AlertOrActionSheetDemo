//
//  FirstViewController.m
//  AlertOrActionSheetDemo
//
//  Created by mao wangxin on 2016/12/29.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import "FirstViewController.h"
#import "OKActionSheetView.h"
#import "OKAlertView.h"


@implementation FirstViewController

/**
 * 可以在程序启动后,初始化OKActionSheetView单个控件的主题色, App设置一次全局生效
 */
+ (void)initialize {
    //设置全局标题主题色
    //    NSMutableDictionary *dict0 = [NSMutableDictionary dictionary];
    //    dict0[NSForegroundColorAttributeName] = [UIColor redColor];
    //    [OKActionSheetView appearance].titleTextAttributes = dict0;

    //设置全局其他按钮主题色
    //    NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
    //    dict2[NSForegroundColorAttributeName] = [UIColor purpleColor];
    //    [OKActionSheetView appearance].otherBtnTitleAttributes = dict2;

    //设置全局取消按钮主题色
    //    NSMutableDictionary *dict3 = [NSMutableDictionary dictionary];
    //    dict3[NSForegroundColorAttributeName] = [UIColor blueColor];
    //    [OKActionSheetView appearance].cancelBtnTitleAttributes = dict3;
}


/**
 * 顶部下拉弹框
 */
- (IBAction)style1Action:(UIButton *)sender
{
    NSArray *btnImgNameArr = @[@"commonQut-nor",@"commonQut-nor",@"commonQut-nor",@"commonQut-nor",@"commonQut-nor",@"commonQut-nor",@"commonQut-nor"];
    NSArray *btnTitleArr = @[@"常见问题1",@"常见问题2",@"常见问题3",@"常见问题4",@"常见问题5",@"常见问题6",@"常见问题7"];

    [OKActionSheetView actionSheetByTopSquare:^(NSInteger buttonIndex) {
        ShowAlertToast([NSString stringWithFormat:@"点击了第%zd行",buttonIndex]);
        
    } cancelButtonBlock:^{
        ShowAlertToast(@"点击取消按钮");
        
    } superView:self.view position:CGPointMake(0, 64) buttonTitleArr:btnTitleArr buttonImageArr:btnImgNameArr];
}


/**
 * 底部上拉弹框直角
 */
- (IBAction)style2Action:(UIButton *)sender{
    NSString *title = @"人在临死的时候最明白一切都是过眼云烟";
    NSArray *otherTitleArr = @[@"按钮1",@"按钮2",@"按钮3",@"按钮4",@"按钮5",@"按钮6",@"按钮7",@"按钮8"];

    [OKActionSheetView actionSheetByBottomSquare:^(NSInteger buttonIndex) {
        ShowAlertToast([NSString stringWithFormat:@"点击了第%zd个按钮",buttonIndex]);

    } cancelButtonBlock:^{
        ShowAlertToast(@"点击取消按钮");
        
    } WithTitle:title cancelButtonTitle:@"取消" otherButtonTitleArr:otherTitleArr];
}

/**
 * 底部上拉弹框圆角
 */
- (IBAction)style3Action:(UIButton *)sender{
    NSString *title = @"生命是个过程，死亡只是必然的结果，但轨迹是自己的色彩和温度，既然不可避免，那么就更无所畏惧。";
    NSArray *otherTitleArr = @[@"按钮1",@"按钮2",@"按钮3",@"按钮4",@"按钮5",@"按钮6",@"按钮7",@"按钮8"];

    [OKActionSheetView actionSheetByBottomCornerRadius:^(NSInteger buttonIndex) {
        ShowAlertToast([NSString stringWithFormat:@"点击了第%zd行",buttonIndex]);

    } cancelButtonBlock:^ {
        ShowAlertToast(@"点击取消按钮");
        
    } WithTitle:title cancelButtonTitle:@"取消" otherButtonTitleArr:otherTitleArr];
}


@end
