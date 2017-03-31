//
//  NSObject+CCRuntime.h
//  基础框架类
//
//  Created by 雷祥 on 16/12/26.
//  Copyright © 2016年 leixiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (OkRuntime)

/**
 * 获取类的成员变量名数组(当前类定义，包括属性定义的成员变量)
 */
+ (NSArray *)ok_memberVaribaleNames;


/**
 * 获取类的属性名数组(当前类定义,只是声明property的成员变量。)
 */
+ (NSArray *)ok_propertyNames;


/**
 * 获取类方法名数组(当前类定义，不包括父类中的方法)
 */
+ (NSArray *)ok_methodNames;


/**
 *  交换两个类方法的实现
 *
 *  @param class          类名
 *  @param originSelector 原始方法
 *  @param otherSelector  需要覆盖原始的方法
 */
+ (void)ok_exchangeClassMethod:(Class)class originSelector:(SEL)originSelector otherSelector:(SEL)otherSelector;

/**
 *  校验一个类是否有该属性
 */
+ (BOOL)ok_hasVarName:(NSString *)name;

/**
 *  交换两个实例方法的实现
 *
 *  @param class          类名
 *  @param originSelector 原始方法
 *  @param otherSelector  需要覆盖原始的方法
 */
+ (void)ok_exchangeInstanceMethod:(Class)class originSelector:(SEL)originSelector otherSelector:(SEL)otherSelector;




@end
