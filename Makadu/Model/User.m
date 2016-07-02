//
//  User.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 11/22/15.
//  Copyright © 2015 Madhava. All rights reserved.
//

#import "User.h"
#import "MakaduService.h"

@implementation User


- (void)encodeWithCoder:(NSCoder *)coder;
{
    [coder encodeObject:self.ID forKey:@"ID"];
    [coder encodeObject:self.fullName forKey:@"fullName"];
    [coder encodeObject:self.userName forKey:@"userName"];
    [coder encodeObject:self.email forKey:@"email"];
    [coder encodeObject:self.password forKey:@"password"];
}

- (id)initWithCoder:(NSCoder *)coder;
{
    if(self = [super init])
    {
        self.ID = [coder decodeObjectForKey:@"ID"];
        self.fullName = [coder decodeObjectForKey:@"fullName"];
        self.userName = [coder decodeObjectForKey:@"userName"];
        self.email = [coder decodeObjectForKey:@"email"];
        self.password = [coder decodeObjectForKey:@"password"];
    }
    return self;
}


-(void)save {
    
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    NSString* savedItems = @"user_sigin";
    NSData* userObj = [NSKeyedArchiver archivedDataWithRootObject:self];
    
    [preferences setObject:userObj forKey: savedItems];
    [preferences synchronize];
}

-(User *)getUser:(NSString *)username password:(NSString *)password {
    
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    NSString* savedItems = @"user_sigin";
    
    NSData *archiveArray = [preferences objectForKey: savedItems];
    User *user = [NSKeyedUnarchiver unarchiveObjectWithData: archiveArray];
    if ([user.userName isEqualToString:username] && [user.password isEqualToString:password]) {
        return user;
    }
    return nil;
}

-(BOOL)userAuthenticate {
    
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    NSString* savedItems = @"user_sigin";
    
    NSData *archiveArray = [preferences objectForKey:savedItems];
    
    User *user = [NSKeyedUnarchiver unarchiveObjectWithData: archiveArray];
    if (user || user != nil) {
        return YES;
    }
    return NO;
}

+(void)logout {

    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [defs dictionaryRepresentation];
    for (id key in dict) {
        if (![key isEqualToString:@"deviceToken"]) {
            [defs removeObjectForKey:key];
        }
    }
    [defs synchronize];
}

+(User *)currentUser {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    NSString* savedItems = @"user_sigin";
    
    NSData *archiveArray = [preferences objectForKey: savedItems];
    User *user = [NSKeyedUnarchiver unarchiveObjectWithData: archiveArray];
    
    return user;
}

#pragma mark - WebService
+ (void)createNewUserWithFullName:(NSString *)fullName userName:(NSString *)userName email:(NSString *)email password:(NSString *)password
        withCompletitionBlock:(void(^)(AFHTTPRequestOperation *operation,id responseObject)) success
                 andFailBlock:(void(^)(AFHTTPRequestOperation *operation,NSError *error))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"user": @{@"full_name": fullName, @"username":userName, @"email":email, @"password":password}};

    
    [manager POST:@"http://api.makadu.net/users/new" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
    
        success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

+ (void)authUser:(NSString *)userName password:(NSString *)password
            withCompletitionBlock:(void(^)(AFHTTPRequestOperation *operation,id responseObject)) success
                     andFailBlock:(void(^)(AFHTTPRequestOperation *operation,NSError *error))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"username":userName, @"password":password};
    
    [manager POST:@"http://api.makadu.net/users/auth" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
            success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

+ (void)recoveryPassword:(NSString *)userName
withCompletitionBlock:(void(^)(AFHTTPRequestOperation *operation,id responseObject)) success
    andFailBlock:(void(^)(AFHTTPRequestOperation *operation,NSError *error))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"username":userName};
    
    [manager POST:@"http://api.makadu.net/users/password_recovery" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

@end
