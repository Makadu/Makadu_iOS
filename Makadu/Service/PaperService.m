//
//  PaperService.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 4/5/16.
//  Copyright © 2016 Madhava. All rights reserved.
//

#import "PaperService.h"
#import "MakaduService.h"
#import "Paper.h"

@implementation PaperService

+(NSURLSessionDataTask *)getPapersWithEventId:(NSString *)eventId block:(void (^)(NSArray *papers, NSError *error))block {
    
    return [[MakaduService sharedInstance] GET:[NSString stringWithFormat:@"/events/%@/papers", eventId] parameters:nil success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSMutableArray *mutablePapers = [[NSMutableArray alloc] init];
        for (NSDictionary *attributes in JSON) {
            Paper *paper = [[Paper alloc] initWithAttributes:attributes];
            [mutablePapers addObject:paper];
        }
        
        if (block) {
            [Paper save:mutablePapers];
            block([NSArray arrayWithArray:mutablePapers], nil);
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (block) {
            block([NSArray array], error);
        }
    }];
}

@end
