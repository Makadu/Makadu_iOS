//
//  LoginViewController.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/25/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "LoginViewController.h"
#import "Messages.h"
#import "Analitcs.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    self.emailTextField.delegate = self;
    self.emailTextField.returnKeyType = UIReturnKeyDefault;
    
    self.passwordTextField.delegate = self;
    self.passwordTextField.returnKeyType = UIReturnKeyDefault;
    
    [self.emailTextField addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.passwordTextField addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventEditingDidEndOnExit];
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
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
        [Messages failMessageWithTitle:nil andMessage:@"Você deve informar o usuário e a senha"];
        [Analitcs saveDataAnalitcsWithType:@"Efetuou" screenAccess:@"Login" description:@"Ocorreu um erro:O campo usuário e/ou senha não foi preenchido."];
    } else {
        [PFUser logInWithUsernameInBackground:self.emailTextField.text password:self.passwordTextField.text block:^(PFUser *user, NSError * error) {
            if (error) {
                NSLog(@"Erro %@ - %@", error.localizedDescription, error.userInfo);
                [Messages failMessageWithTitle:nil andMessage:@"Usuário ou senha inválido."];
                [Analitcs saveDataAnalitcsWithUser:user typeOperation:@"Efetuou" screenAccess:@"Login" description:@"Ocorreu um erro no login do usuário"];
            } else {
                [Analitcs saveDataAnalitcsWithUser:user typeOperation:@"Efetuou" screenAccess:@"Login" description:@"Usuário inseriu os dados corretos para o acesso"];
                self.navigationController.navigationBarHidden = NO;
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }];
    }
}
@end
