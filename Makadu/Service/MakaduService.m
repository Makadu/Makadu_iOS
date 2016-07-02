//
//  MakaduService.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 10/25/15.
//  Copyright © 2015 Madhava. All rights reserved.
//

#import "MakaduService.h"

static NSString * const AFAppMakaduBaseRESTURLString = @"KEY_SERVER";

@implementation MakaduService

+(instancetype) sharedInstance {
    static MakaduService *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[MakaduService alloc] initWithBaseURL:[NSURL URLWithString:AFAppMakaduBaseRESTURLString]];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    });
    
    return _sharedClient;
}

@end
