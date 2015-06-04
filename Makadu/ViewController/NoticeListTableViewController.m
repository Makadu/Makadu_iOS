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
#import "Analitcs.h"
#import "NoticeTableViewCell.h"

@interface NoticeListTableViewController ()

@property (nonatomic, strong) NSArray * listNotice;
@property (nonatomic, strong) PFObject *talkObject;
@property (nonatomic, strong) Notice * notice;
@property (nonatomic, strong) Event * event;

@end

@implementation NoticeListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showEventViewController = (ShowEventViewController *)self.tabBarController;
    self.showEventViewController.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.translucent = NO;
    
    self.event = self.showEventViewController.event;
    
    self.navigationController.navigationBar.topItem.title = @"Palestras";
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor lightGrayColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(getLatestNotices) forControlEvents:UIControlEventValueChanged];

    [self fetchNotices];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    if (self.showEventViewController.eventObject != nil) {
        [Analitcs saveDataAnalitcsWithUser:[PFUser currentUser] typeOperation:@"Acessou" screenAccess:@"Lista de Noticias" description:@"O usuário acessou a lista de Noticias do evento" event:self.showEventViewController.eventObject];
    } else {
        [Analitcs saveDataAnalitcsWithUser:[PFUser currentUser] typeOperation:@"Acessou" screenAccess:@"Lista de Noticias" description:@"O usuário sem acesso a internet"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Update notices
- (void)getLatestNotices
{
    
    if (self.showEventViewController.eventObject != nil) {
        [Analitcs saveDataAnalitcsWithUser:[PFUser currentUser] typeOperation:@"Atualizou" screenAccess:@"Lista de Noticias" description:@"O usuário atualizou o lista de Avisos do evento" event:self.showEventViewController.eventObject];
    } else {
        [Analitcs saveDataAnalitcsWithUser:[PFUser currentUser] typeOperation:@"Atualizou" screenAccess:@"Lista de Noticias" description:@"O usuário sem acesso a internet"];
    }
    
    [self fetchNotices];
}

- (void)reloadData
{
    // Reload table data
    [self.tableView reloadData];
    
    if (self.refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictonary = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictonary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        [self.refreshControl endRefreshing];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.listNotice count] > 0) {
        return [self.listNotice count];
    } else {
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Notice * notice = [self.listNotice objectAtIndex:indexPath.row];
    
    CGFloat height = [NoticeTableViewCell calculateCellHeightWithNotice:notice.notice noticeDetail:notice.noticeDetail width:[[UIScreen mainScreen] bounds].size.width];
    
    return height + 52;
}

#pragma Mark - fetch

-(void)fetchNotices {
    if (self.showEventViewController.eventObject == nil) {
        self.listNotice = nil;
        [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    } else {
        [NoticeDAO fetchNoticeByEvent:self.showEventViewController.eventObject notices:^(NSArray * objects) {
            self.listNotice = objects;
            [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        } failure:^(NSString * error) {
            NSLog(@"%@", error);
        }];
    }
}
@end
