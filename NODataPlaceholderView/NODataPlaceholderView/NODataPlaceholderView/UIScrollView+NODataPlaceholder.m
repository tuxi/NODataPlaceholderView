//
//  UIScrollView+NODataPlaceholder.m
//  NODataPlaceholderView
//
//  Created by Ossey on 2017/5/29.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "UIScrollView+NODataPlaceholder.h"

@interface UIView (ConstraintBasedLayoutExtensions)

/// 创建视图的约束
- (NSLayoutConstraint *)equallyRelatedConstraintWithView:(UIView *)view
                                               attribute:(NSLayoutAttribute)attribute;

@end

@interface NODataPlaceholderView : UIView

/** 内容视图 */
@property (nonatomic, weak, readonly) UIView *contentView;
/** 标题label */
@property (nonatomic, weak, readonly) UILabel *titleLabel;
/** 详情label */
@property (nonatomic, weak, readonly) UILabel *detailLabel;
/** 图片视图 */
@property (nonatomic, weak, readonly) UIImageView *backgroundImageView;
/** 重新加载的button */
@property (nonatomic, weak, readonly) UIButton *reloadButton;
/** 自定义视图 */
@property (nonatomic, weak, readonly) UIView *customView;
/** 点按手势 */
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
/** 垂直偏移量 */
@property (nonatomic, assign) CGFloat verticalOffsetY;
/** 垂直间距 */
@property (nonatomic, assign) CGFloat verticalSpace;
/** 是否淡入淡出显示 */
@property (nonatomic, assign) BOOL *fadeInOnDisplay;

/// 设置子控件的约束
- (void)setupConstraints;
/// 准备复用
- (void)prepareForReuse;

@end

@implementation UIScrollView (NODataPlaceholder)


@end

@implementation NODataPlaceholderView

@synthesize
contentView = _contentView,
titleLabel = _titleLabel,
detailLabel = _detailLabel,
backgroundImageView = _backgroundImageView,
reloadButton = _reloadButton,
customView = _customView;

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self contentView];
}

- (void)didMoveToSuperview {
    CGRect superviewBounds = self.superview.bounds;
    self.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(superviewBounds), CGRectGetHeight(superviewBounds));
    // 当需要淡入淡出时结合动画执行
    void (^fadeInBlock)(void) = ^{
        _contentView.alpha = 1.0;
    };
    
    if (self.fadeInOnDisplay) {
        [UIView animateWithDuration:0.25 animations:fadeInBlock];
    } else {
        fadeInBlock();
    }
}

#pragma mark - get
- (UIView *)contentView {
    if (_contentView == nil) {
        UIView *contentView = [UIView new];
        contentView.translatesAutoresizingMaskIntoConstraints = NO;
        contentView.backgroundColor = [UIColor clearColor];
        contentView.userInteractionEnabled = YES;
        contentView.alpha = 0;
        contentView.accessibilityIdentifier = @"no data placeholder contentView";
        _contentView = contentView;
        [self addSubview:contentView];
    }
    return _contentView;
}

- (UIImageView *)backgroundImageView {
    if (_backgroundImageView == nil) {
        UIImageView *imageView = [UIImageView new];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        imageView.backgroundColor = [UIColor clearColor];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.userInteractionEnabled = NO;
        _backgroundImageView = imageView;
        _backgroundImageView.accessibilityIdentifier = @"no data placeholder background image";
        [[self contentView] addSubview:_backgroundImageView];
    }
    return _backgroundImageView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        UILabel *titleLabel = [UILabel new];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        titleLabel.backgroundColor = [UIColor clearColor];
        
        titleLabel.font = [UIFont systemFontOfSize:27.0];
        titleLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.numberOfLines = 0;
        // 通过accessibilityIdentifier来定位元素,相当于这个控件的id
        titleLabel.accessibilityIdentifier = @"no data placeholder title";
        _titleLabel = titleLabel;
        
        [[self contentView] addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (_detailLabel == nil) {
        UILabel *detailLabel = [UILabel new];
        detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
        detailLabel.backgroundColor = [UIColor clearColor];
        
        detailLabel.font = [UIFont systemFontOfSize:17.0];
        detailLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        detailLabel.textAlignment = NSTextAlignmentCenter;
        detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
        detailLabel.numberOfLines = 0;
        detailLabel.accessibilityIdentifier = @"no data placeholder detail label";
        _detailLabel = detailLabel;
        
        [[self contentView] addSubview:_detailLabel];
    }
    return _detailLabel;
}

- (UIButton *)reloadButton {
    if (_reloadButton == nil) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        btn.backgroundColor = [UIColor clearColor];
        // 按钮内部控件垂直对齐方式为中心
        btn.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [btn addTarget:self action:@selector(clickReloadBtn:) forControlEvents:UIControlEventTouchUpInside];
        _reloadButton = btn;
    }
    return _reloadButton;
}


- (BOOL)canShowBackgroundImage {
    return _backgroundImageView.image && _backgroundImageView.superview;
}

- (BOOL)canShowTitle {
    return _titleLabel.text.length > 0 && _titleLabel.superview;
}

- (BOOL)canShowDetail {
    return _detailLabel.text.length > 0 && _detailLabel.superview;
}

- (BOOL)canShowReloadButton {
    if ([_reloadButton attributedTitleForState:UIControlStateNormal].string.length > 0 || [_reloadButton imageForState:UIControlStateNormal]) {
        return _reloadButton.superview != nil;
    }
    return NO;
}

#pragma mark - set 

- (void)setCustomView:(UIView *)customView {
    if (!customView) {
        return;
    }
    
    if (_customView) {
        [_customView removeFromSuperview];
        _customView = nil;
    }
    
    _customView = customView;
    _customView.translatesAutoresizingMaskIntoConstraints = NO;
    _customView.accessibilityIdentifier = @"no data placeholder custom view";
    [self.contentView addSubview:_customView];
}

#pragma mark - Events

/// 点击刷新按钮时处理事件
- (void)clickReloadBtn:(UIButton *)btn {
    SEL selector = NSSelectorFromString(@"xy_clickReloadBtn:");
    // 让btn所在的父控件去执行点击事件
    if ([self.superview respondsToSelector:selector]) {
        [self.superview performSelector:selector withObject:btn afterDelay:0.0];
    }
}


#pragma mark - Auto Layout
/// 移除所有约束
- (void)removeAllConstraints {
    [self removeAllConstraints];
    [_contentView removeConstraints:_contentView.constraints];
}

- (void)setupConstraints {
    
    // contentView 与 父视图 保持一致
    NSLayoutConstraint *contentViewX = [self equallyRelatedConstraintWithView:self.contentView attribute:NSLayoutAttributeCenterX];
    NSLayoutConstraint *contentViewY = [self equallyRelatedConstraintWithView:self.contentView attribute:NSLayoutAttributeCenterY];
    [self addConstraint:contentViewX];
    [self addConstraint:contentViewY];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:@{@"contentView": self.contentView}]];
    
    // 当verticalOffset(自定义的垂直偏移量)有值时，需要调整垂直偏移量的约束值
    if (self.verticalOffsetY != 0.0 && self.constraints.count > 0) {
        contentViewY.constant = self.verticalOffsetY;
    }
    
    // 若有customView 则 让其与contentView的约束相同
    if (_customView) {
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[customView]|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:@{@"customView": self.contentView}]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[customView]|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:@{@"customView": self.contentView}]];
    } else {
        
        // 无customView
        CGFloat width = CGRectGetWidth(self.frame) ?: CGRectGetWidth([UIScreen mainScreen].bounds);
        CGFloat horizontalSpace = roundf(width / 16.0); // 计算间距  四舍五入
        CGFloat verticalSpace = self.verticalSpace ?: 11.0; // 默认为11.0
        
        NSMutableArray<NSString *> *subviewsNames = [NSMutableArray arrayWithCapacity:0];
        NSMutableDictionary *views = [NSMutableDictionary dictionaryWithCapacity:0];
        NSDictionary *metrics = @{@"horizontalSpace": @(horizontalSpace)};
        
        // 设置backgroundImageView水平约束
        if (_backgroundImageView.superview) {
            [subviewsNames addObject:@"backgroundImageView"];
            views[[subviewsNames lastObject]] = _backgroundImageView;
            
            [self.contentView addConstraint:[self.contentView equallyRelatedConstraintWithView:_backgroundImageView attribute:NSLayoutAttributeCenterX]];
        }
        
        // 根据title是否可以显示，设置titleLable的水平约束
        if ([self canShowTitle]) {
            [subviewsNames addObject:@"titleLabel"];
            views[[subviewsNames lastObject]] = _titleLabel;
            
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(horizontalSpace@750)-[titleLabel(>=0)]-(horizontalSpace@750)-|"
                                                                                     options:0
                                                                                     metrics:metrics
                                                                                       views:views]];
        } else {
            // 不显示就移除
            [_titleLabel removeFromSuperview];
            _titleLabel = nil;
        }
        
        // 根据是否可以显示detail, 设置detailLabel水平约束
        if ([self canShowDetail]) {
            [subviewsNames addObject:@"detailLabel"];
            views[[subviewsNames lastObject]] = _detailLabel;
            
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(horizontalSpace@750)-[detailLabel(>=0)]-(horizontalSpace@750)-|"
                                                                                     options:0
                                                                                     metrics:metrics
                                                                                       views:views]];
        } else {
            // 不显示就移除
            [_detailLabel removeFromSuperview];
            _detailLabel = nil;
        }
        
        // 根据reloadButton是否能显示，设置其水平约束
        if ([self canShowReloadButton]) {
            [subviewsNames addObject:@"reloadButton"];
            views[[subviewsNames lastObject]] = _reloadButton;
            
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(horizontalSpace@750)-[reloadButton(>=0)]-(horizontalSpace@750)-|"
                                                                                     options:0
                                                                                     metrics:metrics
                                                                                       views:views]];
        } else {
            // 不显示就移除
            [_reloadButton removeFromSuperview];
            _reloadButton = nil;
        }
        
        // 设置垂直约束
        NSMutableString *verticalFormat = [NSMutableString new];
        // 拼接字符串，添加每个控件垂直边缘之间的约束值, 默认为verticalSpace 11.0
        for (NSInteger i = 0; i < subviewsNames.count; ++i) {
            NSString *viewName = subviewsNames[i];
            // 拼接控件的属性名
            [verticalFormat appendFormat:@"[%@]", viewName];
            if (i < subviewsNames.count - 1) {
                // 拼接间距值
                [verticalFormat appendFormat:@"-(%.f@750)-", verticalSpace];
            }
        }
        
        // 向contentView分配垂直约束
        if (verticalFormat.length > 0) {
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|%@|", verticalFormat]
                                                                                     options:0
                                                                                     metrics:metrics
                                                                                       views:views]];
        }
    }
    
}

// 控制器事件的响应
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    UIView *hitView = [super hitTest:point withEvent:event];
    
    // 如果hitView是UIControl或其子类初始化的，就返回此hitView的实例
    if ([hitView isKindOfClass:[UIControl class]]) {
        return hitView;
    }
    
    // 如果hitView是contentView或customView, 就返回此实例
    if ([hitView isEqual:_contentView] || [hitView isEqual:_customView]) {
        return hitView;
    }
    
    return nil;
}

@end

@implementation UIView (ConstraintBasedLayoutExtensions)

- (NSLayoutConstraint *)equallyRelatedConstraintWithView:(UIView *)view
                                               attribute:(NSLayoutAttribute)attribute {

    return [NSLayoutConstraint constraintWithItem:view
                                        attribute:attribute
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:self attribute:attribute
                                       multiplier:1.0
                                         constant:0.0];
}

@end
