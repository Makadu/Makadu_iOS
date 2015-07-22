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

@interface RememberPasswordViewController ()

@end

@implementation RememberPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.emailTextField.delegate = self;
    self.emailTextField.returnKeyType = UIReturnKeyDefault;
    [self.emailTextField addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventEditingDidEndOnExit];
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
        [Messages failMessageWithTitle:nil andMessage:@"E-mail inválido"];
    } else {
        if (![Validations verifyExistUser:self.emailTextField.text]) {
            [Messages failMessageWithTitle:nil andMessage:@"E-mail não cadastrado."];
        } else {
            [PFUser requestPasswordResetForEmail:self.emailTextField.text];
            [Messages failMessageWithTitle:nil andMessage:@"Acesse seu e-mail para redefinir sua senha"];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}
@end
