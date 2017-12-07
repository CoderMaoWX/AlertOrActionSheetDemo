//
//  OKAlertView.m
//  AlertOrActionSheetDemo
//
//  Created by mao wangxin on 2017/3/28.
//  Copyright © 2017年 okdeer. All rights reserved.
//

#import "OKAlertView.h"
#import <objc/message.h>

//进制颜色转换
#ifndef ColorFromHex
#define ColorFromHex(hexValue)                  ([UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0x00FF00) >> 8))/255.0 blue:((float)(hexValue & 0x0000FF))/255.0 alpha:1.0])
#endif

/** 屏幕宽度 */
#ifndef kFullScreenWidth
#define kFullScreenWidth                        ([UIScreen mainScreen].bounds.size.width)
#endif

//弹框字体大小
#ifndef  FONTDEFAULT
#define  FONTDEFAULT(fontSize)                  ([UIFont systemFontOfSize:fontSize])
#endif

//取消按钮主色调颜色
#ifndef  OKAlertView_MainColor
#define  OKAlertView_MainColor                  ColorFromHex(0x2F7AFF)
#endif

//按钮普通状态字体颜色
#ifndef  OKAlertView_BtnTitleNorColor
#define  OKAlertView_BtnTitleNorColor           ColorFromHex(0x323232)
#endif

//按钮高亮状态背景颜色
#ifndef  OKAlertView_BtnBgHighColor
#define  OKAlertView_BtnBgHighColor             [[UIColor groupTableViewBackgroundColor] colorWithAlphaComponent:0.5]
#endif

//按钮不可用状态背景颜色
#ifndef  OKAlertView_BtnBgDisabledColor
#define  OKAlertView_BtnBgDisabledColor         ColorFromHex(0xe2e2e2)
#endif

//弹框自动消失时间2秒
#ifndef  OKAlertView_ToastDismissTime
#define  OKAlertView_ToastDismissTime           2.0
#endif

//按钮高度
#ifndef  OKAlertView_BigBtnHeight
#define  OKAlertView_BigBtnHeight               44.0f
#endif

//弹框离屏幕边缘宽度
#ifndef  OKAlertView_ScreenSpace
#define  OKAlertView_ScreenSpace    ([UIScreen mainScreen].bounds.size.width<375 ? 25 : kFullScreenWidth*0.14)
#endif

//Label与contenView的间距
#define  OKAlertView_KitMargin                  20
//线条高度
#define  OKAlertView_LineHeight                 (1/[UIScreen mainScreen].scale)
//线条颜色
#define  OKAlertView_LineColor                  ColorFromHex(0xe2e2e2)
//文本颜色
#define  OKAlertView_LabelColor                 [UIColor blackColor]


@interface OKAlertView ()

/** AlertView主视图 */
@property (nonatomic, strong) UIView *contentView;
/** AlertView所有按钮数组 */
@property (nonatomic, strong) NSMutableArray *alertAllButtonArr;
/** OKAlertView普通按钮点击回调 */
@property (nonatomic, copy) OKAlertViewCallBackBlock alertCallBackBlock;
/** 取消按钮标题 */
@property (nonatomic, strong) NSString *cancelTitle;
/** AlertView消失时间 */
@property (nonatomic, assign) NSTimeInterval dismissDuration;
/** AlertView消失回调 */
@property (nonatomic, copy) void (^dismissBlock)(void);
@end

@implementation OKAlertView

/**
 自定义的UIAlertView弹框
 注意:如果有设置cancelButton, 则取消按钮的buttonIndex为:0, 其他otherButton的Index依次加1;
 
 @param alertWithCallBlock     点击按钮回调Block
 @param title                  弹框标题->(支持 NSString、NSAttributedString)
 @param message                弹框描述->(支持 NSString、NSAttributedString)
 @param cancelButtonTitle       取消按钮标题，<只能设置NSString>
 @param otherButtonTitles      其他按钮标题，<只能设置NSString>
 */
+ (instancetype)alertWithCallBlock:(OKAlertViewCallBackBlock)alertWithCallBlock
                             title:(id)title
                           message:(id)message
                 cancelButtonTitle:(id)cancelButtonTitle
                 otherButtonTitles:(id)otherButtonTitles, ...NS_REQUIRES_NIL_TERMINATION
{
    BOOL canShow = [self judgeCanShowAlert:cancelButtonTitle
                                   message:message
                                     title:title];
    if(!canShow) return nil;
    
    //包装按钮标题数组
    NSMutableArray *otherTitleArr = [NSMutableArray array];
    va_list otherButtonTitleList;
    va_start(otherButtonTitleList, otherButtonTitles);
    {
        for (NSString *otherButtonTitle = otherButtonTitles; otherButtonTitle != nil; otherButtonTitle = va_arg(otherButtonTitleList, NSString *)) {
            [otherTitleArr addObject:otherButtonTitle];
        }
    }
    va_end(otherButtonTitleList);
    
    CGRect rect = [UIScreen mainScreen].bounds;
    return [[OKAlertView alloc] initWithFrame:rect
                                        title:title
                                      message:message
                            cancelButtonTitle:cancelButtonTitle
                            otherButtonTitles:otherTitleArr
                                callBackBlock:alertWithCallBlock];
}

/**
 使用方式同上个方法, (效果和上面的方法一样,c函数的方式调用代码量更少)
 
 @param title 弹框标题->(支持 NSString、NSAttributedString)
 @param message 弹框描述->(支持 NSString、NSAttributedString)
 @param cancelButtonTitle 取消按钮标题->(支持 NSString、NSAttributedString)
 @param otherButtonTitles 其他按钮标题->(支持 NSString、NSAttributedString)
 @param alertWithCallBlock 点击按钮回调Block
 @return 弹框实例对象
 */
OKAlertView* ShowAlertView(id title, id message, id cancelButtonTitle, NSArray *otherButtonTitles,  OKAlertViewCallBackBlock alertWithCallBlock)
{
    BOOL canShow = [OKAlertView judgeCanShowAlert:cancelButtonTitle
                                          message:message
                                            title:title];
    if(!canShow) return nil;
    
    CGRect rect = [UIScreen mainScreen].bounds;
    return [[OKAlertView alloc] initWithFrame:rect
                                        title:title
                                      message:message
                            cancelButtonTitle:cancelButtonTitle
                            otherButtonTitles:otherButtonTitles
                                callBackBlock:alertWithCallBlock];
}

/**
 * 单个按钮提示Alert弹框, 没有事件只做提示使用
 *
 @param title 弹框标题->(支持 NSString、NSAttributedString)
 @param message 弹框描述->(支持 NSString、NSAttributedString)
 @param cancelButtonTitle 取消按钮标题->(支持 NSString、NSAttributedString)
 */
void ShowAlertSingleBtnView(id title, id message, id cancelButtonTitle){
    [OKAlertView alertWithCallBlock:nil
                              title:title
                            message:message
                  cancelButtonTitle:cancelButtonTitle
                  otherButtonTitles: nil];
}

/**
 根据条件判断能否显示弹框
 */
+ (BOOL)judgeCanShowAlert:(id)cancelButtonTitle message:(id)message title:(id)title
{
    if(!title && !message){
        return NO;
    }
    
    if (title && ![title isKindOfClass:[NSString class]] &&
        ![title isKindOfClass:[NSAttributedString class]]){
        return NO;
    }
    
    if (message && ![message isKindOfClass:[NSString class]] &&
        ![message isKindOfClass:[NSAttributedString class]]){
        return NO;
    }
    
    if (cancelButtonTitle && ![cancelButtonTitle isKindOfClass:[NSString class]] &&
        ![cancelButtonTitle isKindOfClass:[NSAttributedString class]]){
        return NO;
    }
    return YES;
}

#pragma mark - 初始化自定义OKAlertView

- (instancetype)initWithFrame:(CGRect)frame
                        title:(id)title
                      message:(id)message
            cancelButtonTitle:(id)cancelTitle
            otherButtonTitles:(NSArray *)buttonTitleArr
                callBackBlock:(OKAlertViewCallBackBlock)alertWithCallBlock
{
    self = [super initWithFrame:frame];
    if(self){
        //点击按钮回调
        self.alertCallBackBlock = alertWithCallBlock;
        
        //取消按钮标题
        self.cancelTitle = cancelTitle;
        
        //设置按钮标题主色
        self.mainColor = [OKAlertView appearance].mainColor ? : OKAlertView_MainColor;
        
        //1.先移除window上已存在的OKAlertView
        [self removeOkAlertFromWindow];
        
        //2.初始化弹框标题和描述
        CGFloat lastLabMaxY = [self layoutTitleAndMessageUI:title message:message];
        
        //按钮大于一个就把"取消"按钮放最后， 否则就放第一个
        NSMutableArray *allTitleArr = [NSMutableArray arrayWithArray:buttonTitleArr];
        if(cancelTitle) {
            if (allTitleArr.count > 1) {
                [allTitleArr addObject:cancelTitle];
            } else {
                [allTitleArr insertObject:cancelTitle atIndex:0];
            }
        }
        
        if (allTitleArr.count > 0) {
            //3.布局所有弹框按钮
            [self layoutMutableBtnUI:allTitleArr contentView:self.contentView lastUImaxY:lastLabMaxY];
            
        } else { //没有设置按钮就默认直接延迟2秒退出弹框
            NSInteger dismissTime = self.dismissDuration>0 ? self.dismissDuration : OKAlertView_ToastDismissTime;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(dismissTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissOKAlertView:nil];
            });
        }
        
        //4.显示在窗口
        [self showOKAlertViewToWindow];
    }
    return self;
}

/**
 * 初始化弹框主视图
 */
- (CGFloat)layoutTitleAndMessageUI:(id)title message:(id)message
{
    //弹框矩形视图
    CGFloat contentW = kFullScreenWidth-OKAlertView_ScreenSpace*2;
    CGRect rect = CGRectMake(OKAlertView_ScreenSpace, 0, contentW, 0);
    
    UIView *contentView = [[UIView alloc] initWithFrame:rect];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = 15;
    contentView.layer.masksToBounds = YES;
    [self addSubview:contentView];
    self.contentView = contentView;
    
    CGFloat lastLabMaxY = 0;
    CGFloat labelWidth = contentW-OKAlertView_KitMargin*2;
    
    //提示标题
    UILabel *titleLab = nil;
    if (title) {
        titleLab = [[UILabel alloc] init];
        titleLab.backgroundColor = [UIColor clearColor];
        [titleLab setTextColor:OKAlertView_LabelColor];
        [titleLab setTextAlignment:NSTextAlignmentCenter];
        [titleLab setFont:[UIFont boldSystemFontOfSize:17]];
        [contentView addSubview:titleLab];
        titleLab.numberOfLines = 0;
        
        //赋值文本标题
        [self setTextStyle:titleLab textString:title];
        CGFloat titleHeight = [OKAlertView calculateTextHeight:titleLab.font
                                            constrainedToWidth:labelWidth
                                                     textStyle:title];
        titleLab.frame = CGRectMake(OKAlertView_KitMargin, OKAlertView_KitMargin, labelWidth, titleHeight);
        lastLabMaxY = message ? CGRectGetMaxY(titleLab.frame) : (CGRectGetMaxY(titleLab.frame)+OKAlertView_KitMargin);
    }
    
    //详细信息
    UILabel *messageLab = nil;
    if (message) {
        messageLab = [[UILabel alloc] init];
        messageLab.backgroundColor = [UIColor clearColor];
        [messageLab setTextColor:OKAlertView_LabelColor];
        [messageLab setTextAlignment:NSTextAlignmentCenter];
        [messageLab setFont:FONTDEFAULT(13)];
        [contentView addSubview:messageLab];
        messageLab.numberOfLines = 0;
        
        //赋值文本详细信息
        [self setTextStyle:messageLab textString:message];
        CGFloat msgHeight = [OKAlertView calculateTextHeight:messageLab.font
                                          constrainedToWidth:labelWidth
                                                   textStyle:message];
        CGFloat messageLabY = title ? (lastLabMaxY+OKAlertView_KitMargin*0.2) : OKAlertView_KitMargin;
        messageLab.frame = CGRectMake(OKAlertView_KitMargin, messageLabY, labelWidth, msgHeight);
        lastLabMaxY = CGRectGetMaxY(messageLab.frame)+OKAlertView_KitMargin;
    }
    
    contentView.bounds = CGRectMake(0, 0, contentW, lastLabMaxY);
    contentView.center = self.center;
    return lastLabMaxY;
}

/**
 * 布局所有Alert按钮
 */
- (void)layoutMutableBtnUI:(NSArray *)allTitleArr
               contentView:(UIView *)contentView
                lastUImaxY:(CGFloat)lastLabMaxY
{
    if (allTitleArr.count==0) return;
    
    CGFloat lastBtnMaxY = lastLabMaxY;
    CGFloat contentW = kFullScreenWidth-OKAlertView_ScreenSpace*2;
    
    for (int i = 0 ; i<allTitleArr.count; i++) {
        //分割线
        CGRect lineRect = CGRectMake(0, lastBtnMaxY, contentW, OKAlertView_LineHeight);
        UILabel *line = [[UILabel alloc] initWithFrame:lineRect];
        line.backgroundColor = OKAlertView_LineColor;
        [contentView addSubview:line];
        
        //按钮
        UIButton *actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        actionBtn.backgroundColor = [UIColor whiteColor];
        [actionBtn.titleLabel setFont:FONTDEFAULT(16)];
        [actionBtn setTitleColor:OKAlertView_BtnTitleNorColor forState:0];
        [actionBtn addTarget:self action:@selector(alertBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [actionBtn setBackgroundImage:[OKAlertView ok_imageWithColor:OKAlertView_BtnBgDisabledColor] forState:UIControlStateDisabled];
        [actionBtn setBackgroundImage:[OKAlertView ok_imageWithColor:OKAlertView_BtnBgHighColor] forState:UIControlStateHighlighted];
        [actionBtn setExclusiveTouch:YES];
        [contentView addSubview:actionBtn];
        actionBtn.tag = i;
        
        //赋值按钮标题
        [self setTextStyle:actionBtn textString:allTitleArr[i]];
        
        //保存按钮
        [self.alertAllButtonArr addObject:actionBtn];
        
        //标记按钮位置，在取按钮的函数(buttonAtIndex:)时用到
        if (self.cancelTitle) {
            NSInteger cancelBtnIndex = [allTitleArr indexOfObject:self.cancelTitle];
            if (cancelBtnIndex == 0) {
                actionBtn.tag = i;
            } else {
                actionBtn.tag = (i == allTitleArr.count-1) ? 0 : i+1;
            }
        }
        
        //按钮个数大于2个
        if (allTitleArr.count > 2) {
            actionBtn.frame = CGRectMake(0, CGRectGetMaxY(line.frame), contentW, OKAlertView_BigBtnHeight);
            
            //大于两个按钮时，变取消按钮显示特定颜色
            if (self.cancelTitle &&
                [self.cancelTitle isKindOfClass:[NSString class]] &&
                [self.cancelTitle isEqualToString:allTitleArr[i]]) {
                [actionBtn setTitleColor:self.mainColor forState:0];
            }
            
        } else {
            CGFloat btnY = lastLabMaxY+OKAlertView_LineHeight;
            CGFloat btnW = allTitleArr.count==2 ? contentW/2 : contentW;
            CGFloat lineY = allTitleArr.count==2 ? (i==0?lastLabMaxY:btnY) : lastLabMaxY;
            CGFloat lineW = allTitleArr.count==2 ? (i==0?contentW:OKAlertView_LineHeight) : contentW;
            CGFloat lineH = allTitleArr.count==2 ? (i==0?OKAlertView_LineHeight:OKAlertView_BigBtnHeight) : OKAlertView_BigBtnHeight;
            line.frame = CGRectMake((contentW/2)*i, lineY, lineW, lineH);
            actionBtn.frame = CGRectMake((contentW/2+OKAlertView_LineHeight)*i, btnY, btnW, OKAlertView_BigBtnHeight);
            
            if (self.cancelTitle && i==allTitleArr.count-1) {
                //只有两个按钮时，第二个按钮显示特定颜色
                [actionBtn setTitleColor:self.mainColor forState:0];
            }
        }
        
        //记住按钮y位置
        lastBtnMaxY = CGRectGetMaxY(actionBtn.frame);
        contentView.bounds = CGRectMake(0, 0, kFullScreenWidth-OKAlertView_ScreenSpace*2, CGRectGetMaxY(actionBtn.frame));
        contentView.center = self.center;
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
 *  2秒自动消失的系统Alert弹框
 *
 *  @msg 提示标题->(支持 NSString、NSAttributedString)
 */
void ShowAlertToast(id msg) {
    ShowAlertToastByTitle(nil, msg);
}


/**
 * 2秒自动消失带标题的系统Alert弹框
 
 * @param title 提示标题->(支持 NSString、NSAttributedString)
 * @param msg   提示信息->(支持 NSString、NSAttributedString)
 */
void ShowAlertToastByTitle(id title, id msg) {
    
    if (!title && !msg) return;
    [OKAlertView alertWithCallBlock:nil
                              title:title
                            message:msg
                  cancelButtonTitle:nil
                  otherButtonTitles:nil];
}

/**
 * 指定时间消失Alert弹框
 
 * @param title         提示标题->(支持 NSString、NSAttributedString)
 * @param msg           提示信息->(支持 NSString、NSAttributedString)
 * @param duration      消失时间
 * @param dismissBlock  消失回调
 */
void ShowAlertToastDelay(id title, id msg, NSTimeInterval duration, void(^dismissBlock)(void)){
    
    if (!title && !msg) return;
    OKAlertView *alertView = [OKAlertView alertWithCallBlock:nil
                                                       title:title
                                                     message:msg
                                           cancelButtonTitle:nil
                                           otherButtonTitles: nil];
    alertView.dismissDuration = duration;
    alertView.dismissBlock = dismissBlock;
}

#pragma mark -===========显示，退出弹框===========

/**
 *  显示弹框
 */
- (void)showOKAlertViewToWindow
{
    self.alpha = 0.0;
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    
    //添加AlertView到窗口上
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window endEditing:YES];
    [window addSubview:self];
    
    self.contentView.transform = CGAffineTransformMakeScale(1.12, 1.12);
    [UIView animateWithDuration:0.15f animations:^{
        self.alpha = 1;
        self.contentView.transform = CGAffineTransformIdentity;
    }];
}

/**
 *  退出弹框
 */
- (void)dismissOKAlertView:(id)sender
{
    [UIView animateWithDuration:0.1f animations:^{
        self.alpha = 0.0;
        self.contentView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    } completion:^(BOOL finished) {
        if (self.dismissBlock) {
            self.dismissBlock();
        }
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
                              keyboardType:(UIKeyboardType)keyboardType
                               buttonBlock:(void (^)(NSString *inputText))otherBlock
                               cancelBlock:(void (^)(void))cancelBlock
{
    if (![OKAlertView appearance].mainColor) {
        [OKAlertView appearance].mainColor = OKAlertView_MainColor;
    }
    
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
        textField.keyboardType = keyboardType;
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 9.0) {
            textField.superview.superview.layer.cornerRadius = 1;
            textField.superview.superview.layer.masksToBounds = YES;
            textField.superview.superview.layer.borderColor = ColorFromHex(0xdcdcdc).CGColor;
            textField.superview.superview.layer.borderWidth = 0.5;
        } else {
            
            /** 是否能获取该属性*/
            Class cls = NSClassFromString(@"_UIAlertControllerTextField");
            if([textField isKindOfClass:cls] && [OKAlertView verifyObject:cls ok_hasVarName:@"_textFieldView"])
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
    if(title && [OKAlertView verifyObject:alertController ok_hasVarName:@"attributedTitle"])
    {
        //设置标题为细体
        NSAttributedString *titleAttrs = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:OKAlertView_BtnTitleNorColor, NSFontAttributeName: FONTDEFAULT(16)}];
        [alertController setValue:titleAttrs forKey:@"attributedTitle"];
    }
    
    //设置按钮颜色
    if([OKAlertView verifyObject:[UIAlertAction class] ok_hasVarName:@"titleTextColor"])
    {
        for(int i = 0; i<alertController.actions.count; i++)
        {
            UIAlertAction *action = alertController.actions[i];
            if(i == alertController.actions.count-1) {
                //最后一个按钮设置特定颜色
                [action setValue:[OKAlertView appearance].mainColor forKey:@"titleTextColor"];
                
            } else {
                [action setValue:OKAlertView_BtnTitleNorColor forKey:@"titleTextColor"];
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(OKAlertView_ToastDismissTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alertController dismissViewControllerAnimated:YES completion:nil];
        });
    }
    
    return alertController;
}

#pragma mark - 工具方法,不引入其他类直接写在当前类

/**
 * 根据颜色获取一个单位大小的图片
 */
+ (UIImage *)ok_imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/**
 *  计算不同文本类型的高度
 */
+ (CGFloat)calculateTextHeight:(UIFont *)font
            constrainedToWidth:(CGFloat)width
                     textStyle:(id)textObject
{
    if ([textObject isKindOfClass:[NSAttributedString class]]) {
        CGSize textSize = [textObject boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                                options:(NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingTruncatesLastVisibleLine)
                                                context:nil].size;
        return ceil(textSize.height);
        
    } else if ([textObject isKindOfClass:[NSString class]]) {
        
        UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
        CGSize textSize;
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                     NSParagraphStyleAttributeName: paragraph};
        
        textSize = [(NSString *)textObject boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                      options:(NSStringDrawingUsesLineFragmentOrigin |
                                               NSStringDrawingTruncatesLastVisibleLine)
                                   attributes:attributes
                                      context:nil].size;
        return ceil(textSize.height);
    }
    return 0.0;
}


/**
 *  校验一个类是否有该属性
 */
+ (BOOL)verifyObject:(id)verifyObject ok_hasVarName:(NSString *)name
{
    unsigned int outCount;
    BOOL hasProperty = NO;
    Ivar *ivars = class_copyIvarList([verifyObject class], &outCount);
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

- (void)dealloc
{
    //NSLog(@"OKAlertView dealloc");
}

@end
