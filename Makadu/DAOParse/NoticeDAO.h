//
//  NoticeDAO.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/31/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface NoticeDAO : NSObject

+(void)fetchNoticeByEvent:(PFObject *)event notices:(void(^)(NSArray* notices))success failure:(void(^)(NSString *errorMessage))failure;

@end
