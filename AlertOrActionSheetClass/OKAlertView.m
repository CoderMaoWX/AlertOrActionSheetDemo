//
//  OKAlertView.m
//  AlertOrActionSheetDemo
//
//  Created by mao wangxin on 2017/3/28.
//  Copyright © 2017年 okdeer. All rights reserved.
//

#import "OKAlertView.h"
#import "NSObject+OKRuntime.h"
#import "NSString+OKExtension.h"
#import "UIButton+OKExtension.h"
#import "NSAttributedString+OKExtension.h"

//进制颜色转换
#ifndef ColorFromHex
#define ColorFromHex(hexValue)                  ([UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0x00FF00) >> 8))/255.0 blue:((float)(hexValue & 0x0000FF))/255.0 alpha:1.0])
#endif

//获取系统版本
#ifndef KsystemVersion
#define KsystemVersion                          [[[UIDevice currentDevice] systemVersion] floatValue]
#endif

/** 屏幕宽度 */
#ifndef kFullScreenWidth
#define kFullScreenWidth                        ([UIScreen mainScreen].bounds.size.width)
#endif

//弹框字体大小
#ifndef  FONTDEFAULT
#define  FONTDEFAULT(fontSize)                   ([UIFont systemFontOfSize:fontSize])
#endif

//弹框粗体字体
#ifndef  FONTBOLD
#define  FONTBOLD(fontSize)                      ([UIFont boldSystemFontOfSize:fontSize])
#endif

//全局主色调颜色
#ifndef  OK_Main_Color
#define  OK_Main_Color                           ColorFromHex(0x8CC63F)
#endif

//按钮普通状态字体颜色
#ifndef  OK_Btn_Normal_Title_Color
#define  OK_Btn_Normal_Title_Color               ColorFromHex(0x323232)
#endif

//按钮高亮状态背景颜色
#ifndef  OK_Btn_Highlighted_Bg_Color
#define  OK_Btn_Highlighted_Bg_Color             [[UIColor groupTableViewBackgroundColor] colorWithAlphaComponent:0.5]
#endif

//按钮不可用状态背景颜色
#ifndef  OK_Btn_Disabled_Bg_Color
#define  OK_Btn_Disabled_Bg_Color                ColorFromHex(0xe2e2e2)
#endif

//弹框自动消失时间2秒
#ifndef  OKToast_dismissTime
#define  OKToast_dismissTime                     2.0
#endif

//按钮高度
#ifndef  OK_BigBtn_Height
#define  OK_BigBtn_Height                        44.0f
#endif

//弹框离屏幕边缘宽度
#ifndef  OKAlertView_ScreenSpace
#define  OKAlertView_ScreenSpace                 30
#endif


@interface OKAlertView ()

/** AlertView主视图 */
@property (nonatomic, strong) UIView *contentView;
/** AlertView所有按钮数组 */
@property (nonatomic, strong) NSMutableArray *alertAllButtonArr;
/** OKAlertView普通按钮点击回调 */
@property (nonatomic, copy) OKAlertViewCallBackBlock alertCallBackBlock;
/** 取消按钮标题 */
@property (nonatomic, strong) NSString *cancelTitle;
@end

@implementation OKAlertView

/**
 iOS的系统弹框, <已兼容iOS7的UIAlertView>;
 注意:如果有设置cancelButton, 则取消按钮的buttonIndex为:0, 其他otherButton的Index依次加1;
 
 @param alertViewCallBackBlock 点击按钮回调Block
 @param title                  弹框标题->(支持 NSString、NSAttributedString)
 @param message                弹框描述->(支持 NSString、NSAttributedString)
 @param cancelButtonName       取消按钮标题，<只能设置NSString>
 @param otherButtonTitles      其他按钮标题，<只能设置NSString>
 */
+ (instancetype)alertWithCallBackBlock:(OKAlertViewCallBackBlock)alertViewCallBackBlock
                                 title:(id)title
                               message:(id)message
                      cancelButtonName:(id)cancelButtonName
                     otherButtonTitles:(id)otherButtonTitles, ...NS_REQUIRES_NIL_TERMINATION
{
    if(!title && !message){
        NSLog(@"弹框至少要有一个文本信息");
        return nil;
    }
    
    if (title && ![title isKindOfClass:[NSString class]] &&
        ![title isKindOfClass:[NSAttributedString class]]){
        NSLog(@"弹框标题错误!");
        return nil;
    }
    
    if (message && ![message isKindOfClass:[NSString class]] &&
        ![message isKindOfClass:[NSAttributedString class]]){
        NSLog(@"弹框提示信息错误");
        return nil;
    }
    
    if (cancelButtonName && ![cancelButtonName isKindOfClass:[NSString class]] &&
        ![cancelButtonName isKindOfClass:[NSAttributedString class]]){
        NSLog(@"取消按钮标题错误");
        return nil;
    }
    
    //包装按钮标题数组
    NSMutableArray *mutableOtherTitles = [NSMutableArray array];
    va_list otherButtonTitleList;
    va_start(otherButtonTitleList, otherButtonTitles);
    {
        for (NSString *otherButtonTitle = otherButtonTitles; otherButtonTitle != nil; otherButtonTitle = va_arg(otherButtonTitleList, NSString *)) {
            [mutableOtherTitles addObject:otherButtonTitle];
        }
    }
    va_end(otherButtonTitleList);
    
    return [[OKAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds
                                        title:title
                                      message:message
                            cancelButtontitle:cancelButtonName
                          otherButtonTitleArr:mutableOtherTitles
                                callBackBlock:alertViewCallBackBlock];
}

#pragma mark - 初始化自定义OKAlertView

- (instancetype)initWithFrame:(CGRect)frame
                        title:(id)title
                      message:(id)message
            cancelButtontitle:(id)cancelTitle
          otherButtonTitleArr:(NSArray *)buttonTitleArr
                callBackBlock:(OKAlertViewCallBackBlock)alertViewCallBackBlock
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    
    if(self){
        self.alpha = 0.0;
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        
        //点击按钮回调
        self.alertCallBackBlock = alertViewCallBackBlock;
        self.cancelTitle = cancelTitle;
        
        //大于一个就把 "取消"按钮放最后， 否则就放第一个
        NSMutableArray *allTitleArr = [NSMutableArray arrayWithArray:buttonTitleArr];
        if(cancelTitle) {
            if (allTitleArr.count > 1) {
                [allTitleArr addObject:cancelTitle];
            } else {
                [allTitleArr insertObject:cancelTitle atIndex:0];
            }
        }
        
        //初始化弹框主视图
        [self initAlertContentViewWithTitle:title message:message buttonTitleArr:allTitleArr];
        
        //显示在窗口
        [self showOKAlertView];
    }
    return self;
}

/**
 * 初始化弹框主视图
 */
- (void)initAlertContentViewWithTitle:(id)title
                              message:(id)message
                       buttonTitleArr:(NSArray *)allTitleArr
{
    //移除window上已存在的OKAlertView
    [self removeOkAlertFromWindow];
    
    CGRect rect = CGRectMake(OKAlertView_ScreenSpace, 0, kFullScreenWidth-OKAlertView_ScreenSpace*2, 60);
    UIView *contentView = [[UIView alloc] initWithFrame:rect];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = 12;
    contentView.layer.masksToBounds = YES;
    [self addSubview:contentView];
    self.contentView = contentView;
    
    CGFloat labelWidth = contentView.frame.size.width-OKAlertView_ScreenSpace*2;
    CGFloat lastUImaxY = 0;
    CGFloat marginSpace = 30;
    
    //提示标题
    UILabel *titleLab = nil;
    if (title) {
        titleLab = [[UILabel alloc] init];
        titleLab.backgroundColor = [UIColor whiteColor];
        [titleLab setTextColor:OK_Btn_Normal_Title_Color];
        [titleLab setTextAlignment:NSTextAlignmentCenter];
        [titleLab setFont:FONTBOLD(16)];
        titleLab.numberOfLines = 0;
        titleLab.adjustsFontSizeToFitWidth = YES;
        [contentView addSubview:titleLab];
        
        CGFloat titleHeight = [title heightWithFont:titleLab.font constrainedToWidth:labelWidth];
        if (!message && titleHeight<60) {
            titleHeight = 60;
        } else {
            titleHeight = titleHeight+marginSpace;
        }
        titleLab.frame = CGRectMake(OKAlertView_ScreenSpace, 0, labelWidth, titleHeight);
        
        //设置显示文字样式
        [self setTextStyle:titleLab textString:title];
        lastUImaxY = CGRectGetMaxY(titleLab.frame);
    }
    
    //提示信息
    UILabel *messageLab = nil;
    if (message) {
        messageLab = [[UILabel alloc] init];
        messageLab.backgroundColor = [UIColor whiteColor];
        [messageLab setTextColor:OK_Btn_Normal_Title_Color];
        [messageLab setTextAlignment:NSTextAlignmentCenter];
        [messageLab setFont:FONTDEFAULT(14)];
        messageLab.numberOfLines = 0;
        [contentView addSubview:messageLab];
        
        CGFloat msgY = title ? lastUImaxY-marginSpace/2 : lastUImaxY;
        CGFloat msgHeight = [message heightWithFont:messageLab.font constrainedToWidth:labelWidth];
        if (!title && msgHeight<60) {
            msgHeight = 60;
        } else {
            msgHeight = msgHeight+marginSpace;
        }
        messageLab.frame = CGRectMake(OKAlertView_ScreenSpace, msgY, labelWidth, msgHeight);
        
        //设置显示文字样式
        [self setTextStyle:messageLab textString:message];
        lastUImaxY = CGRectGetMaxY(messageLab.frame);
    }
    
    NSInteger cancelButtonTag = 0;
    if (self.cancelTitle) {
        cancelButtonTag = [allTitleArr indexOfObject:self.cancelTitle];
    }
    
    //布局所有Alert按钮
    [self moduleAlertButton:allTitleArr
            cancelButtonTag:cancelButtonTag
                contentView:contentView
                 lastUImaxY:lastUImaxY];
    
    //添加AlertView到窗口上
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window endEditing:YES];
    [window addSubview:self];
}

/**
 * 布局所有Alert按钮
 */
- (void)moduleAlertButton:(NSArray *)allTitleArr
          cancelButtonTag:(NSInteger)cancelButtonTag
              contentView:(UIView *)contentView
               lastUImaxY:(CGFloat)lastUImaxY
{
    //设置所有按钮
    if (allTitleArr.count>0) {
        CGFloat lastBtnMaxY = lastUImaxY;
        
        for (int i = 0 ; i<allTitleArr.count; i++) {
            //分割线
            UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, lastBtnMaxY, contentView.frame.size.width, 1)];
            line.backgroundColor = [UIColor groupTableViewBackgroundColor];
            [contentView addSubview:line];
            
            //按钮
            UIButton *actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            actionBtn.backgroundColor = [UIColor whiteColor];
            [actionBtn.titleLabel setFont:FONTDEFAULT(16)];
            [actionBtn addTarget:self action:@selector(alertBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            [actionBtn setTitleColor:OK_Btn_Normal_Title_Color forState:0];
            [actionBtn setBackgroundColor:OK_Btn_Disabled_Bg_Color forState:UIControlStateDisabled];
            [actionBtn setBackgroundColor:OK_Btn_Highlighted_Bg_Color forState:UIControlStateHighlighted];
            [actionBtn setExclusiveTouch:YES];
            [contentView addSubview:actionBtn];
            
            //标记取消按钮位置
            if (cancelButtonTag == (allTitleArr.count-1)) {
                actionBtn.tag = (i == allTitleArr.count-1) ? 0 : i+1;
            } else {
                actionBtn.tag = i;
            }
            
            //设置显示文字样式
            [self setTextStyle:actionBtn textString:allTitleArr[i]];
            
            //布局按钮个数
            CGFloat actionBtnWidth = contentView.frame.size.width/2;
            if (allTitleArr.count == 2) {
                if (i == 0) {
                    actionBtn.frame = CGRectMake(0, CGRectGetMaxY(line.frame), actionBtnWidth, OK_BigBtn_Height);
                } else {
                    line.frame = CGRectMake(actionBtnWidth, CGRectGetMaxY(line.frame), 1, OK_BigBtn_Height);
                    actionBtn.frame = CGRectMake(actionBtnWidth+1, CGRectGetMinY(line.frame), actionBtnWidth, OK_BigBtn_Height);
                    
                    //只有两个按钮时，第二个按钮显示特定颜色
                    [actionBtn setTitleColor:OK_Main_Color forState:0];
                }
            } else {
                //布局控件位置
                actionBtn.frame = CGRectMake(0, CGRectGetMaxY(line.frame), contentView.frame.size.width, OK_BigBtn_Height);
                
                //记住位置y
                lastBtnMaxY = CGRectGetMaxY(actionBtn.frame);
                
                //大于两个按钮时，变取消按钮显示特定颜色
                if (self.cancelTitle &&
                    [self.cancelTitle isKindOfClass:[NSString class]] &&
                    [self.cancelTitle isEqualToString:allTitleArr[i]]) {
                    [actionBtn setTitleColor:OK_Main_Color forState:0];
                }
            }
            
            contentView.bounds = CGRectMake(0, 0, kFullScreenWidth-OKAlertView_ScreenSpace*2, CGRectGetMaxY(actionBtn.frame));
            contentView.center = self.center;
            
            //保存按钮
            [self.alertAllButtonArr addObject:actionBtn];
        }
    } else {
        contentView.bounds = CGRectMake(0, 0, kFullScreenWidth-OKAlertView_ScreenSpace*2, lastUImaxY);
        contentView.center = self.center;
        
        //没有设置按钮就延迟2秒退出弹框
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(OKToast_dismissTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissOKAlertView:nil];
        });
    }
}

/**
 * 根据文字类型设置控件标题
 */
- (void)setTextStyle:(id)uiKit textString:(id)text
{
    if ([uiKit isKindOfClass:[UILabel class]]) {
        
        UILabel *label = (UILabel *)uiKit;
        if ([text isKindOfClass:[NSString class]]) {
            [label setText:text];
            
        } else if([text isKindOfClass:[NSAttributedString class]]){
            [label setAttributedText:text];
        }
        
    } else if ([uiKit isKindOfClass:[UIButton class]]) {
        
        UIButton *button = (UIButton *)uiKit;
        if ([text isKindOfClass:[NSString class]]) {
            [button setTitle:text forState:0];
            
        } else if([text isKindOfClass:[NSAttributedString class]]){
            [button setAttributedTitle:text forState:0];
        }
    }
}

#pragma mark -===========按钮操作事件===========

/**
 *  获取ActionSheet上的指定按钮
 *  注意:index为所有按钮数组的角标(cancelButton的角标为0 ,其他依次加1)
 */
- (UIButton *)buttonAtIndex:(NSInteger)index
{
    if (self.alertAllButtonArr.count>0) {
        for (UIButton *actionBtn in self.alertAllButtonArr) {
            if ([actionBtn isKindOfClass:[UIButton class]] && actionBtn.tag == index) {
                return actionBtn;
            }
        }
    }
    return nil;
}

/**
 *  给ActionSheet的指定按钮设置标题
 *  注意:index为所有按钮数组的角标(cancelButton的角标为0 ,其他依次加1)
 */
- (void)setButtonTitleToIndex:(NSInteger)index title:(id)title enable:(BOOL)enable
{
    if (self.alertAllButtonArr.count>0) {
        for (UIButton *actionBtn in self.alertAllButtonArr) {
            
            if ([actionBtn isKindOfClass:[UIButton class]] && actionBtn.tag == index) {
                actionBtn.enabled = enable;
                
                //根据文字类型设置标题
                [self setTextStyle:actionBtn textString:title];
                break;
            }
        }
    }
}

#pragma mark -===========按钮点击事件===========

/**
 *  alertView操作按钮事件
 */
- (void)alertBtnAction:(UIButton *)actionBtn
{
    NSLog(@"点击了ActionSheet弹框按钮==%zd",actionBtn.tag);
    if (self.alertCallBackBlock) {
        self.alertCallBackBlock(actionBtn.tag);
    }
    
    //退出弹框
    [self dismissOKAlertView:nil];
}

/**
 *  alertView所有按钮数组
 */
- (NSMutableArray *)alertAllButtonArr
{
    if (!_alertAllButtonArr) {
        _alertAllButtonArr = [NSMutableArray array];
    }
    return _alertAllButtonArr;
}

#pragma mark -===========2秒自动消失弹框===========

/**
 *  2秒自动消失系统Alert弹框
 *
 *  @msg 提示文字
 */
void ShowAlertToast(id msg) {
    ShowAlertToastByTitle(nil, msg);
}


/**
 2秒自动消失带标题的系统Alert弹框
 
 @param title 标题
 @param msg 提示信息
 */
void ShowAlertToastByTitle(id title, id msg) {
    
    if (!title && !msg) return;
    
    [OKAlertView alertWithCallBackBlock:nil title:title message:msg cancelButtonName:nil otherButtonTitles: nil];
}


/**
 * 显示错误提示信息
 */
+ (void)showMsgWithError:(NSError *)error defaultMsg:(NSString *)defaultMsg{
    NSString *errorMsg = error.domain;
    NSInteger code = error.code;
    if (code > 200 && code < 500 && errorMsg.length) {
        ShowAlertToastByTitle(@"提示", errorMsg);
    }
    else if (defaultMsg.length){
        ShowAlertToastByTitle(@"提示", defaultMsg);
    }
}

#pragma mark -===========显示，退出弹框===========

/**
 *  显示弹框
 */
- (void)showOKAlertView
{
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.alpha = 1;
    } completion:nil];
}

/**
 *  退出弹框
 */
- (void)dismissOKAlertView:(id)sender
{
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

/**
 * 移除window上已存在的OKAlertView
 */
- (void)removeOkAlertFromWindow
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    for (UIView *windowSubView in window.subviews) {
        if ([windowSubView isKindOfClass:[OKAlertView class]]) {
            [windowSubView removeFromSuperview];
            break;
        }
    }
}

#pragma mark ========================= 系统带输入的UIAlertView弹框 ========================

+ (UIAlertController *)inputAlertWithTitle:(NSString *)title
                               placeholder:(NSString *)placeholder
                               cancelTitle:(NSString *)cancelTitle
                                otherTitle:(NSString *)otherTitle
                               buttonBlock:(void (^)(NSString *inputText))otherBlock
                               cancelBlock:(void (^)())cancelBlock
{
    //警告： 弹出ios8以上的系统框
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
            textField.superview.superview.layer.borderColor = ColorFromHex(0xdcdcdc).CGColor;
            textField.superview.superview.layer.borderWidth = 0.5;
        } else {
            
            /** 是否能获取该属性*/
            Class cls = NSClassFromString(@"_UIAlertControllerTextField");
            if([textField isKindOfClass:cls] && [cls ok_hasVarName:@"_textFieldView"])
            {
                UIView *textFieldBorderView = [textField valueForKeyPath:@"_textFieldView"];
                if ([textFieldBorderView isKindOfClass:[UIView class]]) {
                    textFieldBorderView.layer.cornerRadius = 3;
                    textFieldBorderView.layer.masksToBounds = YES;
                    textFieldBorderView.layer.borderWidth = 0.5;
                    textFieldBorderView.layer.borderColor = ColorFromHex(0xdcdcdc).CGColor;
                }
            }
        }
    }];
    
    /** 是否能获取该属性*/
    if(title && [[alertController class] ok_hasVarName:@"attributedTitle"])
    {
        //设置标题为细体
        NSAttributedString *titleAttrs = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:OK_Btn_Normal_Title_Color, NSFontAttributeName: FONTDEFAULT(16)}];
        [alertController setValue:titleAttrs forKey:@"attributedTitle"];
    }
    
    //设置按钮颜色
    if([[UIAlertAction class] ok_hasVarName:@"titleTextColor"])
    {
        for(int i = 0; i<alertController.actions.count; i++)
        {
            UIAlertAction *action = alertController.actions[i];
            if(i == alertController.actions.count-1) {
                //最后一个按钮设置特定颜色
                [action setValue:OK_Main_Color forKey:@"titleTextColor"];
                
            } else {
                [action setValue:OK_Btn_Normal_Title_Color forKey:@"titleTextColor"];
            }
        }
    }
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIViewController *tempVC = window.rootViewController;
    if (tempVC.presentedViewController) {
        tempVC = tempVC.presentedViewController;
    }
    [tempVC presentViewController:alertController animated:YES completion:nil];
    
    //如果弹框没有一个按钮，则自动延迟隐藏
    if(!cancelTitle && !otherTitle){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(OKToast_dismissTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alertController dismissViewControllerAnimated:YES completion:nil];
        });
    }
    
    return alertController;
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

@end

