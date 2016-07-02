//
//  DeviceService.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 3/11/16.
//  Copyright © 2016 Madhava. All rights reserved.
//

#import "DeviceService.h"
#import "MakaduService.h"

#import "User.h"

@implementation DeviceService

+(void)setPushToken:(NSData *)deviceToken {
    
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    NSString* savedDeviceToken = @"deviceToken";
    NSData* device = [NSKeyedArchiver archivedDataWithRootObject:deviceToken];
    [preferences setObject:device forKey: savedDeviceToken];
    [preferences synchronize];
}

+(NSData *)loadDeviceToken {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    NSString* savedDeviceToken = @"deviceToken";
    
    id device = [preferences objectForKey:savedDeviceToken];
    return [NSKeyedUnarchiver unarchiveObjectWithData: device];
}

+ (void)sentDeviceToken:(NSData *)deviceToken withCompletitionBlock:(void(^)(AFHTTPRequestOperation *operation,id responseObject)) success andFailBlock:(void(^)(AFHTTPRequestOperation *operation,NSError *error))failure {
    
    NSLog(@"Model: %@ - System: %@ - Device: %@",[UIDevice currentDevice].model, [UIDevice currentDevice].systemVersion, deviceToken);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"mobile_device": @{@"model":[UIDevice currentDevice].model, @"os":[UIDevice currentDevice].systemVersion, @"push_id":deviceToken}};
    
    [manager POST:[NSString stringWithFormat:@"http://api.makadu.net/users/%@/mobile_devices/new", [User currentUser].ID] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation, responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}
@end
