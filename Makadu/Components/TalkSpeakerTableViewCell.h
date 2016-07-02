//
//  TalkSpeakerTableViewCell.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/28/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TalkSpeakerTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UITextView *aboutSpeakerTextView;
@property (nonatomic, weak) IBOutlet UILabel *speakerNameLabel;

@end
