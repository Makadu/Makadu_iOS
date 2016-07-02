//
//  Poll.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 3/31/16.
//  Copyright © 2016 Madhava. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Poll : NSObject

@property(nonatomic, strong) NSString *ID;
@property(nonatomic, strong) NSString *talkID;
@property(nonatomic, strong) NSString *startTime;
@property(nonatomic, strong) NSString *endTime;
@property(nonatomic, strong) NSString *currentTime;
@property(nonatomic, strong) NSString *question;
@property(nonatomic, strong) NSArray *answers;

- (instancetype)initWithAttributes:(NSDictionary *)attributes answers:(NSArray *)aAnswers;
@end
