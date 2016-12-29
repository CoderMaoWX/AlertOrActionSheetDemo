//
//  UIView+Extension.h
//  PointLegend
//
//  Created by leon guo on 15/9/10.
//  Copyright (c) 2015年 CenturyGalaxyNetworkDevelopment. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface UIView (Extension)
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGPoint origin;

- (UIViewController *)viewcontroller;

@end
