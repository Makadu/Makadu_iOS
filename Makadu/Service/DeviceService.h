//
//  DeviceService.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 3/11/16.
//  Copyright © 2016 Madhava. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPSessionManager.h>
#import <AFNetworking/AFNetworking.h>

@interface DeviceService : NSObject

+(void)setPushToken:(NSData *)deviceToken;
+(NSData *)loadDeviceToken;

+ (void)sentDeviceToken:(NSData *)deviceToken withCompletitionBlock:(void(^)(AFHTTPRequestOperation *operation,id responseObject)) success andFailBlock:(void(^)(AFHTTPRequestOperation *operation,NSError *error))failure;

@end
