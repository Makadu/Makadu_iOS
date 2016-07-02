//
//  EventViewController.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/26/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "EventViewController.h"
#import "Event.h"
#import "EventDAO.h"
#import "Localytics.h"
#import "DateFormatter.h"
#import "Messages.h"

#import "EvaluationTableViewController.h"

#import "User.h"

@interface EventViewController ()

@property (nonatomic, strong) Event *event;

@property (nonatomic, weak) IBOutlet UIImageView *imgEvent;
@property (strong, nonatomic) IBOutlet UIButton *btnAddFavorites;
@property (strong, nonatomic) IBOutlet UIButton *btnEvaluation;

@end

@implementation EventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showEventViewController = (ShowEventViewController *)self.tabBarController;
    self.event = self.showEventViewController.event;
    
    self.titleLabel.text = self.event.title;
    self.localLabel.text = [NSString stringWithFormat:@"%@ - %@", self.event.venue, self.event.address];
    
    self.dateLabel.text = [NSString stringWithFormat:@"%@ a %@", [DateFormatter formateUniversalDate:self.event.startDate withZone:NO], [DateFormatter formateUniversalDate:self.event.endDate withZone:NO]];
    self.descriptionLabel.text = self.event.eventDescription;
    
    if (self.event.imgLogoMedium || self.event.imgLogoMedium != nil) {
        self.imgEvent.image = [UIImage imageWithData:self.event.imgLogoMedium];
        self.imgEvent.contentMode = UIViewContentModeScaleAspectFit;
    } else {
        [self loadImageEvent:self.event];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [Localytics tagEvent:@"Event Detail" attributes:@{@"Username" : [User currentUser].userName , @"Event:" : self.event.title }];
    
    self.btnEvaluation.titleLabel.text = NSLocalizedString(@"evaluation", nil);
    [self.btnAddFavorites.titleLabel sizeToFit];
    [self.btnAddFavorites.titleLabel setTextAlignment: NSTextAlignmentCenter];
}



-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    
    
    [self setBtnTitleFavorites];
    
    CGFloat height = 0;
    
    CGFloat width = self.scrollView.bounds.size.width;
    CGFloat heightImg = CGRectGetHeight(self.imgEvent.frame);
    
    height += heightImg;
    
    CGFloat heightBtnAddFavorite = CGRectGetHeight(self.btnAddFavorites.frame);
    height += heightBtnAddFavorite;
    
    CGFloat heightBtnEvaluation = CGRectGetHeight(self.btnEvaluation.frame);
    height += heightBtnEvaluation;
    
    CGFloat heightLocal = CGRectGetHeight(self.localLabel.frame);
    height += heightLocal;
    
    CGFloat heightDate = CGRectGetHeight(self.dateLabel.frame);
    height += heightDate;
    
    CGFloat heightDescription = CGRectGetHeight(self.descriptionLabel.frame);
    height += heightDescription;
    
    CGFloat heighTitle = CGRectGetHeight(self.titleLabel.frame);
    height += heighTitle;
    
    self.scrollView.contentSize = CGSizeMake(width, height + 65);
    self.scrollView.contentOffset = CGPointZero;
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - LoadImages

-(void)loadImageEvent:(Event *)event {
    
    NSURL *url = [NSURL URLWithString:[event.logoMedium stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [Event downloadImageWithURL:url completionBlock:^(BOOL succeeded, UIImage *image) {
        if (succeeded) {
            [Event saveImageLogoMedium:image eventId:event.ID];
            self.imgEvent.image = image;
            self.imgEvent.contentMode = UIViewContentModeScaleAspectFit;
            [self.view reloadInputViews];
        } else {
            self.imgEvent.image = [UIImage imageNamed:@"makadu.png"];
            self.imgEvent.contentMode = UIViewContentModeScaleAspectFit;
        }
    }];
}

-(IBAction)addToFavorites:(id)sender {
    
    if([self.event isFavorite]) {
        [self removeEventFavoriteRemote];
        [self.event toggleFavorite:NO];
    } else {
        if (([self.event.eventType isEqualToString:@"private"] && [Event eventSavePassword:self.event]) || ([self.event.eventType isEqualToString:@"Publico"] || [self.event.eventType isEqualToString:@"Oculto"]) || [self.event isFavorite]) {
            
            [self addNewEventFavoriteRemote];
            [self.event toggleFavorite:YES];
            
            
            [self setBtnTitleFavorites];
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


-(void)setBtnTitleFavorites {
    
    [self.btnAddFavorites.titleLabel setTextAlignment: NSTextAlignmentCenter];
    
    if ([self.event isFavorite])
        self.btnAddFavorites.titleLabel.text = NSLocalizedString(@"remove_events", nil);
    else
        self.btnAddFavorites.titleLabel.text = NSLocalizedString(@"add_events", nil);
}

-(void)addNewEventFavoriteRemote {
    
    [MRProgressOverlayView showOverlayAddedTo:self.view title:NSLocalizedString(@"add_event_to_favorites", nil) mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
    
    [Event addNewEventFavorite:self.event.ID username:[User currentUser].userName withCompletitionBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [Localytics tagEvent:@"Add Event Success" attributes:@{@"Username" : [User currentUser].userName, @"Event:" : self.event.title}];
        
        [Messages successMessageWithTitle:@"Success" andMessage:NSLocalizedString(@"success_event", nil) ];
        [MRProgressOverlayView dismissAllOverlaysForView:self.view animated:YES];
        
    } andFailBlock:^(AFHTTPRequestOperation * operation, NSError *error){
        
        [Localytics tagEvent:@"Add Event Fail" attributes:@{@"Username" : [User currentUser].userName, @"Event:" : self.event.title, @"Error" : error.localizedDescription }];
        
        [MRProgressOverlayView dismissAllOverlaysForView:self.view animated:YES];
        NSLog(@"Error == %@", error.localizedDescription);
        
    }];
}

-(void)removeEventFavoriteRemote {
    [MRProgressOverlayView showOverlayAddedTo:self.view title:NSLocalizedString(@"removing_event", nil) mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
    
    [Event removeEventFavorite:self.event.ID username:[User currentUser].userName withCompletitionBlock:^(AFHTTPRequestOperation * operation, id responseObject){
        
        [Localytics tagEvent:@"Remove Event Success" attributes:@{@"Username" : [User currentUser].userName, @"Event:" : self.event.title}];
        
        [Messages successMessageWithTitle:@"Sucesso" andMessage:NSLocalizedString(@"removing_event_success", nil) ];
        [MRProgressOverlayView dismissAllOverlaysForView:self.view animated:YES];
        
    } andFailBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Localytics tagEvent:@"Remove Event Fail" attributes:@{@"Username" : [User currentUser].userName, @"Event:" : self.event.title, @"Error" : error.localizedDescription }];
        
        [MRProgressOverlayView dismissAllOverlaysForView:self.view animated:YES];
        NSLog(@"Error == %@", error.localizedDescription);
    }];
}

-(IBAction)tapEvaluation:sender {
    if (([self.event.eventType isEqualToString:@"private"] && [Event eventSavePassword:self.event]) || ([self.event.eventType isEqualToString:@"Publico"] || [self.event.eventType isEqualToString:@"Oculto"]) || [self.event isFavorite]) {
        
        
        EvaluationTableViewController *evaluationTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EvaluationTableViewController"];
        [evaluationTableViewController setEventId:self.event.ID];
        [self.navigationController pushViewController:evaluationTableViewController animated:YES];
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

@end