//
//  QuestionViewController.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/29/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "QuestionViewController.h"
#import "Connection.h"
#import "Messages.h"
#import "TalkDAO.h"
#import "Localytics.h"
#import "User.h"

@interface QuestionViewController ()

@property (weak, nonatomic) IBOutlet UITextView *questionTextView;

@end

@implementation QuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetchTalk];
    self.questionTextView.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated {
    
    [Localytics tagScreen:@"Question"];
    
    if (![Connection existConnection]) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Delegate Text View

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSRange resultRange = [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch];
    if ([text length] == 1 && resultRange.location != NSNotFound) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma mark - Action

- (IBAction)tapSendQuestion:(id)sender {
    
    [MRProgressOverlayView showOverlayAddedTo:self.view title:NSLocalizedString(@"sending_message", nil) mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
    
    User *user = [User currentUser];
    
    [Question sentQuestionByEventId:self.talk.eventId talkId:self.talk.ID username:user.userName question:self.questionTextView.text withCompletitionBlock:^(AFHTTPRequestOperation * operation, id responseObject) {
        
        [Localytics tagEvent:@"Question Success" attributes:@{@"Username" : user.userName, @"Event:" : self.event.title, @"Question" : self.questionTextView.text }];
        
        [Messages successMessageWithTitle:@"Sucesso" andMessage:NSLocalizedString(@"success_question", nil) ];
        [MRProgressOverlayView dismissAllOverlaysForView:self.view animated:YES];
        
        [self dismissViewControllerAnimated:NO completion:nil];
        
        
        
    } andFailBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [Localytics tagEvent:@"Question Fail" attributes:@{@"Username" : user.userName, @"Event:" : self.event.title, @"Question" : self.questionTextView.text, @"Error" : error.localizedDescription }];
        
        [Messages failMessageWithTitle:@"Alerta" andMessage:NSLocalizedString(@"error_sending_message", nil)];
        [MRProgressOverlayView dismissAllOverlaysForView:self.view animated:YES];
        [self dismissViewControllerAnimated:NO completion:nil];
        
    }];
}

- (IBAction)tapCancelSendQuestion:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}


-(void)fetchTalk {

}

@end
