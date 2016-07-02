//
//  PollTalkTableViewCell.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 3/30/16.
//  Copyright © 2016 Madhava. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PollTalkTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleAndHourlabel;
@property (nonatomic, weak) IBOutlet UILabel *localAndDuration;
@property (nonatomic, weak) IBOutlet UILabel *speakers;

@property (nonatomic, weak) IBOutlet UIButton *btnDownload;
@property (nonatomic, weak) IBOutlet UIButton *btnQuestion;
@property (nonatomic, weak) IBOutlet UIButton *btnFavorite;
@property (nonatomic, weak) IBOutlet UIButton *btnPoll;

@end
