//
//  EventViewController.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/26/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "EventViewController.h"
#import "Event.h"
#import "EventDAO.h"

@interface EventViewController ()

@property (nonatomic, strong) Event *event;

@end

@implementation EventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showEventViewController = (ShowEventViewController *)self.tabBarController;
    self.event = self.showEventViewController.event;
    self.titleLabel.text = self.event.name;
    self.localLabel.text = [NSString stringWithFormat:@"%@ - %@", self.event.local, self.event.address];
    
    self.dateLabel.text = [NSString stringWithFormat:@"%@ a %@", self.event.startDate, self.event.endDate];
    self.descriptionTextView.text = self.event.eventDescription;
    
    [self loadImageEvent:self.event.fileImgEvent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - LoadImages

-(void)loadImageEvent:(PFFile *)image {
    
    [image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            self.logoPFImageView.image = [UIImage imageWithData:data];
        }
        else {
            self.logoPFImageView.image = [UIImage imageNamed:@"makadu.png"];
        }
    }];
}
@end
