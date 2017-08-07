//
//  BaseTableViewController.m
//  NODataPlaceholderView
//
//  Created by Ossey on 2017/5/30.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "BaseTableViewController.h"
#import "UIScrollView+NoDataExtend.h"

@interface BaseTableViewController () <UIAlertViewDelegate, NoDataPlaceholderDelegate>
{
    NSMutableArray<NSString *> *_dataSource;
    
    NSInteger _currentClickRow;
    
}

@end

@implementation BaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _dataSource = [NSMutableArray array];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuseIdentifier"];
    
    // 自定义NoDataPlaceholder的子控件
//    [self setupNodataViewForNewSubviews];
    
    // 使用默认的子控件 配置
    [self setupNodataView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"打开调试窗口" style:0 target:self action:@selector(openTestWindow)];
}

// 使用默认的子控件进行配置
- (void)setupNodataView {
    __weak typeof(self) weakSelf = self;
    
    self.tableView.noDataPlaceholderDelegate = self;

    self.tableView.customNoDataView = ^UIView * _Nonnull{
        if (weakSelf.tableView.xy_loading) {
            UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [activityView startAnimating];
            return activityView;
        }else {
            return nil;
        }
        
    };
    
    self.tableView.noDataTextLabelBlock = ^(UILabel * _Nonnull textLabel) {
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.font = [UIFont systemFontOfSize:27.0];
        textLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        textLabel.numberOfLines = 0;
        textLabel.attributedText = [weakSelf attributedStringWithText:@"没有正在下载的歌曲" color:[UIColor grayColor] fontSize:16];;
    };
    
    self.tableView.noDataDetailTextLabelBlock = ^(UILabel * _Nonnull detailTextLabel) {
        detailTextLabel.backgroundColor = [UIColor clearColor];
        detailTextLabel.font = [UIFont systemFontOfSize:17.0];
        detailTextLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        detailTextLabel.textAlignment = NSTextAlignmentCenter;
        detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        detailTextLabel.numberOfLines = 0;
        detailTextLabel.attributedText = [weakSelf attributedStringWithText:@"可以去下载历史，批量找回下载过的歌曲" color:[UIColor grayColor] fontSize:16];
    };
    
    self.tableView.noDataTextEdgeInsets = UIEdgeInsetsMake(20, 0, 5, 0);
    
    self.tableView.noDataImageViewBlock = ^(UIImageView * _Nonnull imageView) {
        imageView.backgroundColor = [UIColor clearColor];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.userInteractionEnabled = NO;
        imageView.image = [UIImage imageNamed:@"qqMusic_empty"];

    };
    
    self.tableView.noDataReloadButtonBlock = ^(UIButton * _Nonnull reloadButton) {
        reloadButton.backgroundColor = [UIColor clearColor];
        reloadButton.layer.borderWidth = 0.5;
        reloadButton.layer.borderColor = [UIColor colorWithRed:49/255.0 green:194/255.0 blue:124/255.0 alpha:1.0].CGColor;
        reloadButton.layer.cornerRadius = 2.0;
        [reloadButton.layer setMasksToBounds:YES];
        // 按钮内部控件垂直对齐方式为中心
        reloadButton.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
        reloadButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [reloadButton setAttributedTitle:[weakSelf attributedStringWithText:@"查看下载历史" color:[UIColor colorWithRed:49/255.0 green:194/255.0 blue:124/255.0 alpha:1.0] fontSize:15.0] forState:UIControlStateNormal];
        [reloadButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];

    };
    
    self.tableView.noDataButtonEdgeInsets = UIEdgeInsetsMake(11, 100, 11, 100);
}


// 创建新的子控件，可以自定义子控件，只要符合回调的类型即可
- (void)setupNodataViewForNewSubviews {
    
    __weak typeof(self) weakSelf = self;
    
    self.tableView.noDataPlaceholderDelegate = self;
    
    self.tableView.customNoDataView = ^UIView * _Nonnull{
        if (weakSelf.tableView.xy_loading) {
            UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [activityView startAnimating];
            return activityView;
        }else {
            return nil;
        }
        
    };
    
    self.tableView.noDataTextLabel = ^UILabel * _Nonnull{
        UILabel *titleLabel = [UILabel new];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont systemFontOfSize:27.0];
        titleLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.numberOfLines = 0;
        // 通过accessibilityIdentifier来定位元素,相当于这个控件的id
        titleLabel.accessibilityIdentifier = @"no data placeholder title";
        titleLabel.attributedText = [weakSelf attributedStringWithText:@"没有正在下载的歌曲" color:[UIColor grayColor] fontSize:16];;
        return titleLabel;
    };
    
    self.tableView.noDataTextEdgeInsets = UIEdgeInsetsMake(20, 0, 5, 0);
    
    self.tableView.noDataDetailTextLabel = ^UILabel * _Nonnull{
        UILabel *detailLabel = [UILabel new];
        detailLabel.backgroundColor = [UIColor clearColor];
        
        detailLabel.font = [UIFont systemFontOfSize:17.0];
        detailLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        detailLabel.textAlignment = NSTextAlignmentCenter;
        detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
        detailLabel.numberOfLines = 0;
        detailLabel.accessibilityIdentifier = @"no data placeholder detail label";
        detailLabel.attributedText = [weakSelf attributedStringWithText:@"可以去下载历史，批量找回下载过的歌曲" color:[UIColor grayColor] fontSize:16];
        return detailLabel;
        
    };
    
    self.tableView.noDataImageView = ^UIImageView * _Nonnull{
        UIImageView *imageView = [UIImageView new];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.userInteractionEnabled = NO;
        imageView.accessibilityIdentifier = @"no data placeholder image view";
        imageView.image = [UIImage imageNamed:@"qqMusic_empty"];
        return imageView;
    };
    
    self.tableView.noDataReloadButton = ^UIButton * _Nonnull{
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = [UIColor clearColor];
        btn.layer.borderWidth = 0.5;
        btn.layer.borderColor = [UIColor colorWithRed:49/255.0 green:194/255.0 blue:124/255.0 alpha:1.0].CGColor;
        btn.layer.cornerRadius = 2.0;
        [btn.layer setMasksToBounds:YES];
        // 按钮内部控件垂直对齐方式为中心
        btn.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [btn setAttributedTitle:[weakSelf attributedStringWithText:@"查看下载历史" color:[UIColor colorWithRed:49/255.0 green:194/255.0 blue:124/255.0 alpha:1.0] fontSize:15.0] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        return btn;
    };
    
    self.tableView.noDataButtonEdgeInsets = UIEdgeInsetsMake(11, 100, 11, 100);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Table view data source
////////////////////////////////////////////////////////////////////////

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

////////////////////////////////////////////////////////////////////////
#pragma mark - UIAlertViewDelegate
////////////////////////////////////////////////////////////////////////

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

////////////////////////////////////////////////////////////////////////
#pragma mark - other
////////////////////////////////////////////////////////////////////////

- (void)getDataFromServer {
    
    self.tableView.xy_loading = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self addData];
        [self.tableView reloadData];
        self.tableView.xy_loading = NO;
    });
}

- (void)addData {
    int i = 0;
    while (i < 10) {
        
        [_dataSource addObject:[NSString stringWithFormat:@"%d", i]];
        
        i++;
    }
    
}


////////////////////////////////////////////////////////////////////////
#pragma mark - Other Events
////////////////////////////////////////////////////////////////////////

- (void)openTestWindow {
    //     打开调试窗口
#pragma clang diagnostic push
#pragma clang diagnostic ignored   "-Warc-performSelector-leaks"
    Class someClass = NSClassFromString(@"UIDebuggingInformationOverlay");
    id obj = [someClass performSelector:NSSelectorFromString(@"overlay")];
    [obj performSelector:NSSelectorFromString(@"toggleVisibility")];
#pragma clang diagnostic pop
}


////////////////////////////////////////////////////////////////////////
#pragma mark - NoDataPlaceholderDelegate
////////////////////////////////////////////////////////////////////////

- (void)noDataPlaceholder:(UIScrollView *)scrollView didClickReloadButton:(UIButton *)button {
    [self getDataFromServer];
}

- (BOOL)noDataPlaceholderShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
}

- (void)noDataPlaceholder:(UIScrollView *)scrollView didTapOnContentView:(UITapGestureRecognizer *)tap {
    [self getDataFromServer];
}

- (CGFloat)contentOffsetYForNoDataPlaceholder:(UIScrollView *)scrollView {
    return -60;
}

- (NSAttributedString *)attributedStringWithText:(NSString *)string color:(UIColor *)color fontSize:(CGFloat)fontSize {
    NSString *text = string;
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    UIColor *textColor = color;
    
    NSMutableDictionary *attributeDict = [NSMutableDictionary new];
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.lineBreakMode = NSLineBreakByWordWrapping;
    style.alignment = NSTextAlignmentCenter;
    style.lineSpacing = 4.0;
    [attributeDict setObject:font forKey:NSFontAttributeName];
    [attributeDict setObject:textColor forKey:NSForegroundColorAttributeName];
    [attributeDict setObject:style forKey:NSParagraphStyleAttributeName];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributeDict];
    
    return attributedString;
    
}


@end
