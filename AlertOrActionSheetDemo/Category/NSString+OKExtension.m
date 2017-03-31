//
//  NSString+Extention.m
//  基础框架类
//
//  Created by 雷祥 on 16/12/26.
//  Copyright © 2016年 leixiang. All rights reserved.
//

#import "NSString+OKExtension.h"
#import <UIKit/UIKit.h>

@implementation NSString (OKExtension)
/**
 * 判断是否包含
 */
-(BOOL)ok_containsString:(NSString *)str {
    //不是字符串
    if (![str isKindOfClass:[NSString class]]) {
        return NO;
    }

    if ([[UIDevice currentDevice] systemVersion].floatValue >= 8.0) {
        return [self containsString:str];
    }
    else {
        NSRange range = [str rangeOfString:self];
        if (range.location == NSNotFound) {
            return NO;
        }
        else {
            return YES;
        }
    }
}

/**
 * 是否时有效的范围
 */
- (BOOL)ok_isValidRange:(NSRange)range {
    if (range.location + range.length > self.length) {
        return NO;
    }
    else {
        return YES;
    }
}

/**
 * 字符串长度是否在给定的range范围内
 */
- (BOOL)ok_lengthInRange:(NSRange)range {
    if (self.length >= range.location && self.length <= (range.location + range.length)) {
        return YES;
    }
    else {
        return NO;
    }
}

/**
 * 转化为字典
 */
- (NSDictionary *)toDictionary {
    NSData *jsonData = [self dataUsingEncoding:(NSUTF8StringEncoding)];
    NSError *errer;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&errer];
    if (errer) {
        return nil;
    }

    return dic;
}

/**
 * 判断是否是有效价格
 */
- (BOOL)ok_validPrice {
    NSString *regex = @"^[0-9]+(\\.[0-9]{1,2})?$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [predicate evaluateWithObject:self];

}

/**
 * 是否是正数
 */
- (BOOL)ok_isPositiveNumber {
    NSString *regex = @"^[1-9][0-9]*$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [predicate evaluateWithObject:self];
}


//对特殊字符编码(不包含#)
- (NSString *)ok_urlStringEncoding {
    NSCharacterSet *uRLCombinedCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@" \"+<>[\\]^`{|}"] invertedSet];
    return [self stringByAddingPercentEncodingWithAllowedCharacters:uRLCombinedCharacterSet];
}

//对参数进行编码
- (NSString *)ok_parameterEncoding {
    NSCharacterSet *uRLCombinedCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@" \"+%<>[\\]^`{|}/"] invertedSet];   //对"%"和"／"进行了编码
    return [self stringByAddingPercentEncodingWithAllowedCharacters:uRLCombinedCharacterSet];
}

/**
 *  判断是不是http字符串（在传图片时，判断是本地图片或者是网络图片）
 *  @return
 */
- (BOOL)ok_isHttpString{

    NSString *httpStrRegex = @"^http[s]{0,1}://.+";
    NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:httpStrRegex options:0 error:nil];
    NSArray *array = [regular matchesInString:self options:0 range:NSMakeRange(0, self.length)];

    return array.count ;
}

/**
 *  替换掉表情
 *
 *  @param inputStr 输入的文字
 *
 *  @return 替换掉后的文字
 */
-(NSString *)disable_emoji{
    __block NSString *noEmoji = self;
    __block BOOL isEmoji = NO ;
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair

         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     noEmoji = [noEmoji stringByReplacingOccurrencesOfString:substring withString:@""];
                     isEmoji = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 noEmoji = [noEmoji stringByReplacingOccurrencesOfString:substring withString:@""];
                 isEmoji = YES;
             }else if (ls >= 0xfe0f){
                 isEmoji = YES;
                 noEmoji = [noEmoji stringByReplacingOccurrencesOfString:substring withString:@""] ;
             }

         } else {
             // non surrogate

             if (hs >= 0x2500 && hs<= 0x254b) {

             }else if (0x2100 <= hs && hs <= 0x27ff && hs != 0x22ef && hs != 0x263b) {
                 noEmoji = [noEmoji stringByReplacingOccurrencesOfString:substring withString:@""];
                 isEmoji = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 noEmoji = [noEmoji stringByReplacingOccurrencesOfString:substring withString:@""];
                 isEmoji = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 noEmoji = [noEmoji stringByReplacingOccurrencesOfString:substring withString:@""];
                 isEmoji = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 noEmoji = [noEmoji stringByReplacingOccurrencesOfString:substring withString:@""];
                 isEmoji = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50 || hs == 0x231a ) {
                 noEmoji = [noEmoji stringByReplacingOccurrencesOfString:substring withString:@""];
                 isEmoji = YES;
             }
         }
     }];
    
    return noEmoji;
}


-(BOOL)hasEmoji {
    NSString *noEmoji = [self disable_emoji];
    return  [self isEqualToString:noEmoji];
}

/**
 * 拼接token
 */
- (NSString *)ok_appendToken:(NSString *)token {
    if (!token.length) {
        token = @"";
    }

    NSString *str = [self copy];
    NSRange rang = [str rangeOfString:@"?"];
    if (rang.location == NSNotFound) {
        str = [NSString stringWithFormat:@"%@%@token=%@",str,@"?",token];
    }else{
        str = [NSString stringWithFormat:@"%@%@token=%@",str,@"&",token];
    }
    return str;
}


#pragma mark - /*** 添加部分方法 add by chenzl ***/
/**
 计算高度或宽度   返回 大小
 @parm font  字体
 @parm size  限制的宽度或高度
 */
- (CGSize )calculateheight:(UIFont *)font andcontSize:(CGSize )size{
    if (self.length == 0 || !font) {
        return CGSizeMake(0, 0);
    }
    CGSize contSize ;
    
    CGRect oldframe = [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    contSize = oldframe.size;
    
    return contSize ;
}
/**
 *  根据字体大小 计算
 */
- (CGSize)calculateheight:(UIFont *)font
{
    CGSize contSize = CGSizeZero;
    if (!font ) {
        return contSize;
    }else if (self.length ==0 ){
        return contSize;
    }
    
    contSize = [self sizeWithAttributes:@{NSFontAttributeName:font}];
    return contSize;
}


- (CGFloat)heightWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width
{
    
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGSize textSize;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                     NSParagraphStyleAttributeName: paragraph};
        textSize = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                      options:(NSStringDrawingUsesLineFragmentOrigin |
                                               NSStringDrawingTruncatesLastVisibleLine)
                                   attributes:attributes
                                      context:nil].size;
    } else {
        textSize = [self sizeWithFont:textFont
                    constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                        lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                 NSParagraphStyleAttributeName: paragraph};
    textSize = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                  options:(NSStringDrawingUsesLineFragmentOrigin |
                                           NSStringDrawingTruncatesLastVisibleLine)
                               attributes:attributes
                                  context:nil].size;
#endif
    
    return ceil(textSize.height);
}

- (CGFloat)widthWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height
{
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGSize textSize;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                     NSParagraphStyleAttributeName: paragraph};
        textSize = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                      options:(NSStringDrawingUsesLineFragmentOrigin |
                                               NSStringDrawingTruncatesLastVisibleLine)
                                   attributes:attributes
                                      context:nil].size;
    } else {
        textSize = [self sizeWithFont:textFont
                    constrainedToSize:CGSizeMake(CGFLOAT_MAX, height)
                        lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                 NSParagraphStyleAttributeName: paragraph};
    textSize = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                  options:(NSStringDrawingUsesLineFragmentOrigin |
                                           NSStringDrawingTruncatesLastVisibleLine)
                               attributes:attributes
                                  context:nil].size;
#endif
    
    return ceil(textSize.width);
}

- (CGSize)sizeWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width
{
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGSize textSize;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                     NSParagraphStyleAttributeName: paragraph};
        textSize = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                      options:(NSStringDrawingUsesLineFragmentOrigin |
                                               NSStringDrawingTruncatesLastVisibleLine)
                                   attributes:attributes
                                      context:nil].size;
    } else {
        textSize = [self sizeWithFont:textFont
                    constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                        lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                 NSParagraphStyleAttributeName: paragraph};
    textSize = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                  options:(NSStringDrawingUsesLineFragmentOrigin |
                                           NSStringDrawingTruncatesLastVisibleLine)
                               attributes:attributes
                                  context:nil].size;
#endif
    
    return CGSizeMake(ceil(textSize.width), ceil(textSize.height));
}

- (CGSize)sizeWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height
{
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGSize textSize;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                     NSParagraphStyleAttributeName: paragraph};
        textSize = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                      options:(NSStringDrawingUsesLineFragmentOrigin |
                                               NSStringDrawingTruncatesLastVisibleLine)
                                   attributes:attributes
                                      context:nil].size;
    } else {
        textSize = [self sizeWithFont:textFont
                    constrainedToSize:CGSizeMake(CGFLOAT_MAX, height)
                        lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                 NSParagraphStyleAttributeName: paragraph};
    textSize = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                  options:(NSStringDrawingUsesLineFragmentOrigin |
                                           NSStringDrawingTruncatesLastVisibleLine)
                               attributes:attributes
                                  context:nil].size;
#endif
    
    return CGSizeMake(ceil(textSize.width), ceil(textSize.height));
}

@end
