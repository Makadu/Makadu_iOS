//
//  AppHelper.m
//  Tcc
//
//  Created by Márcio Habigzang Brufatto on 21/10/13.
//  Copyright (c) 2013 Márcio Habigzang Brufatto. All rights reserved.
//

#import "AppHelper.h"

@implementation AppHelper

+(BOOL)existAccessInternet
{
    BOOL sucesso = false;
    const char *hostPing = [@"google.com"cStringUsingEncoding:NSASCIIStringEncoding];
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL,hostPing);
    SCNetworkReachabilityFlags flags;
    sucesso = SCNetworkReachabilityGetFlags(reachability, &flags);
    BOOL isAvailable = sucesso && (flags & kSCNetworkFlagsReachable) &&
    !(flags & kSCNetworkFlagsConnectionRequired);
    if (isAvailable) {
        return YES;
    }else{
        return NO;
    }
}

+(AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

+ (void)setNetworkActivityIndicatorVisible:(BOOL)visible
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:visible];
}

+ (NSString *)pathNameDatabase
{
    NSArray* dirPaths;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    return [[dirPaths objectAtIndex:0] stringByAppendingPathComponent:@"Makadu.sqlite"];
}

@end