//
//  ShowEventViewController.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/26/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>

#import "Event.h"
#import "Talk.h"

@interface ShowEventViewController : UITabBarController  <UITabBarDelegate>

@property (nonatomic, strong) Event * event;
@property (nonatomic, strong) PFObject * eventObject;


@end
