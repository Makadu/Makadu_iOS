//
//  Answer.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 3/31/16.
//  Copyright © 2016 Madhava. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Answer : NSObject

@property(nonatomic, strong) NSString *ID;
@property(nonatomic, strong) NSString *answer;

- (instancetype)initWithAttributes:(NSDictionary *)attributes;

@end
