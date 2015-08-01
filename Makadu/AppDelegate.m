//
//  AppDelegate.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/23/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "AppDelegate.h"
#import "Localytics.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //Configuration of the Parse
    [Parse setApplicationId:@"IDPARSE"
                  clientKey:@"CLIENTKEY"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:(121.0/255.0) green:(175.0/255.0) blue:(168.0/255.0) alpha:1]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    
    //Configuration of the Localytics
    [Localytics autoIntegrate:@"<IDLOCALYTICS>" launchOptions:launchOptions];
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
    else
    {
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

@end
