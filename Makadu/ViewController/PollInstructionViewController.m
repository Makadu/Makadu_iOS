//
//  PollInstructionViewController.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 2/18/16.
//  Copyright © 2016 Madhava. All rights reserved.
//

#import "PollInstructionViewController.h"

@interface PollInstructionViewController ()

@property (weak, nonatomic) IBOutlet UILabel *indtructionLabel;

@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UIButton *btnVote;

@end

@implementation PollInstructionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.indtructionLabel.text = NSLocalizedString(@"voting_instruction", nil);
    self.btnVote.titleLabel.text = NSLocalizedString(@"vote", nil);
    self.btnClose.titleLabel.text = NSLocalizedString(@"close", nil);
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.indtructionLabel.text = NSLocalizedString(@"voting_instruction", nil);
    self.btnVote.titleLabel.text = NSLocalizedString(@"vote", nil);
    self.btnClose.titleLabel.text = NSLocalizedString(@"close", nil);
}

-(IBAction)vote:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)close:(id)sender {
    [self.delegate goToTalks];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
