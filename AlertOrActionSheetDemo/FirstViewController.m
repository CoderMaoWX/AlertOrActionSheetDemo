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
 * 顶部下拉弹框
 */
- (IBAction)style1Action:(UIButton *)sender
{
    [OKActionSheetView actionSheetByTopSquare:^(NSInteger buttonIndex) {
        NSString *tip = [NSString stringWithFormat:@"点击了第%zd行",buttonIndex];
        ShowAlertToast(tip);
        
    } cancelBlock:^{
        ShowAlertToast(@"点击背景取消");
        
    } superView:self.view position:CGPointMake(0, 64) buttonTitleArr:@[@"我的车辆",@"添加车辆",@"常见问题1",@"常见问题2",@"常见问题3",@"常见问题4",@"常见问题5"] buttonImageArr:@[@"myCar-nor",@"addCar-nor",@"commonQut-nor",@"commonQut-nor",@"commonQut-nor",@"commonQut-nor",@"commonQut-nor"]];
}


/**
 * 底部上拉弹框直角
 */
- (IBAction)style2Action:(UIButton *)sender
{
    [OKActionSheetView actionSheetByBottomSquare:^(NSInteger buttonIndex) {
        NSString *tip = [NSString stringWithFormat:@"点击了第%zd个按钮",buttonIndex];
        ShowAlertToast(tip);
    } cancelBlock:^{
        ShowAlertToast(@"点击背景取消");
        
    } WithTitle:@"测试底部按钮" cancelButtonTitle:@"取消" otherButtonTitleArr:@[@"按钮1",@"按钮2",@"按钮3",@"按钮4",@"按钮5",@"按钮6",@"按钮7",@"按钮8"]];
}

/**
 * 底部上拉弹框圆角
 */
- (IBAction)style3Action:(UIButton *)sender
{
    [OKActionSheetView actionSheetByBottomCornerRadius:^(NSInteger buttonIndex) {
        NSString *tip = [NSString stringWithFormat:@"点击了第%zd行",buttonIndex];
        ShowAlertToast(tip);
        
    } cancelBlock:^{
        ShowAlertToast(@"点击背景取消");
        
    } WithTitle:@"测试底部按钮" cancelButtonTitle:@"取消" otherButtonTitleArr:@[@"按钮1",@"按钮2",@"按钮3",@"按钮4",@"按钮5",@"按钮6",@"按钮7",@"按钮8"]];
}

/**
 判断传入一个数大于10
 */
- (BOOL)judgeNumGreaterTen:(NSInteger)number
{
    if (number > 10) {
        return YES;
    } else {
        return NO;
    }
}

@end
