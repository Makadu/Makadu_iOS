//
//  Talk.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/26/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "Talk.h"
#import "TalkDAO.h"
#import "TalkFavoriteDAO.h"

@implementation Talk

- (void)toggleFavorite:(BOOL)isFavorite {
    if (![PFUser currentUser]) {
        return;
    }
    NSArray *favorites = [[NSUserDefaults standardUserDefaults] objectForKey:@"favorities_talks"];
    
    PFObject * talk = [TalkDAO fetchTalkByTalkId:self];
    
    if (isFavorite) {
        if (favorites == nil) {
            favorites = @[ talk ];
        } else {
            favorites = [favorites arrayByAddingObject:talk];
        }
        [TalkFavoriteDAO saveFavorities:favorites];
    } else {
        
        [TalkFavoriteDAO removeFavorite:@[talk]];
    }
}

- (BOOL)isFavorite {
    NSArray * favorities = [PFUser currentUser][@"favorities_talks"];
    for (PFObject * object in favorities) {
        if ([object.objectId isEqualToString:self.talkID]) {
            return YES;
        }
    }
    return NO;
}


@end
