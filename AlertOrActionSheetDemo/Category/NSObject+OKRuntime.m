//
//  NSObject+CCRuntime.m
//  基础框架类
//
//  Created by 雷祥 on 16/12/26.
//  Copyright © 2016年 leixiang. All rights reserved.
//

#import "NSObject+OKRuntime.h"
#import <objc/message.h>

@implementation NSObject (OKRuntime)
/**
 * 获取成员变量
 */
+ (NSArray *)ok_memberVaribaleNames {
    unsigned int numIvars;
    Ivar * vars = class_copyIvarList(self, &numIvars);
    NSMutableArray *tempResultArr = [NSMutableArray arrayWithCapacity:numIvars];
    for (NSInteger i = 0; i < numIvars; i++) {
        Ivar thisIvar = vars[i];
        NSString *varibleName = [NSString stringWithUTF8String:ivar_getName(thisIvar)]; //获取成员变量名字
        NSLog(@"ok_memberVaribaleNames===%@",varibleName);
        [tempResultArr addObject:varibleName];
    }
    free(vars);

    return [NSArray arrayWithArray:tempResultArr];
}

/**
 * 获取类的属性名数组(只是声明property的成员变量)
 */
+ (NSArray *)ok_propertyNames {
    unsigned int numPropertys;
    objc_property_t *propertys = class_copyPropertyList(self, &numPropertys);
    NSMutableArray *tempResultArr = [NSMutableArray arrayWithCapacity:numPropertys];
    for (NSInteger i = 0; i < numPropertys; i++) {
        objc_property_t thisProperty = propertys[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(thisProperty)];
        NSLog(@"ok_propertyNames-----%@",propertyName);
        [tempResultArr addObject:propertyName];
    }
    free(propertys);

    return [NSArray arrayWithArray:tempResultArr];
}

/**
 * 获取类方法名数组(当前类定义的，不包括父类中的方法)
 */
+ (NSArray *)ok_methodNames {
    unsigned int numMethods;
    Method *methods = class_copyMethodList(self, &numMethods);
    NSMutableArray *tempResultArr = [NSMutableArray arrayWithCapacity:numMethods];
    for (NSInteger i = 0; i < numMethods; i++) {
        Method method = methods[i];
        SEL sel = method_getName(method);
        NSString *selName = [NSString stringWithUTF8String:sel_getName(sel)];
        [tempResultArr addObject:selName];
    }
    free(methods);

    return [NSArray arrayWithArray:tempResultArr];
}


/**
 *  校验一个类是否有该属性
 */
+ (BOOL)ok_hasVarName:(NSString *)name
{
    unsigned int outCount;
    BOOL hasProperty = NO;
    Ivar *ivars = class_copyIvarList([self class], &outCount);
    for (int i = 0; i < outCount; i++)
    {
        Ivar property = ivars[i];
        NSString *keyName = [NSString stringWithCString:ivar_getName(property) encoding:NSUTF8StringEncoding];
        keyName = [keyName stringByReplacingOccurrencesOfString:@"_" withString:@""];

        NSString *absoluteName = [NSString stringWithString:name];
        absoluteName = [absoluteName stringByReplacingOccurrencesOfString:@"_" withString:@""];
        if ([keyName isEqualToString:absoluteName]) {
            hasProperty = YES;
            break;
        }
    }
    //释放
    free(ivars);
    return hasProperty;
}


/**
 *  交换两个类方法的实现
 *
 *  @param class          类名
 *  @param originSelector 原始方法
 *  @param otherSelector  需要覆盖原始的方法
 */
+ (void)ok_exchangeClassMethod:(Class)class originSelector:(SEL)originSelector otherSelector:(SEL)otherSelector
{
    Method otherMehtod = class_getClassMethod(class, otherSelector);
    Method originMehtod = class_getClassMethod(class, originSelector);
    method_exchangeImplementations(otherMehtod, originMehtod);
}

/**
 *  交换两个实例方法的实现
 *
 *  @param class          类名
 *  @param originSelector 原始方法
 *  @param otherSelector  需要覆盖原始的方法
 */
+ (void)ok_exchangeInstanceMethod:(Class)class originSelector:(SEL)originSelector otherSelector:(SEL)otherSelector
{
    Method otherMehtod = class_getInstanceMethod(class, otherSelector);
    Method originMehtod = class_getInstanceMethod(class, originSelector);
    method_exchangeImplementations(otherMehtod, originMehtod);
}




/**
 *  创建setter方法
 *
 *  @param propertyName 方法名
 *
 *  @return 方法
 */
+ (SEL)creatSetterWithPropertyName:(NSString *)propertyName {
    if (propertyName.length == 0) {
        return nil;
    }

    return NSSelectorFromString([NSString stringWithFormat:@"set%@:",[propertyName capitalizedString]]);
}

+ (SEL) creatGetterWithPropertyName: (NSString *) propertyName{
    if (propertyName.length == 0) {
        return nil;
    }
    //1.返回get方法: oc中的get方法就是属性的本身
    return NSSelectorFromString(propertyName);
}



@end
