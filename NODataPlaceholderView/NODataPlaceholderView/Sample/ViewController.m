//
//  ViewController.m
//  NODataPlaceholderView
//
//  Created by Ossey on 2017/5/29.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+NoDataPlaceholder.h"

@interface ViewController () <NoDataPlaceholderDataSource, NoDataPlaceholderDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.tableView.noDataPlaceholderDataSource = self;
    self.tableView.noDataPlaceholderDelegate = self;

    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - <NoDataPlaceholderDataSource, NoDataPlaceholderDelegate>

- (NSAttributedString *)titleAttributedStringForNoDataPlaceholder:(UIScrollView *)scrollView {
    NSString *text = nil;
    UIFont *font = nil;
    UIColor *textColor = nil;
    
    text = @"没有关注的好友!";
    font = [UIFont boldSystemFontOfSize:18.0];
    textColor = [UIColor redColor];
    
    NSMutableDictionary *attributeDict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.lineBreakMode = NSLineBreakByWordWrapping;
    style.alignment = NSTextAlignmentCenter;
    
    [attributeDict setObject:font forKey:NSFontAttributeName];
     [attributeDict setObject:textColor forKey:NSForegroundColorAttributeName];
    [attributeDict setObject:style forKey:NSParagraphStyleAttributeName];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributeDict];
    
    return attributedString;

}

- (NSAttributedString *)detailAttributedStringForNoDataPlaceholder:(UIScrollView *)scrollView {
    NSString *text = nil;
    UIFont *font = nil;
    UIColor *textColor = nil;
    
    NSMutableDictionary *attributeDict = [NSMutableDictionary new];
    
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.lineBreakMode = NSLineBreakByWordWrapping;
    style.alignment = NSTextAlignmentCenter;
    
    text = @"快去关注你喜欢的达人吧! TA的最新动态将在本页中展示！";
    font = [UIFont systemFontOfSize:16.0];
    textColor = [UIColor greenColor];
    style.lineSpacing = 4.0;
    [attributeDict setObject:font forKey:NSFontAttributeName];
    [attributeDict setObject:textColor forKey:NSForegroundColorAttributeName];
    [attributeDict setObject:style forKey:NSParagraphStyleAttributeName];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributeDict];
    
    return attributedString;
    
}

- (NSAttributedString *)reloadbuttonTitleAttributedStringForNoDataPlaceholder:(UIScrollView *)scrollView forState:(UIControlState)state {
    
    NSString *text = nil;
    UIFont *font = nil;
    UIColor *textColor = nil;
    
    text = @"获取达人";
    font = [UIFont systemFontOfSize:15.0];
    textColor = [UIColor blackColor];
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    if (font) [attributes setObject:font forKey:NSFontAttributeName];
    if (textColor) [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (void)noDataPlaceholder:(UIScrollView *)scrollView didTapOnContentView:(nonnull UITapGestureRecognizer *)tap {
    self.tableView.loading = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.tableView.loading = NO;
    });
}

- (void)noDataPlaceholder:(UIScrollView *)scrollView didClickReloadButton:(UIButton *)button {
    
    self.tableView.loading = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.tableView.loading = NO;
    });
    
    // 打开调试窗口
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored   "-Warc-performSelector-leaks"
//    Class someClass = NSClassFromString(@"UIDebuggingInformationOverlay");
//    id obj = [someClass performSelector:NSSelectorFromString(@"overlay")];
//    [obj performSelector:NSSelectorFromString(@"toggleVisibility")];
//#pragma clang diagnostic pop
}

- (UIImage *)imageForNoDataPlaceholder:(UIScrollView *)scrollView
{
    if (self.tableView.loading) {
        return [UIImage imageNamed:@"loading_imgBlue_78x78" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    }
    else {
        
        UIImage *image = [UIImage imageNamed:@"placeholder_instagram"];
        
        return image;
    }
}

- (BOOL)noDataPlaceholderShouldAnimateImageView:(UIScrollView *)scrollView {
    return self.tableView.loading;
}

- (CAAnimation *)imageAnimationForNoDataPlaceholder:(UIScrollView *)scrollView {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.toValue = [NSValue valueWithCATransform3D: CATransform3DMakeRotation(M_PI_2, 0.0, 0.0, 1.0) ];
    animation.duration = 0.25;
    animation.cumulative = YES;
    animation.repeatCount = MAXFLOAT;
    
    return animation;
}

- (UIColor *)reloadButtonBackgroundColorForNoDataPlaceholder:(UIScrollView *)scrollView {
    return [UIColor blueColor];
}

- (CGFloat)noDataPlaceholderContentOffsetYForNoDataPlaceholder:(UIScrollView *)scrollView {
    return 0;
}

- (CGFloat)noDataPlaceholderContentSubviewsVerticalSpace:(UIScrollView *)scrollView {
    return 30;
}

- (UIView *)customViewForNoDataPlaceholder:(UIScrollView *)scrollview {
    if (self.tableView.isLoading) {
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityView startAnimating];
        return activityView;
    }else {
        return nil;
    }
}

- (BOOL)noDataPlaceholderShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
}

#pragma mark - set


@end
