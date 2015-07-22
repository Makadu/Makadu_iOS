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

@interface QuestionViewController ()

@property (weak, nonatomic) IBOutlet UITextView *questionTextView;

@end

@implementation QuestionViewController

- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    
    self.questionTextView.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated {
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
    
    [MRProgressOverlayView showOverlayAddedTo:self.view title:@"Enviando mensagem." mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
    
    PFObject *question = [PFObject objectWithClassName:@"Questions"];
    question[@"question"] = self.questionTextView.text;
    question[@"talk"] = self.talkObject;
    question[@"questioning"] = [PFUser currentUser];
    question[@"active"] = [NSNumber numberWithBool:YES];
    [question saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [Messages successMessageWithTitle:@"Sucesso" andMessage:@"Sua pergunta foi enviada com com sucesso"];
            [self dismissViewControllerAnimated:NO completion:nil];
        } else {
            [Messages failMessageWithTitle:@"Alerta" andMessage:@"Ocorreu um erro no envio de sua menssagem"];
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }];
    [MRProgressOverlayView dismissOverlayForView:self.view animated:YES];

}

- (IBAction)tapCancelSendQuestion:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}


@end
