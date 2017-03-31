//
//  NSString+Extention.h
//  基础框架类
//
//  Created by 雷祥 on 16/12/26.
//  Copyright © 2016年 leixiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (OKExtension)
/**
 * 判断是否包含
 */
- (BOOL)ok_containsString:(NSString *)str;

/**
 * 是否是有效的范围(range不超过字符串长度)
 */
- (BOOL)ok_isValidRange:(NSRange)range;

/**
 * 字符串长度是否在给定的range范围内(闭区间)
 */
- (BOOL)ok_lengthInRange:(NSRange)range;

/**
 * 转化为字典
 */
- (NSDictionary *)toDictionary ;

/**
 * 判断是否是有效价格
 */
- (BOOL)ok_validPrice;

/**
 * 是否是正数
 */
- (BOOL)ok_isPositiveNumber;

//对特殊字符编码(没有"%"和"／"进行了编码，没有"#")
- (NSString *)ok_urlStringEncoding;

//对参数进行编码（对"%"和"／"进行了编码，没有"#"）
- (NSString *)ok_parameterEncoding;
/**
 *  判断是不是http字符串（在传图片时，判断是本地图片或者是网络图片）
 *  @return
 */
- (BOOL)ok_isHttpString;

/**
 *  替换掉表情
 *
 *  @return 替换掉后的文字
 */
- (NSString *)disable_emoji;

/**
 * 是否是表情
 */
- (BOOL)hasEmoji;

/**
 * 拼接token
 */
- (NSString *)ok_appendToken:(NSString *)token;


#pragma mark - /*** 添加部分方法 add by chenzl ***/
/**
 计算高度或宽度   返回 大小
 @parm font  字体
 @parm size  限制的宽度或高度
 */
- (CGSize )calculateheight:(UIFont *)font andcontSize:(CGSize )size;
/**
 *  根据字体大小 计算
 */
- (CGSize)calculateheight:(UIFont *)font;

/**
 *  @brief 计算文字的高度
 *
 *  @param font  字体(默认为系统字体)
 *  @param width 约束宽度
 */
- (CGFloat)heightWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width;
/**
 *  @brief 计算文字的宽度
 *
 *  @param font   字体(默认为系统字体)
 *  @param height 约束高度
 */
- (CGFloat)widthWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height;
/**
 *  @brief 计算文字的大小
 *
 *  @param font  字体(默认为系统字体)
 *  @param width 约束宽度
 */
- (CGSize)sizeWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width;
/**
 *  @brief 计算文字的大小
 *
 *  @param font   字体(默认为系统字体)
 *  @param height 约束高度
 */
- (CGSize)sizeWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height;




@end
