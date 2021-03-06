//
//  TalkTableViewCell.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/27/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TalkTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleAndHourlabel;
@property (nonatomic, weak) IBOutlet UILabel *localAndDuration;
@property (nonatomic, weak) IBOutlet UILabel *speakers;

@property (nonatomic, weak) IBOutlet UIButton *btnDownload;
@property (nonatomic, weak) IBOutlet UIButton *btnQuestion;
@property (nonatomic, weak) IBOutlet UIButton *btnFavorite;
@property (nonatomic, weak) IBOutlet UIButton *btnInteractive;

@end
