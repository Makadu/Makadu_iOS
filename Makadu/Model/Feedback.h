//
//  Feedback.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 4/10/16.
//  Copyright © 2016 Madhava. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Feedback : NSObject

@property(nonatomic, strong) NSString *question;
@property(nonatomic, strong) NSString *evaluationId;
@property(nonatomic, strong) NSString *value;
@property(nonatomic, strong) NSString *commentary;
@property(nonatomic, strong) NSString *eventId;

+(void)save:(NSArray *)feedbacks;
+(NSArray *)retriveFeedbacks;
+(void)removeAllFeedbacks;

@end
