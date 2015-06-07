//
//  TalkFavoriteListTableViewController.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 6/6/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "TalkFavoriteListTableViewController.h"

#import "TalkTableViewCell.h"

#import "TalkFavoriteDAO.h"
#import "TalkDAO.h"

@interface TalkFavoriteListTableViewController ()

@property (nonatomic, strong) NSArray * listTalk;
@property (nonatomic, strong) Event * event;

@end

@implementation TalkFavoriteListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showEventViewController = (ShowEventViewController *)self.tabBarController;
    self.showEventViewController.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.translucent = NO;
    
    self.event = self.showEventViewController.event;
    
    self.navigationController.navigationBar.topItem.title = @"Favoritos";
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    [self fetchTalks];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.listTalk count] > 0)
        return [self.listTalk count];
    return 0;
}

#pragma mark - Table view delagate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * cellEvent = @"listTalkCell";
    TalkTableViewCell *cell = (TalkTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellEvent];
    
    if (cell == nil) {
        cell = [[TalkTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellEvent];
    }
    
    if(indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    
    Talk * talk = [self.listTalk objectAtIndex:indexPath.row];
    
    cell.titleAndHourlabel.text = [NSString stringWithFormat:@"%@ %@", talk.startHour, talk.title];
    [cell.titleAndHourlabel sizeToFit];
    cell.localAndDuration.text = [NSString stringWithFormat:@"%@ - %@ às %@", talk.local, talk.startHour, talk.endHour];
    [cell.localAndDuration sizeToFit];
    cell.speakers.text = [self showSpeakers:talk.speakers];
    [cell.speakers sizeToFit];
    
    cell.btnDownload.hidden = !talk.allowFile;
    cell.btnQuestion.hidden = !talk.allowQuestion;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Talk * talk = [self.listTalk objectAtIndex:indexPath.row];
    
    CGFloat height = [TalkTableViewCell calculateCellHeightWithTitle:[NSString stringWithFormat:@"%@ %@", talk.startHour, talk.title] localAndDuration:[NSString stringWithFormat:@"%@ - %@ às %@", talk.local, talk.startHour, talk.endHour] speakers:[self showSpeakers:talk.speakers] width:[[UIScreen mainScreen] bounds].size.width - 40];
    
    height += 95;
    
    if (!talk.allowFile && !talk.allowQuestion)
        height -= 20;
    
    if ([talk.speakers count] == 0)
        height -= 30;
    
    return height;
}

#pragma mark - fetch

-(void)fetchTalks {
    if (self.showEventViewController.eventObject == nil) {
        self.listTalk = nil;
        [self.tableView reloadData];
    } else {
        [TalkFavoriteDAO fetchTalkFavoriteByEvent:self.showEventViewController.eventObject talks:^(NSArray * talks){
            self.listTalk = talks;
            [self.tableView reloadData];
        } failure:^(NSString * error) {
            NSLog(@"%@", error);
        }];
    }
}

#pragma mark - Extraction speaker

-(NSString *)showSpeakers:(NSArray *)aSpeakers
{
    NSMutableString *speakers = [NSMutableString new];
    if ([aSpeakers count] == 1) {
        speakers = [NSMutableString stringWithFormat:@" - %@", aSpeakers[0][@"full_name"]];
    } else {
        for (PFObject * speaker in aSpeakers) {
            [speakers appendString:[NSString stringWithFormat:@" - %@", speaker[@"full_name"]]];
        }
    }
    return speakers;
}
@end