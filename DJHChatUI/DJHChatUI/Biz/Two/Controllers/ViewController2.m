//
//  ViewController1.m
//  DuanJiaHuanProject
//
//  Created by 段佳欢 on 15/9/23.
//  Copyright (c) 2015年 段佳欢. All rights reserved.
//

#import "ViewController2.h"
#import "MessageViewController.h"
#import "MJRefresh.h"

@interface ViewController2 () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *dataSource;

@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self buildView];
    
    [self loadData];
}

- (void)buildView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, MainScreenWidth, MainScreenHeight - 64 - 49) style:(UITableViewStyleGrouped)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [self loadData];
    __weak typeof(self) weakself = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakself loadData];
        [weakself.tableView.mj_header endRefreshing];
    }];
}

- (void)loadData
{
    EMError *error = nil;
    NSArray *buddyList = [[EMClient sharedClient].contactManager getContactsFromServerWithError:&error];
    
    if (!error) {
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:buddyList];
        [self.tableView reloadData];
    }
    
    NSArray *buddys = [[EMClient sharedClient].contactManager getContactsFromDB];
    if (buddys.count > 0) {
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:buddys];
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        return self.dataSource.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cellId];
        cell.imageView.layer.masksToBounds = YES;
        cell.imageView.layer.cornerRadius = 5;
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = @"联系客服";
    } else {
        NSString *buddy = self.dataSource[indexPath.row];
        
        cell.textLabel.text = buddy;
    }
    
    UIImage *icon = [UIImage imageNamed:@"friend_head_default"];
    CGSize itemSize = CGSizeMake(40, 40);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO,0.0);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [icon drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 0) {
        self.hidesBottomBarWhenPushed = YES;
        MessageViewController *messageVC = [[MessageViewController alloc] initWithConversationChatter:CustomerImUsername conversationType:EMConversationTypeChat messageExt:nil];
        messageVC.title = @"联系客服";
        [self.navigationController pushViewController:messageVC animated:YES];
        self.hidesBottomBarWhenPushed = NO;
    } else {
        NSString *buddy = self.dataSource[indexPath.row];
        
        self.hidesBottomBarWhenPushed = YES;
        MessageViewController *messageVC = [[MessageViewController alloc] initWithConversationChatter:buddy conversationType:EMConversationTypeChat messageExt:nil];
        messageVC.title = buddy;
        [self.navigationController pushViewController:messageVC animated:YES];
        self.hidesBottomBarWhenPushed = NO;
    }
}

#pragma mark - Getter

- (NSMutableArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    
    return _dataSource;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
