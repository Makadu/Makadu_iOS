//
//  EvaluationTableViewController.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 4/10/16.
//  Copyright © 2016 Madhava. All rights reserved.
//

#import "EvaluationTableViewController.h"
#import <MRProgress/MRProgress.h>

#import "Connection.h"
#import "Evaluation.h"
#import "Feedback.h"
#import "Messages.h"

#import "Localytics.h"
#import "User.h"

#import "EvaluationService.h"

#import "EvaluationTableViewCell.h"

#import "UIRefreshControl+AFNetworking.h"
#import "UIAlertView+AFNetworking.h"

@interface EvaluationTableViewController ()

@property(nonatomic, strong) NSArray *listEvaluations;
@property(nonatomic, strong) NSArray *feedBacks;
@property(nonatomic, strong) NSIndexPath *editingIndexPath;


@end

@implementation EvaluationTableViewController

- (void)reload:(__unused id)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [MRProgressOverlayView showOverlayAddedTo:self.view title:NSLocalizedString(@"loading_programming", nil) mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
    
    [EvaluationService getEvaluationssWithEventId:self.eventId block:^(NSArray *evolutions, NSError *error) {
        
        [MRProgressOverlayView dismissAllOverlaysForView:self.view animated:YES];

        if (!error) {
            [self retriveLocal];
        }
    }];
}

- (void)retriveLocal {
    self.listEvaluations = [[NSArray alloc] initWithArray:[Evaluation retriveEvaluations:self.eventId]];
    [self.tableView reloadData];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"talk", nil);
    self.tableView.backgroundColor = [UIColor whiteColor];

    [self configureTableView];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [Localytics tagEvent:@"Access Evaluation" attributes:@{@"Username" : [User currentUser].userName, @"Event_id" : self.eventId}];
    
    if(![Connection existConnection]) {
        [self retriveLocal];
    } else {
        [self reload:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    if ([self.listEvaluations count] > 0) {
        return 1;
    } else {
        UILabel * messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        messageLabel.text = NSLocalizedString(@"no_evaluation_yet", nil);
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.listEvaluations.count > 0)
        return [self.listEvaluations count] + 1;
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.listEvaluations.count == indexPath.row) {
        static NSString * cellSubmit = @"submitCell";
        
        UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellSubmit];
        
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.text = NSLocalizedString(@"submit", nil);
        
        return cell;
    } else {
        
        static NSString * cellEvaluation = @"evaluationCell";
        
        EvaluationTableViewCell *cell = (EvaluationTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellEvaluation];
        
        Evaluation *evaluation = [self.listEvaluations objectAtIndex:indexPath.row];
        
        cell.tableview = self.tableView;
        
        cell.question.text = evaluation.value;
        
        cell.evaluationId = evaluation.ID;
        cell.eventId = self.eventId;
        
        cell.commentary.delegate = cell;
        cell.commentary.tag = indexPath.row;
        
        cell.stars.backgroundColor  = [UIColor whiteColor];
        cell.stars.starImage = [UIImage imageNamed:@"star.png"];
        cell.stars.starHighlightedImage = [UIImage imageNamed:@"starhighlighted.png"];
        cell.stars.maxRating = 5.0;
        cell.stars.delegate = cell;
        cell.stars.horizontalMargin = 12;
        cell.stars.editable = YES;
        cell.stars.displayMode=EDStarRatingDisplayFull;
        cell.stars.tag = indexPath.row;
        
        cell.tag = indexPath.row;
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.listEvaluations.count == indexPath.row) {
        NSArray * feeds = [Feedback retriveFeedbacks];
    
        if (feeds.count > 0) {
        
            [EvaluationService sendFeedbacks:self.eventId feedbacks:feeds withCompletitionBlock:^(AFHTTPRequestOperation *operation, id responseObject) {

                [Messages successMessageWithTitle:nil andMessage:@"Avaliação realizada com sucesso"];
                
                [Localytics tagEvent:@"Evoluating" attributes:@{@"Username" : [User currentUser].userName, @"Event_id" : self.eventId, @"Feeds" : feeds}];
                
                [Feedback removeAllFeedbacks];
                
                [self.navigationController popViewControllerAnimated:YES];
                
            } andFailBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                [Localytics tagEvent:@"Evoluating Error" attributes:@{@"Username" : [User currentUser].userName, @"Event_id" : self.eventId, @"Feeds" : feeds, @"Code_Error" : [NSString stringWithFormat:@"%ld", (long)error.code], @"Code_Description" : error.localizedDescription }];
                
                [Feedback removeAllFeedbacks];
                
                [Messages failMessageWithTitle:nil andMessage:[NSString stringWithFormat:@"Ocerreu o seguinte erro: %ld - %@", (long)error.code, error.localizedDescription]];
            } ];
        } else {
            [Messages failMessageWithTitle:nil andMessage:@"Você não realizou nenhuma avaliação! Por faavor realize a avaliação antes de enviar."];
        }
    }
}

-(void)configureTableView {
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 213.0;
}

@end