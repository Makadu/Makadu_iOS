//
//  PollViewController.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 2/15/16.
//  Copyright © 2016 Madhava. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Talk.h"

#import "PollInstructionViewController.h"

@interface PollViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, ReturnToTalksDelegate>

@property (nonatomic, weak) Talk * talk;

@end
