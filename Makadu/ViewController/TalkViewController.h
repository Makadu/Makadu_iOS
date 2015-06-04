//
//  TalkViewController.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/27/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Talk.h"
#import "Question.h"
#import <EDStarRating/EDStarRating.h>

@interface TalkViewController : UIViewController <EDStarRatingProtocol,UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) Talk *talk;
@property (nonatomic, strong) PFObject *eventObject;
@property (nonatomic, strong) PFObject *talkObject;

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *localLabel;

@property (nonatomic, strong) IBOutlet UIButton *questionButton;
@property (nonatomic, strong) IBOutlet UIButton *downloadButton;

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
