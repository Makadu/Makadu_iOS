//
//  Validations.h
//  Makadu_iOS
//
//  Created by Marcio Habigzang Brufatto on 4/5/15.
//  Copyright (c) 2015 Makadu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Validations : NSObject

+(BOOL)usernameEmpty:(NSString *)username;
+(BOOL)userEmailEmpty:(NSString *)email;
+(BOOL)userPasswordEmpty:(NSString *)password;

+(BOOL)emailValid:(NSString *)candidate;
+(BOOL)verifyExistUser:(NSString *)email;

@end
