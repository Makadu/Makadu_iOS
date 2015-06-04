//
//  ShowEventViewController.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/26/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "ShowEventViewController.h"
#import "EventDAO.h"

@interface ShowEventViewController ()

@end

@implementation ShowEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetchEventsByEventID];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(void)fetchEventsByEventID {
    self.eventObject = [EventDAO fetchEventByEventId:self.event];
}

@end
