//
//  RatingDAO.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 6/3/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Rating.h"

@interface RatingDAO : NSObject

+ (void)saveRating:(Rating *) rating;
+ (Rating *)fetchRatingByUserAndTalk:(PFUser *)user talk:(PFObject *)talk;

@end
