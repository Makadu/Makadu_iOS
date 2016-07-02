//
//  PollInstructionViewController.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 2/18/16.
//  Copyright © 2016 Madhava. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ReturnToTalksDelegate <NSObject>
@optional
- (void)goToTalks;
@end

@interface PollInstructionViewController : UIViewController

@property (nonatomic, weak) id <ReturnToTalksDelegate> delegate;

@end
