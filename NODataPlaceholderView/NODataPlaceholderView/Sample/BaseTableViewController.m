//
//  BaseTableViewController.m
//  NODataPlaceholderView
//
//  Created by Ossey on 2017/5/30.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "BaseTableViewController.h"
#import "UIScrollView+NoDataPlaceholder.h"

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
    
    __weak typeof(self) weakSelf = self;
    
    self.tableView.noDataPlaceholderDelegate = self;
    
    self.tableView.customNoDataView = ^UIView * _Nonnull{
        if (weakSelf.tableView.isLoading) {
            UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [activityView startAnimating];
            return activityView;
        }else {
            return nil;
        }
  
    };
    
    self.tableView.noDataTextLabel = ^UILabel * _Nonnull{
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
        titleLabel.attributedText = [weakSelf titleAttributedStringForNoDataPlaceholder];
        return titleLabel;
    };
    
    
    
    self.tableView.noDataDetailTextLabel = ^UILabel * _Nonnull{
        UILabel *detailLabel = [UILabel new];
        detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
        detailLabel.backgroundColor = [UIColor clearColor];
        
        detailLabel.font = [UIFont systemFontOfSize:17.0];
        detailLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        detailLabel.textAlignment = NSTextAlignmentCenter;
        detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
        detailLabel.numberOfLines = 0;
        detailLabel.accessibilityIdentifier = @"no data placeholder detail label";
        detailLabel.attributedText = [weakSelf detailAttributedStringForNoDataPlaceholder];
        return detailLabel;

    };
    
    self.tableView.noDataImageView = ^UIImageView * _Nonnull{
        UIImageView *imageView = [UIImageView new];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        imageView.backgroundColor = [UIColor clearColor];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.userInteractionEnabled = NO;
        imageView.accessibilityIdentifier = @"no data placeholder image view";
        imageView.image = [UIImage imageNamed:@"qqMusic_empty"];
        return imageView;
    };
    
    self.tableView.noDataReloadButton = ^UIButton * _Nonnull{
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        btn.backgroundColor = [UIColor clearColor];
        btn.layer.borderWidth = 0.5;
        btn.layer.borderColor = [UIColor colorWithRed:49/255.0 green:194/255.0 blue:124/255.0 alpha:1.0].CGColor;
        btn.layer.cornerRadius = 2.0;
        [btn.layer setMasksToBounds:YES];
        // 按钮内部控件垂直对齐方式为中心
        btn.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [btn setAttributedTitle:[weakSelf reloadbuttonTitleAttributedStringForNoDataPlaceholder] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        return btn;
    };
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"打开调试窗口" style:0 target:self action:@selector(openTestWindow)];
}

- (void)noDataPlaceholder:(UIScrollView *)scrollView didClickReloadButton:(UIButton *)button {
    [self getDataFromNetwork];
}

- (BOOL)noDataPlaceholderShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
}

- (void)noDataPlaceholder:(UIScrollView *)scrollView didTapOnContentView:(UITapGestureRecognizer *)tap {
    [self getDataFromNetwork];
}

- (NSAttributedString *)titleAttributedStringForNoDataPlaceholder {
    NSString *text = @"没有正在下载的歌曲";
    UIFont *font = [UIFont boldSystemFontOfSize:18.0];
    UIColor *textColor = [UIColor grayColor];
    
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

- (NSAttributedString *)detailAttributedStringForNoDataPlaceholder {
    NSString *text = @"可以去下载历史，批量找回下载过的歌曲";
    UIFont *font = [UIFont systemFontOfSize:16.0];
    UIColor *textColor = [UIColor grayColor];
    
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

- (NSAttributedString *)reloadbuttonTitleAttributedStringForNoDataPlaceholder {
    
    NSString *text = @"查看下载历史";
    UIFont *font = [UIFont systemFontOfSize:15.0];
    UIColor *textColor = [UIColor colorWithRed:49/255.0 green:194/255.0 blue:124/255.0 alpha:1.0];
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    if (font) [attributes setObject:font forKey:NSFontAttributeName];
    if (textColor) [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
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

#pragma mark - other

- (void)getDataFromNetwork {
    
    self.tableView.loading = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self addData];
        [self.tableView reloadData];
        self.tableView.loading = NO;
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
