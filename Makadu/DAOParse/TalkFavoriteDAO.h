//
//  TalkFavoriteDAO.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 6/6/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface TalkFavoriteDAO : NSObject

+(void)fetchTalkFavoriteByEvent:(PFObject *)event talks:(void(^)(NSArray* talks))success failure:(void(^)(NSString *errorMessage))failure;
+(void)saveFavorities:(PFObject *)talk;
@end
