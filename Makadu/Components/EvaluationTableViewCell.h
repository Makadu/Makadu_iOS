//
//  EvaluationTableViewCell.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 4/13/16.
//  Copyright © 2016 Madhava. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EDStarRating/EDStarRating.h>

@interface EvaluationTableViewCell : UITableViewCell <EDStarRatingProtocol, UITextViewDelegate>

@property (nonatomic, strong) IBOutlet UILabel *question;
@property (nonatomic, strong) IBOutlet EDStarRating *stars;
@property (nonatomic, strong) IBOutlet UITextView *commentary;
@property (nonatomic, strong) NSString *evaluationId;
@property (nonatomic, strong) NSString *eventId;
@property (nonatomic, strong) UITableView *tableview;

@end


