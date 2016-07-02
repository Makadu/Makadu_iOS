//
//  PollViewController.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 2/15/16.
//  Copyright © 2016 Madhava. All rights reserved.
//

#import "PollViewController.h"
#import "PollTableViewCell.h"

#import "PollService.h"

#import "MRProgressOverlayView.h"
#import "Messages.h"

#import "Poll.h"
#import "Answer.h"

#import "DateFormatter.h"

#import "PollService.h"
#import "User.h"
#import "Localytics.h"

#import "UIRefreshControl+AFNetworking.h"
#import "UIAlertView+AFNetworking.h"

@interface PollViewController ()

@property (nonatomic, weak) IBOutlet UILabel *questionLabel;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray * alphabet;
@property (nonatomic, strong) NSArray * responses;

@property (nonatomic, strong) PollTableViewCell *prototypeCell;
@property (nonatomic, strong) Answer *answerSelected;

@property (nonatomic, strong) IBOutlet UILabel * matchMinuteAndSecondsLabel;
@property (nonatomic, strong) IBOutlet UIButton * btnVote;

@property (nonatomic, weak) NSTimer *timer;

@property (nonatomic, strong) NSString * currentDate;
@property (nonatomic, strong) NSString * pollStarTime;
@property (nonatomic, strong) NSString * pollEndTime;

@property (nonatomic, strong) NSIndexPath * indexPathSelected;

@property (nonatomic, strong) Poll * poll;

@property double diff;

@end

@implementation PollViewController

- (void)reload:(__unused id)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [MRProgressOverlayView showOverlayAddedTo:self.view title:NSLocalizedString(@"loading_question", nil) mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
    
    NSURLSessionTask *task = [PollService getQuestionWithTalkId:self.talk.ID block:^(NSArray *questions, NSError *error){
        [MRProgressOverlayView dismissAllOverlaysForView:self.view animated:YES];
        if (!error) {
            
            self.poll = ((Poll *)[questions lastObject]);
            
            self.questionLabel.text = self.poll.question;
            
            self.alphabet = @[@"A)", @"B)",@"C)", @"D)", @"E)", @"F)",@"G)", @"H)", @"I)", @"J)", @"K)", @"L)", @"M)", @"N)", @"O)", @"P)", @"Q)", @"R", @"S", @"T)", @"U)", @"V)", @"X)", @"W)", @"Y)"];
            
            self.responses = self.poll.answers;
            
            self.currentDate = [DateFormatter currentDate:self.poll.currentTime];
            self.pollStarTime = self.poll.startTime;
            self.pollEndTime = self.poll.endTime;
            
            self.diff = [self getDateDifference];
            
            self.matchMinuteAndSecondsLabel.text = @"00 : 00";
            
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                        target:self
                                                        selector:@selector(countDownTimer) userInfo:nil repeats:YES];
            
            [self.tableView reloadData];
            
        } else {
            NSLog(@"Ocorreu um erro == %@", error.localizedDescription);
        }
        
    }];
    
    [UIAlertView showAlertViewForTaskWithErrorOnCompletion:task delegate:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureTableView];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Localytics tagEvent:@"Access Poll" attributes:@{@"Username" : [User currentUser].userName, @"Talk" : self.talk.title, @"Event_id" : self.talk.eventId}];
    
    
    [self.btnVote setEnabled:NO];
    
    [self reload:nil];
}


#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.responses.count;
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellPollIdentifier = @"responseCell";
    
    PollTableViewCell * cell = (PollTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellPollIdentifier];
    
    if(indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSIndexPath *oldIndex = [self.tableView indexPathForSelectedRow];
    
    [self.tableView cellForRowAtIndexPath:oldIndex].accessoryType = UITableViewCellAccessoryNone;
    [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    
    self.answerSelected = self.poll.answers[indexPath.row];
    
    [self.btnVote setEnabled:YES];
    
    self.indexPathSelected = indexPath;
    
    return indexPath;
}

#pragma mark - UITableView Support
-(void) configureTableView {
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80.0;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[PollTableViewCell class]])
    {
        PollTableViewCell *textCell = (PollTableViewCell *)cell;
        
        textCell.responseLabel.text = [NSString stringWithFormat:@"%@ %@", self.alphabet[indexPath.row], ((Answer *)self.responses[indexPath.row]).answer];
        
        textCell.responseLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    }
}

#pragma Mark - Countdown
- (void)countDownTimer {
    // my method which returns the differences between two dates in my case
    self.diff = self.diff - 1;
    
    int seconds  = fmod(self.diff, 60.0);
    int minutes  = fmod(trunc(self.diff / 60.0), 60.0);
    
    if([self currentDateGreaterThanPollStartTime] && [self currentDateLessThanPollEndTime] && self.diff > 0) {
        self.matchMinuteAndSecondsLabel.text = [NSString stringWithFormat:@"%02u : %02u", minutes, seconds];
    } else {
        [self.timer invalidate];
        self.timer = nil;
        [self.tableView cellForRowAtIndexPath:self.indexPathSelected].accessoryType = UITableViewCellAccessoryNone;
        [self showPopoverInstruction];
    }
}

- (double)getDateDifference {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *dateFromString = [[NSDate alloc] init];
    NSDate *now = nil;
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"];
    
    dateFromString = [dateFormatter dateFromString:self.pollEndTime];
    now = [dateFormatter dateFromString:[DateFormatter currentDate:self.currentDate]];
    
    double diff = [dateFromString timeIntervalSinceDate:now];
    return diff;
}
#pragma Mark - Validate Date

-(BOOL)currentDateGreaterThanPollStartTime {
    
    NSDateFormatter *datFormatter = [[NSDateFormatter alloc] init];
    [datFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"];
    
    NSDate* currentDate = [datFormatter dateFromString:self.currentDate];
    
    NSDate* startDate = [datFormatter dateFromString:self.pollStarTime];
    
    if ([currentDate compare:startDate] == NSOrderedDescending)  {
        return YES;
    } else if ([currentDate compare:startDate] == NSOrderedSame) {
        return YES;
    } else {
        return NO;
    }
    
    return NO;
}

-(BOOL)currentDateLessThanPollEndTime {
    
    NSDateFormatter *datFormatter = [[NSDateFormatter alloc] init];
    [datFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"];
    
    NSDate* currentDate = [datFormatter dateFromString:self.currentDate];
    
    NSDate* startDate = [datFormatter dateFromString:self.pollEndTime];
    
    if ([currentDate compare:startDate] == NSOrderedAscending) {
        return YES;
    }
    
    return NO;
}

-(NSDate *)convertStrCurrentDateInDate {
    
    NSDateFormatter *datFormatter = [[NSDateFormatter alloc] init];
    [datFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"];
    
    return [datFormatter dateFromString:self.currentDate];
}


#pragma Mark - Pop
- (void)showPopoverInstruction {
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PollInstructionViewController *pollInstructionViewController = [storyboard instantiateViewControllerWithIdentifier:@"pollInstructionIdentifier"];
    pollInstructionViewController.delegate = self;
    
    [self presentViewController:pollInstructionViewController animated:YES completion:nil];
}

-(void)goToTalks {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma Mark - Action
-(IBAction)tapVote:(id)sender {
    [PollService sendAnswerInteractive:self.talk.ID questionId:self.poll.ID aswerId:self.answerSelected.ID withCompletitionBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [Localytics tagEvent:@"Vote" attributes:@{@"Username" : [User currentUser].userName, @"Talk" : self.talk.title, @"Event_id" : self.talk.eventId, @"Question" : self.questionLabel.text}];
        
        [Messages successMessageWithTitle:@"Sucesso!" andMessage:@"Obrigado por votar!"];
        
    } andFailBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Messages failMessageWithTitle:nil andMessage:[NSString stringWithFormat:@"Error: %ld - %@", (long)error.code, error.localizedDescription]];
    }];
}

@end
