//
//  LoginViewController.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/25/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "LoginViewController.h"
#import "Messages.h"
#import "Localytics.h"
#import "User.h"
#import "DeviceService.h"

@interface LoginViewController ()

@property(nonatomic, weak) IBOutlet UIButton *btnAccess;
@property(nonatomic, weak) IBOutlet UIButton *btnRecoveryPassword;
@property(nonatomic, weak) IBOutlet UIButton *btnRegister; 
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.navigationController.navigationBarHidden = NO;
    
    self.emailTextField.delegate = self;
    self.emailTextField.returnKeyType = UIReturnKeyDefault;
    
    self.passwordTextField.delegate = self;
    self.passwordTextField.returnKeyType = UIReturnKeyDefault;
    
    [self.emailTextField addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.passwordTextField addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventEditingDidEndOnExit];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [Localytics tagScreen:@"Login"];

}

- (void)hideKeyboard {
    [self.emailTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Action

-(IBAction)login:(id)sender
{
    NSString * username = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString * password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([username length] == 0 || [password length] == 0) {
        [Messages failMessageWithTitle:nil andMessage:NSLocalizedString(@"user_and_password", nil)];
    } else {
        [User authUser:username password:password withCompletitionBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([[responseObject objectForKey:@"data"] boolValue]) {
                User *user = [User new];
                user.ID = [responseObject objectForKey:@"user_id"];
                user.fullName = @"";
                user.userName = username;
                user.email = username;
                user.password = password;
                
                [user save];
                
                NSLog(@"%@", [DeviceService loadDeviceToken]);
                
                [DeviceService sentDeviceToken:[DeviceService loadDeviceToken] withCompletitionBlock: ^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"Registro realizado com sucesso");
                } andFailBlock:^(AFHTTPRequestOperation *operation, NSError *error){
                    NSLog(@"Error: %ld - %@", (long)error.code, error.localizedDescription);
                }];
                
                
                [Localytics tagEvent:@"Login Success" attributes:@{@"Login" : username }];
                
                self.navigationController.navigationBarHidden = NO;
                [self.navigationController popToRootViewControllerAnimated:YES];
            } else {
                [Messages failMessageWithTitle:nil andMessage:NSLocalizedString(@"user_or_password_invalid", nil)];
            }
        } andFailBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
            [Localytics tagEvent:@"Login Fail" attributes:@{@"Login" : username, @"Error:" : [NSString stringWithFormat:@"%ld - %@", (long)error.code, error.localizedDescription]}];
            
            [Messages failMessageWithTitle:nil andMessage:[NSString stringWithFormat:@"%ld - %@", (long)error.code, error.localizedDescription]];
        }];
    }
}
@end
