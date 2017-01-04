//
//  OKAlertController.h
//  OkdeerUser
//
//  Created by mao wangxin on 2016/11/15.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^OKAlertViewCallBackBlock)(NSInteger buttonIndex);

#pragma mark - 普通系统弹框

/**
 *  兼容iOS7的UIAlertView的系统弹框
 */
@interface OKAlertController : NSObject

/**
 iOS的系统弹框, <已兼容iOS7的UIAlertView>;
 注意:如果有设置cancelButton, 则取消按钮的buttonIndex为:0, 其他otherButton的Index依次加1;

 @param alertViewCallBackBlock 点击按钮回调Block
 @param title                  弹框标题->(支持 NSString、NSAttributedString)
 @param message                弹框描述->(支持 NSString、NSAttributedString)
 @param cancelButtonName       取消按钮标题，<只能设置NSString>
 @param otherButtonTitles      其他按钮标题，<只能设置NSString>
 */
+ (void)alertWithCallBackBlock:(OKAlertViewCallBackBlock)alertViewCallBackBlock
                         title:(id)title
                       message:(id)message
              cancelButtonName:(NSString *)cancelButtonName
             otherButtonTitles:(NSString *)otherButtonTitles, ...NS_REQUIRES_NIL_TERMINATION ;


#pragma mark - 带输入框的系统弹框

/**
 兼容iOS7.0的带输入框的UIAlertView
 
 @param title 标题
 @param placeholder 占位文字
 @param cancelTitle 取消按钮标题
 @param otherTitle 其他按钮标题
 @param otherBlock 其他按钮回调
 @param cancelBlock 取消按钮回调
 */
+ (void)inputAlertWithTitle:(NSString *)title
                placeholder:(NSString *)placeholder
                cancelTitle:(NSString *)cancelTitle
                 otherTitle:(NSString *)otherTitle
                buttonBlock:(void (^)(NSString *inputText))otherBlock
                cancelBlock:(void (^)())cancelBlock;


#pragma mark - 系统自动消失Toast弹框

/**
 *  2秒自动消失的系统Alert弹框
 *
 *  @msg 提示标题->(支持 NSString、NSAttributedString)
 */
void ShowAlertToast(id msg);


/**
 * 2秒自动消失带标题的系统Alert弹框
 
 * @param title 提示标题->(支持 NSString、NSAttributedString)
 * @param msg   提示信息->(支持 NSString、NSAttributedString)
 */
void ShowAlertToastByTitle(id title, id msg);

@end


