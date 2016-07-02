//
//  NoticeTableViewCell.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/31/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "NoticeTableViewCell.h"

@implementation NoticeTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    return [super initWithStyle:style reuseIdentifier:reuseIdentifier];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

+ (CGFloat)calculateCellHeightWithNotice:(NSString *)notice noticeDetail:(NSString *)noticeDetail width:(CGFloat)width {
    
    NSAttributedString *attributedNotice = [[NSAttributedString alloc] initWithString:notice attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f]}];
    
    CGRect noticeRect = [attributedNotice boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                           context:nil];
    CGSize noticeSize = noticeRect.size;
    
    
    NSAttributedString *attributedNoticeDetail = [[NSAttributedString alloc] initWithString:noticeDetail attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f]}];
    
    CGRect noticeDetailRect = [attributedNoticeDetail boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                                 context:nil];
    CGSize noticeDetailSize = noticeDetailRect.size;
    
    
    return noticeSize.height + noticeDetailSize.height;
}

@end
