//
//  UIButton+OKExtension.h
//  SendHttpDemo
//
//  Created by mao wangxin on 2016/12/28.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TouchedBlock)(UIButton *btn);


@interface UIButton (OKExtension)

/**
 button不同状态的背景颜色（代替图片）
 
 @param backgroundColor 图片代替背景色
 @param state 状态
 */
- (void)setBackgroundColor:(UIColor *)backgroundColor
                  forState:(UIControlState)state;

@end
