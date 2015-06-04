//
//  SignupViewController.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/25/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface SignupViewController : UIViewController <UITextFieldDelegate>

@property(weak, nonatomic) IBOutlet UITextField * usernameTextField;
@property(weak, nonatomic) IBOutlet UITextField * emailTextField;
@property(weak, nonatomic) IBOutlet UITextField * passwordTextField;

-(IBAction)signup:(id)sender;

@end
