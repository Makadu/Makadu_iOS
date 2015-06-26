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

-(void)fetchEventsByEventID {
    self.eventObject = [EventDAO fetchEventByEventId:self.event];
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
    if([item.title isEqualToString:@"Programação"])
    {
        [self addImageView];
    }
}

-(void)addImageView {
    
    if([self.eventObject objectForKey:@"sponsor"]) {
    
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        UIImageView *patronageImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        patronageImage.image = self.event.imageLoaded;
    
        [self.view addSubview:patronageImage];
    
        [self performSelector:@selector(removeImage:) withObject:patronageImage afterDelay:10.0];
    }
}

-(void)removeImage:(PFImageView *)imageView {
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [imageView removeFromSuperview];
}


@end
