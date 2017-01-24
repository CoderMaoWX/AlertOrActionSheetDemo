//
//  OKActionSheetView.m
//  OkdeerUser
//
//  Created by mao wangxin on 2016/12/29.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import "OKActionSheetView.h"

#define RGB(r,g,b)                          [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f                                                                                 alpha:1.f]
#define UIColorFromHex(hexValue)            [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0x00FF00) >> 8))/255.0 blue:((float)(hexValue & 0x0000FF))/255.0 alpha:1.0]
#define kFullScreenWidth                    ([UIScreen mainScreen].bounds.size.width)
#define kFullScreenHeight                   ([UIScreen mainScreen].bounds.size.height)
#define OKActionSheet_font(fontSize)        ([UIFont systemFontOfSize:fontSize])

//全局黑色字体颜色
#define OKActionSheet_BlackColor            UIColorFromHex(0x323232)

//主色 (草绿色)
#define OKActionSheet_MainColor             UIColorFromHex(0x8CC63F)

//灰色线条颜色
#define OKActionSheet_LineColor             UIColorFromHex(0xe5e5e5)

// 按钮超过最大个数,则滚动
#define OKActionSheet_MaxButtonCount        5

// 按钮高度
#define OKActionSheet_ButtonHeight          44.0f

// 按钮间隙
#define OKActionSheet_CancelBtnSpace        10.0f

// 控件离屏幕边缘上下左右间距
#define OKActionSheet_LineSpacing           15


typedef enum : NSUInteger {
    BottomSquareSheetStyle,         //底部直角ActionSheet
    BottomCornerRadiusSheetStyle,   //底部圆角ActionSheet
    TopSquareSheetStyle,            //顶部直角ActionSheet
} CCActionSheetStyleType;


@interface OKActionSheetView ()

/** ActionSheet主视图 */
@property (nonatomic, strong) UIView *contentView;

/** ActionSheet所有按钮数组 */
@property (nonatomic, strong) NSMutableArray *actionSheetButtonArr;

/** ActionSheet样式 */
@property (nonatomic, assign) CCActionSheetStyleType actionSheetStyleType;

/** ActionSheet普通按钮点击回调 */
@property (nonatomic, copy) OKActionSheetCallBackBlock buttonBlock;

/** ActionSheet取消按钮点击回调 */
@property (nonatomic, copy) void(^cancelBlock)();

@property (nonatomic, assign)CGPoint showTopPosition;
@end

@implementation UIView (Extension)

- (void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)size
{
    return self.frame.size;
}
@end

@implementation OKActionSheetView


#pragma mark - 底部显示建直角ActionSheet入口

/**
 * 从底部弹出直角的ActionSheet
 */
+ (instancetype)actionSheetByBottomSquare:(OKActionSheetCallBackBlock)buttonBlock
                              cancelBlock:(void (^)())cancelBlock
                                WithTitle:(id)title
                        cancelButtonTitle:(id)cancelButtonTitle
                      otherButtonTitleArr:(NSArray *)otherButtonTitleArr
{
    if(otherButtonTitleArr.count == 0 && !cancelButtonTitle){
        NSLog(@"按钮至少要有一个");
        return nil;
    }
    
    return [[self alloc] initWithFrame:[UIScreen mainScreen].bounds
                             superView:nil
                              position:CGPointZero
                                 title:title
                      cancelButtonName:cancelButtonTitle
                        buttonTitleArr:otherButtonTitleArr
                        buttonImageArr:nil
                                 block:buttonBlock
                           cancelBlock:cancelBlock
                  actionSheetStyleType:BottomSquareSheetStyle];
}


#pragma mark - 底部显示建圆角ActionSheet入口

/**
 * 从底部弹出带圆角的ActionSheet
 */
+ (instancetype)actionSheetByBottomCornerRadius:(OKActionSheetCallBackBlock)buttonBlock
                                    cancelBlock:(void (^)())cancelBlock
                                      WithTitle:(id)title
                              cancelButtonTitle:(id)cancelButtonTitle
                            otherButtonTitleArr:(NSArray *)otherButtonTitleArr
{
    if(otherButtonTitleArr.count == 0 && !cancelButtonTitle) {
        NSLog(@"按钮至少要有一个");
        return nil;
    }
    
    return [[self alloc] initWithFrame:[UIScreen mainScreen].bounds
                             superView:nil
                              position:CGPointZero
                                 title:title
                      cancelButtonName:cancelButtonTitle
                        buttonTitleArr:otherButtonTitleArr
                        buttonImageArr:nil
                                 block:buttonBlock
                           cancelBlock:cancelBlock
                  actionSheetStyleType:BottomCornerRadiusSheetStyle];
}

#pragma mark - 顶部显示建直角ActionSheet入口

/**
 * 从顶部弹出带圆角的ActionSheet
 */
+ (instancetype)actionSheetByTopSquare:(OKActionSheetCallBackBlock)buttonBlock
                           cancelBlock:(void (^)())cancelBlock
                             superView:(UIView *)superView
                              position:(CGPoint)position
                        buttonTitleArr:(NSArray *)buttonTitleArr
                        buttonImageArr:(NSArray *)buttonImageArr
{
    if(buttonTitleArr.count == 0) {
        NSLog(@"按钮至少要有一个");
        return nil;
    }
    
    return [[self alloc] initWithFrame:[UIScreen mainScreen].bounds
                             superView:superView
                              position:position
                                 title:nil
                      cancelButtonName:nil
                        buttonTitleArr:buttonTitleArr
                        buttonImageArr:buttonImageArr
                                 block:buttonBlock
                           cancelBlock:cancelBlock
                  actionSheetStyleType:TopSquareSheetStyle];
}


#pragma mark - 初始化自定义ActionSheet

- (instancetype)initWithFrame:(CGRect)frame
                    superView:(UIView *)superView
                     position:(CGPoint)position
                        title:(id)title
             cancelButtonName:(id)cancelTitle
               buttonTitleArr:(NSArray *)buttonTitleArr
               buttonImageArr:(NSArray *)buttonImageArr
                        block:(OKActionSheetCallBackBlock)callBackBlock
                  cancelBlock:(void (^)())cancelBlock
         actionSheetStyleType:(CCActionSheetStyleType)styleType
{
    if (superView) {
        CGRect rect = CGRectMake(position.x, position.y, superView.bounds.size.width, superView.bounds.size.height);
        self = [super initWithFrame:rect];
    } else {
        self = [super initWithFrame:[UIScreen mainScreen].bounds];
    }
    
    if (self) {
        self.buttonBlock = callBackBlock;
        self.cancelBlock = cancelBlock;
        self.actionSheetStyleType = styleType;
        
        self.alpha = 0.0;
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
        
        //点击背景消失
        UIControl *control = [[UIControl alloc] initWithFrame:self.frame];
        [control addTarget:self action:@selector(dismissCCActionSheet:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:control];
        
        if (styleType == BottomCornerRadiusSheetStyle) { //底部创建圆角ActionSheet
            [self initBottomCornerRadiusActionSheetUI:title
                                          cancelTitle:cancelTitle
                                       buttonTitleArr:buttonTitleArr];
            
        } else if (styleType == BottomSquareSheetStyle) { //底部创建直角ActionSheet
            [self initBottomSquareActionSheetUI:title
                                    cancelTitle:cancelTitle
                                 buttonTitleArr:buttonTitleArr];
            
        } else if (styleType == TopSquareSheetStyle) { //顶部创建直角ActionSheet
            if (!superView) return nil;
            [self initTopSquareActionSheetUI:superView
                                    position:position
                              buttonTitleArr:buttonTitleArr
                              buttonImageArr:buttonImageArr];
        }
        //显示在窗口
        [self showCCActionSheet];
    }
    return self;
}

/**
 *  ActionSheet所有按钮数组
 */
- (NSMutableArray *)actionSheetButtonArr
{
    if (!_actionSheetButtonArr) {
        _actionSheetButtonArr = [NSMutableArray array];
    }
    return _actionSheetButtonArr;
}

#pragma mark -=========================== 底部创建圆角的ActionSheet ==========================

/**
 *  创建圆角的ActionSheet
 */
- (void)initBottomCornerRadiusActionSheetUI:(id)title cancelTitle:(id)cancelTitle buttonTitleArr:(NSArray *)buttonTitleArr
{
    CGFloat contentViewH = OKActionSheet_ButtonHeight;
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(OKActionSheet_LineSpacing, kFullScreenHeight-(OKActionSheet_LineSpacing+OKActionSheet_CancelBtnSpace), kFullScreenWidth-OKActionSheet_LineSpacing*2, contentViewH)];
    contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:contentView];
    self.contentView = contentView;
    
    //上半部分按钮
    UIView *aboveView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentView.width, contentViewH)];
    aboveView.backgroundColor = UIColorFromHex(0xf5f5f5);
    aboveView.layer.cornerRadius = 5;
    aboveView.layer.masksToBounds = YES;
    [contentView addSubview:aboveView];
    
    //最后一个按钮的高度
    CGFloat titleHY = 0;
    
    //是否有标题
    if (title){
        CGFloat fontNum = 16;
        UILabel *titleLab = [[UILabel alloc] init];
        titleLab.backgroundColor = UIColorFromHex(0xf5f5f5);
        [titleLab setTextColor:UIColorFromHex(0x666666)];
        [titleLab setTextAlignment:NSTextAlignmentCenter];
        [titleLab setFont:OKActionSheet_font(fontNum)];
        titleLab.backgroundColor = UIColorFromHex(0xf5f5f5);
        titleLab.numberOfLines = 0;
        [aboveView addSubview:titleLab];
        
        //根据文字类型设置标题
        NSString *titleString = nil;
        CGFloat btnHeight = OKActionSheet_ButtonHeight+5;
        if ([title isKindOfClass:[NSString class]])
        {
            titleString = title;
            [titleLab setText:title];
            
        } else if([title isKindOfClass:[NSAttributedString class]]){
            [titleLab setAttributedText:title];
            titleString = ((NSAttributedString *)title).string;
        }
        /*
         if ([CCAlertView stringSize:titleString andFont:titleLab.font andwidth:MAXFLOAT].height > fontNum+2){
         btnHeight +=10;
         }
         */
        
        [titleLab setFrame:CGRectMake(0, 0, aboveView.width, btnHeight)];
        
        //线条
        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLab.frame), titleLab.width, 0.5f)];
        [line setImage:[UIImage imageNamed:@"cellLine"]];
        [aboveView addSubview:line];
        if (!line.image) {
            line.backgroundColor = OKActionSheet_LineColor;
        }
        
        titleHY = CGRectGetMaxY(titleLab.frame);
    }
    
    //所有按钮标题
    NSMutableArray *allbuttontitleArr = [NSMutableArray arrayWithArray:buttonTitleArr];
    if (cancelTitle) {
        [allbuttontitleArr addObject:cancelTitle];
    }
    
    //兼容按钮超过五个的场景就滚动
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, titleHY, aboveView.width, OKActionSheet_ButtonHeight)];
    [aboveView addSubview:scrollView];
    
    [self.actionSheetButtonArr removeAllObjects];
    //设置所有按钮
    for (int i = 0 ; i<allbuttontitleArr.count; i++) {
        
        UIButton *actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [actionBtn setSize:CGSizeMake(aboveView.width, OKActionSheet_ButtonHeight)];
        actionBtn.backgroundColor = [UIColor whiteColor];
        [actionBtn setTitleColor:OKActionSheet_BlackColor forState:0];
        [actionBtn.titleLabel setFont:OKActionSheet_font(16)];
        [actionBtn setTitleColor:OKActionSheet_BlackColor forState:0];
        [actionBtn addTarget:self action:@selector(actionBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [actionBtn setTitleColor:RGB(231, 231, 231) forState:UIControlStateDisabled];
        [actionBtn setBackgroundImage:[self imageWithColor:[UIColor groupTableViewBackgroundColor]] forState:UIControlStateHighlighted];
        [actionBtn setExclusiveTouch:YES];
        
        //添加所有actionSheet按钮
        [self.actionSheetButtonArr addObject:actionBtn];
        
        //取消按钮
        if (cancelTitle && i == allbuttontitleArr.count-1)
        {
            actionBtn.tag = 0;
            actionBtn.layer.cornerRadius = 5;
            actionBtn.layer.masksToBounds = YES;
            actionBtn.y = CGRectGetMaxY(aboveView.frame)+OKActionSheet_CancelBtnSpace;
            [actionBtn setTitleColor:OKActionSheet_MainColor forState:0];
            [contentView addSubview:actionBtn];
            
            //设置整体contentView高度
            contentView.height = CGRectGetMaxY(aboveView.frame);
            
        } else { //上半部分普通按钮
            actionBtn.tag = i+1;
            actionBtn.y = OKActionSheet_ButtonHeight*i;
            [scrollView addSubview:actionBtn];
            
            if (i>OKActionSheet_MaxButtonCount) { //不能超过5个按钮高度
                scrollView.height =  OKActionSheet_ButtonHeight*OKActionSheet_MaxButtonCount;
                scrollView.bounces = YES;
            } else {
                scrollView.height =  CGRectGetMaxY(actionBtn.frame);
                scrollView.bounces = NO;
            }
            scrollView.contentSize = CGSizeMake(scrollView.width, CGRectGetMaxY(actionBtn.frame));
            
            //设置上半部分按钮整体高度
            aboveView.height = CGRectGetMaxY(scrollView.frame);
        }
        
        //根据文字类型设置标题
        id buttonTitle = allbuttontitleArr[i];
        if ([buttonTitle isKindOfClass:[NSString class]]) {
            [actionBtn setTitle:buttonTitle forState:0];
            
        } else if([buttonTitle isKindOfClass:[NSAttributedString class]]){
            [actionBtn setAttributedTitle:buttonTitle forState:0];
        }
        
        //线条
        UIImageView *line = [[UIImageView alloc] init];
        [line setImage:[UIImage imageNamed:@"cellLine"]];
        [line setFrame:CGRectMake(10, 0, contentView.width-20, 0.5f)];
        [actionBtn addSubview:line];
        if (!line.image) {
            line.backgroundColor = [UIColor groupTableViewBackgroundColor];
        }
        
        contentView.height = CGRectGetMaxY(actionBtn.frame)+OKActionSheet_LineSpacing;
    }
    
    //创建滚动底下提示文字
    if (allbuttontitleArr.count > OKActionSheet_MaxButtonCount) {
        
        UILabel *topTipLab = [[UILabel alloc] initWithFrame:CGRectMake(0, titleHY+5, aboveView.width, 20)];
        topTipLab.text = @"已经到顶了哦^_^";
        topTipLab.textColor = OKActionSheet_LineColor;
        topTipLab.textAlignment = NSTextAlignmentCenter;
        topTipLab.font = [UIFont systemFontOfSize:12];
        [aboveView insertSubview:topTipLab atIndex:0];
        
        
        UILabel *bottomTipLab = [[UILabel alloc] initWithFrame:CGRectMake(0, aboveView.height-25, aboveView.width, 20)];
        bottomTipLab.text = @"已经到没有了哦^_^";
        bottomTipLab.textColor = OKActionSheet_LineColor;
        bottomTipLab.textAlignment = NSTextAlignmentCenter;
        bottomTipLab.font = [UIFont systemFontOfSize:12];
        [aboveView insertSubview:bottomTipLab atIndex:0];
    }
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window endEditing:YES];
    [window addSubview:self];
}

#pragma mark -========================= 底部创建直角的ActionSheet =============================

/**
 *  创建直角的ActionSheet
 */
- (void)initBottomSquareActionSheetUI:(id)title cancelTitle:(id)cancelTitle buttonTitleArr:(NSArray *)buttonTitleArr
{
    CGFloat contentViewH = OKActionSheet_ButtonHeight;
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, kFullScreenHeight, kFullScreenWidth, contentViewH)];
    contentView.backgroundColor = UIColorFromHex(0xf5f5f5);
    [self addSubview:contentView];
    self.contentView = contentView;
    
    //最后一个按钮的高度
    CGFloat titleHY = 0;
    
    //是否有标题
    if (title)
    {
        UILabel *titleLab = [[UILabel alloc] init];
        titleLab.backgroundColor = UIColorFromHex(0xf5f5f5);
        [titleLab setTextColor:UIColorFromHex(0x666666)];
        [titleLab setTextAlignment:NSTextAlignmentCenter];
        [titleLab setFont:OKActionSheet_font(16)];
        titleLab.numberOfLines = 0;
        titleLab.frame = CGRectMake(0, 0, contentView.width, OKActionSheet_ButtonHeight);
        [contentView addSubview:titleLab];
        
        //根据文字类型设置标题
        if ([title isKindOfClass:[NSString class]]) {
            [titleLab setText:title];
            
        } else if([title isKindOfClass:[NSAttributedString class]]){
            [titleLab setAttributedText:title];
        }
        
        //线条
        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(titleLab.frame), kFullScreenWidth, 0.5f)];
        [line setImage:[UIImage imageNamed:@"cellLine"]];
        [contentView addSubview:line];
        if (!line.image) {
            line.backgroundColor = OKActionSheet_LineColor;
        }
        
        titleHY = CGRectGetMaxY(titleLab.frame);
    }
    
    //所有按钮标题
    NSMutableArray *allbuttontitleArr = [NSMutableArray arrayWithArray:buttonTitleArr];
    
    //兼容按钮超过五个的场景就滚动
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, titleHY, kFullScreenWidth, 100)];
    [contentView addSubview:scrollView];
    
    [self.actionSheetButtonArr removeAllObjects];
    //设置所有按钮
    for (int i = 0 ; i<allbuttontitleArr.count; i++) {
        
        UIButton *actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [actionBtn setSize:CGSizeMake(kFullScreenWidth, OKActionSheet_ButtonHeight)];
        actionBtn.backgroundColor = [UIColor whiteColor];
        actionBtn.y = OKActionSheet_ButtonHeight*i;
        actionBtn.tag = i+1;
        [actionBtn.titleLabel setFont:OKActionSheet_font(16)];
        [actionBtn addTarget:self action:@selector(actionBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [actionBtn setTitleColor:RGB(231, 231, 231) forState:UIControlStateDisabled];
        [actionBtn setTitleColor:OKActionSheet_BlackColor forState:0];
        [actionBtn setBackgroundImage:[self imageWithColor:[UIColor groupTableViewBackgroundColor]] forState:UIControlStateHighlighted];
        [scrollView addSubview:actionBtn];//把每个按钮添加到scrollView上
        [actionBtn setExclusiveTouch:YES];
        
        //添加所有actionSheet按钮
        [self.actionSheetButtonArr addObject:actionBtn];
        
        //根据文字类型设置actionBtn标题
        id buttonTitle = allbuttontitleArr[i];
        if ([buttonTitle isKindOfClass:[NSString class]]) {
            [actionBtn setTitle:buttonTitle forState:0];
            
        } else if([buttonTitle isKindOfClass:[NSAttributedString class]]){
            [actionBtn setAttributedTitle:buttonTitle forState:0];
        }
        
        //线条
        UIImageView *line = [[UIImageView alloc] init];
        [line setImage:[UIImage imageNamed:@"cellLine"]];
        [line setContentMode:UIViewContentModeCenter];
        [line setFrame:CGRectMake(0, 0, kFullScreenWidth, 1.0f)];
        [actionBtn addSubview:line];
        if (!line.image) {
            line.backgroundColor = [UIColor groupTableViewBackgroundColor];
        }
        
        if (i>OKActionSheet_MaxButtonCount) { //不能超过5个按钮高度
            scrollView.height = OKActionSheet_ButtonHeight*OKActionSheet_MaxButtonCount;
            scrollView.bounces = YES;
        } else {
            scrollView.height = CGRectGetMaxY(actionBtn.frame);
            scrollView.bounces = NO;
        }
        scrollView.contentSize = CGSizeMake(kFullScreenWidth, CGRectGetMaxY(actionBtn.frame));
    }
    
    //添加取消按钮
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setSize:CGSizeMake(kFullScreenWidth, OKActionSheet_ButtonHeight)];
    cancelBtn.backgroundColor = [UIColor whiteColor];
    cancelBtn.y = CGRectGetMaxY(scrollView.frame)+5;
    cancelBtn.tag = 0;
    [cancelBtn.titleLabel setFont:OKActionSheet_font(16)];
    [cancelBtn addTarget:self action:@selector(actionBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitleColor:RGB(231, 231, 231) forState:UIControlStateDisabled];
    [cancelBtn setTitleColor:OKActionSheet_MainColor forState:0];
    [cancelBtn setBackgroundImage:[self imageWithColor:[UIColor groupTableViewBackgroundColor]] forState:UIControlStateHighlighted];
    [contentView addSubview:cancelBtn];
    [cancelBtn setExclusiveTouch:YES];
    
    //根据文字类型设置取消按钮标题
    if ([cancelTitle isKindOfClass:[NSString class]]) {
        [cancelBtn setTitle:cancelTitle forState:0];
        
    } else if([cancelTitle isKindOfClass:[NSAttributedString class]]){
        [cancelBtn setAttributedTitle:cancelTitle forState:0];
    }
    
    //设置弹框主视图的高度
    contentView.height = CGRectGetMaxY(cancelBtn.frame);
    
    //创建滚动底下提示文字
    if (allbuttontitleArr.count > OKActionSheet_MaxButtonCount) {
        
        UILabel *topTipLab = [[UILabel alloc] initWithFrame:CGRectMake(0, titleHY+5, contentView.width, 20)];
        topTipLab.text = @"已经到顶了哦^_^";
        topTipLab.textColor = OKActionSheet_LineColor;
        topTipLab.textAlignment = NSTextAlignmentCenter;
        topTipLab.font = [UIFont systemFontOfSize:12];
        [contentView insertSubview:topTipLab atIndex:0];
        
        
        UILabel *bottomTipLab = [[UILabel alloc] initWithFrame:CGRectMake(0, cancelBtn.y-30, contentView.width, 20)];
        bottomTipLab.text = @"已经到没有了哦^_^";
        bottomTipLab.textColor = OKActionSheet_LineColor;
        bottomTipLab.textAlignment = NSTextAlignmentCenter;
        bottomTipLab.font = [UIFont systemFontOfSize:12];
        [contentView insertSubview:bottomTipLab atIndex:0];
    }
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window endEditing:YES];
    [window addSubview:self];
}


#pragma mark -========================= 顶部创建直角的ActionSheet =============================

/**
 *  顶部创建直角的ActionSheet
 */
- (void)initTopSquareActionSheetUI:(UIView *)superView
                          position:(CGPoint)position
                    buttonTitleArr:(NSArray *)buttonTitleArr
                    buttonImageArr:(NSArray *)buttonImageArr
{
    self.showTopPosition = position;
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kFullScreenWidth, OKActionSheet_ButtonHeight)];
    contentView.backgroundColor = UIColorFromHex(0xf5f5f5);
    [self addSubview:contentView];
    self.contentView = contentView;
    
    //所有按钮标题
    NSMutableArray *allbuttontitleArr = [NSMutableArray arrayWithArray:buttonTitleArr];
    
    //兼容按钮超过五个的场景就滚动
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kFullScreenWidth, 100)];
    [contentView addSubview:scrollView];
    
    [self.actionSheetButtonArr removeAllObjects];
    
    //设置所有按钮
    for (int i = 0 ; i<allbuttontitleArr.count; i++) {
        
        UIButton *actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [actionBtn setSize:CGSizeMake(kFullScreenWidth, OKActionSheet_ButtonHeight)];
        actionBtn.backgroundColor = [UIColor whiteColor];
        actionBtn.y = OKActionSheet_ButtonHeight*i;
        actionBtn.tag = i;
        [actionBtn.titleLabel setFont:OKActionSheet_font(16)];
        [actionBtn addTarget:self action:@selector(actionBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [actionBtn setTitleColor:RGB(231, 231, 231) forState:UIControlStateDisabled];
        [actionBtn setTitleColor:OKActionSheet_BlackColor forState:0];
        [actionBtn setBackgroundImage:[self imageWithColor:[UIColor groupTableViewBackgroundColor]] forState:UIControlStateHighlighted];
        actionBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        actionBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 15);
        actionBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 15);
        [scrollView addSubview:actionBtn];//把每个按钮添加到scrollView上
        [actionBtn setExclusiveTouch:YES];
        
        //设置按钮图片
        if (buttonImageArr.count > i) {
            id obj = buttonImageArr[i];
            if ([obj isKindOfClass:[NSString class]]) {
                [actionBtn setImage:[UIImage imageNamed:obj] forState:0];
                
            } else if ([obj isKindOfClass:[UIImage class]]) {
                [actionBtn setImage:obj forState:0];
            }
        }
        
        //添加所有actionSheet按钮
        [self.actionSheetButtonArr addObject:actionBtn];
        
        //根据文字类型设置actionBtn标题
        id buttonTitle = allbuttontitleArr[i];
        if ([buttonTitle isKindOfClass:[NSString class]]) {
            [actionBtn setTitle:buttonTitle forState:0];
            
        } else if([buttonTitle isKindOfClass:[NSAttributedString class]]){
            [actionBtn setAttributedTitle:buttonTitle forState:0];
        }
        
        //线条
        UIImageView *line = [[UIImageView alloc] init];
        [line setImage:[UIImage imageNamed:@"cellLine"]];
        [line setContentMode:UIViewContentModeCenter];
        [line setFrame:CGRectMake(0, 0, kFullScreenWidth, 1.0f)];
        [actionBtn addSubview:line];
        if (!line.image) {
            line.backgroundColor = [UIColor groupTableViewBackgroundColor];
        }
        
        if (i>OKActionSheet_MaxButtonCount) { //不能超过5个按钮高度
            scrollView.height = OKActionSheet_ButtonHeight*OKActionSheet_MaxButtonCount;
            scrollView.bounces = YES;
        } else {
            scrollView.height = CGRectGetMaxY(actionBtn.frame);
            scrollView.bounces = NO;
        }
        //设置弹框滚动视图的高度
        scrollView.contentSize = CGSizeMake(kFullScreenWidth, CGRectGetMaxY(actionBtn.frame));
        
        //设置弹框主视图的高度
        contentView.height = scrollView.height;
    }
    
    //设置弹框主视图的起始位置
    contentView.y = -(scrollView.height);
    
    //创建滚动底下提示文字
    if (allbuttontitleArr.count > OKActionSheet_MaxButtonCount) {
        
        UILabel *topTipLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, contentView.width, 20)];
        topTipLab.text = @"已经到顶了哦^_^";
        topTipLab.textColor = OKActionSheet_LineColor;
        topTipLab.textAlignment = NSTextAlignmentCenter;
        topTipLab.font = [UIFont systemFontOfSize:12];
        [contentView insertSubview:topTipLab atIndex:0];
        
        
        UILabel *bottomTipLab = [[UILabel alloc] initWithFrame:CGRectMake(0, contentView.height-25, contentView.width, 20)];
        bottomTipLab.text = @"已经到没有了哦^_^";
        bottomTipLab.textColor = OKActionSheet_LineColor;
        bottomTipLab.textAlignment = NSTextAlignmentCenter;
        bottomTipLab.font = [UIFont systemFontOfSize:12];
        [contentView insertSubview:bottomTipLab atIndex:0];
    }
    
    [superView endEditing:YES];
    [superView addSubview:self];
}

#pragma mark - 按钮操作事件

/**
 *  获取ActionSheet上的指定按钮
 *  注意:index为所有按钮数组的角标(cancelButton的角标为0 ,其他依次加1)
 */
- (UIButton *)buttonAtIndex:(NSInteger)index
{
    if (self.actionSheetButtonArr.count>0) {
        for (UIButton *actionBtn in self.actionSheetButtonArr) {
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
    if (self.actionSheetButtonArr.count>0) {
        for (UIButton *actionBtn in self.actionSheetButtonArr) {
            
            if ([actionBtn isKindOfClass:[UIButton class]] && actionBtn.tag == index) {
                actionBtn.enabled = enable;
                
                //根据文字类型设置标题
                if ([title isKindOfClass:[NSString class]]) {
                    [actionBtn setTitle:title forState:0];
                    
                } else if([title isKindOfClass:[NSAttributedString class]]){
                    [actionBtn setAttributedTitle:title forState:0];
                }
                break;
            }
        }
    }
}


/**
 *  操作按钮事件
 */
- (void)actionBtnAction:(UIButton *)actionBtn
{
    NSLog(@"点击了ActionSheet弹框按钮==%zd",actionBtn.tag);
    if (self.actionSheetStyleType != TopSquareSheetStyle) { //从底部弹出
        if (actionBtn.tag == 0) { //取消按钮
            if (self.cancelBlock) {
                self.cancelBlock();
            }
        } else { //其他按钮
            if (self.buttonBlock) {
                self.buttonBlock(actionBtn.tag);
            }
        }
    } else { //顶部弹框
        if (self.buttonBlock) {
            self.buttonBlock(actionBtn.tag);
        }
    }
    [self dismissCCActionSheet:nil];
}


/**
 *  显示弹框
 */
- (void)showCCActionSheet
{
    CGFloat contentViewY = 0;
    if (self.self.actionSheetStyleType != TopSquareSheetStyle) { //从底部弹出
        contentViewY = kFullScreenHeight - self.contentView.height;
    } else { //从顶部弹出 (如果superView的起始位置为64,则这里的y就是0)
        contentViewY = 0;
    }
    
    [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.alpha = 1;
        self.contentView.y = contentViewY;
    } completion:nil];
}

/**
 *  退出弹框
 */
- (void)dismissCCActionSheet:(id)sender
{
    CGFloat contentViewY = 0;
    if (self.self.actionSheetStyleType != TopSquareSheetStyle) { //从底部弹出
        contentViewY = kFullScreenHeight;
    } else { //从顶部弹出 (如果superView的起始位置为64,则这里的y就是contentView的高度)
        contentViewY = -(self.contentView.height);
    }
    
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0];
        self.contentView.y = contentViewY;
        //self.alpha = 0;
        
    } completion:^(BOOL finished) {
        if (sender) {
            NSLog(@"点击了ActionSheet灰色背景消失");
            if (self.cancelBlock) {
                self.cancelBlock();
            }
        }
        [self removeFromSuperview];
    }];
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end


