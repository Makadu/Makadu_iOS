//
//  Evaluation.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 4/10/16.
//  Copyright © 2016 Madhava. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Evaluation : NSObject

@property(nonatomic, strong) NSString *ID;
@property(nonatomic, strong) NSString *value;
@property(nonatomic, strong) NSString *eventId;

- (instancetype)initWithAttributes:(NSDictionary *)attributes;
+(void)save:(NSArray *)eveluations;
+(NSArray *)retriveEvaluations:(NSString *)eventId;

@end
