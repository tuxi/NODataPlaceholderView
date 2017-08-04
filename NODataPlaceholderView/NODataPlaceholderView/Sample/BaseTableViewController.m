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

    _dataSource = [NSMutableArray array];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuseIdentifier"];
    
    __weak typeof(self) weakSelf = self;
    self.tableView.reloadButtonClickBlock = ^{
      [weakSelf getDataFromNetwork];
    };
    
    
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
