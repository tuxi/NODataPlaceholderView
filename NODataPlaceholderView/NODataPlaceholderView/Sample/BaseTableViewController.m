//
//  BaseTableViewController.m
//  NODataPlaceholderView
//
//  Created by Ossey on 2017/5/30.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "BaseTableViewController.h"

@interface BaseTableViewController () <UIAlertViewDelegate>
{
    NSMutableArray<NSString *> *_dataSource;
    
    NSInteger _currentClickRow;
}
@end

@implementation BaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.noDataPlaceholderDataSource = self;
    self.tableView.noDataPlaceholderDelegate = self;
    _dataSource = [NSMutableArray array];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuseIdentifier"];
    
    // 在这个block块中设置传入的子控件属性，会导致这些子控件相关的数据源方法不再调用
//    __weak typeof(self) weakSelf = self;
//    [self.tableView setNoDataPlaceholderContentViewAttribute:^(UIButton *const  _Nonnull reloadBtn, UILabel *const  _Nonnull titleLabel, UILabel *const  _Nonnull detailLabel, UIImageView *const  _Nonnull imageView) {
//    
//        
//        // 设置reloadBtn
//        NSString *text = @"获取达人";
//        UIFont *font = [UIFont systemFontOfSize:15.0];
//        UIColor *textColor = [UIColor blackColor];
//        NSMutableDictionary *attributes = [NSMutableDictionary new];
//        [attributes setObject:font forKey:NSFontAttributeName];
//        [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
//        
//        NSAttributedString *reloadString = [[NSAttributedString alloc] initWithString:text attributes:attributes];
//        [reloadBtn setAttributedTitle:reloadString forState:UIControlStateNormal];
//        [reloadBtn setBackgroundColor:[UIColor orangeColor]];
//        reloadBtn.layer.cornerRadius = 8.8;
//        [reloadBtn.layer setMasksToBounds:YES];
//        
//        
//        // 设置titleLabel
//        [titleLabel setText:@"获取数据"];
//        // 设置detailLabel
//        [detailLabel setText:@"今天加载数据，没准可以找到你心仪的女神哦~~~~~~~~~~!"];
//        // 设置imageView
//        if (weakSelf.tableView.isLoading) {
//            [imageView setImage:[UIImage imageNamed:@"loading_imgBlue_78x78"]];
//        
//            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
//            animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
//            animation.toValue = [NSValue valueWithCATransform3D: CATransform3DMakeRotation(M_PI_2, 0.0, 0.0, 1.0) ];
//            animation.duration = 0.25;
//            animation.cumulative = YES;
//            animation.repeatCount = MAXFLOAT;
//            
//            [imageView.layer addAnimation:animation forKey:@"animation"];
//        } else {
//            [imageView setImage:[UIImage imageNamed:@"placeholder_instagram"]];
//            [imageView.layer removeAnimationForKey:@"animation"];
//        }
//        
//        
//    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"打开调试窗口" style:0 target:self action:@selector(openTestWindow)];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Other Events
- (void)openTestWindow {
    //     打开调试窗口
#pragma clang diagnostic push
#pragma clang diagnostic ignored   "-Warc-performSelector-leaks"
    Class someClass = NSClassFromString(@"UIDebuggingInformationOverlay");
    id obj = [someClass performSelector:NSSelectorFromString(@"overlay")];
    [obj performSelector:NSSelectorFromString(@"toggleVisibility")];
#pragma clang diagnostic pop
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"添加10条数据";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"删除全部数据";
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"删除第%ld行",indexPath.row];
    }
    
    cell.backgroundColor = [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _currentClickRow = indexPath.row;
    [[[UIAlertView alloc] initWithTitle:@"请选择" message:nil delegate:self cancelButtonTitle:@"不" otherButtonTitles:@"好的", nil] show];
}

#pragma mark - <UIAlertViewDelegate>

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        
        if (_currentClickRow == 0) {
            [self addData];
        } else if (_currentClickRow == 1) {
            [_dataSource removeAllObjects];
        } else {
            if (_currentClickRow < _dataSource.count) {
                [_dataSource removeObjectAtIndex:_currentClickRow];
            } else {
                NSAssert(_currentClickRow < _dataSource.count, @"要删除的数据索引超出了数组的长度");
            }
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}

#pragma mark - <NoDataPlaceholderDataSource>

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



- (UIImage *)imageForNoDataPlaceholder:(UIScrollView *)scrollView {
    if (self.tableView.loading) {
        return [UIImage imageNamed:@"loading_imgBlue_78x78" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    } else {
        
        UIImage *image = [UIImage imageNamed:@"placeholder_instagram"];
        return image;
    }
}

- (UIColor *)reloadButtonBackgroundColorForNoDataPlaceholder:(UIScrollView *)scrollView {
    return [UIColor orangeColor];
}

- (CGFloat)contentOffsetYForNoDataPlaceholder:(UIScrollView *)scrollView {
    return 0;
}

- (CGFloat)contentSubviewsVerticalSpaceFoNoDataPlaceholder:(UIScrollView *)scrollView {
    return 30;
}


#pragma mark - <NoDataPlaceholderDelegate>

- (void)noDataPlaceholder:(UIScrollView *)scrollView didTapOnContentView:(nonnull UITapGestureRecognizer *)tap {
    
    [self getDataFromNetwork];
}

- (void)noDataPlaceholder:(UIScrollView *)scrollView didClickReloadButton:(UIButton *)button {
    
    [self getDataFromNetwork];

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


#pragma mark - other

- (void)getDataFromNetwork {
    
    self.tableView.loading = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self addData];
        self.tableView.loading = NO;
        [self.tableView reloadData];
    });
}

- (void)addData {
    int i = 0;
    while (i < 10) {
        
        [_dataSource addObject:[NSString stringWithFormat:@"%d", i]];
        
        i++;
    }
    
}
@end
