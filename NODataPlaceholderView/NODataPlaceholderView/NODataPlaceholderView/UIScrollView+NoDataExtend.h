//
//  UIScrollView+NoDataExtend.h
//  NODataPlaceholderView
//
//  Created by alpface on 2017/5/29.
//  Copyright © 2017年 alpface. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, UIScrollViewNoDataContentLayouAttribute) {
    UIScrollViewNoDataContentLayouAttributeCenterY,
    UIScrollViewNoDataContentLayouAttributeTop
};

@protocol NoDataPlaceholderDelegate;

@interface UIScrollView (NoDataExtend)

@property (nonatomic, weak, nullable) id<NoDataPlaceholderDelegate> noDataPlaceholderDelegate;

/// use custom view
@property (nonatomic, copy) UIView * _Nullable (^customNoDataView)(void);

// setup subviews
@property (nonatomic, copy) void  (^ _Nullable noDataTextLabelBlock)(UILabel *textLabel);
@property (nonatomic, copy) void  (^ _Nullable noDataDetailTextLabelBlock)(UILabel *detailTextLabel);
@property (nonatomic, copy) void  (^ _Nullable noDataImageViewBlock)(UIImageView *imageView);
@property (nonatomic, copy) void  (^ _Nullable noDataReloadButtonBlock)(UIButton *reloadButton);

/// titleLabel 的间距
@property (nonatomic, assign) UIEdgeInsets noDataTextEdgeInsets;
/// imageView 的间距
@property (nonatomic, assign) UIEdgeInsets noDataImageEdgeInsets;
/// detaileLable 的间距
@property (nonatomic, assign) UIEdgeInsets noDataDetailEdgeInsets;
/// reloadButton 的间距
@property (nonatomic, assign) UIEdgeInsets noDataButtonEdgeInsets;

/// 空数据视图 的背景颜色
@property (nonatomic, strong) UIColor *noDataViewBackgroundColor;
/// 空数据视图中contentView的背景颜色
@property (nonatomic, strong) UIColor *noDataViewContentBackgroundColor;

/// 刷新空数据视图
/// 如果需要在请求数据期间显示loading菊花样式，需要在请求数据前主动调用xy_beginLoading方法
/// @note 刷新完数据后不必主动调用此方法，因为执行tableView的readData、endUpdates或者CollectionView的readData时会主动执行此方法
- (void)xy_reloadNoData;

/// 用于请求数据前的loading样式
/// 需在请求前执行xy_beginLoading，请求完成后执行xy_endLoading
/// @note 如果使用了customNoDataView block 则此方法无效
- (void)xy_beginLoading;
- (void)xy_endLoading;

@end

@protocol NoDataPlaceholderDelegate <NSObject>

@optional

/// 是否应该淡入淡出，default is YES
- (BOOL)noDataPlaceholderShouldFadeInOnDisplay:(UIScrollView *)scrollView;

/// 是否应显示空数据视图, 默认YES
/// @return 通过delegate方法决定是否应该显示noData, 当return YES 时 即使无数据页也会显示空数据视图
- (BOOL)noDataPlaceholderShouldDisplay:(UIScrollView *)scrollView;

/// 当前所在页面的数据源itemCount>0时，是否应该实现NoDataPlaceholder，default return NO
/// @return 如果需要强制显示NoDataPlaceholder，return YES即可
- (BOOL)noDataPlaceholderShouldBeForcedToDisplay:(UIScrollView *)scrollView;

/// 当空数据视图即将显示的回调
- (void)noDataPlaceholderWillAppear:(UIScrollView *)scrollView;

/// 当空数据视图完全显示的回调
- (void)noDataPlaceholderDidAppear:(UIScrollView *)scrollView;

/// 当空数据视图即将消失的回调
- (void)noDataPlaceholderWillDisappear:(UIScrollView *)scrollView;

/// 当空数据视图完全消失的回调
- (void)noDataPlaceholderDidDisappear:(UIScrollView *)scrollView;

/// 空数据视图是否可以响应事件，默认YES
- (BOOL)noDataPlaceholderShouldAllowResponseEvent:(UIScrollView *)scrollView;

/// 空数据视图是否可以滚动，默认YES
- (BOOL)noDataPlaceholderShouldAllowScroll:(UIScrollView *)scrollView;

- (void)noDataPlaceholder:(UIScrollView *)scrollView didTapOnContentView:(UITapGestureRecognizer *)tap;

- (void)noDataPlaceholder:(UIScrollView *)scrollView didClickReloadButton:(UIButton *)button;

/// 空数据视图各子控件之间垂直的间距，默认为11
- (CGFloat)contentSubviewsGlobalVerticalSpaceFoNoDataPlaceholder:(UIScrollView *)scrollView;

/// 空数据视图 的 contentView左右距离父控件的间距值
- (CGFloat)contentViewHorizontalSpaceFoNoDataPlaceholder:(UIScrollView *)scrollView;

/// 空数据视图 顶部 和 左侧 相对 父控件scrollView 顶部 的偏移量, default is 0,0
- (CGPoint)contentOffsetForNoDataPlaceholder:(UIScrollView *)scrollView;

/// imageView的size, 有的时候图片本身太大，导致imageView的尺寸并不是我们想要的，可以通过此方法设置, 当为CGSizeZero时不设置,默认为CGSizeZero
- (CGSize)imageViewSizeForNoDataPlaceholder:(UIScrollView *)scrollView;

/// 空数据视图contentView相对其父控件的约束
- (UIScrollViewNoDataContentLayouAttribute)contentLayouAttributeOfNoDataPlaceholder:(UIScrollView *)scrollView;

@end


NS_ASSUME_NONNULL_END

