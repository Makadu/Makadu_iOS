//
//  TalkViewController.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/27/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EDStarRating/EDStarRating.h>

#import "Talk.h"
#import "Question.h"


@interface TalkViewController : UIViewController <EDStarRatingProtocol,UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) Talk *talk;
@property (nonatomic, strong) PFObject *eventObject;
@property (nonatomic, strong) PFObject *talkObject;

@property (weak, nonatomic) IBOutlet EDStarRating *starRating;

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *localLabel;

@property (nonatomic, weak) IBOutlet UIButton * questionButton;
@property (nonatomic, weak) IBOutlet UIButton * downloadButton;
@property (weak, nonatomic) IBOutlet UIButton * favoriteButton;

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
