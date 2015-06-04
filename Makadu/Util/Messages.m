//
//  Messages.m
//  Makadu_iOS
//
//  Created by Marcio Habigzang Brufatto on 4/1/15.
//  Copyright (c) 2015 Makadu. All rights reserved.
//

#import "Messages.h"

@implementation Messages

+(void)failMessageWithTitle:(NSString *)title andMessage:(NSString *)message {
    
    [TSMessage showNotificationWithTitle:title
                                subtitle:message
                                    type:TSMessageNotificationTypeError];
}

+(void)successMessageWithTitle:(NSString *)title andMessage:(NSString *)message {

    [TSMessage showNotificationWithTitle:title
                                subtitle:message
                                    type:TSMessageNotificationTypeSuccess];
}

+(void)simpleMessageWithTitle:(NSString *)title andMessage:(NSString *)message {
    
    [TSMessage showNotificationWithTitle:title
                                subtitle:message
                                    type:TSMessageNotificationTypeSuccess];
}

@end
