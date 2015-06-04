//
//  Messages.h
//  Makadu_iOS
//
//  Created by Marcio Habigzang Brufatto on 4/1/15.
//  Copyright (c) 2015 Makadu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TSMessages/TSMessageView.h>

@interface Messages : NSObject

+(void)failMessageWithTitle:(NSString *)title andMessage:(NSString *)message;
+(void)successMessageWithTitle:(NSString *)title andMessage:(NSString *)message;
+(void)simpleMessageWithTitle:(NSString *)title andMessage:(NSString *)message;

@end
