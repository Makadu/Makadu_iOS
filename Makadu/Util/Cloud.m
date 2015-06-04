//
//  Cloud.m
//  Makadu_iOS
//
//  Created by Marcio Habigzang Brufatto on 4/13/15.
//  Copyright (c) 2015 Makadu. All rights reserved.
//

#import "Cloud.h"
#import "Messages.h"

@implementation Cloud

+(void)sendMail:(NSString *)toEmail url:(NSString *)url talkName:(NSString *)talkName {

        [PFCloud callFunctionInBackground:@"sendMail"
                       withParameters:@{@"toEmail":toEmail,
                                        @"fromEmail":@"no-reply@makadu.net",
                                        @"text":[NSString stringWithFormat:@"Material da palestra - %@ \n Clique no link abaixo para realizar o download do material \n\n %@", talkName, url],
                                        @"subject":[NSString stringWithFormat:@"Material da palestra - %@", talkName]}
                            block:^(NSString *result, NSError *error) {
                                if (!error) {
                                    [Messages successMessageWithTitle:nil andMessage:[NSString stringWithFormat:@"O material foi enviado para o e-mail %@ com sucesso!", toEmail]];
                                } else {
                                    NSLog(@"ERROR ==== %@", error.localizedDescription);
                                }
                            }];
}

@end
