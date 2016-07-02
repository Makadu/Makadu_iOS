//
//  TalkFavoriteListTableViewController.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 6/6/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "TalkFavoriteListTableViewController.h"

#import "Localytics.h"

#import "TalkTableViewCell.h"
#import "TalkViewController.h"
#import "QuestionViewController.h"
#import "PollViewController.h"

#import "PollTalkTableViewCell.h"

#import "TalkDAO.h"
#import "Connection.h"
#import "Messages.h"

#import "DateFormatter.h"

#import "UIRefreshControl+AFNetworking.h"
#import "UIAlertView+AFNetworking.h"

@interface TalkFavoriteListTableViewController ()

@property (nonatomic, strong) NSArray * listTalk;
@property (nonatomic, strong) NSArray * listDateTalk;
@property (nonatomic, strong) NSIndexPath *indexPathSelected;
@property (nonatomic, strong) Event * event;
@property (nonatomic, strong) Talk * talkSelected;
@property (nonatomic, weak) IBOutlet UIButton *favoriteButton;

@end

@implementation TalkFavoriteListTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showEventViewController = (ShowEventViewController *)self.tabBarController;
    self.showEventViewController.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.translucent = NO;
    self.event = self.showEventViewController.event;
    
    self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"talk", nil);
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor lightGrayColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(getLatestTalks) forControlEvents:UIControlEventValueChanged];
    
    [self configureTableView];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    [Localytics tagScreen:@"Talk List"];
    [self fetchTalks];
    
    self.indexPathSelected = nil;
}

#pragma mark - fetch

-(void)fetchTalks {
    Talk *talk = [Talk new];
    self.listTalk = [talk loadFavoritiesTalks:self.event.ID];
    [self.tableView reloadData];
}

#pragma mark - Update Talks

- (void)getLatestTalks
{
    [self fetchTalks];
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
    
    if ([self.listTalk count] > 0) {
        self.tableView.backgroundView = nil;
        return [self.listTalk count];
    } else {
        UILabel * messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        messageLabel.text = NSLocalizedString(@"no_favorite_talks_yet", nil);
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        messageLabel.tag = 3000;
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return 0;
}

#pragma mark - Table view delagate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString * cellEvent = @"listTalkCell";
    static NSString * pollCell = @"pollCell";
    
    UIImage * imageNormal = [UIImage imageNamed:@"star_empty.png"];
    UIImage * imageSelected = [UIImage imageNamed:@"star_selected.png"];
    
    Talk * talk = [self.listTalk objectAtIndex:indexPath.row];
    
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

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 17;
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"talkSegue"]) {
        NSIndexPath *indexPath;
        if (self.indexPathSelected != nil) {
            indexPath = self.indexPathSelected;
        } else {
            indexPath = [self.tableView indexPathForSelectedRow];
        }
        
        TalkViewController *talkViewController = [segue destinationViewController];
        
        Talk * talk = [self.listTalk objectAtIndex:indexPath.row];
        [talkViewController setTalk:talk];
        [talkViewController setEvent:self.event];
        
    } else if ([segue.identifier isEqualToString:@"addQuestionSegue"]) {
        
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        QuestionViewController *questionViewController = [segue destinationViewController];
        self.indexPathSelected = [self.tableView indexPathForRowAtPoint:buttonPosition];
        
        Talk * talk = [self.listTalk objectAtIndex:self.indexPathSelected.row];
        [questionViewController setTalk:talk];
        [questionViewController setEvent:self.event];
    }
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
    
    [Localytics tagScreen:@"Tap Favorites"];
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    self.indexPathSelected = [self.tableView indexPathForRowAtPoint:buttonPosition];
    Talk * talk = [self.listTalk objectAtIndex:self.indexPathSelected.row];
    [talk toggleFavorite:NO];
    [self fetchTalks];
}

- (IBAction)tapDownload:(id)sender {
    if (([self.event.eventType isEqualToString:@"private"] && [Event eventSavePassword:self.event]) || ([self.event.eventType isEqualToString:@"Publico"] || [self.event.eventType isEqualToString:@"Oculto"]) || [self.event isFavorite]) {
        
        [Localytics tagScreen:@"Tap Download"];
    
        if([Connection existConnection]) {
            CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
            self.indexPathSelected = [self.tableView indexPathForRowAtPoint:buttonPosition];
        
            Talk * talk = [self.listTalk objectAtIndex:self.indexPathSelected.row];
        
            User *user = [User currentUser];
        
            [Talk downloadMaterial:user.userName eventId:talk.eventId talkId:talk.ID withCompletitionBlock:^(AFHTTPRequestOperation * operation, id responseObject){
            
                if(responseObject[@"result"] && [responseObject[@"result"] isEqualToString:@"link enviado"]) {
                    [Messages successMessageWithTitle:nil andMessage:[NSString stringWithFormat:NSLocalizedString(@"sent_email_when_exist_material", nil), user.email]];
                } else {
                    [Messages successMessageWithTitle:nil andMessage:[NSString stringWithFormat:NSLocalizedString(@"sent_email_when_available", nil), user.email]];
                }
            
            } andFailBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
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

- (IBAction)tapQuestion:(id)sender {
    
    if (([self.event.eventType isEqualToString:@"private"] && [Event eventSavePassword:self.event]) || ([self.event.eventType isEqualToString:@"Publico"] || [self.event.eventType isEqualToString:@"Oculto"]) || [self.event isFavorite]) {
        [Localytics tagScreen:@"Tap Question"];
    
        if ([Connection existConnection]) {
            CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
            self.indexPathSelected = [self.tableView indexPathForRowAtPoint:buttonPosition];
        
            [self performSegueWithIdentifier:@"addQuestionSegue" sender:sender];
            [self performSegueWithIdentifier:@"talkSegue" sender:nil];
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

- (IBAction)tapPoll:(id)sender {
    
    if (([self.event.eventType isEqualToString:@"private"] && [Event eventSavePassword:self.event]) || ([self.event.eventType isEqualToString:@"Publico"] || [self.event.eventType isEqualToString:@"Oculto"]) || [self.event isFavorite]) {
        
        [Localytics tagScreen:@"Tap Question"];
        
        if ([Connection existConnection]) {
            CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
            self.indexPathSelected = [self.tableView indexPathForRowAtPoint:buttonPosition];
            
            Talk * talk = [self.listTalk objectAtIndex:self.indexPathSelected.row];
            
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

#pragma mark - Other methods Table View

-(void) configureTableView {
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 117.0;
}
@end