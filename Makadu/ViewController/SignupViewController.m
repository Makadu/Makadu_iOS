//
//  SignupViewController.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/25/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "SignupViewController.h"
#import "Messages.h"
#import "Validations.h"
#import "Analitcs.h"

@interface SignupViewController ()

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    
    self.navigationController.navigationBar.topItem.title = @"Cadastro";
    
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
    NSString *username = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *email    = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([username length] == 0 || [password length] == 0 || [email length] == 0) {
        [Messages failMessageWithTitle:nil andMessage:@"Você deve preencher todos os campos."];
        [Analitcs saveDataAnalitcsWithType:@"Cadastro" screenAccess:@"Cadastre-se" description:@"O usuário não preencheu algum dos campos necessários"];
    } else {
        if (![Validations emailValid:email]) {
            [Messages failMessageWithTitle:nil andMessage:@"E-mail invávido"];
            [Analitcs saveDataAnalitcsWithType:@"Cadastro" screenAccess:@"Cadastre-se" description:@"E-mail informado pelo usuário não era válido"];
        } else {
            PFUser *newUser = [PFUser user];
            newUser.username = email;
            newUser.email = email;
            newUser.password = password;
            newUser[@"full_name"] = username;
        
            [newUser signUpInBackgroundWithBlock:^(BOOL secceeded, NSError * error) {
                if (error) {
                    [Messages failMessageWithTitle:nil andMessage:@"O e-mail selecionado já está em uso. Faça seu login."];
                    [Analitcs saveDataAnalitcsWithUser:newUser typeOperation:@"Cadastro" screenAccess:@"Cadatre-se" description:[NSString stringWithFormat:@"Ocorreu um erro inesperado: %@", error.localizedDescription]];
                } else {
                    [Analitcs saveDataAnalitcsWithUser:newUser typeOperation:@"Cadastro" screenAccess:@"Cadatre-se" description:@"O usuario realizou o cadastro com sucesso"];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }];
        }
    }
}
@end