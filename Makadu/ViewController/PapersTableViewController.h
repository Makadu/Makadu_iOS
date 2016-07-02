//
//  PapersTableViewController.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 4/5/16.
//  Copyright © 2016 Madhava. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MRProgress/MRProgress.h>

#import "ShowEventViewController.h"

@interface PapersTableViewController : UITableViewController <UISearchBarDelegate, UISearchResultsUpdating>

@property (strong, nonatomic) ShowEventViewController *showEventViewController;

@end
