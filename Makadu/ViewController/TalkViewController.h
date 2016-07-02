//
//  TalkViewController.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/27/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EDStarRating/EDStarRating.h>
#import <MRProgress/MRProgress.h>
#import "Event.h"
#import "Talk.h"
#import "Question.h"


@interface TalkViewController : UIViewController <EDStarRatingProtocol,UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) Talk *talk;
@property (nonatomic, strong) Event * event;

@end
