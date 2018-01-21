//
//  BaseTableViewController.m
//  NODataPlaceholderView
//
//  Created by alpface on 2017/5/30.
//  Copyright © 2017年 alpface. All rights reserved.
//

#import "BaseTableViewController.h"
#import "UIScrollView+NoDataExtend.h"

@interface BaseTableViewController () <UIAlertViewDelegate, NoDataPlaceholderDelegate> {
    NSMutableArray<NSString *> *_dataArray;
    NSInteger _currentClickRow;
}

@end

@implementation BaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = [NSMutableArray array];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuseIdentifier"];
    
    [self setupNodataView];

}


- (void)setupNodataView {
    __weak typeof(self) weakSelf = self;
    
    self.tableView.noDataPlaceholderDelegate = self;

    self.tableView.customNoDataView = ^UIView * _Nonnull{
        if (weakSelf.tableView.xy_loading) {
            UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [activityView startAnimating];
            return activityView;
        }
        else {
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
        [reloadButton setAttributedTitle:[weakSelf attributedStringWithText:@"查看下载历史" color:[UIColor colorWithRed:49/255.0 green:194/255.0 blue:124/255.0 alpha:1.0] fontSize:15.0] forState:UIControlStateNormal];
        [reloadButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];

    };
    

    self.tableView.noDataTextEdgeInsets = UIEdgeInsetsMake(20, 0, 20, 0);
    self.tableView.noDataButtonEdgeInsets = UIEdgeInsetsMake(20, 100, 11, 100);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Table view data source
////////////////////////////////////////////////////////////////////////

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"add";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"delete all";
    } else {
        cell.textLabel.text = @"delete current row";
    }
    
    cell.backgroundColor = [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _currentClickRow = indexPath.row;
    [[[UIAlertView alloc] initWithTitle:@"请选择" message:nil delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"OK", nil] show];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIAlertViewDelegate
////////////////////////////////////////////////////////////////////////

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        
        if (_currentClickRow == 0) {
            [self addData];
        } else if (_currentClickRow == 1) {
            [_dataArray removeAllObjects];
        } else {
            if (_currentClickRow < _dataArray.count) {
                [_dataArray removeObjectAtIndex:_currentClickRow];
            } else {
                NSAssert(_currentClickRow < _dataArray.count, @"要删除的数据索引超出了数组的长度");
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
        
        [_dataArray addObject:[NSString stringWithFormat:@"%d", i]];
        
        i++;
    }
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self.tableView xy_reloadNoData];
    
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


- (CGPoint)contentOffsetForNoDataPlaceholder:(UIScrollView *)scrollView {
    if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait) {
        return CGPointMake(0.0, 80.0);
    }
    return CGPointMake(0.0, 30.0);
}


- (void)noDataPlaceholderWillAppear:(UIScrollView *)scrollView {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}

- (void)noDataPlaceholderDidDisappear:(UIScrollView *)scrollView {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

- (BOOL)noDataPlaceholderShouldFadeInOnDisplay:(UIScrollView *)scrollView {
    return YES;
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
