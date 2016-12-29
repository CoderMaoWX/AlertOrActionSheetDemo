//
//  UIButton+CCExtension.m
//  Okdeer-jieshun-parkinglot
//
//  Created by mao wangxin on 2016/11/21.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import "UIButton+CCExtension.h"
#import <objc/runtime.h>

static const void *UIButtonBlockKey = &UIButtonBlockKey;

@implementation UIButton (CCExtension)

#pragma mark - ============ 给按钮点击事件 ============

-(void)addTouchUpInsideHandler:(TouchedBlock)handler
{
    objc_setAssociatedObject(self, UIButtonBlockKey, handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(cc_touchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)cc_touchUpInsideAction:(UIButton *)btn{
    TouchedBlock block = objc_getAssociatedObject(self, UIButtonBlockKey);
    if (block) {
        block(btn);
    }
}

#pragma mark - ============ 给按钮设置状态颜色 ============

/**
 *  设置按钮背景颜色
 */
- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state
{
    [self setBackgroundImage:[UIButton imageWithColor:backgroundColor] forState:state];
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - ============ 设置按钮的属性文字 ============

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
                       alignment:(NSTextAlignment)alignment
{
    if (textArr.count >0 && fontArr.count >0 && colorArr.count > 0) {
        
        NSMutableString *allString = [NSMutableString string];
        for (NSString *tempText in textArr) {
            [allString appendFormat:@"%@",tempText];
        }
        
        NSRange lastTextRange = NSMakeRange(0, 0);
        NSMutableArray *rangeArr = [NSMutableArray array];
        
        for (NSString *tempText in textArr) {
            NSRange range = [allString rangeOfString:tempText];
            
            //如果存在相同字符,则换一种查找的方法
            if ([allString componentsSeparatedByString:tempText].count>2) { //存在多个相同字符
                range = NSMakeRange(lastTextRange.location+lastTextRange.length, tempText.length);
            }
            
            [rangeArr addObject:NSStringFromRange(range)];
            lastTextRange = range;
        }
        
        //设置属性文字
        NSMutableAttributedString *textAttr = [[NSMutableAttributedString alloc] initWithString:allString];
        for (int i=0; i<textArr.count; i++) {
            NSRange range = NSRangeFromString(rangeArr[i]);
            
            UIFont *font = (i > fontArr.count-1) ? [fontArr lastObject] : fontArr[i];
            [textAttr addAttribute:NSFontAttributeName value:font range:range];
            
            UIColor *color = (i > colorArr.count-1) ? [colorArr lastObject] : colorArr[i];
            [textAttr addAttribute:NSForegroundColorAttributeName value:color range:range];
        }
        
        //如果需要换行
        if ([allString rangeOfString:@"\n"].location != NSNotFound) {
            self.titleLabel.numberOfLines = 0;
        }
        
        [self setAttributedTitle:textAttr forState:0];
        
        //段落 <如果有换行 或者 字体宽度超过一行就设置行间距>
        if (self.frame.size.width > [UIScreen mainScreen].bounds.size.width || [allString rangeOfString:@"\n"].location != NSNotFound) {
            NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineSpacing = spacing;
            paragraphStyle.alignment = alignment;
            self.titleLabel.numberOfLines = 0;
            [textAttr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0,allString.length)];
            [self setAttributedTitle:textAttr forState:0];
        }
        
    } else {
        [self setTitle:@"文字,颜色,字体 每个数组至少有一个" forState:0];
    }
}



@end
