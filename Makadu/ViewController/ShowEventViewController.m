//
//  ShowEventViewController.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/26/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "ShowEventViewController.h"
#import "EventDAO.h"
#import "Notice.h"
#import "NoticeListTableViewController.h"

@interface ShowEventViewController ()

@end

@implementation ShowEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateBadgeValue:@{@"event_id": self.event.ID}];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBadgeValue:) name:@"pushNotices" object:nil];
    
    
    [[self.tabBar.items objectAtIndex:0] setTitle:NSLocalizedString(@"events", nil)];
    [[self.tabBar.items objectAtIndex:1] setTitle:NSLocalizedString(@"schedule", nil)];
    [[self.tabBar.items objectAtIndex:2] setTitle:NSLocalizedString(@"papers", nil)];
    [[self.tabBar.items objectAtIndex:3] setTitle:NSLocalizedString(@"favorites", nil)];
    [[self.tabBar.items objectAtIndex:4] setTitle:NSLocalizedString(@"notices", nil)];
}


-(void)updateBadgeValue:(id)eventId {

    if ([Notice getNoticesNotVisualizedByEventId:[self retriveEventId:eventId]] > 0) {
        [[self.viewControllers objectAtIndex:4] tabBarItem].badgeValue = [NSString stringWithFormat:@"%d", [Notice getNoticesNotVisualizedByEventId:[self retriveEventId:eventId]]];
    } else {
        [[self.viewControllers objectAtIndex:4] tabBarItem].badgeValue = nil;
    }
    
    if (self.tabBar.selectedItem.tag == 4000) {
        [[self.viewControllers objectAtIndex:4] tabBarItem].badgeValue = nil;
    }
}

-(NSString *)retriveEventId:(id)userInfo {
    
    NSString * event_ID = @"";
    if ([userInfo isKindOfClass:[NSNotification class]])
        event_ID = [[(NSNotification *)userInfo userInfo] objectForKey:@"event_id"];
    
    if ([userInfo isKindOfClass:[NSDictionary class]])
        event_ID = [(NSDictionary *)userInfo objectForKey:@"event_id"];
    
    return event_ID;
}

@end
