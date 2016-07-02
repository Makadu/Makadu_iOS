//
//  Answer.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 3/31/16.
//  Copyright © 2016 Madhava. All rights reserved.
//

#import "Answer.h"

@implementation Answer

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.ID   = [attributes valueForKeyPath:@"id"];
    self.answer = [attributes valueForKeyPath:@"answer"];
    
    return self;
}

@end
