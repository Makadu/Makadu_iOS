//
//  Analitcs.h
//  Makadu_iOS
//
//  Created by Marcio Habigzang Brufatto on 4/11/15.
//  Copyright (c) 2015 Makadu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Analitcs : NSObject

+(void)saveDataAnalitcsWithUser:(PFUser *)user typeOperation:(NSString *)typeOperation screenAccess:(NSString *)screenAccess description:(NSString *)description;

+(void)saveDataAnalitcsWithType:(NSString *)typeOperation screenAccess:(NSString *)screenAccess description:(NSString *)description;

+(void)saveDataAnalitcsWithUser:(PFUser *)user typeOperation:(NSString *)typeOperation screenAccess:(NSString *)screenAccess description:(NSString *)description event:(PFObject *)event;

+(void)saveDataAnalitcsWithUser:(PFUser *)user typeOperation:(NSString *)typeOperation screenAccess:(NSString *)screenAccess description:(NSString *)description event:(PFObject *)event talk:(PFObject *)talk;

+(void)saveDataAnalitcsWithUser:(PFUser *)user typeOperation:(NSString *)typeOperation screenAccess:(NSString *)screenAccess description:(NSString *)description event:(PFObject *)event talk:(PFObject *)talk question:(PFObject *)question;
@end
