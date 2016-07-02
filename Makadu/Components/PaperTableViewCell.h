//
//  PaperTableViewCell.h
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 4/6/16.
//  Copyright © 2016 Madhava. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaperTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *title;
@property (nonatomic, weak) IBOutlet UILabel *authors;
@property (nonatomic, weak) IBOutlet UILabel *abstract;

@end
