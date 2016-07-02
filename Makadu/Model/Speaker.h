//
//  Speaker.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 11/1/15.
//  Copyright © 2015 Madhava. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Speaker : NSObject

@property(nonatomic, strong) NSString *ID;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *about;
@property(nonatomic, strong) NSString *createdAt;
@property(nonatomic, strong) NSString *updatedAt;

- (instancetype)initWithAttributes:(NSDictionary *)attributes;

+(NSArray *)retrieveByTalkId:(NSString *)talkId;
+(BOOL)existSpeakerForTalk:(NSString *)talkId;
@end
