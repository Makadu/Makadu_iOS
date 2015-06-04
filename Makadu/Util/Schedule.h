//
//  Schedule.h
//  Makadu_iOS
//
//  Created by Marcio Habigzang Brufatto on 4/13/15.
//  Copyright (c) 2015 Makadu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Talk.h"

@interface Schedule : NSObject

+(void)saveDataScheduleWithUser:(PFUser *)user talk:(Talk *)talk;

@end
