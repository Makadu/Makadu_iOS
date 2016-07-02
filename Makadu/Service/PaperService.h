//
//  PaperService.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 4/5/16.
//  Copyright © 2016 Madhava. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaperService : NSObject

+(NSURLSessionDataTask *)getPapersWithEventId:(NSString *)eventId block:(void (^)(NSArray *papers, NSError *error))block;

@end
