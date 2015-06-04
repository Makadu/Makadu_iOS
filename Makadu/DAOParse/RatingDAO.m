//
//  RatingDAO.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 6/3/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "RatingDAO.h"
#import "Connection.h"
#import "Rating.h"

@implementation RatingDAO

+ (void)saveRating:(Rating *)rating {
    
    PFObject * ratingObject = [PFObject objectWithClassName:@"Rating"];
    ratingObject[@"description"] = rating.ratingDescription;
    ratingObject[@"note"] = rating.note;
    ratingObject[@"talk"] = rating.talk;
    ratingObject[@"user"] = rating.user;
    [ratingObject saveInBackground];
}

+ (Rating *)fetchRatingByUserAndTalk:(PFUser *)user talk:(PFObject *)talk {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Rating"];
    [query whereKey:@"talk" equalTo:talk];
    [query whereKey:@"user" equalTo:user];
    [query orderByDescending:@"createdAt"];
    
    if (![Connection existConnection]) {
        [query setCachePolicy:kPFCachePolicyCacheOnly];
    } else {
        [query setCachePolicy:kPFCachePolicyCacheElseNetwork];
        [query setMaxCacheAge:1];
    }
    
    PFObject * ratingObject = [query getFirstObject];
    
    Rating *rating = [Rating new];
    rating.user = [ratingObject objectForKey:@"user"];
    rating.talk = [ratingObject objectForKey:@"talk"];
    rating.note = [ratingObject objectForKey:@"note"];
    rating.ratingDescription = [ratingObject objectForKey:@"description"];
    
    return rating;
}

@end
