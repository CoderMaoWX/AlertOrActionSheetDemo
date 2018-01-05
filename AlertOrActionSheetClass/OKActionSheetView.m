//
//  OKActionSheetView.m
//  AlertOrActionSheetDemo
//
//  Created by mao wangxin on 2016/12/29.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import "OKActionSheetView.h"

#define OkColorFromHex(hexValue)            [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0x00FF00) >> 8))/255.0 blue:((float)(hexValue & 0x0000FF))/255.0 alpha:1.0]
#define isPhoneX 							(([UIScreen mainScreen ].bounds.size.height == 812.0)?YES:NO)
#define kOkHomeBarHeight              		(isPhoneX ? 34 : 0)
#define kOkFullScreenHeight                 ([UIScreen mainScreen].bounds.size.height - kOkHomeBarHeight)
#define kOKFullScreenWidth                  ([UIScreen mainScreen].bounds.size.width)
#define OKActionSheet_font(fontSize)        ([UIFont systemFontOfSize:fontSize])

//重写NSLog,Debug模式下打印日志和当前行数
#if DEBUG
#define OKLog(fmt, ...) NSLog((@"[函数名:%s] " " [行号:%d] " fmt), __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define OKLog(fmt, ...)
#endif

// 黑色字体颜色
#define OKActionSheet_BlackColor            OkColorFromHex(0x323232)
// 按钮标题颜色
#define OKActionSheet_ButtonTitleColor      OkColorFromHex(0xE7E7E7)
// 主色 (默认为系统 UIAlertView的蓝色)
#define OKActionSheet_cancelTitleColor      OkColorFromHex(0x2F7AFF)
// 灰色线条颜色
#define OKActionSheet_LineColor             OkColorFromHex(0xDDDDDD)
// 按钮不可用状态背景颜色
#define OK_Btn_Disabled_Bg_Color            OkColorFromHex(0xe2e2e2)
// 按钮高亮状态背景颜色
#define OK_Btn_Highlighted_Bg_Color         [OkColorFromHex(0xe8e8e8) colorWithAlphaComponent:0.5]
// 按钮超过最大个数,则滚动
#define OKActionSheet_MaxButtonCount        5
// 控件离屏幕边缘上下左右间距
#define OKActionSheet_LineSpacing           10
// 按钮高度
#define OKActionSheet_ButtonHeight          44.0f
// 按钮间隙
#define OKActionSheet_CancelBtnSpace        10.0f
// 标记取消按钮tag
#define OKActionCancelBtnTag				2017
// 圆角
#define OKActionCornerRadius				15


typedef enum : NSUInteger {
	TopSquareSheetStyle,            	//顶部直角ActionSheet
	BottomSquareSheetStyle,         	//底部直角ActionSheet
	BottomCornerRadiusSheetStyle,   	//底部圆角ActionSheet
	BottomItemCornerRadiusSheetStyle,   //底部横向Item按钮圆角ActionSheet
} CCActionSheetStyleType;

@implementation UIView (OKFrame)

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

@interface OKActionSheetView ()<UIScrollViewDelegate>

/** ActionSheet主视图 */
@property (nonatomic, strong) UIView *contentView;
/** ActionSheet所有按钮数组 */
@property (nonatomic, strong) NSMutableArray *actionSheetButtonArr;
/** ActionSheet样式 */
@property (nonatomic, assign) CCActionSheetStyleType actionSheetStyleType;
/** ActionSheet普通按钮点击回调 */
@property (nonatomic, copy) OKActionSheetCallBackBlock buttonBlock;
/** ActionSheet取消按钮点击回调 */
@property (nonatomic, copy) void(^cancelButtonBlock)(void);
/** ActionSheet滚动条 */
@property (nonatomic, strong) UIView *lastIndicatorView;
@end

@implementation OKActionSheetView

#pragma mark - 底部显示建直角ActionSheet入口

/**
 * 从底部弹出直角的ActionSheet
 */
+ (instancetype)actionSheetByBottomSquare:(OKActionSheetCallBackBlock)buttonBlock
						cancelButtonBlock:(void (^)(void))cancelButtonBlock
								sheetTitle:(id)title
						cancelButtonTitle:(id)cancelButtonTitle
					  otherButtonTitleArr:(NSArray *)otherButtonTitleArr
{
	if(otherButtonTitleArr.count == 0 && !cancelButtonTitle){
		OKLog(@"至少要有一个按钮");
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
					 cancelButtonBlock:cancelButtonBlock
				  actionSheetStyleType:BottomSquareSheetStyle];
}


#pragma mark - 底部显示建圆角ActionSheet入口

/**
 * 从底部弹出带圆角的ActionSheet
 */
+ (instancetype)actionSheetByBottomCornerRadius:(OKActionSheetCallBackBlock)buttonBlock
							  cancelButtonBlock:(void (^)(void))cancelButtonBlock
									  sheetTitle:(id)title
							  cancelButtonTitle:(id)cancelButtonTitle
							otherButtonTitleArr:(NSArray *)otherButtonTitleArr
{
	if(otherButtonTitleArr.count == 0 && !cancelButtonTitle) {
		OKLog(@"至少要有一个按钮");
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
					 cancelButtonBlock:cancelButtonBlock
				  actionSheetStyleType:BottomCornerRadiusSheetStyle];
}

#pragma mark - 顶部显示建直角ActionSheet入口

/**
 * 从顶部弹出带圆角的ActionSheet
 */
+ (instancetype)actionSheetByTopSquare:(OKActionSheetCallBackBlock)buttonBlock
					 cancelButtonBlock:(void (^)(void))cancelButtonBlock
							 superView:(UIView *)superView
							  position:(CGPoint)position
						buttonTitleArr:(NSArray *)buttonTitleArr
						buttonImageArr:(NSArray *)buttonImageArr
{
	if(buttonTitleArr.count == 0) {
		OKLog(@"至少要有一个按钮");
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
					 cancelButtonBlock:cancelButtonBlock
				  actionSheetStyleType:TopSquareSheetStyle];
}

#pragma mark - 底部横向显示按钮Item圆角ActionSheet入口

/**
 底部横向显示按钮Item圆角的ActionSheet

 @param buttonBlock     点击按钮回调
 @param cancelButtonBlock 点击取消或点击背景退出弹框事件回调
 @param buttonTitleArr  按钮标题(支持 NSString、NSAttributedString)
 @param buttonImageArr  按钮图标(支持 NSString、UIImage)
 @return                返回自定义的ActionSheet实例
 */
+ (instancetype)actionSheetByBottomItemCornerRadius:(OKActionSheetCallBackBlock)buttonBlock
								  cancelButtonBlock:(void (^)(void))cancelButtonBlock
										 sheetTitle:(id)title
								  cancelButtonTitle:(id)cancelButtonTitle
									 buttonTitleArr:(NSArray *)buttonTitleArr
									 buttonImageArr:(NSArray *)buttonImageArr
{
	if(buttonTitleArr.count == 0) {
		OKLog(@"至少要有一个按钮");
		return nil;
	}

	return [[self alloc] initWithFrame:[UIScreen mainScreen].bounds
							 superView:nil
							  position:CGPointZero
								 title:title
					  cancelButtonName:cancelButtonTitle
						buttonTitleArr:buttonTitleArr
						buttonImageArr:buttonImageArr
								 block:buttonBlock
					 cancelButtonBlock:cancelButtonBlock
				  actionSheetStyleType:BottomItemCornerRadiusSheetStyle];
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
			cancelButtonBlock:(void (^)(void))cancelButtonBlock
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
		self.cancelButtonBlock = cancelButtonBlock;
		self.actionSheetStyleType = styleType;

		self.alpha = 0.0;
		self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];

		//点击背景消失
		UIControl *control = [[UIControl alloc] initWithFrame:self.frame];
		[control addTarget:self action:@selector(dismissCCActionSheet:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:control];

		//设置按钮标题主色
		self.titleTextAttributes = [OKActionSheetView appearance].titleTextAttributes ? : nil;
		self.otherBtnTitleAttributes = [OKActionSheetView appearance].otherBtnTitleAttributes ? : nil;
		self.themeColorBtnTitleAttributes = [OKActionSheetView appearance].themeColorBtnTitleAttributes ? : nil;

		//1.先移除window上已存在的OKActionSheetView
		[self removeOKActionSheetFromWindow];

		if (styleType == TopSquareSheetStyle) { //创建顶部直角ActionSheet
			if (!superView) {
				OKLog(@"父视图不存在");
				return nil;
			}
			self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
			[self initTopSquareActionSheetUI:superView
									position:position
							  buttonTitleArr:buttonTitleArr
							  buttonImageArr:buttonImageArr];

		} else if (styleType == BottomSquareSheetStyle) { //创建底部直角ActionSheet
			[self initBottomSquareActionSheetUI:title
									cancelTitle:cancelTitle
								 buttonTitleArr:buttonTitleArr];

		} else if (styleType == BottomCornerRadiusSheetStyle) { //创建底部圆角ActionSheet
			[self initBottomCornerRadiusActionSheetUI:title
										  cancelTitle:cancelTitle
									   buttonTitleArr:buttonTitleArr];

		} else if (styleType == BottomItemCornerRadiusSheetStyle) { //创建底部横向Item按钮圆角ActionSheet
			if (buttonTitleArr.count != buttonImageArr.count) {
				OKLog(@"按钮标题和图标数不一致");
				return nil;
			}
			[self initBottomItemCornerRadiusActionSheetUI:title
											  cancelTitle:cancelTitle
										   buttonTitleArr:buttonTitleArr
										   buttonImageArr:buttonImageArr];
		}
		//显示在窗口
		[self showCCActionSheet];
	}
	return self;
}

/**
 * 移除window上已存在的OKActionSheetView
 */
- (void)removeOKActionSheetFromWindow
{
	UIWindow *window = [[UIApplication sharedApplication] keyWindow];
	for (UIView *windowSubView in window.subviews) {
		if ([windowSubView isKindOfClass:[OKActionSheetView class]]) {
			[windowSubView removeFromSuperview];
			break;
		}
	}
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

#pragma mark -========================= 顶部下拉直角的ActionSheet =============================

/**
 *  顶部创建直角的ActionSheet
 */
- (void)initTopSquareActionSheetUI:(UIView *)superView
						  position:(CGPoint)position
					buttonTitleArr:(NSArray *)buttonTitleArr
					buttonImageArr:(NSArray *)buttonImageArr
{
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kOKFullScreenWidth, OKActionSheet_ButtonHeight)];
	contentView.backgroundColor = OkColorFromHex(0xf5f5f5);
	[self addSubview:contentView];
	self.contentView = contentView;

	contentView.layer.borderColor = OKActionSheet_LineColor.CGColor;
	contentView.layer.borderWidth = 0.5;

	//所有按钮标题
	NSMutableArray *allbuttontitleArr = [NSMutableArray arrayWithArray:buttonTitleArr];

	//兼容按钮超过五个的场景就滚动
	UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kOKFullScreenWidth, 100)];
	scrollView.showsVerticalScrollIndicator = NO;
	[contentView addSubview:scrollView];

	[self.actionSheetButtonArr removeAllObjects];

	//设置所有按钮
	for (int i = 0 ; i<allbuttontitleArr.count; i++) {

		UIButton *actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[actionBtn setSize:CGSizeMake(kOKFullScreenWidth, OKActionSheet_ButtonHeight)];
		actionBtn.backgroundColor = [UIColor whiteColor];
		actionBtn.y = OKActionSheet_ButtonHeight*i;
		actionBtn.tag = i;
		[actionBtn.titleLabel setFont:OKActionSheet_font(16)];
		[actionBtn addTarget:self action:@selector(actionBtnAction:) forControlEvents:UIControlEventTouchUpInside];
		[actionBtn setTitleColor:OKActionSheet_ButtonTitleColor forState:UIControlStateDisabled];
		[actionBtn setTitleColor:OKActionSheet_BlackColor forState:0];
		[actionBtn setBackgroundImage:[OKActionSheetView ok_imageWithColor:OK_Btn_Disabled_Bg_Color] forState:UIControlStateDisabled];
		[actionBtn setBackgroundImage:[OKActionSheetView ok_imageWithColor:OK_Btn_Highlighted_Bg_Color] forState:UIControlStateHighlighted];
		actionBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
		actionBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 15);
		actionBtn.adjustsImageWhenHighlighted = NO;
		[scrollView addSubview:actionBtn];//把每个按钮添加到scrollView上
		[actionBtn setExclusiveTouch:YES];

		//设置按钮图片
		if (buttonImageArr.count > i) {
			id obj = buttonImageArr[i];
			if ([obj isKindOfClass:[NSString class]]) {
				UIImage *image = [UIImage imageNamed:obj];
				if (image) {
					[actionBtn setImage:image forState:0];
					actionBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 15);
					actionBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 15);
				}

			} else if ([obj isKindOfClass:[UIImage class]]) {
				[actionBtn setImage:obj forState:0];
				actionBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 15);
				actionBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 15);
			}
		}

		//添加所有actionSheet按钮
		[self.actionSheetButtonArr addObject:actionBtn];

		//根据文字类型设置actionBtn标题
		id buttonTitle = allbuttontitleArr[i];
		if ([buttonTitle isKindOfClass:[NSString class]]) {

			if (self.otherBtnTitleAttributes) {
				NSAttributedString *buttonTitleAttr = [[NSAttributedString alloc] initWithString:buttonTitle attributes:self.otherBtnTitleAttributes];
				[actionBtn setAttributedTitle:buttonTitleAttr forState:0];
			} else {
				[actionBtn setTitle:buttonTitle forState:0];
			}

		} else if([buttonTitle isKindOfClass:[NSAttributedString class]]){
			[actionBtn setAttributedTitle:buttonTitle forState:0];
		}

		//线条
		UIImageView *line = [[UIImageView alloc] init];
		[line setImage:[UIImage imageNamed:@"cellLine"]];
		[line setContentMode:UIViewContentModeCenter];
		[line setFrame:CGRectMake(0, 0, kOKFullScreenWidth, 0.5f)];
		[actionBtn addSubview:line];
		if (!line.image) {
			line.backgroundColor = OKActionSheet_LineColor;
		}

		if (i>OKActionSheet_MaxButtonCount) { //不能超过5个按钮高度
			scrollView.height = OKActionSheet_ButtonHeight*OKActionSheet_MaxButtonCount;
			scrollView.bounces = YES;
		} else {
			scrollView.height = CGRectGetMaxY(actionBtn.frame);
			scrollView.bounces = NO;
		}
		//设置弹框滚动视图的高度
		scrollView.contentSize = CGSizeMake(kOKFullScreenWidth, CGRectGetMaxY(actionBtn.frame));

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
		topTipLab.font = [UIFont systemFontOfSize:10];
		[contentView insertSubview:topTipLab atIndex:0];


		UILabel *bottomTipLab = [[UILabel alloc] initWithFrame:CGRectMake(0, contentView.height-25, contentView.width, 20)];
		bottomTipLab.text = @"已经到底了哦^_^";
		bottomTipLab.textColor = OKActionSheet_LineColor;
		bottomTipLab.textAlignment = NSTextAlignmentCenter;
		bottomTipLab.font = [UIFont systemFontOfSize:10];
		[contentView insertSubview:bottomTipLab atIndex:0];
	}

	[superView endEditing:YES];
	[superView addSubview:self];
}


#pragma mark -========================= 底部上拉直角的ActionSheet =============================

/**
 *  创建直角的ActionSheet
 */
- (void)initBottomSquareActionSheetUI:(id)title
						  cancelTitle:(id)cancelTitle
					   buttonTitleArr:(NSArray *)buttonTitleArr
{
	CGFloat contentViewH = OKActionSheet_ButtonHeight;

	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, kOkFullScreenHeight, kOKFullScreenWidth, contentViewH)];
	contentView.backgroundColor = OkColorFromHex(0xf5f5f5);
	[self addSubview:contentView];
	self.contentView = contentView;

	//最后一个按钮的高度
	CGFloat titleHY = 0;

	//是否有标题
	if (title)
		{
		UILabel *titleLab = [[UILabel alloc] init];
		titleLab.backgroundColor = OkColorFromHex(0xf5f5f5);
		[titleLab setTextColor:OkColorFromHex(0x666666)];
		[titleLab setTextAlignment:NSTextAlignmentCenter];
		[titleLab setFont:OKActionSheet_font(14)];
		titleLab.numberOfLines = 0;
		[contentView addSubview:titleLab];

		//根据文字类型设置标题
		id titleObject = title;
		if ([title isKindOfClass:[NSString class]]) {

			if (self.titleTextAttributes) {
				NSAttributedString *titleAttr = [[NSAttributedString alloc] initWithString:title attributes:self.titleTextAttributes];
				[titleLab setAttributedText:titleAttr];
				titleObject = titleAttr;

			} else {
				[titleLab setText:title];
			}

		} else if([title isKindOfClass:[NSAttributedString class]]){
			[titleLab setAttributedText:title];
		}

		CGFloat titleLabW = contentView.width-OKActionSheet_LineSpacing*2;
		CGFloat btnHeight = OKActionSheet_ButtonHeight;
		CGFloat fontSize = [OKActionSheetView calculateTextHeight:titleLab.font constrainedToWidth:titleLabW textObject:titleObject];
		btnHeight = (fontSize+20);
		if (btnHeight < OKActionSheet_ButtonHeight) {
			btnHeight = OKActionSheet_ButtonHeight;
		}
		[titleLab setFrame:CGRectMake(OKActionSheet_LineSpacing, 0, titleLabW, btnHeight)];

		//线条
		UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(titleLab.frame), kOKFullScreenWidth, 0.5f)];
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
	UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, titleHY, kOKFullScreenWidth, 100)];
	scrollView.showsVerticalScrollIndicator = NO;
	[contentView addSubview:scrollView];

	[self.actionSheetButtonArr removeAllObjects];
	//设置所有按钮
	for (int i = 0 ; i<allbuttontitleArr.count; i++) {

		UIButton *actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[actionBtn setSize:CGSizeMake(kOKFullScreenWidth, OKActionSheet_ButtonHeight)];
		actionBtn.backgroundColor = [UIColor whiteColor];
		actionBtn.y = OKActionSheet_ButtonHeight*i;
		actionBtn.tag = i;
		[actionBtn.titleLabel setFont:OKActionSheet_font(16)];
		[actionBtn addTarget:self action:@selector(actionBtnAction:) forControlEvents:UIControlEventTouchUpInside];
		[actionBtn setTitleColor:OKActionSheet_ButtonTitleColor forState:UIControlStateDisabled];
		[actionBtn setTitleColor:OKActionSheet_BlackColor forState:0];
		[actionBtn setBackgroundImage:[OKActionSheetView ok_imageWithColor:OK_Btn_Disabled_Bg_Color] forState:UIControlStateDisabled];
		[actionBtn setBackgroundImage:[OKActionSheetView ok_imageWithColor:OK_Btn_Highlighted_Bg_Color] forState:UIControlStateHighlighted];
		[scrollView addSubview:actionBtn];//把每个按钮添加到scrollView上
		[actionBtn setExclusiveTouch:YES];

		//添加所有actionSheet按钮
		[self.actionSheetButtonArr addObject:actionBtn];

		//根据文字类型设置actionBtn标题
		id buttonTitle = allbuttontitleArr[i];
		if ([buttonTitle isKindOfClass:[NSString class]]) {

			if (self.otherBtnTitleAttributes) {
				NSAttributedString *buttonTitleAttr = [[NSAttributedString alloc] initWithString:buttonTitle attributes:self.otherBtnTitleAttributes];
				[actionBtn setAttributedTitle:buttonTitleAttr forState:0];
			} else {
				[actionBtn setTitle:buttonTitle forState:0];
			}

		} else if([buttonTitle isKindOfClass:[NSAttributedString class]]){
			[actionBtn setAttributedTitle:buttonTitle forState:0];
		}

		//线条
		UIImageView *line = [[UIImageView alloc] init];
		[line setImage:[UIImage imageNamed:@"cellLine"]];
		[line setContentMode:UIViewContentModeCenter];
		[line setFrame:CGRectMake(0, 0, kOKFullScreenWidth, 0.5f)];
		[actionBtn addSubview:line];
		if (!line.image) {
			line.backgroundColor = OKActionSheet_LineColor;
		}

		if (i>OKActionSheet_MaxButtonCount) { //不能超过5个按钮高度
			scrollView.height = OKActionSheet_ButtonHeight*OKActionSheet_MaxButtonCount;
			scrollView.bounces = YES;
		} else {
			scrollView.height = CGRectGetMaxY(actionBtn.frame);
			scrollView.bounces = NO;
		}
		scrollView.contentSize = CGSizeMake(kOKFullScreenWidth, CGRectGetMaxY(actionBtn.frame));
	}

	//添加取消按钮
	UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[cancelBtn setSize:CGSizeMake(kOKFullScreenWidth, OKActionSheet_ButtonHeight)];
	cancelBtn.backgroundColor = [UIColor whiteColor];
	cancelBtn.y = CGRectGetMaxY(scrollView.frame)+5;
	cancelBtn.tag = OKActionCancelBtnTag;
	[cancelBtn.titleLabel setFont:OKActionSheet_font(16)];
	[cancelBtn addTarget:self action:@selector(actionBtnAction:) forControlEvents:UIControlEventTouchUpInside];
	[cancelBtn setTitleColor:OKActionSheet_ButtonTitleColor forState:UIControlStateDisabled];
	[cancelBtn setTitleColor:OKActionSheet_cancelTitleColor forState:0];
	[cancelBtn setBackgroundImage:[OKActionSheetView ok_imageWithColor:OK_Btn_Disabled_Bg_Color] forState:UIControlStateDisabled];
	[cancelBtn setBackgroundImage:[OKActionSheetView ok_imageWithColor:OK_Btn_Disabled_Bg_Color] forState:UIControlStateHighlighted];
	[contentView addSubview:cancelBtn];
	[cancelBtn setExclusiveTouch:YES];

	//根据文字类型设置取消按钮标题
	if ([cancelTitle isKindOfClass:[NSString class]]) {

		if (self.themeColorBtnTitleAttributes) {
			NSAttributedString *cancelTitleAttr = [[NSAttributedString alloc] initWithString:cancelTitle attributes:self.themeColorBtnTitleAttributes];
			[cancelBtn setAttributedTitle:cancelTitleAttr forState:0];
		} else {
			[cancelBtn setTitleColor:OKActionSheet_cancelTitleColor forState:0];
			[cancelBtn setTitle:cancelTitle forState:0];
		}

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
		topTipLab.font = [UIFont systemFontOfSize:10];
		[contentView insertSubview:topTipLab atIndex:0];


		UILabel *bottomTipLab = [[UILabel alloc] initWithFrame:CGRectMake(0, cancelBtn.y-30, contentView.width, 20)];
		bottomTipLab.text = @"已经到底了哦^_^";
		bottomTipLab.textColor = OKActionSheet_LineColor;
		bottomTipLab.textAlignment = NSTextAlignmentCenter;
		bottomTipLab.font = [UIFont systemFontOfSize:10];
		[contentView insertSubview:bottomTipLab atIndex:0];
	}

	UIWindow *window = [[UIApplication sharedApplication] keyWindow];
	[window endEditing:YES];
	[window addSubview:self];
}


#pragma mark -=========================== 底部上拉圆角的ActionSheet ==========================

/**
 *  创建圆角的ActionSheet
 */
- (void)initBottomCornerRadiusActionSheetUI:(id)title
								cancelTitle:(id)cancelTitle
							 buttonTitleArr:(NSArray *)buttonTitleArr
{
	CGFloat contentViewH = OKActionSheet_ButtonHeight;

	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(OKActionSheet_LineSpacing, kOkFullScreenHeight-(OKActionSheet_LineSpacing+OKActionSheet_CancelBtnSpace), kOKFullScreenWidth-OKActionSheet_LineSpacing*2, contentViewH)];
	contentView.backgroundColor = [UIColor clearColor];
	[self addSubview:contentView];
	self.contentView = contentView;

	//上半部分按钮
	UIView *aboveView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentView.width, contentViewH)];
	aboveView.backgroundColor = OkColorFromHex(0xf5f5f5);
	aboveView.layer.cornerRadius = OKActionCornerRadius;
	aboveView.layer.masksToBounds = YES;
	[contentView addSubview:aboveView];

	//最后一个按钮的高度
	CGFloat titleHY = 0;

	//是否有标题
	if (title){
		UILabel *titleLab = [[UILabel alloc] init];
		titleLab.backgroundColor = OkColorFromHex(0xf5f5f5);
		[titleLab setTextColor:OkColorFromHex(0x666666)];
		[titleLab setTextAlignment:NSTextAlignmentCenter];
		[titleLab setFont:OKActionSheet_font(14)];
		titleLab.backgroundColor = OkColorFromHex(0xf5f5f5);
		titleLab.numberOfLines = 0;
		[aboveView addSubview:titleLab];

		//根据文字类型设置标题
		id titleObject = title;
		if ([title isKindOfClass:[NSString class]])
			{
			if (self.titleTextAttributes) {
				NSAttributedString *titleAttr = [[NSAttributedString alloc] initWithString:title attributes:self.titleTextAttributes];
				[titleLab setAttributedText:titleAttr];
				titleObject = titleAttr;
			} else {
				[titleLab setText:title];
			}

			} else if([title isKindOfClass:[NSAttributedString class]]){
				[titleLab setAttributedText:title];
			}

		CGFloat btnHeight = OKActionSheet_ButtonHeight;
		CGFloat titleLabW = aboveView.width-OKActionSheet_LineSpacing*2;
		CGFloat fontSize = [OKActionSheetView calculateTextHeight:titleLab.font constrainedToWidth:titleLabW textObject:titleObject];
		btnHeight = (fontSize+20);
		[titleLab setFrame:CGRectMake(OKActionSheet_LineSpacing, 0, titleLabW, btnHeight)];

		//线条
		UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLab.frame), aboveView.width, 0.5f)];
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
	scrollView.showsVerticalScrollIndicator = NO;
	[aboveView addSubview:scrollView];

	[self.actionSheetButtonArr removeAllObjects];
	//设置所有按钮
	for (int i = 0 ; i<allbuttontitleArr.count; i++) {

		UIButton *actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[actionBtn setSize:CGSizeMake(aboveView.width, OKActionSheet_ButtonHeight)];
		actionBtn.backgroundColor = [UIColor whiteColor];
		[actionBtn.titleLabel setFont:OKActionSheet_font(16)];
		[actionBtn addTarget:self action:@selector(actionBtnAction:) forControlEvents:UIControlEventTouchUpInside];
		[actionBtn setTitleColor:OKActionSheet_BlackColor forState:0];
		[actionBtn setTitleColor:OKActionSheet_ButtonTitleColor forState:UIControlStateDisabled];
		[actionBtn setBackgroundImage:[OKActionSheetView ok_imageWithColor:OK_Btn_Disabled_Bg_Color] forState:UIControlStateDisabled];
		[actionBtn setBackgroundImage:[OKActionSheetView ok_imageWithColor:OK_Btn_Highlighted_Bg_Color] forState:UIControlStateHighlighted];
		[actionBtn setExclusiveTouch:YES];

		//添加所有actionSheet按钮
		[self.actionSheetButtonArr addObject:actionBtn];

		//取消按钮
		if (cancelTitle && i == allbuttontitleArr.count-1)
			{
			actionBtn.tag = OKActionCancelBtnTag;
			actionBtn.layer.cornerRadius = OKActionCornerRadius;
			actionBtn.layer.masksToBounds = YES;
			actionBtn.y = CGRectGetMaxY(aboveView.frame)+OKActionSheet_CancelBtnSpace;
			[actionBtn setTitleColor:OKActionSheet_cancelTitleColor forState:0];
			[contentView addSubview:actionBtn];

			//设置整体contentView高度
			contentView.height = CGRectGetMaxY(aboveView.frame);

			} else { //上半部分普通按钮
				actionBtn.tag = i;
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

			//设置取消按钮标题
			if (cancelTitle && i == allbuttontitleArr.count-1) {
				if (self.themeColorBtnTitleAttributes) {
					NSAttributedString *buttonTitleAttr = [[NSAttributedString alloc] initWithString:buttonTitle attributes:self.themeColorBtnTitleAttributes];
					[actionBtn setAttributedTitle:buttonTitleAttr forState:0];

				} else {
					[actionBtn setTitleColor:OKActionSheet_cancelTitleColor forState:0];
					[actionBtn setTitle:buttonTitle forState:0];
				}

			} else { //设置其他按钮标题

				if (self.otherBtnTitleAttributes) {
					NSAttributedString *buttonTitleAttr = [[NSAttributedString alloc] initWithString:buttonTitle attributes:self.otherBtnTitleAttributes];
					[actionBtn setAttributedTitle:buttonTitleAttr forState:0];
				} else {
					[actionBtn setTitle:buttonTitle forState:0];
				}
			}

		} else if([buttonTitle isKindOfClass:[NSAttributedString class]]){
			[actionBtn setAttributedTitle:buttonTitle forState:0];
		}

		//线条
		CGFloat lineSpace = (i==0) ? 0 : 10;
		UIImageView *line = [[UIImageView alloc] init];
		[line setImage:[UIImage imageNamed:@"cellLine"]];
		[line setFrame:CGRectMake(lineSpace, 0, contentView.width-lineSpace*2, 0.5f)];
		[actionBtn addSubview:line];
		if (!line.image) {
			line.backgroundColor = OKActionSheet_LineColor;
		}

		contentView.height = CGRectGetMaxY(actionBtn.frame)+OKActionSheet_LineSpacing;
	}

	//创建滚动底下提示文字
	if (allbuttontitleArr.count > OKActionSheet_MaxButtonCount) {
		UILabel *topTipLab = [[UILabel alloc] initWithFrame:CGRectMake(0, titleHY+5, aboveView.width, 20)];
		topTipLab.text = @"已经到顶了哦^_^";
		topTipLab.textColor = OKActionSheet_LineColor;
		topTipLab.textAlignment = NSTextAlignmentCenter;
		topTipLab.font = [UIFont systemFontOfSize:10];
		[aboveView insertSubview:topTipLab atIndex:0];

		UILabel *bottomTipLab = [[UILabel alloc] initWithFrame:CGRectMake(0, aboveView.height-25, aboveView.width, 20)];
		bottomTipLab.text = @"已经到底了哦^_^";
		bottomTipLab.textColor = OKActionSheet_LineColor;
		bottomTipLab.textAlignment = NSTextAlignmentCenter;
		bottomTipLab.font = [UIFont systemFontOfSize:10];
		[aboveView insertSubview:bottomTipLab atIndex:0];
	}

	UIWindow *window = [[UIApplication sharedApplication] keyWindow];
	[window endEditing:YES];
	[window addSubview:self];
}


#pragma mark -=========================== 底部上拉横向Item按钮圆角ActionSheet ==========================

/**
 *  创建底部横向Item按钮圆角ActionSheet
 */
- (void)initBottomItemCornerRadiusActionSheetUI:(id)tipTitle
									cancelTitle:(id)cancelTitle
								 buttonTitleArr:(NSArray *)buttonTitleArr
								 buttonImageArr:(NSArray *)buttonImageArr
{
	CGRect rect = CGRectMake(OKActionSheet_LineSpacing,kOkFullScreenHeight-(OKActionSheet_LineSpacing+OKActionSheet_CancelBtnSpace),
							 kOKFullScreenWidth-OKActionSheet_LineSpacing*2, OKActionSheet_ButtonHeight);
	UIView *contentView = [[UIView alloc] initWithFrame:rect];
	contentView.backgroundColor = [UIColor whiteColor];
	contentView.layer.cornerRadius = OKActionCornerRadius;
	contentView.layer.masksToBounds = YES;
	[self addSubview:contentView];
	self.contentView = contentView;

	UIColor *lineColor = OkColorFromHex(0xe5e5e5);
	CGFloat maxHeight = 0;
	if (tipTitle) {
		UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, contentView.width, 15)];
		titleLab.adjustsFontSizeToFitWidth = YES;
		titleLab.backgroundColor = [UIColor clearColor];
		[titleLab setTextColor:OkColorFromHex(0x323232)];
		[titleLab setTextAlignment:NSTextAlignmentCenter];
		[titleLab setFont:OKActionSheet_font(15)];
		[contentView addSubview:titleLab];

		//根据文字类型设置标题
		if ([tipTitle isKindOfClass:[NSString class]]) {
			titleLab.text = tipTitle;
		} else if([tipTitle isKindOfClass:[NSAttributedString class]]){
			titleLab.attributedText = tipTitle;
		}

		//分割线
		UIView *topLine = [[UIView alloc] init];
		topLine.backgroundColor = lineColor;
		topLine.frame = CGRectMake(0, CGRectGetMaxY(titleLab.frame)+10, contentView.width, 0.5f);
		[contentView addSubview:topLine];

		maxHeight = CGRectGetMaxY(topLine.frame);
	}

	NSInteger itemCount = buttonImageArr.count;
	CGFloat pageWidth = contentView.width;
	NSInteger onePageItemCount = 6;//一页的最多6数
	NSInteger maxCols = 3;//一页3列
	CGFloat buttonW = 70;
	CGFloat buttonH = 70;
	CGFloat startY = 0;
	CGFloat startX = (pageWidth - buttonW * maxCols) / (maxCols+1);//间隔距离
	NSInteger pageCount = buttonImageArr.count/onePageItemCount;
	if ((buttonImageArr.count % onePageItemCount) > 0) {
		pageCount += 1;
	}

	//Item按钮超过6个的场景就横向分页滚动
	UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, maxHeight, pageWidth, buttonH * 2)];
	scrollView.contentSize = CGSizeMake(pageWidth * pageCount, scrollView.height);
	scrollView.backgroundColor = [UIColor clearColor];
	scrollView.showsHorizontalScrollIndicator = NO;
	scrollView.pagingEnabled = YES;
	scrollView.bounces = NO;
	[contentView addSubview:scrollView];

	//所有Item按钮
	UIView *tempPageView = nil;
	[self.actionSheetButtonArr removeAllObjects];
	for (NSInteger j = 0; j<itemCount; j++) {

		id imageObj = buttonImageArr[j];
		if ([imageObj isKindOfClass:[NSString class]]) {
			UIImage *image = [UIImage imageNamed:imageObj];
			if (![image isKindOfClass:[UIImage class]]) continue;

		} else if (![imageObj isKindOfClass:[UIImage class]]) continue;

		id bntTitle = nil;
		if (buttonTitleArr.count > j) {
			bntTitle = buttonTitleArr[j];
			if (bntTitle && ![bntTitle isKindOfClass:[NSString class]] &&
				![bntTitle isKindOfClass:[NSAttributedString class]] ) continue;
		}

		if ((j % onePageItemCount) == 0) {
			NSInteger pageIndex = j/onePageItemCount;//第几页
			OKLog(@"共%zd页, 创建第 %zd 页",pageCount ,pageIndex);
			CGRect tempRect = CGRectMake(pageIndex * pageWidth, 0, pageWidth, scrollView.height);
			tempPageView = [[UIView alloc] initWithFrame:tempRect];
			[scrollView addSubview:tempPageView];

			maxHeight = CGRectGetMaxY(tempPageView.frame);
			contentView.height = maxHeight;
		}

		UIButton *itemBtn = [[UIButton alloc] init];
		[tempPageView addSubview:itemBtn];
		NSInteger row = (j % onePageItemCount) / maxCols;
		NSInteger col = j % maxCols;
		itemBtn.x = startX + col * (startX + buttonW);
		itemBtn.y = startY + row * (buttonH + 0);
		itemBtn.width = buttonW;
		itemBtn.height = buttonH;

		itemBtn.adjustsImageWhenHighlighted = NO;
		itemBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
		[itemBtn setTitleColor:OkColorFromHex(0x666666) forState:0];
		itemBtn.titleLabel.font = OKActionSheet_font(12);
		[itemBtn addTarget:self action:@selector(actionBtnAction:) forControlEvents:UIControlEventTouchUpInside];
		itemBtn.tag = j;

		//设置按钮标题
		if ([bntTitle isKindOfClass:[NSString class]]) {

			if (self.otherBtnTitleAttributes) {
				NSAttributedString *buttonTitleAttr = [[NSAttributedString alloc] initWithString:bntTitle attributes:self.otherBtnTitleAttributes];
				[itemBtn setAttributedTitle:buttonTitleAttr forState:0];
			} else {
				[itemBtn setTitle:bntTitle forState:0];
			}

		} else if([bntTitle isKindOfClass:[NSAttributedString class]]){
			[itemBtn setAttributedTitle:bntTitle forState:0];
		}

		//设置图片
		if ([imageObj isKindOfClass:[NSString class]]) {
			UIImage *image = [UIImage imageNamed:imageObj];
			if (image) {
				[itemBtn setImage:image forState:0];
			}
		} else if ([imageObj isKindOfClass:[UIImage class]]) {
			[itemBtn setImage:imageObj forState:0];
		}

		//上下分割开图片和文字
		[self setupBtnImageAndTitle:itemBtn];

		//添加所有actionSheet按钮
		[self.actionSheetButtonArr addObject:itemBtn];

		scrollView.height = CGRectGetMaxY(itemBtn.frame);
		tempPageView.height = scrollView.height;
		maxHeight = CGRectGetMaxY(scrollView.frame);
		contentView.height = maxHeight;
	}

	//添加滚动页显示条
	if (pageCount>1) {
		//有滚动才设置代理
		scrollView.delegate = self;

		CGFloat indicatorHeight = 2;
		CGFloat space = 4;
		CGFloat indicatorWidth = 8;
		CGFloat indicatorAllWidth = indicatorWidth * pageCount + (pageCount-1) * space;
		CGFloat indicatorStartX = (pageWidth-indicatorAllWidth)/2;
		for (int i=0; i<pageCount; i++) {
			CGFloat tempX = indicatorStartX + i * indicatorWidth + i*space;

			UIView *indicatorView = [[UIView alloc] initWithFrame:CGRectMake(tempX, maxHeight, indicatorWidth, indicatorHeight)];
			indicatorView.backgroundColor = (i==0) ? OkColorFromHex(0x666666) : OkColorFromHex(0xDDDDDD);
			indicatorView.layer.cornerRadius = indicatorHeight/2;
			indicatorView.layer.masksToBounds = YES;
			[contentView addSubview:indicatorView];
			indicatorView.tag = OKActionCancelBtnTag*2+i;
			if (i==0) {
				self.lastIndicatorView = indicatorView;
			}
		}
		maxHeight = maxHeight + indicatorHeight;
		contentView.height = maxHeight;
	}

	//添加到window上显示
	UIWindow *window = [[UIApplication sharedApplication] keyWindow];
	[window endEditing:YES];
	[window addSubview:self];

	//如果没有取消按钮就不添加
	if (!cancelTitle) {
		contentView.height = maxHeight + 10;
		return ;
	}

	//分割线
	UIView *bottomLine = [[UIView alloc] init];
	bottomLine.backgroundColor = lineColor;
	bottomLine.frame = CGRectMake(0, maxHeight + 8, contentView.width, 0.5f);
	[contentView addSubview:bottomLine];

	//添加取消按钮
	UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[cancelBtn setSize:CGSizeMake(kOKFullScreenWidth, OKActionSheet_ButtonHeight)];
	cancelBtn.backgroundColor = [UIColor whiteColor];
	cancelBtn.y = CGRectGetMaxY(bottomLine.frame);
	cancelBtn.width = contentView.width;
	cancelBtn.height = OKActionSheet_ButtonHeight;
	cancelBtn.tag = OKActionCancelBtnTag;
	[cancelBtn.titleLabel setFont:OKActionSheet_font(16)];
	[cancelBtn addTarget:self action:@selector(actionBtnAction:) forControlEvents:UIControlEventTouchUpInside];
	[cancelBtn setTitleColor:OKActionSheet_ButtonTitleColor forState:UIControlStateDisabled];
	[cancelBtn setTitleColor:OKActionSheet_cancelTitleColor forState:0];
	[cancelBtn setBackgroundImage:[OKActionSheetView ok_imageWithColor:OK_Btn_Disabled_Bg_Color] forState:UIControlStateDisabled];
	[cancelBtn setBackgroundImage:[OKActionSheetView ok_imageWithColor:OK_Btn_Highlighted_Bg_Color] forState:UIControlStateHighlighted];
	[contentView addSubview:cancelBtn];
	[cancelBtn setExclusiveTouch:YES];

	//设置按钮标题
	if ([cancelTitle isKindOfClass:[NSString class]]) {

		if (self.themeColorBtnTitleAttributes) {
			NSAttributedString *buttonTitleAttr = [[NSAttributedString alloc] initWithString:cancelTitle attributes:self.themeColorBtnTitleAttributes];
			[cancelBtn setAttributedTitle:buttonTitleAttr forState:0];
		} else {
			[cancelBtn setTitle:cancelTitle forState:0];
		}

	} else if([cancelTitle isKindOfClass:[NSAttributedString class]]){
		[cancelBtn setAttributedTitle:cancelTitle forState:0];
	}

	maxHeight = CGRectGetMaxY(cancelBtn.frame);
	contentView.height = maxHeight;

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	self.lastIndicatorView.backgroundColor = OkColorFromHex(0xDDDDDD);
	NSInteger pageIndex = scrollView.contentOffset.x / scrollView.width;

	UIView *indicatorView = [self.contentView viewWithTag:(OKActionCancelBtnTag*2+pageIndex)];
	indicatorView.backgroundColor = OkColorFromHex(0x666666);
	self.lastIndicatorView = indicatorView;
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
	OKLog(@"点击了ActionSheet弹框按钮==%zd",actionBtn.tag);

	//按钮标题
	id titleObjc = nil;
	NSAttributedString *titleAttrStr = actionBtn.currentAttributedTitle;
	if (self.otherBtnTitleAttributes) {
		titleObjc = titleAttrStr;
	} else {
		if (titleAttrStr) {
			titleObjc = titleAttrStr;
		} else {
			titleObjc = actionBtn.currentTitle;
		}
	}

	if (self.actionSheetStyleType == TopSquareSheetStyle) { //顶部弹框
		if (self.buttonBlock) {
			self.buttonBlock(actionBtn.tag, titleObjc);
		}

	} else { //底部方式
		if (actionBtn.tag == OKActionCancelBtnTag) { //取消按钮
			if (self.cancelButtonBlock) {
				self.cancelButtonBlock();
			}
		} else { //其他按钮
			if (self.buttonBlock) {
				self.buttonBlock(actionBtn.tag, titleObjc);
			}
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
	//从顶部弹出 (如果superView的起始位置为64,则这里的y就是0)
	if (self.actionSheetStyleType == TopSquareSheetStyle) {
		contentViewY = 0;

	} else if ((self.actionSheetStyleType == BottomItemCornerRadiusSheetStyle)) { //底部横向Item按钮圆角ActionSheet
		contentViewY = kOkFullScreenHeight - self.contentView.height - OKActionSheet_LineSpacing;

	} else { //其他方式
		contentViewY = kOkFullScreenHeight - self.contentView.height;
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
	//从顶部弹出 (如果superView的起始位置为64,则这里的y就是contentView的高度)
	if (self.actionSheetStyleType == TopSquareSheetStyle) {
		contentViewY = -(self.contentView.height);

	} else { //其他方式
		contentViewY = kOkFullScreenHeight;
	}

	[UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0];
		self.contentView.y = contentViewY;
		//self.alpha = 0;

	} completion:^(BOOL finished) {
		if (sender) {
			OKLog(@"点击了ActionSheet灰色背景消失");
//            if (self.cancelButtonBlock) {
//                self.cancelButtonBlock();
//            }
		}
		[self removeFromSuperview];
	}];
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
					textObject:(id)textObject
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
 * 设置按钮图片和文字上下结构分割开
 */
- (void)setupBtnImageAndTitle:(UIButton *)itemBtn
{
	CGFloat space = 20;
	// 1. 得到imageView和titleLabel的宽、高
	CGFloat imageWith = itemBtn.imageView.frame.size.width;
	CGFloat imageHeight = itemBtn.imageView.frame.size.height;

	CGFloat labelWidth = 0.0;
	CGFloat labelHeight = 0.0;
	if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
		// 由于iOS8中titleLabel的size为0，用下面的这种设置
		labelWidth = itemBtn.titleLabel.intrinsicContentSize.width;
		labelHeight = itemBtn.titleLabel.intrinsicContentSize.height;
	} else {
		labelWidth = itemBtn.titleLabel.frame.size.width;
		labelHeight = itemBtn.titleLabel.frame.size.height;
	}

	// 2. 声明全局的imageEdgeInsets和labelEdgeInsets
	UIEdgeInsets imageEdgeInsets = UIEdgeInsetsZero;
	UIEdgeInsets labelEdgeInsets = UIEdgeInsetsZero;

	imageEdgeInsets = UIEdgeInsetsMake(-labelHeight-space/2.0, 0, 0, -labelWidth);
	labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith, -imageHeight-space/2.0, 0);

	// 3. 赋值
	itemBtn.titleEdgeInsets = labelEdgeInsets;
	itemBtn.imageEdgeInsets = imageEdgeInsets;
}

- (void)dealloc
{
	OKLog(@"OKActionSheetView dealloc");
}

@end

