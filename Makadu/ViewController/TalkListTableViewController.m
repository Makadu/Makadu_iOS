//
//  TalkListTableViewController.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/26/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "TalkListTableViewController.h"
#import "Localytics.h"

#import "TalkTableViewCell.h"
#import "TalkViewController.h"
#import "QuestionViewController.h"
#import "PollViewController.h"

#import "PollTalkTableViewCell.h"
#import "PaperService.h"

#import "DateFormatter.h"
#import "Connection.h"
#import "Messages.h"

#import "UIRefreshControl+AFNetworking.h"
#import "UIAlertView+AFNetworking.h"

@interface TalkListTableViewController ()

@property (nonatomic, strong) NSArray * listTalk;
@property (nonatomic, strong) NSArray * listDateTalk;
@property (strong, nonatomic) NSArray *talksNoFiltered;
@property (strong, nonatomic) NSMutableArray *talksFiltered;
@property (nonatomic, strong) NSIndexPath *indexPathSelected;

@property (nonatomic, strong) Event * event;

@property (nonatomic) BOOL isPositionTable;

@property (strong, nonatomic) UISearchController *searchController;

@end

@implementation TalkListTableViewController

- (void)reload:(__unused id)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [MRProgressOverlayView showOverlayAddedTo:self.view title:NSLocalizedString(@"loading_programming", nil) mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
    
    NSURLSessionTask *task = [Talk getTalksByEvent:self.event.ID block:^(NSArray *talks, NSError *error) {
        
        [MRProgressOverlayView dismissAllOverlaysForView:self.view animated:YES];
        
        if (!error) {
            [self retriveLocal];
        }
    }];
    [self.refreshControl setRefreshingWithStateOfTask:task];
}

- (void)retriveLocal {
    
    self.listTalk = [Talk retrieveTalkByEvent:self.event.ID];
    self.talksNoFiltered = [Talk retrieveTalkByEvent:self.event.ID];
    NSArray *talkDatas = [self sortedDataWithDictionary:[self groupedTalk]];
    self.listTalk = talkDatas;
    self.listDateTalk = talkDatas;
    self.indexPathSelected = nil;
    
    [self.tableView reloadData];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showEventViewController = (ShowEventViewController *)self.tabBarController;
    self.showEventViewController.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.translucent = NO;
    self.event = self.showEventViewController.event;
    
    self.listTalk = @[];
    
    self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"talk", nil);
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 100.0f)];
    [self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    [self.tableView.tableHeaderView addSubview:self.refreshControl];
    
    [self configureUISearchController];
    
    [self configureTableView];
    
    if ([Talk existDataInDataBase:self.event.ID talkId:nil]) {
        [self retriveLocal];
    } else {
        [self reload:nil];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    [Localytics tagEvent:@"Talk List" attributes:@{@"Username" : [User currentUser].userName, @"Event:" : self.event.title }];
    
    self.indexPathSelected = nil;
    
    self.isPositionTable = NO;
    
    [self.tableView reloadData];
    
    self.indexPathSelected = nil;
    
}

- (void)didChangePreferredContentSize:(NSNotification *)notification
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.searchController.active) {
        return 1;
    } else  {
        if ([self.listDateTalk count] > 0) {
            return [self.listDateTalk count];
        } else {
            if (![Connection existConnection]) {
                UILabel * messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
                messageLabel.text = NSLocalizedString(@"unable_load_data", nil);
                messageLabel.textColor = [UIColor blackColor];
                messageLabel.numberOfLines = 0;
                messageLabel.textAlignment = NSTextAlignmentCenter;
                messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
                messageLabel.tag = 3000;
                [messageLabel sizeToFit];
                
                self.tableView.backgroundView = messageLabel;
            }
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
    }
    return 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchController.active) {
        return [self.talksFiltered count];
    } else {
        return [[self.listTalk objectAtIndex:section][@"group"] count];
    }
}

#pragma mark - Table view delagate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString * cellEvent = @"listTalkCell";
    static NSString * pollCell = @"pollCell";
    
    Talk * talk = [Talk new];
    if (self.searchController.active) {
        talk = [self.talksFiltered objectAtIndex:indexPath.row];
    } else {
        talk = [[self.listTalk objectAtIndex:indexPath.section][@"group"] objectAtIndex:indexPath.row];
    }
    
    UIImage * imageNormal = [UIImage imageNamed:@"star_empty.png"];
    UIImage * imageSelected = [UIImage imageNamed:@"star_selected.png"];
    
    if (talk.interactive) {
        PollTalkTableViewCell *cell = (PollTalkTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:pollCell];
        
        if (cell == nil) {
            cell = [[PollTalkTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:pollCell];
        }
        
        [cell.btnFavorite setImage:[self imageWithImage:imageNormal scaledToSize:CGSizeMake(25, 25)]forState:UIControlStateNormal];
        [cell.btnFavorite setImage:[self imageWithImage:imageSelected scaledToSize:CGSizeMake(25, 25)] forState:UIControlStateSelected];
        
        if(indexPath.row % 2 == 0) {
            cell.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1];
        } else {
            cell.backgroundColor = [UIColor whiteColor];
        }
        
        cell.titleAndHourlabel.text = [NSString stringWithFormat:@"%@ %@", [DateFormatter formateHourBrazilian:talk.startTime], talk.title];
        [cell.titleAndHourlabel sizeToFit];
        cell.localAndDuration.text = [NSString stringWithFormat:@"%@ - %@ às %@ \n\n %@", talk.room, [DateFormatter formateHourBrazilian:talk.startTime], [DateFormatter formateHourBrazilian:talk.endTime], talk.speakers];
        
        [cell.localAndDuration sizeToFit];
        
        cell.btnFavorite.backgroundColor = cell.backgroundColor;
        cell.btnDownload.backgroundColor = cell.backgroundColor;
        cell.btnQuestion.backgroundColor = cell.backgroundColor;
        
        cell.btnFavorite.tag = indexPath.row;
        
        cell.btnFavorite.selected = [talk isFavorite];
        
        cell.btnDownload.hidden = !talk.downloads;
        cell.btnQuestion.hidden = !talk.questions;
        cell.btnFavorite.hidden = !talk.favorite;
        
        return cell;
        
    } else {
        
        TalkTableViewCell *cell = (TalkTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellEvent];
        
        if (cell == nil) {
            cell = [[TalkTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellEvent];
        }
        
        [cell.btnFavorite setImage:[self imageWithImage:imageNormal scaledToSize:CGSizeMake(25, 25)]forState:UIControlStateNormal];
        [cell.btnFavorite setImage:[self imageWithImage:imageSelected scaledToSize:CGSizeMake(25, 25)] forState:UIControlStateSelected];
        
        if(indexPath.row % 2 == 0) {
            cell.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1];
        } else {
            cell.backgroundColor = [UIColor whiteColor];
        }
        
        cell.titleAndHourlabel.text = [NSString stringWithFormat:@"%@ %@", [DateFormatter formateHourBrazilian:talk.startTime], talk.title];
        [cell.titleAndHourlabel sizeToFit];
        cell.localAndDuration.text = [NSString stringWithFormat:@"%@ - %@ às %@ \n\n %@", talk.room, [DateFormatter formateHourBrazilian:talk.startTime], [DateFormatter formateHourBrazilian:talk.endTime], talk.speakers];
        
        [cell.localAndDuration sizeToFit];
        
        cell.btnFavorite.backgroundColor = cell.backgroundColor;
        cell.btnDownload.backgroundColor = cell.backgroundColor;
        cell.btnQuestion.backgroundColor = cell.backgroundColor;
        
        cell.btnFavorite.tag = indexPath.row;
        
        cell.btnFavorite.selected = [talk isFavorite];
        
        cell.btnDownload.hidden = !talk.downloads;
        cell.btnQuestion.hidden = !talk.questions;
        cell.btnFavorite.hidden = !talk.favorite;
        
        return cell;
    }
    return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.searchController.active) {
        return nil;
    } else {
        UIView * header = [[UIView alloc] init];
        UILabel * lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, [UIScreen mainScreen].bounds.size.width, 18)];
        lblHeader.text = [self.listDateTalk objectAtIndex:section][@"date"];
        lblHeader.textColor = [UIColor whiteColor];
        lblHeader.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0f];
        lblHeader.textAlignment = NSTextAlignmentCenter;
        [header addSubview:lblHeader];
        
        header.backgroundColor = [UIColor colorWithRed:(33.0/255.0) green:(145.0/255.0) blue:(114.0/255.0) alpha:1];
        
        return header;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 32;
}


-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        
        if(!self.isPositionTable) {
            [self setTablePosition];
            self.isPositionTable = YES;
        }
    }
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *indexPath = nil;
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *cell = (UITableViewCell *)sender;
        indexPath = [self.tableView indexPathForCell:cell];
    } else {
        UIButton *button = (UIButton *)sender;
        UIView *contentView = button.superview;
        UITableViewCell *cell = (UITableViewCell *)contentView.superview;
        indexPath = [self.tableView indexPathForCell:cell];
    }
    
    Talk * talk = [Talk new];
    if (self.searchController.active) {
        talk = [self.talksFiltered objectAtIndex:indexPath.row];
    } else {
        talk = [[self.listTalk objectAtIndex:indexPath.section][@"group"] objectAtIndex:indexPath.row];
    }
    
    if ([segue.identifier isEqualToString:@"talkSegue"]) {
        
        TalkViewController *talkViewController = [segue destinationViewController];
        [talkViewController setTalk:talk];
        [talkViewController setEvent:self.event];
        
    } else if ([segue.identifier isEqualToString:@"addQuestionSegue"]) {
        
        QuestionViewController *questionViewController = [segue destinationViewController];
        
        [questionViewController setTalk:talk];
        [questionViewController setEvent:self.event];
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


- (void)searchForText:(NSString *)searchText {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.title contains[c] %@ OR SELF.room contains[c] %@ or SELF.speakers contains[c] %@ ",searchText, searchText, searchText];
    
    self.talksFiltered = [NSMutableArray arrayWithArray:[self.talksNoFiltered filteredArrayUsingPredicate:predicate]];
}

#pragma mark - resize image

-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - Actions

- (IBAction)tapFavorite:(id)sender {
    
    if (([self.event.eventType isEqualToString:@"private"] && [Event eventSavePassword:self.event]) || ([self.event.eventType isEqualToString:@"Publico"] || [self.event.eventType isEqualToString:@"Oculto"]) || [self.event isFavorite]) {
        
        UIButton *button = (UIButton *)sender;
        
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        self.indexPathSelected = [self.tableView indexPathForRowAtPoint:buttonPosition];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag inSection:self.indexPathSelected.section];
        
        TalkTableViewCell * cell = (TalkTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        Talk *talk = nil;
        if (self.searchController.active) {
            talk = [self.talksFiltered objectAtIndex:self.indexPathSelected.row];
        } else {
            talk = [[self.listTalk objectAtIndex:self.indexPathSelected.section][@"group"] objectAtIndex:self.indexPathSelected.row];
        }
        
        [Localytics tagEvent:@"Tap Favorities" attributes:@{@"Username" : [User currentUser].userName, @"Event:" : self.event.title, @"Talk" : talk.title }];
        
        cell.btnFavorite.selected = ![talk isFavorite];
        [talk toggleFavorite:![talk isFavorite]];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:[NSString stringWithFormat:NSLocalizedString(@"password_to", nil)]
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                                              otherButtonTitles:NSLocalizedString(@"submit", nil), nil];
        alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
        [alert show];
    }
}

- (IBAction)tapQuestion:(id)sender {
    
    if (([self.event.eventType isEqualToString:@"private"] && [Event eventSavePassword:self.event]) || ([self.event.eventType isEqualToString:@"Publico"] || [self.event.eventType isEqualToString:@"Oculto"]) || [self.event isFavorite]) {
        
        [Localytics tagScreen:@"Tap Question"];
        
        if ([Connection existConnection]) {
            
            Talk *talk = nil;
            if (self.searchController.active) {
                talk = [self.talksFiltered objectAtIndex:self.indexPathSelected.row];
                self.searchController.navigationController.hidesBarsOnTap = YES;
            } else {
                talk = [[self.listTalk objectAtIndex:self.indexPathSelected.section][@"group"] objectAtIndex:self.indexPathSelected.row];
            }
            
            [Localytics tagEvent:@"Tap Question" attributes:@{@"Username" : [User currentUser].userName, @"Event:" : self.event.title, @"Talk" : talk.title }];
            
            [self performSegueWithIdentifier:@"addQuestionSegue" sender:sender];
            [self performSegueWithIdentifier:@"talkSegue" sender:sender];
        } else {
            [Messages failMessageWithTitle:nil andMessage:NSLocalizedString(@"no_internet_connection", nil)];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:[NSString stringWithFormat:NSLocalizedString(@"password_to", nil)]
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                                              otherButtonTitles:NSLocalizedString(@"submit", nil), nil];
        alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
        [alert show];
    }
}

- (IBAction)tapDownload:(id)sender {
    
    if (([self.event.eventType isEqualToString:@"private"] && [Event eventSavePassword:self.event]) || ([self.event.eventType isEqualToString:@"Publico"] || [self.event.eventType isEqualToString:@"Oculto"]) || [self.event isFavorite]) {
        
        [Localytics tagScreen:@"Tap Download"];
        
        if([Connection existConnection]) {
            CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
            self.indexPathSelected = [self.tableView indexPathForRowAtPoint:buttonPosition];
            
            Talk *talk = nil;
            if (self.searchController.active) {
                talk = [self.talksFiltered objectAtIndex:self.indexPathSelected.row];
            } else {
                talk = [[self.listTalk objectAtIndex:self.indexPathSelected.section][@"group"] objectAtIndex:self.indexPathSelected.row];
            }
            
            User *user = [User currentUser];
            
            [Talk downloadMaterial:user.userName eventId:talk.eventId talkId:talk.ID withCompletitionBlock:^(AFHTTPRequestOperation * operation, id responseObject){
                
                if(responseObject[@"result"] && [responseObject[@"result"] isEqualToString:@"link enviado"]) {
                    [Messages successMessageWithTitle:nil andMessage:[NSString stringWithFormat:NSLocalizedString(@"sent_email_when_exist_material", nil), user.email]];
                } else {
                    [Messages successMessageWithTitle:nil andMessage:[NSString stringWithFormat:NSLocalizedString(@"sent_email_when_available", nil), user.email]];
                }
                
                [Localytics tagEvent:@"Tap Download" attributes:@{@"Username" : [User currentUser].userName, @"Event:" : self.event.title, @"Talk" : talk.title }];
                
                
                
            } andFailBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                [Localytics tagEvent:@"Tap Download Fail" attributes:@{@"Username" : [User currentUser].userName, @"Event:" : self.event.title, @"Talk" : talk.title, @"Error" : error.localizedDescription}];
                
                [Messages failMessageWithTitle:nil andMessage:NSLocalizedString(@"no_internet_connection", nil)];
            }];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:[NSString stringWithFormat:NSLocalizedString(@"password_to", nil)]
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                                              otherButtonTitles:NSLocalizedString(@"submit", nil), nil];
        alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
        [alert show];
    }
}


- (IBAction)tapPoll:(id)sender {
    
    if (([self.event.eventType isEqualToString:@"private"] && [Event eventSavePassword:self.event]) || ([self.event.eventType isEqualToString:@"Publico"] || [self.event.eventType isEqualToString:@"Oculto"]) || [self.event isFavorite]) {
        
        [Localytics tagScreen:@"Tap Question"];
        
        if ([Connection existConnection]) {
            CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
            self.indexPathSelected = [self.tableView indexPathForRowAtPoint:buttonPosition];
            
            Talk *talk = [Talk new];
            if (self.searchController.active) {
                talk = [self.talksFiltered objectAtIndex:self.indexPathSelected.row];
            } else {
                talk = [[self.listTalk objectAtIndex:self.indexPathSelected.section][@"group"] objectAtIndex:self.indexPathSelected.row];
            }
            
            [Localytics tagEvent:@"Tap Question" attributes:@{@"Username" : [User currentUser].userName, @"Event:" : self.event.title, @"Talk" : talk.title }];
            
            PollViewController *pollViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PollViewController"];
            [pollViewController setTalk:talk];
            [self.navigationController pushViewController:pollViewController animated:YES];
            
        } else {
            [Messages failMessageWithTitle:nil andMessage:NSLocalizedString(@"no_internet_connection", nil)];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:[NSString stringWithFormat:NSLocalizedString(@"password_to", nil)]
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                                              otherButtonTitles:NSLocalizedString(@"submit", nil), nil];
        alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
        [alert show];
    }
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        if([self.event.password isEqualToString:[alertView textFieldAtIndex:0].text]) {
            [Event savePasswordEvent:@[self.event]];
            [Messages successMessageWithTitle:nil andMessage:NSLocalizedString(@"success_saved_password", nil)];
        } else
            [Messages failMessageWithTitle:nil andMessage:NSLocalizedString(@"fail_saved_password", nil)];
    }
}

#pragma mark - Support Methods
-(int)discoveryIndex:(Talk *)talk {
    
    for (int i = 0; i < self.listDateTalk.count; i++) {
        if( [self.listDateTalk[i][@"date"] isEqualToString:[self formettedDateToDate:talk.startTime]]) {
            return i;
        }
    }
    
    return -1;
}

-(NSString *)formettedDateToDate:(NSString *)date {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:date];
    
    NSString *dateString = [formatter stringFromDate:dateFromString];
    
    return dateString;
}

-(NSDictionary *)groupedTalk {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    // Sparse dictionary, containing keys for "days with posts"
    NSMutableDictionary *daysWithTalks = [NSMutableDictionary dictionary];
    [self.listTalk enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSString *aDateString = ((Talk *)obj).startTime;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"];
        NSDate *dateFromString = [[NSDate alloc] init];
        dateFromString = [dateFormatter dateFromString:aDateString];
        
        
        NSString *dateString = [formatter stringFromDate:dateFromString];
        NSMutableArray *talks = [daysWithTalks objectForKey: dateString];
        if (talks == nil || (id)talks == [NSNull null])
        {
            talks = [NSMutableArray arrayWithCapacity:[self.listTalk count]];
            [daysWithTalks setObject:talks forKey: dateString];
        }
        [talks addObject:obj];
    }];
    
    return daysWithTalks;
}

-(NSArray *)sortedDataWithDictionary:(NSDictionary *)data {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    
    // Sort Dictionary Keys by Date
    NSArray *unsortedSectionTitles = [data allKeys];
    NSArray *sortedSectionTitles = [unsortedSectionTitles sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDate *date1 = [formatter dateFromString:obj1];
        NSDate *date2 = [formatter dateFromString:obj2];
        return [date1 compare:date2];
    }];
    
    NSMutableArray *sortedData = [NSMutableArray arrayWithCapacity:data.count];
    
    // Put Data into correct format:
    [sortedSectionTitles enumerateObjectsUsingBlock:^(NSString *dateString, NSUInteger idx, BOOL *stop) {
        NSArray *group = data[dateString];
        
        NSDictionary *dictionary = @{ @"date":dateString,
                                      @"group":group };
        [sortedData addObject:dictionary];
    }];
    
    return sortedData;
}

-(void)setTablePosition {
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd/MM/yyyy"];
    NSDate *now = [[NSDate alloc] init];
    NSString *dateNow = [format stringFromDate:now];
    
    for(int i=0; i < self.listDateTalk.count; i++) {
        if([dateNow isEqualToString:[self.listDateTalk[i] objectForKey:@"date"]]) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:i];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
    }
}


#pragma mark - Other methods Table View

-(void)configureTableView {
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 177.0;
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