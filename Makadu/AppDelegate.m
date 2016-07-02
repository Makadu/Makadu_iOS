//
//  AppDelegate.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/23/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "AppDelegate.h"
#import "Localytics.h"
#import "DeviceService.h"
#import "Notice.h"
#import "ShowEventViewController.h"

#import "AFNetworkActivityIndicatorManager.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:20 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
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
    [Localytics autoIntegrate:@"9169792b91ab629dcb9298a-807aecba-2cd0-11e5-22bb-00020191b0b4" launchOptions:launchOptions];
    
    if (application.applicationState != UIApplicationStateBackground)
    {
        [Localytics openSession];
    }
         
    [self databaseCopy];
    
    return YES;
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    application.applicationIconBadgeNumber = 0;
    
    [Notice reloadNotices:userInfo];
    
    [Localytics handlePushNotificationOpened:userInfo];
    completionHandler(UIBackgroundFetchResultNoData);
}

-(void)applicationDidBecomeActive:(UIApplication *)application {
    
    application.applicationIconBadgeNumber = 0;
    
    [Localytics openSession];
    [Localytics upload];
}

-(void)applicationWillEnterForeground:(UIApplication *)application {
    
    [Localytics openSession];
    [Localytics upload];
}

-(void)applicationDidEnterBackground:(UIApplication *)application {
    
    [Localytics dismissCurrentInAppMessage];
    [Localytics closeSession];
    [Localytics upload];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    return [Localytics handleTestModeURL:url];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    [DeviceService setPushToken:deviceToken];
    [Localytics setPushToken:deviceToken];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    NSLog(@"Failed to register for remote notifications: %@", [error description]);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo {
    
    NSLog(@"Receved push Notification");
}

-(void)databaseCopy
{
    NSString *dbPath = [[NSBundle mainBundle] pathForResource:@"Makadu" ofType:@"sqlite"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [NSString stringWithFormat:@"%@/Makadu.sqlite", [paths objectAtIndex:0]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:path])
    {
        NSURL *urlFile = [[NSURL alloc] initFileURLWithPath:path];
        
        NSError *error = nil;
        
        [fileManager copyItemAtPath:dbPath toPath:path error:&error];
        
        [urlFile setResourceValue: [NSNumber numberWithBool: YES] forKey:
         NSURLIsExcludedFromBackupKey error: &error];
    }
}
@end
