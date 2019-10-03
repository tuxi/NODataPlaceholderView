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
    NSMutableArray<NSMutableArray *> *_dataArray;
    
}

@end

@implementation BaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = [NSMutableArray array];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuseIdentifier"];
    
    [self setupNodataView];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteAll)];
    
//    if (@available(iOS 11.0, *)) {
//        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//    } else {
//        self.automaticallyAdjustsScrollViewInsets = NO;
//    }
}

- (void)deleteAll {
    if (_dataArray.count == 0) {
        return;
    }
    [_dataArray removeAllObjects];
    [self.tableView reloadData];
}

- (void)setupNodataView {
    __weak typeof(self) weakSelf = self;
    
    self.tableView.noDataPlaceholderDelegate = self;
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _dataArray[section].count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"删除当前行 %ld", indexPath.row];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"第%ld组", section];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView beginUpdates];
    NSMutableArray *arr = _dataArray[indexPath.section];
    if (arr.count == 1) {
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        [_dataArray removeObjectAtIndex:indexPath.section];
    }
    else {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [arr removeObjectAtIndex:indexPath.row];
    }
    
    [self.tableView endUpdates];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - other
////////////////////////////////////////////////////////////////////////

/// 以下模拟从服务器请求数据
- (void)getDataFromServer {
    
    // 请求数据前执行此方法，显示加载中的loading，如果不需要加载中的loading，可不执行此方法
    [self.tableView xy_beginLoading];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 模拟数据请求完成
        [self loadSectionData];
    });
}

- (void)loadSectionData {
    
    [_dataArray removeAllObjects];
    
    NSMutableArray *sec1 = [NSMutableArray array];
    [_dataArray addObject:sec1];
    NSMutableArray *sec2 = [NSMutableArray array];
    [_dataArray addObject:sec2];
    
    for (NSInteger i = 0; i < 3; i++) {
        [sec1 addObject:@(i)];
        [sec2 addObject:@(i)];
    }
    
    if (_dataArray.count == 0) {
        [self.tableView reloadData];
        return;
    }
    [self.tableView beginUpdates];
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    [self.tableView xy_endLoading];
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
//    [self getDataFromServer];
}


- (CGPoint)contentOffsetForNoDataPlaceholder:(UIScrollView *)scrollView {
    if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait) {
        return CGPointMake(0.0, 30.0);
    }
    return CGPointMake(0.0, 30.0);
}

- (UIScrollViewNoDataContentLayouAttribute)contentLayouAttributeOfNoDataPlaceholder:(UIScrollView *)scrollView {
    return UIScrollViewNoDataContentLayouAttributeTop;
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
