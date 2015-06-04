//
//  NoticeTableViewCell.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/31/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoticeTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel * noticeLabel;
@property (nonatomic, weak) IBOutlet UILabel * noticeDetailLabel;

+ (CGFloat)calculateCellHeightWithNotice:(NSString *)notice noticeDetail:(NSString *)noticeDetail width:(CGFloat)width;
@end
