# 高度自定义简单易用的UIActionSheet与UIAlertView视图

### 一、模仿系统的``UIActionSheet``,  封装了一个多样式的``ActionSheetView``,  用法简单,导入头文件,  ``OKActionSheetView.h``使用;

### 使用pod导入方法:  pod 'OKAlertContrActionSheet', '~> 0.0.2'

### 1. 顶部下拉弹框样式:

![顶部下拉弹框样式](http://upload-images.jianshu.io/upload_images/762411-f5ed1a4b9fbb8bf7.gif?imageMogr2/auto-orient/strip)



#### 代码用法:
```
    NSArray *btnImgNameArr = @[@"commonQut-nor",@"commonQut-nor",@"commonQut-nor",@"commonQut-nor",@"commonQut-nor",@"commonQut-nor",@"commonQut-nor"];
    NSArray *btnTitleArr = @[@"常见问题1",@"常见问题2",@"常见问题3",@"常见问题4",@"常见问题5",@"常见问题6",@"常见问题7"];

    [OKActionSheetView actionSheetByTopSquare:^(NSInteger buttonIndex) {
        ShowAlertToast([NSString stringWithFormat:@"点击了第%zd行",buttonIndex]);
        
    } cancelButtonBlock:^{
        ShowAlertToast(@"点击取消按钮");
        
    } superView:self.view position:CGPointMake(0, 64) buttonTitleArr:btnTitleArr buttonImageArr:btnImgNameArr];
```

### 2. 底部上拉弹框直角样式:

![底部上拉弹框直角样式](http://upload-images.jianshu.io/upload_images/762411-2bc3047021fe255b.gif?imageMogr2/auto-orient/strip)




#### 代码用法:
```
    NSString *title = @"人在临死的时候最明白一切都是过眼云烟";
    NSArray *otherTitleArr = @[@"按钮1",@"按钮2",@"按钮3",@"按钮4",@"按钮5",@"按钮6",@"按钮7",@"按钮8"];

    [OKActionSheetView actionSheetByBottomSquare:^(NSInteger buttonIndex) {
        ShowAlertToast([NSString stringWithFormat:@"点击了第%zd个按钮",buttonIndex]);

    } cancelButtonBlock:^{
        ShowAlertToast(@"点击取消按钮");
        
    } WithTitle:title cancelButtonTitle:@"取消" otherButtonTitleArr:otherTitleArr];
```

### 3. 底部上拉弹框圆角样式:

![底部上拉弹框圆角样式](http://upload-images.jianshu.io/upload_images/762411-fee0ccb9fb44d876.gif?imageMogr2/auto-orient/strip)



#### 代码用法:
```
    NSString *title = @"生命是个过程，死亡只是必然的结果，但轨迹是自己的色彩和温度，既然不可避免，那么就更无所畏惧。";
    NSArray *otherTitleArr = @[@"按钮1",@"按钮2",@"按钮3",@"按钮4",@"按钮5",@"按钮6",@"按钮7",@"按钮8"];

    [OKActionSheetView actionSheetByBottomCornerRadius:^(NSInteger buttonIndex) {
        ShowAlertToast([NSString stringWithFormat:@"点击了第%zd行",buttonIndex]);

    } cancelButtonBlock:^ {
        ShowAlertToast(@"点击取消按钮");
        
    } WithTitle:title cancelButtonTitle:@"取消" otherButtonTitleArr:otherTitleArr];
```

### 二、封装系统提示框, 兼容iOS9以下的``UiAlertView``, 和iOS9以上的``UIAlertController``;

### 1. 普通两个按钮弹框样式:

![普通两个按钮弹框样式](http://upload-images.jianshu.io/upload_images/762411-8aed3a356bd5627c.gif?imageMogr2/auto-orient/strip)



#### 代码用法:
```
    NSString *tipStr = sender ? @"第2个弹框标题" : @"第1个弹框标题";
    
    [OKAlertView alertWithCallBlock:^(NSInteger buttonIndex) {
        ShowAlertToast([NSString stringWithFormat:@"点击了第%zd个按钮",buttonIndex]);

    } title:@"温馨提示" message:tipStr cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
```

### 2. 普通两个以上按钮弹框样式:

![普通两个以上按钮弹框样式](http://upload-images.jianshu.io/upload_images/762411-5d8ea7d3878ee122.gif?imageMogr2/auto-orient/strip)



#### 代码用法:
```
    NSString *titleStr = @"温馨提示";
    NSString *msgStr = @"显示两个以上按钮";
    
    NSMutableAttributedString *titleAttr = [[NSMutableAttributedString alloc] initWithString:titleStr];
    [titleAttr setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:22],NSForegroundColorAttributeName:[UIColor yellowColor]} range:NSMakeRange(0, 2)];
    
    NSMutableAttributedString *msgAttr = [[NSMutableAttributedString alloc] initWithString:msgStr];
    [msgAttr setAttributes:@{NSForegroundColorAttributeName:[UIColor cyanColor], NSFontAttributeName:[UIFont systemFontOfSize:30]} range:NSMakeRange(2, 2)];

    NSMutableAttributedString *buttonTitleAttr = [[NSMutableAttributedString alloc] initWithString:@"确定测试一下"];
    [buttonTitleAttr setAttributes:@{NSForegroundColorAttributeName:[UIColor redColor], NSFontAttributeName:[UIFont systemFontOfSize:30]} range:NSMakeRange(2, 2)];
    
    [OKAlertView alertWithCallBlock:^(NSInteger buttonIndex) {
        ShowAlertToast([NSString stringWithFormat:@"点击了第%zd个按钮",buttonIndex]);

    } title:titleAttr message:msgAttr cancelButtonTitle:@"取消" otherButtonTitles:@"确定1",buttonTitleAttr,@"确定3", nil];
```

### 3. 系统带输入弹框弹框样式:

![系统带输入弹框弹框样式](http://upload-images.jianshu.io/upload_images/762411-ad630cdf85e6f28b.gif?imageMogr2/auto-orient/strip)



#### 代码用法:
```
[OKAlertView inputAlertWithTitle:@"请输入"
                         placeholder:@"输入弹框控件"
                         cancelTitle:@"取消"
                          otherTitle:@"确定"
                        keyboardType:UIKeyboardTypeDefault
                         buttonBlock:^(NSString *inputText) {
                             ShowAlertToast([NSString stringWithFormat:@"您输入了:\n%@",inputText]);
                         } cancelBlock:^{
                             ShowAlertToast(@"点击了取消按钮");
                         }];
```

