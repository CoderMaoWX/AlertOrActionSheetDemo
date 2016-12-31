//
//  OKAlertController.m
//  OkdeerUser
//
//  Created by mao wangxin on 2016/12/29.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import "OKAlertController.h"
#import <objc/runtime.h>

//进制颜色转换
#define UIColorFromHex(hexValue)                ([UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0x00FF00) >> 8))/255.0 blue:((float)(hexValue & 0x0000FF))/255.0 alpha:1.0])
//获取系统版本
#define KsystemVersion                          [[[UIDevice currentDevice] systemVersion] floatValue]
//弹框字体大小
#define OKAlertContr_font(fontSize)             ([UIFont systemFontOfSize:fontSize])
//弹框黑色字体颜色
#define OKAlertContr_BlackColor                 UIColorFromHex(0x323232)
//弹框草绿色按钮颜色
#define OKAlertContr_MainColor                  UIColorFromHex(0x8CC63F)
//弹框自动消失时间2秒
#define OKAlertContr_dismissTime                2.0

static char const * const UIAlertViewKey        = "UIAlertViewKey";

@implementation UIAlertView (Block)

+ (instancetype)alertWithCallBackBlock:(OKAlertViewCallBackBlock)alertViewCallBackBlock title:(NSString *)title message:(NSString *)message  cancelButtonName:(NSString *)cancelButtonName otherButtonTitles:(NSString *)otherButtonTitles, ...NS_REQUIRES_NIL_TERMINATION {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonName otherButtonTitles: otherButtonTitles, nil];
    NSString *other = nil;
    va_list args;
    if (otherButtonTitles) {
        va_start(args, otherButtonTitles);
        while ((other = va_arg(args, NSString*))) {
            [alert addButtonWithTitle:other];
        }
        va_end(args);
    }
    alert.delegate = alert;
    alert.alertViewCallBackBlock = alertViewCallBackBlock;
    return alert;
}

- (void)setAlertViewCallBackBlock:(OKAlertViewCallBackBlock)alertViewCallBackBlock{
    [self willChangeValueForKey:@"callbackBlock"];
    objc_setAssociatedObject(self, &UIAlertViewKey, alertViewCallBackBlock, OBJC_ASSOCIATION_COPY);
    [self didChangeValueForKey:@"callbackBlock"];
}

- (OKAlertViewCallBackBlock)alertViewCallBackBlock {
    return objc_getAssociatedObject(self, &UIAlertViewKey);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.alertViewCallBackBlock) {
        self.alertViewCallBackBlock(buttonIndex);
    }
}
@end


@implementation OKAlertController

#pragma mark ================================= 系统UIAlertView弹框 ========================

+ (void)alertWithCallBackBlock:(OKAlertViewCallBackBlock)alertViewCallBackBlock
                         title:(NSString *)title
                       message:(NSString *)message
              cancelButtonName:(NSString *)cancelButtonName
             otherButtonTitles:(NSString *)otherButtonTitles, ...NS_REQUIRES_NIL_TERMINATION
{
    if (KsystemVersion < 8.0){ // iOS9以前系统弹框
        
        //移除所有的已存在的 UIAlertView
        [OKAlertController dismissAllAlertViewFromKeyWindow];
        
        UIAlertView *alert = [UIAlertView alertWithCallBackBlock:^(NSInteger buttonIndex) {
            if(alertViewCallBackBlock){
                alertViewCallBackBlock(buttonIndex);
            }
        } title:title message:message cancelButtonName:cancelButtonName otherButtonTitles:otherButtonTitles, nil];
        [[[UIApplication sharedApplication] keyWindow] addSubview:alert];
        [alert show];
        
        
    } else { //ios9以后系统弹框
        
        UIViewController *hasPresentedVC = [[UIApplication sharedApplication] keyWindow].rootViewController.presentedViewController;
        if (hasPresentedVC && [hasPresentedVC isKindOfClass:[UIAlertController class]]) {
            [hasPresentedVC dismissViewControllerAnimated:NO completion:nil];
        } else {
            //hasPresentedVC = [CCUtility obtainCurrentViewController];
            if (hasPresentedVC && [hasPresentedVC isKindOfClass:[UIAlertController class]]) {
                [hasPresentedVC dismissViewControllerAnimated:NO completion:nil];
            }
        }
        
        //获取按钮个数
        NSMutableArray *mutableOtherTitles = [NSMutableArray array];
        va_list otherButtonTitleList;
        va_start(otherButtonTitleList, otherButtonTitles);
        {
            for (NSString *otherButtonTitle = otherButtonTitles; otherButtonTitle != nil; otherButtonTitle = va_arg(otherButtonTitleList, NSString *)) {
                [mutableOtherTitles addObject:otherButtonTitle];
            }
        }
        va_end(otherButtonTitleList);
        
        //按钮至少要有一个
        if(mutableOtherTitles.count == 0 && !cancelButtonName) return;
        
        //防止传入错误参数
        if(title && ![title isKindOfClass:[NSString class]]) {
            title = @"标题错误!";
        }
        
        if(message && ![message isKindOfClass:[NSString class]]) {
            message = @"提示信息错误!";
        }
        
        //弹出ios9以上的系统框
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        
        //添加普通按钮
        void (^addOtherBtn)() = ^(){
            for(int i=0; i<mutableOtherTitles.count; i++) {
                [alertController addAction:[UIAlertAction actionWithTitle:mutableOtherTitles[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    if(alertViewCallBackBlock){
                        
                        if(cancelButtonName){
                            alertViewCallBackBlock(i+1);//取消按钮放在第一个,所以要加1
                        } else {
                            alertViewCallBackBlock(i);
                        }
                    }
                }]];
            }
        };
        
        
        //添加取消按钮
        void (^addCancenBtn)() = ^(){
            if(cancelButtonName) {
                [alertController addAction:[UIAlertAction actionWithTitle:cancelButtonName style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    if(alertViewCallBackBlock){
                        alertViewCallBackBlock(0);
                    }
                }]];
            }
        };
        
        
        /**
         * 多个按钮时,系统布局会有差别,因此需要特定布局
         * 如果普通按钮个数大于一个, 则把 "取消"按钮放最后, 否则放第一个
         */
        if (mutableOtherTitles.count>1) {
            //1.普通按钮放前面
            addOtherBtn();
            
            //2.取消按钮放最后
            if(cancelButtonName) {
                addCancenBtn();
            }
            
        } else {  //普通按钮只有一个的情况
            //1.取消按钮放前面
            if(cancelButtonName) {
                addCancenBtn();
            }
            
            //2.普通按钮放最后
            addOtherBtn();
        }
        
        
        /**<0> 设置每个按钮标题文字颜色*/
        if([OKAlertController getVariableWithClass:[alertController.actions.firstObject class] varName:@"titleTextColor"])
        {
            for(int i = 0;i < alertController.actions.count;i++)
            {
                UIAlertAction *action = alertController.actions[i];
                if(i == alertController.actions.count-1) {
                    //最后一个按钮设置特定颜色
                    [action setValue:OKAlertContr_MainColor forKey:@"titleTextColor"];
                    
                } else {
                    [action setValue:OKAlertContr_BlackColor forKey:@"titleTextColor"];
                }
            }
        }
        
        /**<1> 设置标题字体为细体 */
        if(title && [OKAlertController getVariableWithClass:[alertController class] varName:@"attributedTitle"])
        {
            NSAttributedString *titleAttrs = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:OKAlertContr_BlackColor, NSFontAttributeName: OKAlertContr_font(16)}];
            [alertController setValue:titleAttrs forKey:@"attributedTitle"];
        }
        
        /**<2> 设置提示信息字体为细体 */
        if(message && [OKAlertController getVariableWithClass:[alertController class] varName:@"_attributedMessage"])
        {
            NSAttributedString *messageAttrs = [[NSAttributedString alloc] initWithString:message attributes:@{NSForegroundColorAttributeName:OKAlertContr_BlackColor, NSFontAttributeName: OKAlertContr_font(14)}];
            [alertController setValue:messageAttrs forKey:@"_attributedMessage"];
        }
        
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        [window.rootViewController presentViewController:alertController animated:YES completion:nil];
    }
}


#pragma mark ========================= 系统带输入的UIAlertView弹框 ========================

+ (void)inputAlertWithTitle:(NSString *)title
                placeholder:(NSString *)placeholder
                cancelTitle:(NSString *)cancelTitle
                 otherTitle:(NSString *)otherTitle
                buttonBlock:(void (^)(NSString *inputText))otherBlock
                cancelBlock:(void (^)())cancelBlock
{
    if (KsystemVersion < 8.0){ // iOS9以前系统弹框
        
        //移除所有的已存在的 UIAlertView
        [OKAlertController dismissAllAlertViewFromKeyWindow];
        
        __block UIAlertView *alert = [UIAlertView alertWithCallBackBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                if (cancelBlock) {
                    cancelBlock();
                }
                
            } else if (buttonIndex == 1){
                if (otherBlock) {
                    NSString *inputStr = [[alert textFieldAtIndex:0] text];
                    otherBlock(inputStr);
                }
            }
        } title:title message:nil cancelButtonName:cancelTitle otherButtonTitles:otherTitle, nil];
        
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *textField = [alert textFieldAtIndex:0];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.placeholder = placeholder;
        
        [[[UIApplication sharedApplication] keyWindow] addSubview:alert];
        [alert show];
        
        
    } else { //弹出ios9以上的系统框
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        
        //查看是否已经有弹框,有就先移除弹框, 否则多个弹框显示会异常
        UIViewController *hasPresentedVC = window.rootViewController.presentedViewController;
        if (hasPresentedVC && [hasPresentedVC isKindOfClass:[UIAlertController class]]) {
            [hasPresentedVC dismissViewControllerAnimated:NO completion:nil];
        } else {
            //hasPresentedVC = [CCUtility obtainCurrentViewController];
            if (hasPresentedVC && [hasPresentedVC isKindOfClass:[UIAlertController class]]) {
                [hasPresentedVC dismissViewControllerAnimated:NO completion:nil];
            }
        }
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (cancelBlock) {
                cancelBlock();
            }
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:otherTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (otherBlock) {
                NSString *inputStr = [alertController.textFields[0] text];
                otherBlock(inputStr);
            }
        }]];
        
        
        //美化输入框的边框样式, 系统的比较丑
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.placeholder = placeholder;
            textField.keyboardType = UIKeyboardTypeNumberPad;
            
            if (KsystemVersion < 9.0) {
                textField.superview.superview.layer.cornerRadius = 1;
                textField.superview.superview.layer.masksToBounds = YES;
                textField.superview.superview.layer.borderColor = UIColorFromHex(0xdcdcdc).CGColor;
                textField.superview.superview.layer.borderWidth = 0.5;
            } else {
                
                /** 是否能获取该属性*/
                Class cls = NSClassFromString(@"_UIAlertControllerTextField");
                if([textField isKindOfClass:cls] && [OKAlertController getVariableWithClass:cls varName:@"_textFieldView"])
                {
                    UIView *textFieldBorderView = [textField valueForKeyPath:@"_textFieldView"];
                    if ([textFieldBorderView isKindOfClass:[UIView class]]) {
                        textFieldBorderView.layer.cornerRadius = 3;
                        textFieldBorderView.layer.masksToBounds = YES;
                        textFieldBorderView.layer.borderWidth = 0.5;
                        textFieldBorderView.layer.borderColor = UIColorFromHex(0xdcdcdc).CGColor;
                    }
                }
            }
        }];
        
        /** 是否能获取该属性*/
        if(title && [OKAlertController getVariableWithClass:[alertController class] varName:@"attributedTitle"])
        {
            //设置标题为细体
            NSAttributedString *titleAttrs = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:OKAlertContr_BlackColor, NSFontAttributeName: OKAlertContr_font(16)}];
            [alertController setValue:titleAttrs forKey:@"attributedTitle"];
        }
        
        //设置按钮颜色
        if([OKAlertController getVariableWithClass:[UIAlertAction class] varName:@"titleTextColor"])
        {
            for(int i = 0; i<alertController.actions.count; i++)
            {
                UIAlertAction *action = alertController.actions[i];
                if(i == alertController.actions.count-1) {
                    //最后一个按钮设置特定颜色
                    [action setValue:OKAlertContr_MainColor forKey:@"titleTextColor"];
                    
                } else {
                    [action setValue:OKAlertContr_BlackColor forKey:@"titleTextColor"];
                }
            }
        }
        
        [window.rootViewController presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - 系统Alert弹框,2秒自动消失

/**
 *  2秒自动消失系统Alert弹框
 *
 *  @msg 提示文字
 */
void ShowAlertToast(NSString *msg) {
    ShowAlertToastByTitle(nil, msg);
}


/**
 2秒自动消失带标题的系统Alert弹框
 
 @param title 标题
 @param msg 提示信息
 */
void ShowAlertToastByTitle(NSString *title, NSString *msg) {
    
    if (!title && !msg) return;
    
    if (KsystemVersion < 8.0){ // iOS9以前系统弹框
        
        //移除所有的已存在的 UIAlertView
        [OKAlertController dismissAllAlertViewFromKeyWindow];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        
        //** 设置字体为细体
        NSObject *obj = [alertView valueForKeyPath:@"_alertController"];
        if(msg && [obj isKindOfClass:[UIAlertController class]]){
            
            UIAlertController *alertVC = (UIAlertController *)obj;
            //** 设置字体为细体
            if([OKAlertController getVariableWithClass:[alertVC class] varName:@"_attributedMessage"])
            {
                //细体字
                UIFont *textFont = [UIFont fontWithName:@"Heiti SC" size:14] ? : OKAlertContr_font(14);
                
                if(msg && [OKAlertController getVariableWithClass:[alertVC class] varName:@"_attributedMessage"]){
                    NSAttributedString *messageAttrs = [[NSAttributedString alloc] initWithString:msg attributes:@{NSForegroundColorAttributeName:OKAlertContr_BlackColor, NSFontAttributeName:textFont}];
                    [alertVC setValue:messageAttrs forKey:@"_attributedMessage"];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [alertView show];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(OKAlertContr_dismissTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alertView dismissWithClickedButtonIndex:0 animated:NO];
        });
        
    } else { //ios9以后系统弹框
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        
        //查看是否已经有弹框,有就先移除弹框, 否则多个弹框显示会异常
        UIViewController *hasPresentedVC = window.rootViewController.presentedViewController;
        if (hasPresentedVC && [hasPresentedVC isKindOfClass:[UIAlertController class]]) {
            [hasPresentedVC dismissViewControllerAnimated:NO completion:nil];
        } else {
            //hasPresentedVC = [CCUtility obtainCurrentViewController];
            if (hasPresentedVC && [hasPresentedVC isKindOfClass:[UIAlertController class]]) {
                [hasPresentedVC dismissViewControllerAnimated:NO completion:nil];
            }
        }
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        
        //**1. 设置提示标题字体为细体
        if(title && [OKAlertController getVariableWithClass:[alertController class] varName:@"attributedTitle"])
        {
            //标题就用系统体字
            UIFont *textFont = OKAlertContr_font(16);
            
            NSAttributedString *titleAttrs = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:OKAlertContr_BlackColor, NSFontAttributeName:textFont}];
            [alertController setValue:titleAttrs forKey:@"attributedTitle"];
        }
        
        //**2. 设置提示信息字体为细体
        if(msg && [OKAlertController getVariableWithClass:[alertController class] varName:@"_attributedMessage"])
        {
            //细体字
            UIFont *textFont = [UIFont fontWithName:@"Heiti SC" size:14] ? : OKAlertContr_font(14);
            
            NSAttributedString *messageAttrs = [[NSAttributedString alloc] initWithString:msg attributes:@{NSForegroundColorAttributeName:OKAlertContr_BlackColor, NSFontAttributeName:textFont}];
            [alertController setValue:messageAttrs forKey:@"_attributedMessage"];
        }
        
        [window.rootViewController presentViewController:alertController animated:NO completion:nil];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(OKAlertContr_dismissTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alertController dismissViewControllerAnimated:NO completion:nil];
        });
    }
}


/**
 * 移除所有的已存在的 UIAlertView
 */
+ (void)dismissAllAlertViewFromKeyWindow
{
    for (UIWindow* w in [UIApplication sharedApplication].windows){
        for (NSObject* o in w.subviews){
            if ([o isKindOfClass:[UIAlertView class]]){
                [(UIAlertView*)o dismissWithClickedButtonIndex:[(UIAlertView*)o cancelButtonIndex] animated:NO];
            }
        }
    }
}

/**
 *  校验一个类是否有该属性
 */
+ (BOOL)getVariableWithClass:(Class)myClass varName:(NSString *)name
{
    unsigned int outCount;
    BOOL hasProperty = NO;
    Ivar *ivars = class_copyIvarList(myClass, &outCount);
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

@end

