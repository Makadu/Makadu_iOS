//
//  NoticeListTableViewController.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/31/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ShowEventViewController.h"

@interface NoticeListTableViewController : UITableViewController

@property (strong, nonatomic) ShowEventViewController *showEventViewController;

@end
