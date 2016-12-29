//
//  UIButton+CCExtension.h
//  Okdeer-jieshun-parkinglot
//
//  Created by mao wangxin on 2016/11/21.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TouchedBlock)(UIButton *btn);

@interface UIButton (CCExtension)


-(void)addTouchUpInsideHandler:(TouchedBlock)handler;

//button不同状态的背景颜色（代替图片）
- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;

/**
 *  设置属性文字
 *
 *  @param textArr   需要显示的文字数组,如果有换行请在文字中添加 "\n"换行符
 *  @param fontArr   字体数组, 如果fontArr与textArr个数不相同则获取字体数组中最后一个字体
 *  @param colorArr  颜色数组, 如果colorArr与textArr个数不相同则获取字体数组中最后一个颜色
 *  @param spacing   换行的行间距
 *  @param alignment 换行的文字对齐方式
 */
- (void)setAttriStrWithTextArray:(NSArray *)textArr
                         fontArr:(NSArray *)fontArr
                        colorArr:(NSArray *)colorArr
                     lineSpacing:(CGFloat)spacing
                       alignment:(NSTextAlignment)alignment;

@end
