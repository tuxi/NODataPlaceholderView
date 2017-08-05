//
//  UIScrollView+NoDataPlaceholder.m
//  NODataPlaceholderView
//
//  Created by Ossey on 2017/5/29.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "UIScrollView+NoDataPlaceholder.h"
#import <objc/runtime.h>


typedef NSString * ImplementationKey NS_EXTENSIBLE_STRING_ENUM;

static NSString * const NoDataPlaceholderBackgroundImageViewAnimationKey = @"NoDataPlaceholderBackgroundImageViewAnimation";

#pragma mark *** _WeakObjectContainer ***

@interface _WeakObjectContainer : NSObject

@property (nonatomic, weak, readonly) id weakObject;

- (instancetype)initWithWeakObject:(__weak id)weakObject;

@end

#pragma mark *** _SwizzlingObject ***

@interface _SwizzlingObject : NSObject

@property (nonatomic) Class swizzlingClass;
@property (nonatomic) SEL orginSelector;
@property (nonatomic) SEL swizzlingSelector;
@property (nonatomic) NSValue *swizzlingImplPointer;

@end

@interface NSObject (SwizzlingExtend)

@property (nonatomic, class, readonly) NSMutableDictionary<ImplementationKey, _SwizzlingObject *> *implementationDictionary;

- (void)hockSelector:(SEL)orginSelector swizzlingSelector:(SEL)swizzlingSelector baseClass:(Class)baseClas;

@end

#pragma mark *** NoDataPlaceholderView ***

@interface NoDataPlaceholderView : UIView

/** 内容视图 */
@property (nonatomic, weak) UIView *contentView;
/** 标题label */
@property (nonatomic, weak) UILabel *titleLabel;
/** 详情label */
@property (nonatomic, weak) UILabel *detailLabel;
/** 图片视图 */
@property (nonatomic, weak) UIImageView *imageView;
/** 重新加载的button */
@property (nonatomic, weak) UIButton *reloadButton;
/** 自定义视图 */
@property (nonatomic, strong) UIView *customView;
/** 点按手势 */
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
/** 中心点y的偏移量 */
@property (nonatomic, assign) CGFloat contentOffsetY;
/** 垂直间距 */
@property (nonatomic, assign) CGFloat verticalSpace;
/** 是否淡入淡出显示 */
@property (nonatomic, assign) BOOL fadeInOnDisplay;
/** tap手势回调block */
@property (nonatomic, copy) void (^tapGestureRecognizerBlock)(UITapGestureRecognizer *tap);

/// 设置子控件的约束
- (void)setupConstraints;
/// 移除所有子控件及其约束
- (void)resetSubviews;
/// 设置tap手势
- (void)tapGestureRecognizer:(void (^)(UITapGestureRecognizer *))tapBlock;

@end

#pragma mark *** UIScrollView (NoDataPlaceholder) ***

@interface UIScrollView () <UIGestureRecognizerDelegate>

@property (nonatomic, readonly) NoDataPlaceholderView *noDataPlaceholderView;
@property (nonatomic, assign) BOOL registerNoDataPlaceholder;
@end

@implementation UIScrollView (NoDataPlaceholder)

////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods
////////////////////////////////////////////////////////////////////////

- (void)reloadNoDataView {
    [self xy_reloadNoDataView];
}

- (BOOL)registerNoDataPlaceholder {
    
    BOOL flag = objc_getAssociatedObject(self, _cmd);
    if (!flag) {
        if (![self xy_noDataPlacehodlerCanDisplay]) {
            [self xy_removeNoDataPlacehodlerView];
        }
        
        // 对reloadData方法的实现进行处理, 为加载reloadData时注入额外的实现
        [self hockSelector:@selector(reloadData) swizzlingSelector:@selector(xy_reloadNoDataView) baseClass:xy_baseClassToSwizzlingForTarget(self)];
        
        if ([self isKindOfClass:[UITableView class]]) {
            [self hockSelector:@selector(endUpdates) swizzlingSelector:@selector(xy_reloadNoDataView) baseClass:xy_baseClassToSwizzlingForTarget(self)];
        }
        objc_setAssociatedObject(self, _cmd, @(flag), OBJC_ASSOCIATION_ASSIGN);
    }
    return flag;
}

- (void)setCustomNoDataView:(UIView * _Nonnull (^)(void))customNoDataView {
    objc_setAssociatedObject(self, @selector(customNoDataView), customNoDataView, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self registerNoDataPlaceholder];
}

- (UIView * _Nonnull (^)(void))customNoDataView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setNoDataTextLabel:(UILabel * _Nonnull (^)(void))noDataTextLabel {
    objc_setAssociatedObject(self, @selector(noDataTextLabel), noDataTextLabel, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self registerNoDataPlaceholder];
}

- (UILabel * _Nonnull (^)(void))noDataTextLabel {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setNoDataDetailTextLabel:(UILabel * _Nonnull (^)(void))noDataDetailTextLabel {
    objc_setAssociatedObject(self, @selector(noDataDetailTextLabel), noDataDetailTextLabel, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self registerNoDataPlaceholder];
}

- (UILabel * _Nonnull (^)(void))noDataDetailTextLabel {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setNoDataImageView:(UIImageView * _Nonnull (^)(void))noDataImageView {
    objc_setAssociatedObject(self, @selector(noDataImageView), noDataImageView, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self registerNoDataPlaceholder];
}

- (UIImageView * _Nonnull (^)(void))noDataImageView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setNoDataReloadButton:(UIButton * _Nonnull (^)(void))noDataReloadButton {
    objc_setAssociatedObject(self, @selector(noDataReloadButton), noDataReloadButton, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self registerNoDataPlaceholder];
}

- (UIButton * _Nonnull (^)(void))noDataReloadButton {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setNoDataViewBackgroundColor:(UIColor *)noDataViewBackgroundColor {
    objc_setAssociatedObject(self, @selector(noDataViewBackgroundColor), noDataViewBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)noDataViewBackgroundColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setLoading:(BOOL)loading {
    
    if (self.isLoading == loading) {
        return;
    }
    
    objc_setAssociatedObject(self, @selector(isLoading), @(loading), OBJC_ASSOCIATION_ASSIGN);
    
    [self xy_reloadNoDataView];

}

- (BOOL)isLoading {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}


////////////////////////////////////////////////////////////////////////
#pragma mark - Events
////////////////////////////////////////////////////////////////////////

/// 点击NODataPlaceholderView contentView的回调
- (void)xy_didTapContentView:(UITapGestureRecognizer *)tap {
    if (self.noDataPlaceholderDelegate && [self.noDataPlaceholderDelegate respondsToSelector:@selector(noDataPlaceholder:didTapOnContentView:)]) {
        [self.noDataPlaceholderDelegate noDataPlaceholder:self didTapOnContentView:tap];
    }
}

- (void)xy_clickReloadBtn:(UIButton *)btn {
    if (self.noDataPlaceholderDelegate && [self.noDataPlaceholderDelegate respondsToSelector:@selector(noDataPlaceholder:didClickReloadButton:)]) {
        [self.noDataPlaceholderDelegate noDataPlaceholder:self didClickReloadButton:btn];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods (delegate private api)
////////////////////////////////////////////////////////////////////////

// 是否需要淡入淡出
- (BOOL)xy_noDataPlacehodlerShouldFadeInOnDisplay {
    if (self.noDataPlaceholderDelegate && [self.noDataPlaceholderDelegate respondsToSelector:@selector(noDataPlaceholderShouldFadeInOnDisplay:)]) {
        return [self.noDataPlaceholderDelegate noDataPlaceholderShouldFadeInOnDisplay:self];
    }
    return YES;
}

// 是否符合显示
- (BOOL)xy_noDataPlacehodlerCanDisplay {
    if ([self isKindOfClass:[UITableView class]] || [self isKindOfClass:[UICollectionView class]] || [self isKindOfClass:[UIScrollView class]]) {
        return YES;
    }
    return NO;
}

// 获取UITableView或UICollectionView的所有item的总数
- (NSInteger)xy_itemCount {
    NSInteger itemCount = 0;
    
    // UIScrollView 没有dataSource属性, 所以返回0
    if (![self respondsToSelector:@selector(dataSource)]) {
        return itemCount;
    }
    
    // UITableView
    if ([self isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self;
        id<UITableViewDataSource> dataSource = tableView.dataSource;
        
        NSInteger sections = 1;
        if (dataSource && [dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            sections = [dataSource numberOfSectionsInTableView:tableView];
        }
        if (dataSource && [dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
            // 遍历所有组获取每组的行数，就相加得到所有item的个数，一行就是一个item
            for (NSInteger section = 0; section < sections; ++section) {
                itemCount += [dataSource tableView:tableView numberOfRowsInSection:section];
            }
        }
    }
    
    // UICollectionView
    if ([self isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        id<UICollectionViewDataSource> dataSource = collectionView.dataSource;
        
        NSInteger sections = 1;
        if (dataSource && [dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
            sections = [dataSource numberOfSectionsInCollectionView:collectionView];
        }
        if (dataSource && [dataSource respondsToSelector:@selector(collectionView:numberOfItemsInSection:)]) {
            // 遍历所有组获取每组的行数，就相加得到所有item的个数，一行就是一个item
            for (NSInteger section = 0; section < sections; ++section) {
                itemCount += [dataSource collectionView:collectionView numberOfItemsInSection:section];
            }
        }
    }
    
    return itemCount;
}

/// 是否应该显示
- (BOOL)xy_noDataPlacehodlerShouldDisplay {
    if (self.noDataPlaceholderDelegate && [self.noDataPlaceholderDelegate respondsToSelector:@selector(noDataPlaceholderShouldDisplay:)]) {
        return [self.noDataPlaceholderDelegate noDataPlaceholderShouldDisplay:self];
    }
    return YES;
}

/// 是否应该强制显示,默认不需要的
- (BOOL)xy_noDataPlacehodlerShouldBeForcedToDisplay {
    if (self.noDataPlaceholderDelegate && [self.noDataPlaceholderDelegate respondsToSelector:@selector(noDataPlaceholderShouldBeForcedToDisplay:)]) {
        return [self.noDataPlaceholderDelegate noDataPlaceholderShouldBeForcedToDisplay:self];
    }
    return NO;
}

- (void)xy_noDataPlaceholderViewWillAppear {
    if (self.noDataPlaceholderDelegate && [self.noDataPlaceholderDelegate respondsToSelector:@selector(noDataPlaceholderWillAppear:)]) {
        [self.noDataPlaceholderDelegate noDataPlaceholderWillAppear:self];
    }
}

/// 是否允许响应事件
- (BOOL)xy_noDataPlacehodlerIsAllowedResponseEvent {
    if (self.noDataPlaceholderDelegate && [self.noDataPlaceholderDelegate respondsToSelector:@selector(noDataPlaceholderShouldAllowResponseEvent:)]) {
        return [self.noDataPlaceholderDelegate noDataPlaceholderShouldAllowResponseEvent:self];
    }
    return YES;
}

/// 是否运行滚动
- (BOOL)xy_noDataPlacehodlerIsAllowedScroll  {
    if (self.noDataPlaceholderDelegate && [self.noDataPlaceholderDelegate respondsToSelector:@selector(noDataPlaceholderShouldAllowScroll:)]) {
        return [self.noDataPlaceholderDelegate noDataPlaceholderShouldAllowScroll:self];
    }
    return NO;
}


- (void)xy_noDataPlacehodlerDidAppear {
    if (self.noDataPlaceholderDelegate && [self.noDataPlaceholderDelegate respondsToSelector:@selector(noDataPlaceholderDidAppear:)]) {
        [self.noDataPlaceholderDelegate noDataPlaceholderDidAppear:self];
    }
}

- (void)xy_noDataPlacehodlerWillDisappear {
    if (self.noDataPlaceholderDelegate && [self.noDataPlaceholderDelegate respondsToSelector:@selector(noDataPlaceholderWillDisappear:)]) {
        [self.noDataPlaceholderDelegate noDataPlaceholderWillDisappear:self];
    }
}

- (void)xy_noDataPlacehodlerDidDisappear {
    if (self.noDataPlaceholderDelegate && [self.noDataPlaceholderDelegate respondsToSelector:@selector(noDataPlaceholderDidDisappear:)]) {
        [self.noDataPlaceholderDelegate noDataPlaceholderDidDisappear:self];
    }
}



////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods (dataSource privete api)
////////////////////////////////////////////////////////////////////////

- (UIView *)xy_noDataPlacehodlerCustomView {
    UIView *view = nil;
    if (self.customNoDataView) {
        view = self.customNoDataView();
    }
    if (view) {
        NSAssert([view isKindOfClass:[UIView class]], @"-[customViewForNoDataPlaceholder:] 返回值必须为UIView类或其子类");
        return view;
    }
    return view;
}


- (CGFloat)xy_noDataPlacehodlerVerticalSpace {
    if (self.noDataPlaceholderDelegate && [self.noDataPlaceholderDelegate respondsToSelector:@selector(contentSubviewsVerticalSpaceFoNoDataPlaceholder:)]) {
        return [self.noDataPlaceholderDelegate contentSubviewsVerticalSpaceFoNoDataPlaceholder:self];
    }
    return 0.0;
}

- (CGFloat)xy_noDataPlacehodlerContentOffsetY {
    CGFloat offset = 0.0;
    
    if (self.noDataPlaceholderDelegate && [self.noDataPlaceholderDelegate respondsToSelector:@selector(contentOffsetYForNoDataPlaceholder:)]) {
        offset = [self.noDataPlaceholderDelegate contentOffsetYForNoDataPlaceholder:self];
    }
    return offset;
}

- (UILabel *)xy_noDataPlacehodlerTitleLabel {
    UILabel *titleLabel = nil;
    if (self.noDataTextLabel) {
        titleLabel = self.noDataTextLabel();
    }
    else {
        titleLabel = self.noDataPlaceholderView.titleLabel;
    }
    if (titleLabel) {
        NSAssert([titleLabel isKindOfClass:[UILabel class]], @"[- xy_noDataPlacehodlerTitleLabel:]返回值必须是UILabel或其子类对象");
    }
    return titleLabel;
}

- (UILabel *)xy_noDataPlacehodlerDetailLabel {
    UILabel *detailLabel = nil;
    if (self.noDataDetailTextLabel) {
        detailLabel = self.noDataDetailTextLabel();
    }
    else {
        detailLabel = self.noDataPlaceholderView.detailLabel;
    }
    if (detailLabel) {
        NSAssert([detailLabel isKindOfClass:[UILabel class]], @"[- xy_noDataPlacehodlerDetailLabel:]返回值必须是UILabel或其子类对象");
    }
    return detailLabel;
}

- (UIImageView *)xy_noDataPlacehodlerImageView {
    UIImageView *imageView = nil;
    if (self.noDataImageView) {
        imageView = self.noDataImageView();
    }
    else {
        imageView = self.noDataPlaceholderView.imageView;
    }
    if (imageView) {
        NSAssert([imageView isKindOfClass:[UIImageView class]], @"[- xy_noDataPlacehodlerImageView:]返回值必须是UIImageView或其子类对象");
    }
    return imageView;
}

- (UIButton *)xy_noDataPlacehodlerReloadButton {
    UIButton *btn = nil;
    if (self.noDataReloadButton) {
        btn = self.noDataReloadButton();
    }
    else {
        btn = self.noDataPlaceholderView.reloadButton;
    }
    if (btn) {
        NSAssert([btn isKindOfClass:[UIButton class]], @"[- xy_noDataPlacehodlerReloadButton:]返回值必须是UIImageView或其子类对象");
    }
    return btn;
}

/// 由当前类所在的基类来完成Swizzling
/// 基类分别为：UITableView  UICollectionView  UIScrollView
Class xy_baseClassToSwizzlingForTarget(id target) {
    if ([target isKindOfClass:[UITableView class]]) {
        return [UITableView class];
    }
    if ([target isKindOfClass:[UICollectionView class]]) {
        return [UICollectionView class];
    }
    if ([target isKindOfClass:[UIScrollView class]]) {
        return [UIScrollView class];
    }
    return nil;
}


////////////////////////////////////////////////////////////////////////
#pragma mark - UIGestureRecognizerDelegate
////////////////////////////////////////////////////////////////////////


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer.view isEqual:self.noDataPlaceholderView]) {
        return [self xy_noDataPlacehodlerIsAllowedResponseEvent];
    }
    
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    UIGestureRecognizer *tapGesture = self.noDataPlaceholderView.tapGesture;
    
    if ([gestureRecognizer isEqual:tapGesture] || [otherGestureRecognizer isEqual:tapGesture]) {
        return YES;
    }
    
    if ( (self.noDataPlaceholderDelegate != (id)self) && [self.noDataPlaceholderDelegate respondsToSelector:@selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)]) {
        return [(id)self.noDataPlaceholderDelegate gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
    }
    
    return NO;
}



////////////////////////////////////////////////////////////////////////
#pragma mark - Privite method (reload subviews)
////////////////////////////////////////////////////////////////////////

// 刷新NoDataPlaceholderView 当调用reloadData时也会调用此方法
- (void)xy_reloadNoDataView {
    
    if (![self xy_noDataPlacehodlerCanDisplay]) {
        return;
    }
    
    if (([self xy_noDataPlacehodlerShouldDisplay] && ![self xy_itemCount]) || [self xy_noDataPlacehodlerShouldBeForcedToDisplay]) {
        
        // 通知代理即将显示
        [self xy_noDataPlaceholderViewWillAppear];
        
        NoDataPlaceholderView *noDataPlaceholderView = self.noDataPlaceholderView;
        // 设置是否需要淡入淡出效果
        noDataPlaceholderView.fadeInOnDisplay = [self xy_noDataPlacehodlerShouldFadeInOnDisplay];
        
        if (noDataPlaceholderView.superview == nil) {
            if (([self isKindOfClass:[UITableView class]] || [self isKindOfClass:[UICollectionView class]]) && [self.subviews count] > 1) {
                [self insertSubview:noDataPlaceholderView atIndex:0];
            } else {
                [self addSubview:noDataPlaceholderView];
            }
        }
        
        // 重置视图及其约束对于保证良好状态
        [noDataPlaceholderView resetSubviews];
        
        UIView *customView = [self xy_noDataPlacehodlerCustomView];
        if (customView) {
            noDataPlaceholderView.customView = customView;
        } else {
            
            // customView为nil时，则从dataSource中设置到默认的contentView

            noDataPlaceholderView.titleLabel = [self xy_noDataPlacehodlerTitleLabel];
            noDataPlaceholderView.detailLabel = [self xy_noDataPlacehodlerDetailLabel];
            noDataPlaceholderView.imageView = [self xy_noDataPlacehodlerImageView];
            noDataPlaceholderView.reloadButton = [self xy_noDataPlacehodlerReloadButton];
            
            // 设置noDataPlaceholderView子控件垂直间的间距
            noDataPlaceholderView.verticalSpace = [self xy_noDataPlacehodlerVerticalSpace];
            
        }
        
        noDataPlaceholderView.contentOffsetY = [self xy_noDataPlacehodlerContentOffsetY];
        
        noDataPlaceholderView.backgroundColor = [self xy_noDataPlacehodlerBackgroundColor];
        noDataPlaceholderView.hidden = NO;
        noDataPlaceholderView.clipsToBounds = YES;
        
        noDataPlaceholderView.userInteractionEnabled = [self xy_noDataPlacehodlerIsAllowedResponseEvent];
        
        [noDataPlaceholderView setupConstraints];
        
        // 此方法会先检查动画当前是否启用，然后禁止动画，执行block块语句
        [UIView performWithoutAnimation:^{
            [noDataPlaceholderView layoutIfNeeded];
        }];
        
        self.scrollEnabled = [self xy_noDataPlacehodlerIsAllowedScroll];
        
        // 通知代理完全显示
        [self xy_noDataPlacehodlerDidAppear];
        
    } else {
        [self xy_removeNoDataPlacehodlerView];
    }
    
}

- (void)xy_removeNoDataPlacehodlerView {
    // 通知代理即将消失
    [self xy_noDataPlacehodlerWillDisappear];
    
    if (self.noDataPlaceholderView) {
        [self.noDataPlaceholderView resetSubviews];
        [self.noDataPlaceholderView removeFromSuperview];
        
        [self setNoDataPlaceholderView:nil];
    }
    
    self.scrollEnabled = YES;
    
    // 通知代理完全消失
    [self xy_noDataPlacehodlerDidDisappear];
}

- (UIColor *)xy_noDataPlacehodlerBackgroundColor {
    return self.noDataViewBackgroundColor ?: [UIColor clearColor];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - get
////////////////////////////////////////////////////////////////////////

- (NoDataPlaceholderView *)noDataPlaceholderView {
    
    NoDataPlaceholderView *view = objc_getAssociatedObject(self, _cmd);
    
    if (view == nil) {
        view = [NoDataPlaceholderView new];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.hidden = YES;
        view.tapGesture.delegate = self;
        __weak typeof(self) weakSelf = self;
        [view tapGestureRecognizer:^(UITapGestureRecognizer *tap) {
            [weakSelf xy_didTapContentView:tap];
        }];
        self.noDataPlaceholderView = view;
    }
    
    return view;
}


- (id<NoDataPlaceholderDelegate>)noDataPlaceholderDelegate {
    _WeakObjectContainer *container = objc_getAssociatedObject(self, _cmd);
    return container.weakObject;
}


////////////////////////////////////////////////////////////////////////
#pragma mark - set
////////////////////////////////////////////////////////////////////////



- (void)setNoDataPlaceholderDelegate:(id<NoDataPlaceholderDelegate>)noDataPlaceholderDelegate {
    
    if (noDataPlaceholderDelegate == self.noDataPlaceholderDelegate) {
        return;
    }
    
    if (!noDataPlaceholderDelegate || ![self xy_noDataPlacehodlerCanDisplay]) {
        [self xy_removeNoDataPlacehodlerView];
    }
    _WeakObjectContainer *container = [[_WeakObjectContainer alloc] initWithWeakObject:noDataPlaceholderDelegate];
    objc_setAssociatedObject(self, @selector(noDataPlaceholderDelegate), container, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setNoDataPlaceholderView:(NoDataPlaceholderView *)noDataPlaceholderView {
    objc_setAssociatedObject(self, @selector(noDataPlaceholderView), noDataPlaceholderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@interface UIView (ConstraintBasedLayoutExtensions)

/// 创建视图的约束
- (NSLayoutConstraint *)equallyConstraintWithView:(UIView *)view
                                        attribute:(NSLayoutAttribute)attribute;

@end

#pragma mark *** NoDataPlaceholderView ***

@implementation NoDataPlaceholderView

@synthesize
contentView = _contentView,
titleLabel = _titleLabel,
detailLabel = _detailLabel,
imageView = _imageView,
reloadButton = _reloadButton,
customView = _customView;

////////////////////////////////////////////////////////////////////////
#pragma mark - Initialize
////////////////////////////////////////////////////////////////////////

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
    self.frame = CGRectMake(0.0,
                            0.0,
                            CGRectGetWidth(superviewBounds),
                            CGRectGetHeight(superviewBounds));
    // 当需要淡入淡出时结合动画执行
    void (^fadeInBlock)(void) = ^{
        _contentView.alpha = 1.0;
    };
    
    if (self.fadeInOnDisplay) {
        [UIView animateWithDuration:0.35 animations:fadeInBlock];
    } else {
        fadeInBlock();
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - set
////////////////////////////////////////////////////////////////////////

- (void)setCustomView:(UIView *)customView {
    
    if (!customView) {
        return;
    }
    
    if (_customView) {
        [_customView removeFromSuperview];
        _customView = nil;
    }
    [customView removeConstraints:customView.constraints];
    _customView = customView;
    _customView.translatesAutoresizingMaskIntoConstraints = NO;
    _customView.accessibilityIdentifier = @"no data placeholder custom view";
    [self.contentView addSubview:_customView];
}


- (void)setImageView:(UIImageView *)imageView {
    
    [_imageView removeFromSuperview];
    _imageView = nil;
    
    if (!imageView) {
        return;
    }
    
    [imageView removeConstraints:imageView.constraints];
    _imageView = imageView;
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    _imageView.accessibilityIdentifier = @"no data placeholder image view";
    [self.contentView addSubview:_imageView];
    
}

- (void)setTitleLabel:(UILabel *)titleLabel {
    
    [_titleLabel removeFromSuperview];
    _titleLabel = nil;
    
    if (!titleLabel) {
        return;
    }
    [titleLabel removeConstraints:titleLabel.constraints];
    _titleLabel = titleLabel;
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.accessibilityIdentifier = @"no data placeholder title label";
    [self.contentView addSubview:_titleLabel];
}

- (void)setDetailLabel:(UILabel *)detailLabel {
    [_detailLabel removeFromSuperview];
    _detailLabel = nil;
    
    if (!detailLabel) {
        return;
    }
    [detailLabel removeConstraints:detailLabel.constraints];
    _detailLabel = detailLabel;
    _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _detailLabel.accessibilityIdentifier = @"no data placeholder detail label";
    [self.contentView addSubview:_detailLabel];
}

- (void)setReloadButton:(UIButton *)reloadButton {
    
    [_reloadButton removeFromSuperview];
    _reloadButton = nil;
    
    if (!reloadButton) {
        return;
    }
    [reloadButton removeConstraints:reloadButton.constraints];
    _reloadButton = reloadButton;
    _reloadButton.translatesAutoresizingMaskIntoConstraints = NO;
    _reloadButton.accessibilityIdentifier = @"no data placeholder reload button";
    [_reloadButton addTarget:self action:@selector(clickReloadBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_reloadButton];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - get
////////////////////////////////////////////////////////////////////////
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

- (UIImageView *)imageView {
    if (_imageView == nil) {
        UIImageView *imageView = [UIImageView new];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        imageView.backgroundColor = [UIColor clearColor];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.userInteractionEnabled = NO;
        _imageView = imageView;
        _imageView.accessibilityIdentifier = @"no data placeholder image view";
        [[self contentView] addSubview:_imageView];
    }
    return _imageView;
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
        [[self contentView] addSubview:btn];
    }
    return _reloadButton;
}

- (UITapGestureRecognizer *)tapGesture {
    if (_tapGesture == nil) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureOnSelf:)];
        [self addGestureRecognizer:_tapGesture];
    }
    return _tapGesture;
}


- (BOOL)canShowImage {
    return _imageView.image && _imageView.superview;
}

- (BOOL)canShowTitle {
    return _titleLabel.text.length > 0 && _titleLabel.superview;
}

- (BOOL)canShowDetail {
    return _detailLabel.text.length > 0 && _detailLabel.superview;
}

- (BOOL)canShowReloadButton {
    if ([_reloadButton titleForState:UIControlStateNormal] || [_reloadButton attributedTitleForState:UIControlStateNormal].string.length > 0 || [_reloadButton imageForState:UIControlStateNormal]) {
        return _reloadButton.superview != nil;
    }
    return NO;
}



- (void)tapGestureRecognizer:(void (^)(UITapGestureRecognizer *))tapBlock {
    
    if (!self.tapGesture) {
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureOnSelf:)];
        [self addGestureRecognizer:self.tapGesture];
    }
    if (self.tapGestureRecognizerBlock) {
        self.tapGestureRecognizerBlock = nil;
    }
    self.tapGestureRecognizerBlock = tapBlock;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Events
////////////////////////////////////////////////////////////////////////

/// 点击刷新按钮时处理事件
- (void)clickReloadBtn:(UIButton *)btn {
    SEL selector = NSSelectorFromString(@"xy_clickReloadBtn:");
    UIView *superView = self.superview;
    while (superView) {
        if ([superView isKindOfClass:[UIScrollView class]]) {
            [superView performSelector:selector withObject:btn afterDelay:0.0];
            superView = nil;
        }
        else {
            superView = superView.superview;
        }
    }
}

- (void)tapGestureOnSelf:(UITapGestureRecognizer *)tap {
    if (self.tapGestureRecognizerBlock) {
        self.tapGestureRecognizerBlock(tap);
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Auto Layout
////////////////////////////////////////////////////////////////////////
/// 移除所有约束
- (void)removeAllConstraints {
    [self removeConstraints:self.constraints];
    [_contentView removeConstraints:_contentView.constraints];
}

- (void)setupConstraints {
    
    // contentView 与 父视图 保持一致
    NSLayoutConstraint *contentViewX = [self equallyConstraintWithView:self.contentView attribute:NSLayoutAttributeCenterX];
    NSLayoutConstraint *contentViewY = [self equallyConstraintWithView:self.contentView attribute:NSLayoutAttributeCenterY];
    [self addConstraint:contentViewX];
    [self addConstraint:contentViewY];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:@{@"contentView": self.contentView}]];
    
    // 当verticalOffset(自定义的垂直偏移量)有值时，需要调整垂直偏移量的约束值
    if (self.contentOffsetY != 0.0 && self.constraints.count > 0) {
        contentViewY.constant = self.contentOffsetY;
    }
    
    // 若有customView 则 让其与contentView的约束相同
    if (_customView) {
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[customView]|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:@{@"customView": _customView}]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[customView]|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:@{@"customView": _customView}]];
    } else {
        
        // 无customView
        CGFloat width = CGRectGetWidth(self.frame) ?: CGRectGetWidth([UIScreen mainScreen].bounds);
        CGFloat horizontalSpace = roundf(width / 16.0); // 计算间距  四舍五入
        CGFloat verticalSpace = self.verticalSpace ?: 11.0; // 默认为11.0
        
        NSMutableArray<NSString *> *subviewsNames = [NSMutableArray arrayWithCapacity:0];
        NSMutableDictionary *views = [NSMutableDictionary dictionaryWithCapacity:0];
        NSDictionary *metrics = @{@"horizontalSpace": @(horizontalSpace)};
        
        // 设置imageView水平约束
        if ([self canShowImage]) {
            [subviewsNames addObject:@"imageView"];
            views[[subviewsNames lastObject]] = _imageView;
            
            [self.contentView addConstraint:[self.contentView equallyConstraintWithView:_imageView attribute:NSLayoutAttributeCenterX]];
        } else {
            [_imageView removeFromSuperview];
            _imageView = nil;
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

////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////

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

- (void)resetSubviews {
    [_contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _titleLabel = nil;
    _detailLabel = nil;
    _imageView = nil;
    _customView = nil;
    _reloadButton = nil;
    
    [self removeAllConstraints];
}

@end

@implementation UIView (ConstraintBasedLayoutExtensions)

- (NSLayoutConstraint *)equallyConstraintWithView:(UIView *)view
                                        attribute:(NSLayoutAttribute)attribute {
    
    return [NSLayoutConstraint constraintWithItem:view
                                        attribute:attribute
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:self attribute:attribute
                                       multiplier:1.0
                                         constant:0.0];
}

@end

@implementation _WeakObjectContainer

- (instancetype)initWithWeakObject:(__weak id)weakObject {
    if (self = [super init]) {
        _weakObject = weakObject;
    }
    return self;
}

@end

@implementation _SwizzlingObject

- (NSString *)description {
    
    NSDictionary *descriptionDict = @{@"swizzlingClass": self.swizzlingClass,
                                      @"orginSelector": NSStringFromSelector(self.orginSelector),
                                      @"swizzlingImplPointer": self.swizzlingImplPointer};
    
    return [descriptionDict description];
}

@end

@implementation NSObject (SwizzlingExtend)

////////////////////////////////////////////////////////////////////////
#pragma mark - Method swizzling
////////////////////////////////////////////////////////////////////////


- (void)hockSelector:(SEL)orginSelector swizzlingSelector:(SEL)swizzlingSelector baseClass:(Class)baseClas {
    
    // 本类未实现则return
    if (![self respondsToSelector:orginSelector]) {
        return;
    }
    
    NSLog(@"%@", self.implementationDictionary);
    
    for (_SwizzlingObject *implObject in self.implementationDictionary.allValues) {
        // 确保setImplementation 在UITableView or UICollectionView只调用一次, 也就是每个方法的指针只存储一次
        if (orginSelector == implObject.orginSelector && [self isKindOfClass:implObject.swizzlingClass]) {
            return;
        }
    }
    
    ImplementationKey key = xy_getImplementationKey(baseClas, orginSelector);
    _SwizzlingObject *swizzleObjcet = [self.implementationDictionary objectForKey:key];
    NSValue *implValue = swizzleObjcet.swizzlingImplPointer;
    
    // 如果该类的实现已经存在，就return
    if (implValue || !key || !baseClas) {
        return;
    }
    
    // 注入额外的实现
    Method method = class_getInstanceMethod(baseClas, orginSelector);
    // 设置这个方法的实现
    IMP newImpl = method_setImplementation(method, (IMP)xy_orginalImplementation);
    
    // 将新实现保存到implementationDictionary中
    swizzleObjcet = [_SwizzlingObject new];
    swizzleObjcet.swizzlingClass = baseClas;
    swizzleObjcet.orginSelector = orginSelector;
    swizzleObjcet.swizzlingImplPointer = [NSValue valueWithPointer:newImpl];
    swizzleObjcet.swizzlingSelector = swizzlingSelector;
    [self.implementationDictionary setObject:swizzleObjcet forKey:key];
}

/// 根据类名和方法，拼接字符串，作为implementationDictionary的key
NSString * xy_getImplementationKey(Class clas, SEL selector) {
    if (clas == nil || selector == nil) {
        return nil;
    }
    
    NSString *className = NSStringFromClass(clas);
    NSString *selectorName = NSStringFromSelector(selector);
    return [NSString stringWithFormat:@"%@_%@", className, selectorName];
}

// 对原方法的实现进行加工
void xy_orginalImplementation(id self, SEL _cmd) {
    
    Class baseCls = xy_baseClassToSwizzlingForTarget(self);
    ImplementationKey key = xy_getImplementationKey(baseCls, _cmd);
    _SwizzlingObject *swizzleObject = [[self implementationDictionary] objectForKey:key];
    NSValue *implValue = swizzleObject.swizzlingImplPointer;
    
    // 获取原方法的实现
    IMP impPointer = [implValue pointerValue];
    
    // 执行swizzing
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL swizzlingSelector = swizzleObject.swizzlingSelector;
    if ([self respondsToSelector:swizzlingSelector]) {
        [self performSelector:swizzlingSelector];
    }
#pragma clang diagnostic pop
    
    // 执行原实现
    if (impPointer) {
        ((void(*)(id, SEL))impPointer)(self, _cmd);
    }
}
+ (NSMutableDictionary *)implementationDictionary {
    static NSMutableDictionary *table = nil;
    table = objc_getAssociatedObject(self, _cmd);
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, _cmd, table, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    return table;
}

- (NSMutableDictionary<ImplementationKey, _SwizzlingObject *> *)implementationDictionary {
    return self.class.implementationDictionary;
}

@end
