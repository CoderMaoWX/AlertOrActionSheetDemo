//
//  UIButton+OKExtension.m
//  SendHttpDemo
//
//  Created by mao wangxin on 2016/12/28.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import "UIButton+OKExtension.h"

@implementation UIButton (OKExtension)


#pragma mark - ============ 设置按钮不同状态的背景颜色 ============

/**
 *  设置按钮不同状态的背景颜色（代替图片）
 */
- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state
{
    [self setBackgroundImage:[self ok_imageWithColor:backgroundColor] forState:state];
}

- (UIImage *)ok_imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


@end
