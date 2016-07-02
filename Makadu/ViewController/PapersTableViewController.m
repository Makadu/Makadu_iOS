//
//  PapersTableViewController.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 4/5/16.
//  Copyright © 2016 Madhava. All rights reserved.
//

#import "PapersTableViewController.h"
#import "PaperService.h"

#import "Paper.h"
#import "Connection.h"

#import "PaperTableViewCell.h"

#import "User.h"
#import "Localytics.h"

#import "UIRefreshControl+AFNetworking.h"
#import "UIAlertView+AFNetworking.h"

@interface PapersTableViewController () {

    NSMutableArray      *sectionTitleArray;
    NSMutableDictionary *sectionContentDict;
    NSMutableArray      *arrayForBool;
    
    NSMutableArray *papersFiltered;
    
    NSArray *listPaper;
}

@property (nonatomic, strong) Event * event;
@property (strong, nonatomic) UISearchController *searchController;

@end

@implementation PapersTableViewController

- (void)reload:(__unused id)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [MRProgressOverlayView showOverlayAddedTo:self.view title:NSLocalizedString(@"loading_papers", nil) mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
    
    NSURLSessionTask * task = [PaperService getPapersWithEventId:self.event.ID block:^(NSArray *papers, NSError *error) {
        
        [MRProgressOverlayView dismissAllOverlaysForView:self.view animated:YES];
        
        if (!error) {
            [self retrive];
        }
    }];
    [self.refreshControl setRefreshingWithStateOfTask:task];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.showEventViewController = (ShowEventViewController *)self.tabBarController;
    self.showEventViewController.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.translucent = NO;
    self.event = self.showEventViewController.event;
    
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 100.0f)];
    [self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    [self.tableView.tableHeaderView addSubview:self.refreshControl];
    
    [self configureUISearchController];

    [Localytics tagEvent:@"Access Papers" attributes:@{@"Username" : [User currentUser].userName, @"Event" : self.event.title}];
    
    
    if (![Connection existConnection]) {
        [self retrive];
    } else {
        [self reload:nil];
    }
}

#pragma Mark - Setup

-(void)startSectionTitle {
    if (!sectionTitleArray) {
        sectionTitleArray = [NSMutableArray new];
        for (Paper *aPaper in listPaper) {
            [sectionTitleArray addObject:aPaper];
        }
    }
}

-(void)startStatusCells {
    if (!arrayForBool) {
        arrayForBool = [NSMutableArray new];
        for (int i = 0; i < listPaper.count; i++) {
            [arrayForBool addObject:[NSNumber numberWithBool:NO]];
        }
    }
}

-(void)startContentSection {
    if (!sectionContentDict) {
        sectionContentDict  = [[NSMutableDictionary alloc] init];
        for (Paper *aPaper in listPaper) {
            [sectionContentDict setValue:aPaper forKey:aPaper.title];
        }
    }
}

-(void)retrive {
    listPaper = [self sortPapersByReference:[Paper retrivePapers:self.event.ID]];
    [self startSectionTitle];
    [self startStatusCells];
    [self startContentSection];
    [self.tableView reloadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.searchController.active) {
        return [papersFiltered count];
    } else {
        if (sectionTitleArray.count > 0) {
            self.tableView.backgroundView = nil;
            return [sectionTitleArray count];
        } else {
            UILabel * messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
            messageLabel.text = NSLocalizedString(@"no_papers_yet", nil);
            messageLabel.textColor = [UIColor blackColor];
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = NSTextAlignmentCenter;
            messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
            messageLabel.tag = 3000;
            [messageLabel sizeToFit];
            
            self.tableView.backgroundView = messageLabel;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
    }
    
    return 0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView              = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    headerView.tag                  = section;
    headerView.backgroundColor      = [UIColor whiteColor];
    UILabel *headerString           = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, self.view.frame.size.width-50, 50)];
    
    BOOL manyCells                  = [[arrayForBool objectAtIndex:section] boolValue];
   
    headerString.numberOfLines = 0;
    headerString.lineBreakMode = NSLineBreakByTruncatingTail;
    
    headerString.text = [NSString stringWithFormat:@"%@ - %@",((Paper *)[sectionTitleArray objectAtIndex:section]).reference, ((Paper *)[sectionTitleArray objectAtIndex:section]).title];
    
    headerString.textColor = [UIColor whiteColor];
    headerString.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0f];
    headerString.textAlignment = NSTextAlignmentLeft;
    [headerView addSubview:headerString];
    
    headerView.backgroundColor = [UIColor colorWithRed:(33.0/255.0) green:(145.0/255.0) blue:(114.0/255.0) alpha:1];
    
    UITapGestureRecognizer  *headerTapped   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionHeaderTapped:)];
    [headerView addGestureRecognizer:headerTapped];
    
    //up or down arrow depending on the bool
    UIImageView *upDownArrow        = [[UIImageView alloc] initWithImage:manyCells ? [UIImage imageNamed:@"ic_remove_white_36pt"] : [UIImage imageNamed:@"ic_add_white_36pt"]];
    upDownArrow.autoresizingMask    = UIViewAutoresizingFlexibleLeftMargin;
    upDownArrow.frame               = CGRectMake(self.view.frame.size.width-40, 10, 30, 30);
    [headerView addSubview:upDownArrow];
    
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footer  = [[UIView alloc] initWithFrame:CGRectZero];
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedSectionHeaderHeight = 50;
    return self.tableView.sectionHeaderHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([[arrayForBool objectAtIndex:indexPath.section] boolValue]) {
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 50.0;
        return self.tableView.rowHeight;
    }
    return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"paperCell";
    
    PaperTableViewCell *cell = (PaperTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[PaperTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    BOOL manyCells  = [[arrayForBool objectAtIndex:indexPath.section] boolValue];
    
    if (manyCells) {
        
        Paper *aPaper = [Paper new];
        if (self.searchController.active) {
            aPaper = [papersFiltered objectAtIndex:indexPath.section];
        } else {
            aPaper = [sectionContentDict valueForKey:((Paper *)[sectionTitleArray objectAtIndex:indexPath.section]).title];
        }
        cell.title.text = aPaper.title;
        cell.abstract.text = aPaper.abstract;
        cell.authors.text = aPaper.authors;
    }
    
    return cell;
}

- (void)didChangePreferredContentSize:(NSNotification *)notification
{
    [self.tableView reloadData];
}

#pragma mark - gesture tapped
- (void)sectionHeaderTapped:(UITapGestureRecognizer *)gestureRecognizer {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:gestureRecognizer.view.tag];
    if (indexPath.row == 0) {
        BOOL collapsed  = [[arrayForBool objectAtIndex:indexPath.section] boolValue];
        collapsed       = !collapsed;
        [arrayForBool replaceObjectAtIndex:indexPath.section withObject:[NSNumber numberWithBool:collapsed]];
        
        //reload specific section animated
        NSRange range   = NSMakeRange(indexPath.section, 1);
        NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.tableView reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma Mark - UISearchController

-(void)configureUISearchController {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleProminent;
    
    self.searchController.searchBar.delegate = self;
    
    self.searchController.searchBar.tintColor = [UIColor colorWithRed:(123.0/255.0) green:(191.0/255.0) blue:(178.0/255.0) alpha:1.0];
    
    [self.searchController.searchBar setBarTintColor:[UIColor colorWithRed:(123.0/255.0) green:(191.0/255.0) blue:(178.0/255.0) alpha:0.91]];
    
    [self.searchController.searchBar setTintColor:[UIColor colorWithRed:(109.0/255.0) green:(157.0/255.0) blue:(150.0/255.0) alpha:1.0]];
    
    self.tableView.tableHeaderView = self.searchController.searchBar;

    
    self.definesPresentationContext = YES;
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

- (void)searchForText:(NSString *)searchText {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.title contains[c] %@ or SELF.authors contains[c] %@",searchText, searchText];
    
    papersFiltered = [NSMutableArray arrayWithArray:[listPaper filteredArrayUsingPredicate:predicate]];
}

#pragma Mark - Sort Papers By Reference

-(NSArray *)sortPapersByReference:(NSArray *)listPapers {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"reference" ascending:YES];
    return [listPapers sortedArrayUsingDescriptors:@[sort]];
}

@end
