//
//  ViewController1.m
//  DuanJiaHuanProject
//
//  Created by 段佳欢 on 15/9/23.
//  Copyright (c) 2015年 段佳欢. All rights reserved.
//

#import "ViewController1.h"
#import "MessageViewController.h"
#import "MJRefresh.h"
#import "ConversationEntity.h"
#import "MessageListTableViewCell.h"
#import "NSDate+Category.h"
#import "UIImageView+WebCache.h"
#import "EaseConvertToCommonEmoticonsHelper.h"

@interface ViewController1 () <UITableViewDataSource, UITableViewDelegate>

{
    dispatch_queue_t refreshQueue;
    NSIndexPath *_currentLongPressIndexPath;
}

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *dataSource;

@end

@implementation ViewController1

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self buildView];
    
    [self loadData];
}

- (void)buildView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, MainScreenWidth, MainScreenHeight - 64 - 49) style:(UITableViewStyleGrouped)];
    self.tableView.backgroundColor = [UIColor clearColor];
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
    __weak typeof(self) weakself = self;
    if (!refreshQueue) {
        refreshQueue = dispatch_queue_create("com.easemob.conversation.refresh", DISPATCH_QUEUE_SERIAL);
    }
    dispatch_async(refreshQueue, ^{
        NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
        NSArray* sorted = [conversations sortedArrayUsingComparator:
                           ^(EMConversation *obj1, EMConversation* obj2){
                               EMMessage *message1 = [obj1 latestMessage];
                               EMMessage *message2 = [obj2 latestMessage];
                               if(message1.timestamp > message2.timestamp) {
                                   return(NSComparisonResult)NSOrderedAscending;
                               }else {
                                   return(NSComparisonResult)NSOrderedDescending;
                               }
                           }];
        
        [weakself.dataSource removeAllObjects];
        for (EMConversation *conversation in sorted) {
            if (conversation) {
                ConversationEntity *model = [[ConversationEntity alloc] initWithConversation:conversation];
                [weakself.dataSource addObject:model];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.tableView reloadData];
        });
    });
}

#pragma mark - Action

- (void)deleteLongPress:(UILongPressGestureRecognizer *)recognizer
{
    if(recognizer.state == UIGestureRecognizerStateBegan) {
        MessageListTableViewCell *cell = (MessageListTableViewCell *)recognizer.view;
        if (cell.indexPath.section != 0) {
            _currentLongPressIndexPath = cell.indexPath;
            NSString *title = [NSString stringWithFormat:@"删除与%@的会话吗？", cell.nameLabel.text];
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"确定", nil];
            [actionSheet showInView:self];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    MessageListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell= [[[NSBundle mainBundle] loadNibNamed:@"MessageListTableViewCell" owner:nil options:nil] firstObject];
        
        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteLongPress:)];
        recognizer.minimumPressDuration = 0.5; //设置最小长按时间；默认为0.5秒
        [cell addGestureRecognizer:recognizer];
    }
    
    if (self.dataSource.count > indexPath.row) {
        ConversationEntity *model = [self.dataSource objectAtIndex:indexPath.row];
        [cell.headImgView sd_setImageWithURL:[NSURL URLWithString:model.iconUrl] placeholderImage:model.defaultImage];
        cell.nameLabel.text = model.title;
        cell.detailLabel.text = [self _latestMessageTitleForConversationModel:model];
        cell.timeLabel.text = [self _latestMessageTimeForConversationModel:model];
        if (model.conversation.unreadMessagesCount == 0) {
            cell.badgeLabel.hidden = YES;
        } else {
            cell.badgeLabel.hidden = NO;
            cell.badgeLabel.text = [NSString stringWithFormat:@"%d", model.conversation.unreadMessagesCount];
        }
    }
    
    cell.indexPath = indexPath;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.dataSource.count > indexPath.row) {
        ConversationEntity *model = self.dataSource[indexPath.row];
        
        self.hidesBottomBarWhenPushed = YES;
        MessageViewController *messageVC = [[MessageViewController alloc] initWithConversationChatter:model.conversation.conversationId conversationType:EMConversationTypeChat messageExt:nil];
        messageVC.title = model.title;
        [self.navigationController pushViewController:messageVC animated:YES];
        self.hidesBottomBarWhenPushed = NO;
    }
}

#pragma mark - private

- (NSString *)_latestMessageTitleForConversationModel:(ConversationEntity *)conversationModel
{
    NSString *latestMessageTitle = @"";
    EMMessage *lastMessage = [conversationModel.conversation latestMessage];
    if (lastMessage) {
        EMMessageBody *messageBody = lastMessage.body;
        switch (messageBody.type) {
            case EMMessageBodyTypeImage:{
                latestMessageTitle = @"[图片]";
            } break;
            case EMMessageBodyTypeText:{
                latestMessageTitle = [EaseConvertToCommonEmoticonsHelper
                                      convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
            } break;
            case EMMessageBodyTypeVoice:{
                latestMessageTitle = @"[音频]";
            } break;
            case EMMessageBodyTypeLocation: {
                latestMessageTitle = @"[位置]";
            } break;
            case EMMessageBodyTypeVideo: {
                latestMessageTitle = @"[视频]";
            } break;
            case EMMessageBodyTypeFile: {
                latestMessageTitle = @"文件";
            } break;
            default: {
            } break;
        }
    }
    return latestMessageTitle;
}

- (NSString *)_latestMessageTimeForConversationModel:(ConversationEntity *)conversationModel
{
    NSString *latestMessageTime = @"";
    EMMessage *lastMessage = [conversationModel.conversation latestMessage];;
    if (lastMessage) {
        latestMessageTime = [NSDate formattedTimeFromTimeInterval:lastMessage.timestamp];
    }
    
    return latestMessageTime;
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
