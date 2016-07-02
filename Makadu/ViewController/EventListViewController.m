//
//  EventListViewController.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/25/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "EventListViewController.h"

#import "Event.h"
#import "Localytics.h"
#import "EventTableViewCell.h"
#import "ShowEventViewController.h"

#import "DateFormatter.h"

#import "UIRefreshControl+AFNetworking.h"
#import "UIAlertView+AFNetworking.h"
#import "UIImageView+AFNetworking.h"

#import "User.h"

@interface EventListViewController ()

@property (strong,nonatomic) NSArray *listEvent;
@property (strong,nonatomic) NSMutableArray *eventsFiltered;
@property BOOL loadRemoteImage;

@property (strong, nonatomic) UISearchController *searchController;

@end

@implementation EventListViewController

#pragma Mark - cicle life

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
    
    self.loadRemoteImage = NO;
    
    [self configureTableView];
    
    [self configureUISearchController];
    
    if ([Event existDataInDataBase:nil]) {
        [self retriveLocal];
    } else {
        [self reload:nil];
    }
    
    [[self.tabBarController.tabBar.items objectAtIndex:0] setTitle:NSLocalizedString(@"event", nil)];
    [[self.tabBarController.tabBar.items objectAtIndex:1] setTitle:NSLocalizedString(@"my_events", nil)];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"event", nil);
    
    User *user = [User new];
    if (![user userAuthenticate]) {
        [self performSegueWithIdentifier:@"showSignup" sender:self];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"event", nil);
    
    User *user = [User new];
    if ([user userAuthenticate]) {
        [Localytics tagEvent:@"Event List" attributes:@{@"Username" : [User currentUser].userName }];
    }
}

- (void)reload:(__unused id)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    NSURLSessionTask *task = [Event getEvents:^(NSArray *events, NSError *error) {
        if (!error) {
            self.listEvent = [self sortEvents:events];
            self.loadRemoteImage = YES;
            [self.tableView reloadData];
        } else {
            NSLog(@"Ocorreu um erro");
        }
    }];
    
    [UIAlertView showAlertViewForTaskWithErrorOnCompletion:task delegate:nil];
    [self.refreshControl setRefreshingWithStateOfTask:task];
}

- (void)retriveLocal {
    
    self.listEvent = [Event retrieveEventAll];
    [self.tableView reloadData];
}

- (void)didChangePreferredContentSize:(NSNotification *)notification
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (self.searchController.active) {
        return [self.eventsFiltered count];
    } else {
        return [self.listEvent count];
    }
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


    Event *event = [Event new];
    if (self.searchController.active) {
        event = [self.eventsFiltered objectAtIndex:indexPath.row];
    } else {
        event = [self.listEvent objectAtIndex:indexPath.row];
    }
    
    cell.namelabel.text = event.title;
    cell.cityLabel.text = event.city;
    cell.dateLabel.text = [NSString stringWithFormat:@"%@ a %@", [DateFormatter formateUniversalDate:event.startDate withZone:NO] , [DateFormatter formateUniversalDate:event.endDate withZone:NO]];
 
    
    if (self.loadRemoteImage) {
        
        NSURL *url = [NSURL URLWithString:event.logo];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        UIImage *placeholderImage = [UIImage imageNamed:@"placeholder"];
        
        __weak EventTableViewCell *eventCell = cell;
        
        [cell.imageView setImageWithURLRequest:request
                              placeholderImage:placeholderImage
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           
                                           eventCell.patronageImage.image = image;
                                           [eventCell setNeedsLayout];
                                           eventCell.patronageImage.contentMode = UIViewContentModeScaleAspectFit;
                                           [Event saveImageLogo:image eventId:event.ID];
                                           
                                       } failure:nil];
    } else {
        cell.patronageImage.image = [UIImage imageWithData:event.imgLogo];
        cell.patronageImage.contentMode = UIViewContentModeScaleAspectFit;
    }

    return cell;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"showEvent"]) {
        NSIndexPath *indexPath = nil;
        Event *event = [Event new];

        if (self.searchController.active) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            event = [self.eventsFiltered objectAtIndex:indexPath.row];
        } else {
            indexPath = [self.tableView indexPathForSelectedRow];
            event = [self.listEvent objectAtIndex:indexPath.row];
        }

        ShowEventViewController * desinateViewController = [segue destinationViewController];
        [desinateViewController setEvent:event];
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self updateSearchResultsForSearchController:self.searchController];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    [self searchForText:searchString];
    [self.tableView reloadData];
}


- (void)searchForText:(NSString *)searchText
{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title contains[c] %@",searchText];
    
    self.eventsFiltered = [NSMutableArray arrayWithArray:[self.listEvent filteredArrayUsingPredicate:predicate]];
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

#pragma mark - Logout
-(IBAction)logout:(id)sender {
    [User logout];
    [self performSegueWithIdentifier:@"showSignup" sender:self];
}

#pragma mark - Other methods Table View

-(void) configureTableView {
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80.0;
}

-(void)configureUISearchController {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    // No search results controller to display the search results in the current view
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    self.searchController.searchBar.delegate = self;
    
    self.searchController.searchBar.tintColor = [UIColor colorWithRed:(123.0/255.0) green:(191.0/255.0) blue:(178.0/255.0) alpha:1.0];
    
    [self.searchController.searchBar setBarTintColor:[UIColor colorWithRed:(123.0/255.0) green:(191.0/255.0) blue:(178.0/255.0) alpha:0.91]];
    
    [self.searchController.searchBar setTintColor:[UIColor colorWithRed:(109.0/255.0) green:(157.0/255.0) blue:(150.0/255.0) alpha:1.0]];
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    self.definesPresentationContext = NO;
    
    [self.searchController.searchBar sizeToFit];
}
@end