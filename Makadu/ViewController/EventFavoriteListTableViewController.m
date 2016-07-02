//
//  EventFavoriteListTableViewController.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 1/27/16.
//  Copyright © 2016 Madhava. All rights reserved.
//

#import "EventFavoriteListTableViewController.h"
#import "Event.h"
#import "User.h"
#import "Connection.h"
#import "Localytics.h"
#import "EventTableViewCell.h"
#import "ShowEventViewController.h"

#import "UIRefreshControl+AFNetworking.h"
#import "UIAlertView+AFNetworking.h"
#import "UIImageView+AFNetworking.h"

#import "DateFormatter.h"

@interface EventFavoriteListTableViewController ()

@property (strong,nonatomic) NSArray *listEvent;
@property BOOL loadRemoteImage;

@end

@implementation EventFavoriteListTableViewController

- (void)reload:(__unused id)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [MRProgressOverlayView showOverlayAddedTo:self.view title:NSLocalizedString(@"loading_event", nil) mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
    
    NSURLSessionTask *task = [Event getEventsFavorities:^(NSArray *events, NSError *error) {
        [MRProgressOverlayView dismissAllOverlaysForView:self.view animated:YES];
        
        if (!error) {
            self.listEvent = [self sortEvents:events];
            self.loadRemoteImage = YES;
            [self.tableView reloadData];
        } else {
            NSLog(@"Ocorreu um erro == %@", error.localizedDescription);
        }
    }];
    
    [UIAlertView showAlertViewForTaskWithErrorOnCompletion:task delegate:nil];
    [self.refreshControl setRefreshingWithStateOfTask:task];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.translucent = NO;
    
    self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"events", nil);
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: NSLocalizedString(@"logout", nil)
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(logout:)];
    self.navigationController.navigationBar.topItem.leftBarButtonItem = backButton;
    
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 100.0f)];
    [self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    [self.tableView.tableHeaderView addSubview:self.refreshControl];    
    
    [self configureTableView];
}

-(void)retriveLocal {
    Event * event = [Event new];
    self.listEvent = [event loadFavoritiesEvents];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [Localytics tagEvent:@"Event List" attributes:@{@"Username" : [User currentUser].userName }];
    
    
    self.listEvent = @[];
    
    
    self.loadRemoteImage = YES;
    
    if (![Connection existConnection]) {
        Event * event = [Event new];
        if ([event loadFavoritiesEvents].count > 0) {
            self.loadRemoteImage = NO;
            [self retriveLocal];
        }
    } else {
        self.listEvent = @[];
        [self reload:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.listEvent count] > 0) {
        return [self.listEvent count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * cellEvent = @"listEventCell";
    EventTableViewCell *cell = (EventTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellEvent];
    
    if (cell == nil) {
        cell = [[EventTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellEvent];
    }
    
    if(indexPath.row % 2 == 0)
        cell.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1];
    else
        cell.backgroundColor = [UIColor whiteColor];
    
    
    Event *event = [self.listEvent objectAtIndex:indexPath.row];
    
    cell.namelabel.text = event.title;
    cell.cityLabel.text = event.city;
    cell.dateLabel.text = [NSString stringWithFormat:@"%@ a %@", [DateFormatter formateUniversalDate:event.startDate withZone:NO] , [DateFormatter formateUniversalDate:event.endDate withZone:NO]];
    
    cell.patronageImage.contentMode = UIViewContentModeScaleAspectFit;
    cell.patronageImage.image = [UIImage imageWithData:event.imgLogoMedium];
    return cell;
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showEvent"]) {
        NSIndexPath *indexPath = nil;
        Event *event = [Event new];
        
        indexPath = [self.tableView indexPathForSelectedRow];
        event = [self.listEvent objectAtIndex:indexPath.row];
        
        ShowEventViewController * desinateViewController = [segue destinationViewController];
        [desinateViewController setEvent:event];
    }
}

#pragma mark - Support Method
-(NSArray *)sortEvents:(NSArray *)events {
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate"
                                                 ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [events sortedArrayUsingDescriptors:sortDescriptors];
    
    return sortedArray;
}

-(void) configureTableView {
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80.0;
}


#pragma mark - Logout
-(IBAction)logout:(id)sender {
    
    [Localytics tagEvent:@"Logout" attributes:@{@"Username" : [User currentUser].userName}];
    
    [User logout];
    [self performSegueWithIdentifier:@"showSignup" sender:self];
}
@end
