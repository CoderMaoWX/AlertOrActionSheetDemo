//
//  OKAlertView.h
//  AlertOrActionSheetDemo
//
//  Created by mao wangxin on 2017/3/28.
//  Copyright © 2017年 okdeer. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^OKAlertViewCallBackBlock)(NSInteger buttonIndex);


@interface OKAlertView : UIView

/**
 iOS的系统弹框, <已兼容iOS7的UIAlertView>;
 注意:如果有设置cancelButton, 则取消按钮的buttonIndex为:0, 其他otherButton的Index依次加1;
 
 @param alertViewCallBackBlock 点击按钮回调Block
 @param title                  弹框标题->(支持 NSString、NSAttributedString)
 @param message                弹框描述->(支持 NSString、NSAttributedString)
 @param cancelButtonName       取消按钮标题->(支持 NSString、NSAttributedString)
 @param otherButtonTitles      其他按钮标题->(支持 NSString、NSAttributedString)
 */
+ (instancetype)alertWithCallBackBlock:(OKAlertViewCallBackBlock)alertViewCallBackBlock
                                 title:(id)title
                               message:(id)message
                      cancelButtonName:(id)cancelButtonName
                     otherButtonTitles:(id)otherButtonTitles, ...NS_REQUIRES_NIL_TERMINATION;

/**
 *  获取OKAlertView上的指定按钮
 *  注意:index为所有按钮数组的角标(cancelButton的角标为0 ,其他依次加1)
 */
- (UIButton *)buttonAtIndex:(NSInteger)index;


/**
 *  给OKAlertView的指定按钮设置标题
 *  注意:index为所有按钮数组的角标(cancelButton的角标为0 ,其他依次加1)
 */
- (void)setButtonTitleToIndex:(NSInteger)index title:(id)title enable:(BOOL)enable;

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


/**
 * 显示请求的错误提示信息
 */
+ (void)showMsgWithError:(NSError *)error defaultMsg:(NSString *)defaultMsg;


#pragma mark - 带输入框的系统弹框

/**
 iOS8.0的带输入框的UIAlertController
 
 @param title 标题
 @param placeholder 占位文字
 @param cancelTitle 取消按钮标题
 @param otherTitle 其他按钮标题
 @param otherBlock 其他按钮回调
 @param cancelBlock 取消按钮回调
 */
+ (UIAlertController *)inputAlertWithTitle:(NSString *)title
                               placeholder:(NSString *)placeholder
                               cancelTitle:(NSString *)cancelTitle
                                otherTitle:(NSString *)otherTitle
                               buttonBlock:(void (^)(NSString *inputText))otherBlock
                               cancelBlock:(void (^)())cancelBlock;

@end
