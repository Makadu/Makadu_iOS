//
//  QuestionViewController.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/29/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MRProgress/MRProgress.h>

#import "Talk.h"

@interface QuestionViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, strong) Talk *talk;
@property (nonatomic, strong) PFObject *talkObject;
@property (nonatomic, strong) PFObject *eventObject;

@end
