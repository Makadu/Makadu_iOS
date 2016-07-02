//
//  TalkListTableViewController.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/26/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MRProgress/MRProgress.h>

#import "ShowEventViewController.h"

@interface TalkListTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating>

@property (strong, nonatomic) ShowEventViewController *showEventViewController;


@end
