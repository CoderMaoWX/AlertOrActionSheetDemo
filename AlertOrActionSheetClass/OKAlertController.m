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

/**
 iOS的系统弹框, <已兼容iOS7的UIAlertView>;
 注意:如果有设置cancelButton, 则取消按钮的buttonIndex为:0, 其他otherButton的Index依次加1;
 
 @param alertViewCallBackBlock 点击按钮回调Block
 @param title                  弹框标题->(支持 NSString、NSAttributedString)
 @param message                弹框描述->(支持 NSString、NSAttributedString)
 @param cancelButtonName       取消按钮标题，<暂时只能设置NSString>
 @param otherButtonTitles      其他按钮标题，<暂时只能设置NSString>
 */
+ (void)alertWithCallBackBlock:(OKAlertViewCallBackBlock)alertViewCallBackBlock
                         title:(id)title
                       message:(id)message
              cancelButtonName:(NSString *)cancelButtonName
             otherButtonTitles:(NSString *)otherButtonTitles, ...NS_REQUIRES_NIL_TERMINATION
{
    if(!title && !message){
        NSLog(@"弹框至少要有一个文本信息");
        return;
    }

    if (title && ![title isKindOfClass:[NSString class]] &&
                  ![title isKindOfClass:[NSAttributedString class]]){
        NSLog(@"弹框标题错误!");
        return;
    }
    
    if (message && ![message isKindOfClass:[NSString class]] &&
                    ![message isKindOfClass:[NSAttributedString class]]){
        NSLog(@"弹框提示信息错误");
        return;
    }
    
    //根据系统版本不同来显示弹框
    if (KsystemVersion < 8.0){ //iOS8以前系统弹框用 UIAlertView
        
        //移除所有的已存在的 UIAlertView
        [OKAlertController dismissIOS7AllAlertView];
        
        //暂时不对ios7设置富文本
        if([title isKindOfClass:[NSAttributedString class]]){
            title = ((NSAttributedString *)title).string;
        }
        
        if([message isKindOfClass:[NSAttributedString class]]){
            message = ((NSAttributedString *)message).string;
        }
        
        UIAlertView *alert = [UIAlertView alertWithCallBackBlock:^(NSInteger buttonIndex) {
            if(alertViewCallBackBlock){
                alertViewCallBackBlock(buttonIndex);
            }
        } title:title message:message cancelButtonName:cancelButtonName otherButtonTitles:otherButtonTitles, nil];
        [[[UIApplication sharedApplication] keyWindow] addSubview:alert];
        [alert show];
        
        //如果弹框没有一个按钮，则自动延迟隐藏
        if(!cancelButtonName && !otherButtonTitles){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(OKAlertContr_dismissTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [alert dismissWithClickedButtonIndex:0 animated:YES];
            });
        }
        
    } else { //ios8以后系统弹框用 UIAlertController
        
        //防止窗口上有多个弹框导致弹框显示异常，如果有则先移除旧的弹框
        [OKAlertController dismissIOS8AllAlertController];
        
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
        
        //临时title, message
        NSString *titleStr = title;
        if([title isKindOfClass:[NSAttributedString class]]){
            titleStr = ((NSAttributedString *)title).string;
        }
        
        NSString *messageStr = message;
        if([message isKindOfClass:[NSAttributedString class]]){
            messageStr = ((NSAttributedString *)message).string;
        }
        
        //弹出ios9以上的系统框
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:titleStr message:messageStr preferredStyle:UIAlertControllerStyleAlert];
        
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
        if(alertController.actions.count>0 && [OKAlertController getVariableWithClass:[alertController.actions.firstObject class] varName:@"titleTextColor"])
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
            NSDictionary *attrDic = @{NSForegroundColorAttributeName:OKAlertContr_BlackColor, NSFontAttributeName: OKAlertContr_font(16)};
            
            if([title isKindOfClass:[NSString class]]){ //标题为普通NSString
                
                NSAttributedString *titleAttrs = [[NSAttributedString alloc] initWithString:title attributes:attrDic];
                [alertController setValue:titleAttrs forKey:@"attributedTitle"];
                
            } else if([title isKindOfClass:[NSAttributedString class]]){ //标题为普通富文本
                
                NSAttributedString *attrStr = (NSAttributedString *)title;
                NSMutableAttributedString *titleAttrs = [[NSMutableAttributedString alloc] initWithAttributedString:attrStr];
                [titleAttrs addAttributes:attrDic range:NSRangeFromString(attrStr.string)];
                [alertController setValue:titleAttrs forKey:@"attributedTitle"];
            }
        }
        
        /**<2> 设置提示信息字体为细体 */
        if(message && [OKAlertController getVariableWithClass:[alertController class] varName:@"_attributedMessage"])
        {
            NSDictionary *attrDic = @{NSForegroundColorAttributeName:OKAlertContr_BlackColor, NSFontAttributeName: OKAlertContr_font(14)};
            
            if([message isKindOfClass:[NSString class]]){ //描述信息为普通NSString
                NSAttributedString *messageAttrs = [[NSAttributedString alloc] initWithString:message attributes:attrDic];
                [alertController setValue:messageAttrs forKey:@"_attributedMessage"];
                
            } else if([message isKindOfClass:[NSAttributedString class]]){ //标描述信息为普通富文本
                
                NSAttributedString *attrStr = (NSAttributedString *)message;
                NSMutableAttributedString *titleAttrs = [[NSMutableAttributedString alloc] initWithAttributedString:attrStr];
                [titleAttrs addAttributes:attrDic range:NSRangeFromString(attrStr.string)];
                [alertController setValue:titleAttrs forKey:@"_attributedMessage"];
            }
        }
        
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        [window.rootViewController presentViewController:alertController animated:YES completion:nil];
        
        //如果弹框没有一个按钮，则自动延迟隐藏
        if(mutableOtherTitles.count == 0){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(OKAlertContr_dismissTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [alertController dismissViewControllerAnimated:YES completion:nil];
            });
        }
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
    if (KsystemVersion < 8.0){ // iOS8以前系统弹框
        
        //移除所有的已存在的 UIAlertView
        [OKAlertController dismissIOS7AllAlertView];
        
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
        
        //如果弹框没有一个按钮，则自动延迟隐藏
        if(!cancelTitle && !otherTitle){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(OKAlertContr_dismissTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [alert dismissWithClickedButtonIndex:0 animated:YES];
            });
        }
        
    } else { //弹出ios8以上的系统框
        
        //查看是否已经有弹框,有就先移除弹框, 否则多个弹框显示会异常
        [OKAlertController dismissIOS8AllAlertController];
        
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
        
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        [window.rootViewController presentViewController:alertController animated:YES completion:nil];
        
        //如果弹框没有一个按钮，则自动延迟隐藏
        if(!cancelTitle && !otherTitle){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(OKAlertContr_dismissTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [alertController dismissViewControllerAnimated:YES completion:nil];
            });
        }
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
    
    [OKAlertController alertWithCallBackBlock:nil title:title message:msg cancelButtonName:nil otherButtonTitles: nil];
}


/**
 * iOS8之前系统，移除所有的已存在的 UIAlertView
 */
+ (void)dismissIOS7AllAlertView
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
 * iOS8以后系统，移除所有的已存在的 UIAlertController
 */
+ (void)dismissIOS8AllAlertController
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIViewController *hasPresentedVC = window.rootViewController.presentedViewController;
    if (hasPresentedVC && [hasPresentedVC isKindOfClass:[UIAlertController class]]) {
        [hasPresentedVC dismissViewControllerAnimated:NO completion:nil];
    } else {
        hasPresentedVC = [self activityViewController];
        if (hasPresentedVC && [hasPresentedVC isKindOfClass:[UIAlertController class]]) {
            [hasPresentedVC dismissViewControllerAnimated:NO completion:nil];
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


#pragma mark - 查找当前活动窗口

/**
 遍历窗口上当前的激活窗口的控制器

 @return 激活窗口的控制器
 */
+ (UIViewController *)activityViewController
{
    UIViewController* activityViewController = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    
    if(window.windowLevel != UIWindowLevelNormal){
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow *tmpWin in windows) {
            if(tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    
    NSArray *viewsArray = [window subviews];
    if([viewsArray count] > 0){
        UIView *frontView = [viewsArray objectAtIndex:0];
        id nextResponder = [frontView nextResponder];
        
        if([nextResponder isKindOfClass:[UIViewController class]]) {
            activityViewController = nextResponder;
            
        } else {
            activityViewController = window.rootViewController;
        }
    }
    
    return activityViewController;
}



@end


