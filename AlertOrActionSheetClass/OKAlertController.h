//
//  OKAlertController.h
//  OkdeerUser
//
//  Created by mao wangxin on 2016/11/15.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^OKAlertViewCallBackBlock)(NSInteger buttonIndex);

/**
 *  兼容iOS7的UIAlertView的系统弹框
 */
@interface OKAlertController : NSObject

/**
 *  iOS的系统弹框, <已兼容iOS7的UIAlertView>;
 *  注意:如果有设置cancelButton, 则取消按钮的buttonIndex为:0, 其他otherButton的Index依次加1;
 *  @param alertViewCallBackBlock 点击按钮回调Block
 */
+ (void)alertWithCallBackBlock:(OKAlertViewCallBackBlock)alertViewCallBackBlock
                         title:(NSString *)title
                       message:(NSString *)message
              cancelButtonName:(NSString *)cancelButtonName
             otherButtonTitles:(NSString *)otherButtonTitles, ...NS_REQUIRES_NIL_TERMINATION ;


/**
 *  系统Alert弹框,自动消失,<已兼容iOS7的UIAlertView>
 *
 *  @msg 提示文字
 */
void showAlertToast(NSString *msg);


/**
 兼容iOS7.0的带输入框的UIAlertView

 @param title 标题
 @param placeholder 占位文字
 @param cancelTitle 取消按钮标题
 @param otherTitle 其他按钮标题
 @param buttonBlock 其他按钮回调
 @param cancelBlock 取消按钮回调
 */
+ (void)inputAlertWithTitle:(NSString *)title
                placeholder:(NSString *)placeholder
                cancelTitle:(NSString *)cancelTitle
                 otherTitle:(NSString *)otherTitle
                buttonBlock:(void (^)(NSString *inputText))buttonBlock
                cancelBlock:(void (^)())cancelBlock;

@end


