//
//  TalkViewController.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/27/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "TalkViewController.h"

#import "DateFormatter.h"
#import "Rating.h"
#import "Localytics.h"
#import "Speaker.h"
#import "QuestionDAO.h"
#import "TalkDAO.h"
#import "Connection.h"
#import "Messages.h"
#import "User.h"
#import "DateFormatter.h"

#import "TalkDescriptionTableViewCell.h"
#import "TalkSpeakerTableViewCell.h"
#import "TalkQuestionTableViewCell.h"
#import "QuestionViewController.h"

#import "UIRefreshControl+AFNetworking.h"
#import "UIAlertView+AFNetworking.h"

@interface TalkViewController ()

@property (nonatomic, strong) NSArray *listQuestions;
@property (nonatomic, strong) NSArray *listSpeaker;
@property (strong, nonatomic) NSNumber *ratingNote;
@property (strong, nonatomic) Rating *ratingSelf;

@property (weak, nonatomic) IBOutlet EDStarRating *starRating;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *localLabel;
@property (nonatomic, weak) IBOutlet UIButton * questionButton;
@property (nonatomic, weak) IBOutlet UIButton * downloadButton;
@property (weak, nonatomic) IBOutlet UIButton * favoriteButton;

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end

@implementation TalkViewController

#pragma mark - Data load

- (void)reloadSpeaker:(__unused id)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [MRProgressOverlayView showOverlayAddedTo:self.view title:NSLocalizedString(@"loading_speakers", nil) mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
    
    NSURLSessionTask *task = [Talk getTalkWithEventId:self.talk.eventId talkId:self.talk.ID block:^(NSArray *speakers, NSError *error) {
        if (!error) {
            
            [MRProgressOverlayView dismissAllOverlaysForView:self.view animated:YES];
            
            self.listSpeaker = speakers;
            [self.tableView reloadData];
        } else {
            NSLog(@"Ocorreu um erro");
        }
    }];
    
    [UIAlertView showAlertViewForTaskWithErrorOnCompletion:task delegate:nil];
}

-(void)reloadLocalSpeaker {
    self.listSpeaker = [Speaker retrieveByTalkId:self.talk.ID];
    [self.tableView reloadData];
}

- (void)reloadQuestion:(__unused id)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [MRProgressOverlayView showOverlayAddedTo:self.view title:NSLocalizedString(@"loading_question", nil) mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
    
    NSURLSessionTask *task = [Question getQuestionsByTalkAndEventId:self.talk.ID eventId:self.talk.eventId block:^(NSArray *questions, NSError *error) {
        if (!error) {
            
            [MRProgressOverlayView dismissAllOverlaysForView:self.view animated:YES];
            
            self.listQuestions = questions;
            [self.tableView reloadData];
        } else {
            NSLog(@"Ocorreu um erro");
        }
    }];
    
    [UIAlertView showAlertViewForTaskWithErrorOnCompletion:task delegate:nil];
}

-(void)reloadLocalQuestion {
    self.listQuestions = [Question retrieveByTalkId:self.talk.ID];
    [self.tableView reloadData];
}

- (void)reloadRating:(__unused id)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [MRProgressOverlayView showOverlayAddedTo:self.view title:NSLocalizedString(@"loading_rating", nil) mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
    
    NSURLSessionTask *task = [Rating getRatingByEvent:self.talk.eventId talkId:self.talk.ID block:^(NSArray *rating, NSError *error){
        if (!error) {
            self.ratingSelf = ((Rating *)[rating objectAtIndex:0]);
            
            [self startStarRating];
            
            [MRProgressOverlayView dismissAllOverlaysForView:self.view animated:YES];
            
        } else {
            NSLog(@"Ocorreu um erro");
            [MRProgressOverlayView dismissAllOverlaysForView:self.view animated:YES];
        }
    }];
    
    [UIAlertView showAlertViewForTaskWithErrorOnCompletion:task delegate:nil];
}

-(void)reloadLocalRating {
    self.ratingSelf.note = ((Rating *)[Rating getRating:self.talk.eventId]).note;
}

#pragma mark - verifications
-(void)fetchSpeakers {
    
    if (![Connection existConnection]) {
        [self reloadLocalSpeaker];
    } else {
        [self reloadSpeaker:nil];
    }
}

-(void)fetchQuestions {
    
    if (![Connection existConnection]) {
        [self reloadLocalQuestion];
    } else {
        [self reloadQuestion:nil];
    }
}

-(void)fetchRating {
    
    if (![Connection existConnection]) {
        [self reloadLocalRating];
    } else {
        [self reloadRating:nil];
    }
}

#pragma mark - cicle life
- (void)viewDidLoad {
    [super viewDidLoad];

    [self startStarRating];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    self.localLabel.text = [NSString stringWithFormat:@"%@ - %@ %@", self.talk.room, [DateFormatter formateDateBrazilianWithDiferentFormat:self.talk.startTime], [DateFormatter formateHourBrazilian:self.talk.startTime ]];

    UIImage * imageNormal = [UIImage imageNamed:@"star_empty.png"];
    UIImage * imageSelected = [UIImage imageNamed:@"star_selected.png"];

    [self.favoriteButton setImage:[self imageWithImage:imageNormal scaledToSize:CGSizeMake(25, 25)]forState:UIControlStateNormal];
    [self.favoriteButton setImage:[self imageWithImage:imageSelected scaledToSize:CGSizeMake(25, 25)] forState:UIControlStateSelected];
    self.tableView.rowHeight = 70.0f;
    
    self.favoriteButton.selected = [self.talk isFavorite];
    
    [self fetchSpeakers];
    [self fetchQuestions];
    [self fetchRating];
}

-(void)viewDidAppear:(BOOL)animated {
    
    [Localytics tagEvent:@"Talk Detail" attributes:@{@"Username" : [User currentUser].userName, @"Event:" : self.event.title, @"Talk" : self.talk.title }];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.titleLabel.text = self.talk.title;
    
    self.questionButton.titleLabel.text = NSLocalizedString(@"about_activity", nil);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}
    
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return [self.listSpeaker count];
        case 2:
            return [self.listQuestions count];
        default:
            return 0;
            break;
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        static NSString * scheduleDetailTableCell = @"talkCell";
        TalkDescriptionTableViewCell *cell = (TalkDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:scheduleDetailTableCell];
        
        cell.descriptionTextView.text = self.talk.talkDescription;
        
        return cell;
        
    } else if (indexPath.section == 1) {
        static NSString * scheduleDetailTableCell = @"talkSpeakerCell";
        
        TalkSpeakerTableViewCell *cell = (TalkSpeakerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:scheduleDetailTableCell];
        
        cell.speakerNameLabel.text = ((Speaker *)[self.listSpeaker objectAtIndex:indexPath.row]).name;
        cell.aboutSpeakerTextView.text = ((Speaker *)[self.listSpeaker objectAtIndex:indexPath.row]).about;
        
        return cell;
    } else if (indexPath.section == 2) {
        static NSString * scheduleDetailTableCell = @"talkQuestionCell";
        TalkQuestionTableViewCell *cell = (TalkQuestionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:scheduleDetailTableCell];
        
        Question *question = [self.listQuestions objectAtIndex:indexPath.row];
        
        cell.questionLabel.text = question.question;
        
        NSString * questioning = question.questioning;
        if (!questioning)
            questioning = @"";
        cell.questionigLabel.text = [NSString stringWithFormat:@"%@ %@", questioning, [DateFormatter formateHourBrazilian:question.date]];
        
        return cell;
    }
    return nil;
}

#pragma mark - Other methods Table View

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView * header = [[UIView alloc] init];
    UILabel * lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, [UIScreen mainScreen].bounds.size.width, 13)];
    
    lblHeader.textColor = [UIColor whiteColor];
    lblHeader.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13.0f];
    lblHeader.textAlignment = NSTextAlignmentCenter;
    [header addSubview:lblHeader];
    
    header.backgroundColor = [UIColor colorWithRed:(33.0/255.0) green:(145.0/255.0) blue:(114.0/255.0) alpha:1];
    
    switch (section) {
        case 0:
            lblHeader.text = NSLocalizedString(@"about_activity", nil);
            break;
        case 1:
            lblHeader.text = NSLocalizedString(@"about_Speaker", nil);
            break;
        case 2: {
            lblHeader.text = NSLocalizedString(@"questions", nil);
            UIButton * btnRefreshQuestion = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 40, -4, 32, 32)];
            [btnRefreshQuestion setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
            [btnRefreshQuestion addTarget:self action:@selector(fetchQuestions) forControlEvents:UIControlEventTouchUpInside];
            [header addSubview:btnRefreshQuestion];
        }
        default:
            break;
    }
    return header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return 140;
    } else if (indexPath.section == 1) {
        return 166;
    } else {
        Question * question = [self.listQuestions objectAtIndex:indexPath.row];
        CGFloat height = [TalkQuestionTableViewCell calculateCellHeightWithQuestion:question.question questioning:[NSString stringWithFormat:@"%@ %@", question.questioning, question.date] width:290];
        return height + 52;
    }
}


#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([Connection existConnection]) {
        if ([segue.identifier isEqualToString:@"addQuestionSegue"]) {
            QuestionViewController *questionViewController = [segue destinationViewController];
            [questionViewController setTalk:self.talk];
            [questionViewController setEvent:self.event];
        }
    } else {
        [Messages failMessageWithTitle:nil andMessage:NSLocalizedString(@"no_internet_connection", nil)];
    }
}


#pragma mark - stars
-(void)startStarRating {
    
    // Setup control using iOS7 tint Color
    self.starRating.backgroundColor  = [UIColor whiteColor];
    self.starRating.starImage = [UIImage imageNamed:@"star.png"];
    self.starRating.starHighlightedImage = [UIImage imageNamed:@"starhighlighted.png"];
    self.starRating.maxRating = 5.0;
    self.starRating.delegate = self;
    self.starRating.horizontalMargin = 12;
    self.starRating.editable = YES;
    self.starRating.rating = [self.ratingSelf.note floatValue];
    self.starRating.displayMode=EDStarRatingDisplayFull;
}

-(void)starsSelectionChanged:(EDStarRating *)control rating:(float)rating
{
    
    if (([self.event.eventType isEqualToString:@"private"] && [Event eventSavePassword:self.event]) || ([self.event.eventType isEqualToString:@"Publico"] || [self.event.eventType isEqualToString:@"Oculto"]) || [self.event isFavorite]) {
            self.ratingNote = [NSNumber numberWithFloat:rating];

    
    
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:[NSString stringWithFormat:NSLocalizedString(@"evaluation_of", nil)]
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                                          otherButtonTitles:NSLocalizedString(@"submit", nil), nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            alert.tag = 0;
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:[NSString stringWithFormat:NSLocalizedString(@"password_to", nil)]
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                                              otherButtonTitles:NSLocalizedString(@"submit", nil), nil];
        alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
        alert.tag = 1;
        [alert show];
    }
    
    
}

#pragma mark - Delegate AlertView

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (alertView.tag == 0) {
        
        if (buttonIndex == 1) {
            [Rating createNewRating:self.talk.eventId talkId:self.talk.ID value:[NSString stringWithFormat:@"%@", self.ratingNote] commentary:[alertView textFieldAtIndex:0].text withCompletitionBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [Localytics tagEvent:@"Tap Rating Success" attributes:@{@"Username" : [User currentUser].userName, @"Event:" : self.event.title, @"Talk" : self.talk.title, @"Rating" : self.ratingNote, @"Commetary" : [alertView textFieldAtIndex:0].text }];
                
            } andFailBlock:^(AFHTTPRequestOperation *operation, NSError * error) {
                
                [Localytics tagEvent:@"Tap Rating Fail" attributes:@{@"Username" : [User currentUser].userName, @"Event:" : self.event.title, @"Talk" : self.talk.title, @"Rating" : self.ratingNote, @"Commetary" : [alertView textFieldAtIndex:0].text, @"Error" : error.localizedDescription }];
            }];
        } else {
            self.starRating.rating = [self.ratingSelf.note floatValue];
        }
    } else {
        if (buttonIndex == 1) {
            if([self.event.password isEqualToString:[alertView textFieldAtIndex:0].text]) {
                [Event savePasswordEvent:@[self.event]];
                [Messages successMessageWithTitle:nil andMessage:NSLocalizedString(@"success_saved_password", nil)];
            } else
                [Messages failMessageWithTitle:nil andMessage:NSLocalizedString(@"fail_saved_password", nil)];
        }
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

- (IBAction)tapFavorite:(id)sender {
    if (([self.event.eventType isEqualToString:@"private"] && [Event eventSavePassword:self.event]) || ([self.event.eventType isEqualToString:@"Publico"] || [self.event.eventType isEqualToString:@"Oculto"]) || [self.event isFavorite]) {
        
        [Localytics tagEvent:@"Tap Favorities" attributes:@{@"Username" : [User currentUser].userName, @"Event:" : self.event.title, @"Talk" : self.talk.title }];

        self.favoriteButton.selected = ![self.talk isFavorite];
        [self.talk toggleFavorite:![self.talk isFavorite]];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:[NSString stringWithFormat:NSLocalizedString(@"password_to", nil)]
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                                              otherButtonTitles:NSLocalizedString(@"submit", nil), nil];
        alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
        alert.tag = 1;
        [alert show];
    }
}

- (IBAction)tapDownload:(id)sender {
    
    if (([self.event.eventType isEqualToString:@"private"] && [Event eventSavePassword:self.event]) || ([self.event.eventType isEqualToString:@"Publico"] || [self.event.eventType isEqualToString:@"Oculto"]) || [self.event isFavorite]) {

        if([Connection existConnection]) {
            
            User *user = [User currentUser];
            [Talk downloadMaterial:user.userName eventId:self.talk.eventId talkId:self.talk.ID withCompletitionBlock:^(AFHTTPRequestOperation * operation, id responseObject){
                
                [Localytics tagEvent:@"Tap Download" attributes:@{@"Username" : [User currentUser].userName, @"Event:" : self.event.title, @"Talk" : self.talk.title }];
                
                if(responseObject[@"result"] && [responseObject[@"result"] isEqualToString:@"link enviado"]) {
                    [Messages successMessageWithTitle:nil andMessage:[NSString stringWithFormat:NSLocalizedString(@"sent_email_when_exist_material", nil), user.email]];
                } else {
                    [Messages successMessageWithTitle:nil andMessage:[NSString stringWithFormat:NSLocalizedString(@"sent_email_when_available", nil), user.email]];
                }
                
            } andFailBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                [Messages failMessageWithTitle:nil andMessage:NSLocalizedString(@"no_internet_connection", nil)];
                
                [Localytics tagEvent:@"Tap Download" attributes:@{@"Username" : [User currentUser].userName, @"Event:" : self.event.title, @"Talk" : self.talk.title, @"Error" : error.localizedDescription }];
            }];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:[NSString stringWithFormat:NSLocalizedString(@"password_to", nil)]
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                                              otherButtonTitles:NSLocalizedString(@"submit", nil), nil];
        alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
        alert.tag = 1;
        [alert show];
    }
}

@end