//
//  RememberPasswordViewController.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/25/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "RememberPasswordViewController.h"
#import "Validations.h"
#import "Messages.h"
#import "Localytics.h"
#import "User.h"

@interface RememberPasswordViewController ()

@property(nonatomic, weak) IBOutlet UIButton *btnSent;
@property(nonatomic, weak) IBOutlet UILabel *lblTitle;

@end

@implementation RememberPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.emailTextField.delegate = self;
    self.emailTextField.returnKeyType = UIReturnKeyDefault;
    [self.emailTextField addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventEditingDidEndOnExit];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [Localytics tagScreen:@"Remember Password"];
}

-(void)viewWillAppear:(BOOL)animated {
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Other methods

- (void)hideKeyboard {
    [self.emailTextField resignFirstResponder];
}

#pragma mark - Action

-(IBAction)sendEmailToRememberPassword:(id)sender
{
    if (![Validations emailValid:self.emailTextField.text]) {
        [Messages failMessageWithTitle:nil andMessage:NSLocalizedString(@"invalid_email", nil)];
        
        [Localytics tagEvent:@"Remember Password Fail" attributes:@{@"Username" : self.emailTextField.text, @"Error:" : NSLocalizedString(@"invalid_email", nil) }];
        
    } else {
        [User recoveryPassword:self.emailTextField.text withCompletitionBlock:^(AFHTTPRequestOperation * operation, id responseObject){
            
            [Messages warningMessageWithTitle:nil andMessage:NSLocalizedString(@"rescue_password", nil)];
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        } andFailBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [Localytics tagEvent:@"Remember Password Fail" attributes:@{@"Username" : self.emailTextField.text, @"Error:" : error.localizedDescription }];
            
            [Messages failMessageWithTitle:nil andMessage:[NSString stringWithFormat:@"%ld - %@", (long)error.code, error.localizedDescription]];
        }];
    }
}
@end
