//
//  UIScrollView+NoDataPlaceholder.h
//  NODataPlaceholderView
//
//  Created by Ossey on 2017/5/29.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NoDataPlaceholderDelegate, NoDataPlaceholderDataSource;

@interface UIScrollView (NoDataPlaceholder)

@property (nonatomic, weak, nullable) id<NoDataPlaceholderDataSource> noDataPlaceholderDataSource;
@property (nonatomic, weak, nullable) id<NoDataPlaceholderDelegate> noDataPlaceholderDelegate;
@property (nonatomic, assign, readonly, getter=isNoDatasetVisible) BOOL noDatasetVisible;

@end

@protocol NoDataPlaceholderDelegate <NSObject>

@optional

/// 是否应该淡入淡出，默认为YES
- (BOOL)noDataPlaceholderShouldFadeIn:(UIScrollView *)scrollView;

/// 是否应显示NoDataPlaceholderView, 默认YES
/// @param scrollView UIScrollView及其子类对象通知代理
/// @return 如果当前无数据则应显示NoDataPlaceholderView
- (BOOL)noDataPlaceholderShouldDisplay:(UIScrollView *)scrollView;

/// 当前所在页面的数据源itemCount>0时，是否应该实现NoDataPlaceholder，默认是不显示的
/// @param scrollView UIScrollView及其子类对象通知代理
/// @return 如果需要强制显示NoDataPlaceholder，返回YES即可
- (BOOL)noDataPlaceholderShouldBeForcedToDisplay:(UIScrollView *)scrollView;

/// 当noDataPlaceholder即将显示的回调
- (void)noDataPlaceholderWillAppear:(UIScrollView *)scrollView;

/// 当noDataPlaceholder完全显示的回调
- (void)noDataPlaceholderDidAppear:(UIScrollView *)scrollView;

/// 当noDataPlaceholder即将消失的回调
- (void)noDataPlaceholderWillDisappear:(UIScrollView *)scrollView;

/// 当noDataPlaceholder完全消失的回调
- (void)noDataPlaceholderDidDisappear:(UIScrollView *)scrollView;

/// noDataPlaceholder是否可以接受触摸事件，默认YES
- (BOOL)noDataPlaceholderShouldAllowTouch:(UIScrollView *)scrollView;

/// noDataPlaceholder是否可以滚动，默认NO
- (BOOL)noDataPlaceholderShouldAllowScroll:(UIScrollView *)scrollView;

/// imageview是否可以有动画，默认为NO
- (BOOL)noDataPlaceholderShouldAnimateImageView:(UIScrollView *)scrollView;


- (void)noDataPlaceholder:(UIScrollView *)scrollView didTapOnContentView:(UITapGestureRecognizer *)tap;

- (void)noDataPlaceholder:(UIScrollView *)scrollView didClickReloadButton:(UIButton *)button;

@end

@protocol NoDataPlaceholderDataSource <NSObject>

@optional

/// 当需要显示自定义的视图时，默认的NoDataPlaceholder则为NULL
/// @param scrollview UIScrollView 或其子类对象
/// @return 自定义视图
- (UIView *)customViewForNoDataPlaceholder:(UIScrollView *)scrollview;

/// NoDataPlaceholder需要显示的标题富文本
/// @return NSAttributedString富文本
- (NSAttributedString *)titleAttributedStringForNoDataPlaceholder:(UIScrollView *)scrollView;

/// NoDataPlaceholder需要显示的详情富文本
/// @return NSAttributedString富文本
- (NSAttributedString *)detailAttributedStringForNoDataPlaceholder:(UIScrollView *)scrollView;

/// NoDataPlaceholder的背景图片
///@return UIImage
- (UIImage *)backgroundImageForNoDataPlaceholder:(UIScrollView *)scrollView;

/// 图片的动画，默认为nil
/// @return CAAnimation
- (CAAnimation *)backgroundImageAnimationForNoDataPlaceholder:(UIScrollView *)scrollView;

/// 背景图片的tintColor , 默认无
/// @return UIColor
- (UIColor *)imageTintColorForNoDataPlaceholder:(UIScrollView *)scrollView;

/// 指定reloadButton对应state的富文本
/// @return NSAttributedString类型
- (NSAttributedString *)reloadbuttonTitleAttributedStringForNoDataPlaceholder:(UIScrollView *)scrollView forState:(UIControlState)state;

/// 指定reloadButton对应state的image
- (UIImage *)reloadButtonImageForNoDataPlaceholder:(UIScrollView *)scrollView forState:(UIControlState)state;

- (UIImage *)reloadButtonBackgroundImageForNoDataPlaceholder:(UIScrollView *)scrollView forState:(UIControlState)state;

- (UIColor *)backgroundColorForNoDataPlaceholder:(UIScrollView *)scrollView;

- (UIColor *)reloadButtonBackgroundColorForNoDataPlaceholder:(UIScrollView *)scrollView;

/// NoDataPlaceholderView子控件之间垂直的间距，默认为11
- (CGFloat)spaceHeightForNoDataPlaceholder:(UIScrollView *)scrollView;

- (CGFloat)verticalOffsetForNoDataPlaceholder:(UIScrollView *)scrollView;

@end

NS_ASSUME_NONNULL_END
