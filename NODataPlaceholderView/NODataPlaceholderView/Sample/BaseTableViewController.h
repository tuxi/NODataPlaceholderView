//
//  BaseTableViewController.h
//  NODataPlaceholderView
//
//  Created by Ossey on 2017/5/30.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollView+NoDataPlaceholder.h"

@interface BaseTableViewController : UITableViewController <NoDataPlaceholderDataSource, NoDataPlaceholderDelegate>

@end
