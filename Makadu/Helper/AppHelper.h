//
//  AppHelper.h
//  Tcc
//
//  Created by Márcio Habigzang Brufatto on 21/10/13.
//  Copyright (c) 2013 Márcio Habigzang Brufatto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "AppDelegate.h"

@interface AppHelper : NSObject

+ (AppDelegate *)appDelegate;
+ (BOOL)existAccessInternet;
+ (NSString *)pathNameDatabase;

@end
