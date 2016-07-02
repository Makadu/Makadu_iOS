//
//  QuestionViewController.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/29/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MRProgress/MRProgress.h>
#import "Question.h"
#import "Event.h"
#import "User.h"
#import "Talk.h"

@interface QuestionViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, strong) Talk *talk;
@property (nonatomic, strong) Event *event;

@end
