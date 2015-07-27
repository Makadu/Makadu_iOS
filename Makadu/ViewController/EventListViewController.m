//
//  EventListViewController.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/25/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "EventListViewController.h"
#import "EventDAO.h"
#import "Event.h"
#import "EventTableViewCell.h"
#import "ShowEventViewController.h"
#import "Connection.h"
#import "Localytics.h"

@interface EventListViewController ()

@property (strong,nonatomic) NSArray *listEvent;
@property (strong,nonatomic) NSMutableArray *eventsFiltered;

@property IBOutlet UISearchBar *eventSearchBar;


@end

@implementation EventListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor lightGrayColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(getLatestEvents) forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [Localytics tagScreen:@"Event List"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    PFUser *currentUser = [PFUser currentUser];
    if (![currentUser isAuthenticated]) {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
    
    [self fetchAllEvents];
    
    self.eventsFiltered = [NSMutableArray arrayWithCapacity:[self.listEvent count]];
}

- (void)getLatestEvents
{
    [self fetchAllEvents];
}

- (void)reloadData
{
    // Reload table data
    [self.tableView reloadData];
    
    if (self.refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictonary = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictonary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        [self.refreshControl endRefreshing];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (tableView == self.searchDisplayController.searchResultsTableView) {
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
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        event = [self.eventsFiltered objectAtIndex:indexPath.row];
    } else {
        event = [self.listEvent objectAtIndex:indexPath.row];
    }
    
    cell.namelabel.text = event.name;
    cell.cityLabel.text = event.city;
    cell.dateLabel.text = [NSString stringWithFormat:@"%@ a %@",event.startDate, event.endDate];
    
    PFFile *patronage = event.fileImgPatronage;
    cell.patronageImage.image = [UIImage imageNamed:@"makadu.png"];
    cell.patronageImage.file = patronage;
    [cell.patronageImage loadInBackground];
    
    event.imageLoaded = [self loadImage:event];
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Event * event = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        event = [self.eventsFiltered objectAtIndex:indexPath.row];
    } else {
        event = [self.listEvent objectAtIndex:indexPath.row];
    }
    
    CGFloat height = [EventTableViewCell calculateCellHeightWithName:event.name city:event.city date:[NSString stringWithFormat:@"%@ a %@",event.startDate, event.endDate] width:290];
    
    return height + 68;
}   


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showEvent"]) {
        NSIndexPath *indexPath = nil;
        Event *event = [Event new];
        
        if (self.searchDisplayController.active) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            event = [self.eventsFiltered objectAtIndex:indexPath.row];
        } else {
            indexPath = [self.tableView indexPathForSelectedRow];
            event = [self.listEvent objectAtIndex:indexPath.row];
        }

        ShowEventViewController * desinateViewController = [segue destinationViewController];
        [desinateViewController setEvent:event];
    }
}


#pragma mark - fetchEvents
-(void)fetchAllEvents {
    [EventDAO fetchAllEvents: ^(NSArray * objects) {
        self.listEvent = objects;
        [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    } failure:^(NSString * error) {
        NSLog(@"%@", error);
    }];
}

#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    
    [self.eventsFiltered removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@",searchText];
    self.eventsFiltered = [NSMutableArray arrayWithArray:[self.listEvent filteredArrayUsingPredicate:predicate]];
}

#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    return YES;
}


#pragma mark - Logout
-(IBAction)logout:(id)sender {
    [PFUser logOut];
    [self performSegueWithIdentifier:@"showLogin" sender:self];
}

#pragma mark - Other Methods

-(UIImage *)loadImage:(Event *)event {
    
    PFFile *sponsor = event.fileImgSponsor;
    PFImageView *sponsorImage = [PFImageView new];
    sponsorImage.image = [UIImage imageNamed:@"makadu.png"];
    sponsorImage.file = sponsor;
    [sponsorImage loadInBackground];
    
    return sponsorImage.image;
}

@end
