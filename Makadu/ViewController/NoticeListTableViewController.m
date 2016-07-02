//
//  NoticeListTableViewController.m
//  Makadu
//
//  Created by Marcio Habigzang Brufatto on 5/31/15.
//  Copyright (c) 2015 Madhava. All rights reserved.
//

#import "NoticeListTableViewController.h"
#import "Notice.h"
#import "Event.h"
#import "NoticeDAO.h"
#import "NoticeTableViewCell.h"
#import "Localytics.h"
#import "User.h"
#import "Connection.h"
#import "UIRefreshControl+AFNetworking.h"
#import "UIAlertView+AFNetworking.h"

@interface NoticeListTableViewController ()

@property (nonatomic, strong) NSArray * listNotice;
@property (nonatomic, strong) Notice * notice;

@end

@implementation NoticeListTableViewController

- (void)reload:(__unused id)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    NSURLSessionTask *task = [Notice getNoticesByEvent:self.event.ID block:^(NSArray *notices, NSError *error) {
        if (!error) {
            self.listNotice = notices;
            [self.tableView reloadData];
            [Notice updateNoticeVisualized:self.listNotice andEventId:self.event.ID];
        } else {
            NSLog(@"Ocorreu um erro");
        }
    }];
    
    [UIAlertView showAlertViewForTaskWithErrorOnCompletion:task delegate:nil];
    [self.refreshControl setRefreshingWithStateOfTask:task];
}

- (void)retriveLocal {
    self.listNotice = [Notice getNotices:self.showEventViewController.event.ID];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showEventViewController = (ShowEventViewController *)self.tabBarController;
    self.event = self.showEventViewController.event;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload:) name:@"pushNotices" object:nil];
    
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 100.0f)];
    [self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    [self.tableView.tableHeaderView addSubview:self.refreshControl];
    
    [self configureTableView];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    if (![Connection existConnection]) {
        [self retriveLocal];
    } else {
        [self reload:nil];
    }
    
    [Notice updateNoticeVisualized:self.listNotice andEventId:self.event.ID];
    
    [self.tableView reloadData];
    
    [[self.tabBarController.viewControllers objectAtIndex:3] tabBarItem].badgeValue = nil;
    
    [Localytics tagEvent:@"Notices" attributes:@{@"Username" : [User currentUser].userName, @"Event:" : self.event.title }];
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.listNotice count] > 0) {
        self.tableView.backgroundView = nil;
        return [self.listNotice count];
    } else {
        UILabel * messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        messageLabel.text = NSLocalizedString(@"no_notices_yet", nil);
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        messageLabel.tag = 3000;
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * cellEvent = @"listNoticeCell";
    NoticeTableViewCell *cell = (NoticeTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellEvent];
    
    if (cell == nil) {
        cell = [[NoticeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellEvent];
    }
    
    if(indexPath.row % 2 == 0)
        cell.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1];
    else
        cell.backgroundColor = [UIColor whiteColor];
    
    Notice * notice = [self.listNotice objectAtIndex:indexPath.row];
    
    cell.noticeLabel.text = notice.notice;
    cell.noticeDetailLabel.text = notice.noticeDetail;
    
    return cell;
}

#pragma mark - Other methods Table View

-(void) configureTableView {
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 160.0;
}

@end
