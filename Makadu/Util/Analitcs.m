//
//  Analitcs.m
//  Makadu_iOS
//
//  Created by Marcio Habigzang Brufatto on 4/11/15.
//  Copyright (c) 2015 Makadu. All rights reserved.
//

#import "Analitcs.h"

@implementation Analitcs


+(void)saveDataAnalitcsWithUser:(PFUser *)user typeOperation:(NSString *)typeOperation screenAccess:(NSString *)screenAccess description:(NSString *)description {
    
    PFObject * analitics = [PFObject objectWithClassName:@"Analitics"];
    analitics[@"user"] = user;
    analitics[@"type"] = typeOperation;
    analitics[@"screen"] = screenAccess;
    analitics[@"description"] = description;
    [analitics saveEventually];
}

+(void)saveDataAnalitcsWithType:(NSString *)typeOperation screenAccess:(NSString *)screenAccess description:(NSString *)description {
    
    PFObject * analitics = [PFObject objectWithClassName:@"Analitics"];
    analitics[@"type"] = typeOperation;
    analitics[@"screen"] = screenAccess;
    analitics[@"description"] = description;
    [analitics saveEventually];
}

+(void)saveDataAnalitcsWithUser:(PFUser *)user typeOperation:(NSString *)typeOperation screenAccess:(NSString *)screenAccess description:(NSString *)description event:(PFObject *)event {
    
    PFObject * analitics = [PFObject objectWithClassName:@"Analitics"];
    analitics[@"user"] = user;
    analitics[@"type"] = typeOperation;
    analitics[@"screen"] = screenAccess;
    analitics[@"description"] = description;
    analitics[@"event"] = event;
    [analitics saveEventually];
}

+(void)saveDataAnalitcsWithUser:(PFUser *)user typeOperation:(NSString *)typeOperation screenAccess:(NSString *)screenAccess description:(NSString *)description event:(PFObject *)event talk:(PFObject *)talk {
    
    PFObject * analitics = [PFObject objectWithClassName:@"Analitics"];
    analitics[@"user"] = user;
    analitics[@"type"] = typeOperation;
    analitics[@"screen"] = screenAccess;
    analitics[@"description"] = description;
    analitics[@"event"] = event;
    analitics[@"talk"] = talk;
    [analitics saveEventually];
}

+(void)saveDataAnalitcsWithUser:(PFUser *)user typeOperation:(NSString *)typeOperation screenAccess:(NSString *)screenAccess description:(NSString *)description event:(PFObject *)event talk:(PFObject *)talk question:(PFObject *)question {
    
    PFObject * analitics = [PFObject objectWithClassName:@"Analitics"];
    analitics[@"user"] = user;
    analitics[@"type"] = typeOperation;
    analitics[@"screen"] = screenAccess;
    analitics[@"description"] = description;
    analitics[@"event"] = event;
    analitics[@"talk"] = talk;
    analitics[@"question"] = question;
    [analitics saveEventually];
}
@end
