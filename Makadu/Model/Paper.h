//
//  Paper.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 4/5/16.
//  Copyright © 2016 Madhava. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Paper : NSObject

@property(nonatomic, strong) NSString *ID;
@property(nonatomic, strong) NSString *abstract;
@property(nonatomic, strong) NSString *authors;
@property(nonatomic, strong) NSString *eventId;
@property(nonatomic, strong) NSString *reference;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *createdAt;
@property(nonatomic, strong) NSString *updatedAt;

- (instancetype)initWithAttributes:(NSDictionary *)attributes;

+(void)save:(NSArray *)papers;
+(NSArray *)retrivePapers:(NSString *)eventId;

@end
