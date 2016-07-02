//
//  SignupViewController.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/25/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "SignupViewController.h"
#import "Messages.h"
#import "Connection.h"
#import "Validations.h"
#import "Localytics.h"
#import "User.h"

@interface SignupViewController ()

@property(nonatomic, weak) IBOutlet UIButton *btnLogin;
@property(nonatomic, weak) IBOutlet UIButton *btnRegister;

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"register", nil);
    
    self.usernameTextField.delegate = self;
    self.usernameTextField.returnKeyType = UIReturnKeyDefault;
    
    self.emailTextField.delegate = self;
    self.emailTextField.returnKeyType = UIReturnKeyDefault;
    
    self.passwordTextField.delegate = self;
    self.passwordTextField.returnKeyType = UIReturnKeyDefault;
    
    [self.usernameTextField addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.emailTextField addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.passwordTextField addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventEditingDidEndOnExit];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [Localytics tagScreen:@"Signup"];
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Other methods

- (void)hideKeyboard {
    [self.usernameTextField resignFirstResponder];
}

#pragma mark - Action

-(void)signup:(id)sender
{
    if ([Connection existConnection]) {
        NSString *username = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *email    = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([username length] == 0 || [password length] == 0 || [email length] == 0) {
            [Messages failMessageWithTitle:nil andMessage:NSLocalizedString(@"fields_empty", nil) ];
            [Localytics tagEvent:@"Signup Fail" attributes:@{@"Username" : username, @"Error:" : NSLocalizedString(@"fields_empty", nil) }];
        } else {
            if (![Validations emailValid:email]) {
                [Messages failMessageWithTitle:nil andMessage:NSLocalizedString(@"invalid_email", nil)];
                
                [Localytics tagEvent:@"Signup Fail" attributes:@{@"Username" : username, @"Error:" : NSLocalizedString(@"invalid_email", nil) }];
                
            } else {
                [User createNewUserWithFullName:username userName:email email:email password:password withCompletitionBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                    if([responseObject objectForKey:@"erro"]) {
                        
                        [Messages failMessageWithTitle:nil andMessage:NSLocalizedString(@"user_alredy_exists", nil)];
                        
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                        message:[NSString stringWithFormat:NSLocalizedString(@"user_alredy_exists", nil)]
                                                                       delegate:self
                                                              cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                                                              otherButtonTitles:NSLocalizedString(@"submit", nil), nil];
                        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                        [alert show];
                        
                        
                    } else {
                        User *user = [User new];
                        user.ID = [responseObject objectForKey:@"user_id"];
                        user.fullName = username;
                        user.userName = email;
                        user.email = email;
                        user.password = password;
                        
                        [user save];
                        
                        [Localytics tagEvent:@"Signup Success" attributes:@{@"Username" : email }];
                        
                        self.navigationController.navigationBarHidden = NO;
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }
                    
                } andFailBlock:^(AFHTTPRequestOperation *operation, NSError *error){
                    NSLog(@"Error: %@", error.localizedDescription);
                    
                    [Localytics tagEvent:@"Signup Fail" attributes:@{@"Username" : username, @"Error:" : error.localizedDescription }];
                    
                    [Messages failMessageWithTitle:nil andMessage:NSLocalizedString(@"email_in_use", nil)];
                }];
            }
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        if (![Validations emailValid:[alertView textFieldAtIndex:0].text]) {
            [Messages failMessageWithTitle:nil andMessage:NSLocalizedString(@"invalid_email", nil)];
            
            [Localytics tagEvent:@"Remember Password Fail" attributes:@{@"Username" :[alertView textFieldAtIndex:0].text, @"Error:" : NSLocalizedString(@"invalid_email", nil) }];
            
        } else {
            [User recoveryPassword:self.emailTextField.text withCompletitionBlock:^(AFHTTPRequestOperation * operation, id responseObject){
                [Messages warningMessageWithTitle:nil andMessage:NSLocalizedString(@"rescue_password", nil)];
                [self.navigationController popToRootViewControllerAnimated:YES];
            } andFailBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                [Localytics tagEvent:@"Remember Password Fail" attributes:@{@"Username" :[alertView textFieldAtIndex:0].text, @"Error:" : error.localizedDescription }];
                
                [Messages failMessageWithTitle:nil andMessage:[NSString stringWithFormat:@"%ld - %@", (long)error.code, error.localizedDescription]];
            }];
        }
    }
}
@end