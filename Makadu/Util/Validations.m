//
//  Validations.m
//  Makadu_iOS
//
//  Created by Marcio Habigzang Brufatto on 4/5/15.
//  Copyright (c) 2015 Makadu. All rights reserved.
//

#import "Validations.h"

@implementation Validations

+(BOOL)usernameEmpty:(NSString *)username {
    
    if (username == nil || [username isEqualToString:@""]) {
        return YES;
    }
    return NO;
}

+(BOOL)userEmailEmpty:(NSString *)email {
    if (email == nil || [email isEqualToString:@""]) {
        return YES;
    }
    return NO;
}

+(BOOL)userPasswordEmpty:(NSString *)password {
    
    if (password == nil || [password isEqualToString:@""]) {
        return YES;
    }
    return NO;

}

+(BOOL)emailValid:(NSString *)candidate{
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

+(BOOL)verifyExistUser:(NSString *)email
{
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:email];
    NSArray *username = [query findObjects];
    
    if (username.count > 0) {
        return YES;
    } else {
        return NO;
    }
}

@end
