//
//  User.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 11/22/15.
//  Copyright © 2015 Madhava. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

#import <AFNetworking/AFNetworking.h>

@interface User : NSObject

@property(nonatomic, strong) NSString *ID;
@property(nonatomic, strong) NSString *fullName;
@property(nonatomic, strong) NSString *userName;
@property(nonatomic, strong) NSString *email;
@property(nonatomic, strong) NSString *password;

-(void)save;
-(User *)getUser:(NSString *)username password:(NSString *)password;
-(BOOL)userAuthenticate;
+(void)logout;
+(User *)currentUser;


#pragma mark - WebService

+ (void)createNewUserWithFullName:(NSString *)fullName userName:(NSString *)userName email:(NSString *)email password:(NSString *)password withCompletitionBlock:(void(^)(AFHTTPRequestOperation *operation,id responseObject)) success andFailBlock:(void(^)(AFHTTPRequestOperation *operation,NSError *error))failure;

+ (void)authUser:(NSString *)userName password:(NSString *)password
withCompletitionBlock:(void(^)(AFHTTPRequestOperation *operation,id responseObject)) success
    andFailBlock:(void(^)(AFHTTPRequestOperation *operation,NSError *error))failure;

+ (void)recoveryPassword:(NSString *)userName
   withCompletitionBlock:(void(^)(AFHTTPRequestOperation *operation,id responseObject)) success
            andFailBlock:(void(^)(AFHTTPRequestOperation *operation,NSError *error))failure;
@end
