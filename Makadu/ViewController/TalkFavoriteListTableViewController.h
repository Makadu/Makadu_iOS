//
//  TalkFavoriteListTableViewController.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 6/6/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <MRProgress/MRProgress.h>

#import "ShowEventViewController.h"

@interface TalkFavoriteListTableViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) ShowEventViewController *showEventViewController;

@end