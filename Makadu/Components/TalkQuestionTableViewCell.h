//
//  TalkQuestionTableViewCell.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/28/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TalkQuestionTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel * questionLabel;
@property (nonatomic, weak) IBOutlet UILabel * questionigLabel;

+ (CGFloat)calculateCellHeightWithQuestion:(NSString *)question questioning:(NSString *)questioning width:(CGFloat)width;
@end
