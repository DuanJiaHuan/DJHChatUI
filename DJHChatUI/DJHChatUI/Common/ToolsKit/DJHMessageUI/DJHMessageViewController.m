//
//  DJHMessageViewController.m
//  DJHChatUI
//
//  Created by qch－djh on 16/7/12.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import "DJHMessageViewController.h"
#import "DJHMessageTableViewCell.h"
#import "DJHTimeMessageTableViewCell.h"
#import "FaceSourceManager.h"

#import "MJRefresh.h"

#import "NSDate+Category.h"

#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "MSSBrowseDefine.h"
#import "DJHVoiceMessageHepler.h"

#import "DJHLocationViewController.h"
#import "DJHShareUrlViewController.h"

#import "ExternalShareMenu.h"


@interface DJHMessageViewController () <ChatKeyBoardDelegate, ChatKeyBoardDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, DJHMessageTableViewCellDelegate, DJHLocationViewControllerDelegate, ExternalShareMenuDelegate>

{
    dispatch_queue_t _messageQueue;
    BOOL _showExternal;
    BOOL _viewIsAppear;
}

@property (strong, nonatomic) UIImagePickerController *imagePicker;//图片选择器
@property (nonatomic) BOOL isPlayingAudio;
@property (nonatomic,readwrite) DJHMessageModel *messageForMenu;

@property (strong, nonatomic) NSMutableArray *browseItemArray;
@property (strong, nonatomic) NSMutableArray *morePanelItems;

@end

@implementation DJHMessageViewController

- (instancetype)initWithConversationChatter:(NSString *)conversationChatter
                                   conversationType:(EMConversationType)conversationType messageExt:(NSDictionary*)externalExt
{
    if ([conversationChatter length] == 0) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _conversation = [[EMClient sharedClient].chatManager getConversation:conversationChatter type:conversationType createIfNotExist:YES];
        _messsagesSource = [NSMutableArray array];
        _externalExt = [NSDictionary dictionaryWithDictionary:externalExt];
        _messageCountOfPage = 10;
        if (externalExt) {
            _showExternal = YES;
        }
        
        [_conversation markAllMessagesAsRead];
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _viewIsAppear = YES;
    if (_showExternal) {
        [self addShareView:self.externalExt];
        _showExternal = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _viewIsAppear = NO;
    [_conversation markAllMessagesAsRead];
    [[EMCDDeviceManager sharedInstance] disableProximitySensor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.view.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidHide:) name:UIMenuControllerDidHideMenuNotification object:nil];
    
    [self buildView];
    
    _messageQueue = dispatch_queue_create("easemob.com", NULL);
    
    //注册代理
    [EMCDDeviceManager sharedInstance].delegate = self;
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)buildView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 49) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1];
    [self.view addSubview:self.tableView];
    
    __weak DJHMessageViewController *weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadMessageDataSource];
        [self.tableView.mj_header endRefreshing];
    }];
    
    self.chatKeyBoard = [ChatKeyBoard keyBoard];
    self.chatKeyBoard.delegate = self;
    self.chatKeyBoard.dataSource = self;
    self.chatKeyBoard.associateTableView = self.tableView;
    [self.view addSubview:self.chatKeyBoard];
}

- (void)loadMessageDataSource
{
    NSString *messageId = nil;
    if ([self.messsagesSource count] > 0) {
        messageId = [(EMMessage *)self.messsagesSource.firstObject messageId];
    } else {
        messageId = nil;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSMutableArray *moreMessageModels = [NSMutableArray array];
        NSArray *moreMessages = [weakSelf.conversation loadMoreMessagesFromId:messageId limit:(int)self.messageCountOfPage];
        
        if ([moreMessages count] == 0) {
            return;
        }
        
        //格式化消息
        NSArray *formattedMessages = [weakSelf formatMessages:moreMessages];
        
        [weakSelf.messsagesSource insertObjects:moreMessages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [moreMessages count])]];
        NSInteger scrollToIndex = [weakSelf.dataArray count];
        //合并消息
        id firstObj = [weakSelf.dataArray firstObject];
        BOOL stop = NO;
        for (id obj in formattedMessages) {
            if ([obj isKindOfClass:[DJHMessageModel class]]) {
                [moreMessageModels addObject:obj];
            }
            
            if ([obj isKindOfClass:[NSString class]] && !stop) {
                if ([obj isEqualToString:firstObj]) {
                    [weakSelf.dataArray removeObjectAtIndex:0];
                    stop = YES;
                }
            }
        }
        
        [weakSelf.dataArray insertObjects:formattedMessages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [formattedMessages count])]];
        
        EMMessage *latest = [weakSelf.messsagesSource lastObject];
        weakSelf.messageTimeIntervalTag = latest.timestamp;
        
        //刷新页面
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
            
            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.dataArray count] - scrollToIndex - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        });
        
        //从数据库导入时重新下载没有下载成功的附件
        for (EMMessage *message in moreMessages)
        {
            [weakSelf _downloadMessageAttachments:message];
        }
        
        //发送已读回执
        [weakSelf sendHasReadResponseForMessageModels:moreMessageModels isRead:NO];
    });
}

#pragma mark - Add ShareView

- (void)addShareView:(NSDictionary *)externalExt
{
    [[ExternalShareMenu sharedInstance] showWithShareType:ExternalShareMenuTypeDefault externalExt:externalExt];
    [ExternalShareMenu sharedInstance].delegate = self;
}

#pragma mark - ExternalShareMenuDelegate

- (void)sendExternalShareMenu:(NSDictionary *)ext
{
    [self sendTextMessage:@"shareDefault" withExt:ext];
}

#pragma mark - EaseMob

#pragma mark - EMChatManagerDelegate

- (void)didReceiveMessages:(NSArray *)aMessages
{
    for (EMMessage *message in aMessages) {
        if ([self.conversation.conversationId isEqualToString:message.conversationId]) {
            [self addMessageToDataSource:message progress:nil];
            
            if ([self _shouldMarkMessageAsRead]) {
                [self.conversation markMessageAsReadWithId:message.messageId];
            }
        }
    }
}

- (void)didReceiveCmdMessages:(NSArray *)aCmdMessages
{
    for (EMMessage *message in aCmdMessages) {
        if ([self.conversation.conversationId isEqualToString:message.conversationId]) {
            [self showHint:@"有透传消息"];
            break;
        }
    }
}

- (void)didReceiveHasDeliveredAcks:(NSArray *)aMessages
{
    for(EMMessage *message in aMessages){
        [self _updateMessageStatus:message];
    }
}

- (void)didReceiveHasReadAcks:(NSArray *)aMessages
{
    for (EMMessage *message in aMessages) {
        if (![self.conversation.conversationId isEqualToString:message.conversationId]){
            continue;
        }
        
        __block DJHMessageModel *model = nil;
        __block BOOL isHave = NO;
        [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             if ([obj isKindOfClass:[DJHMessageModel class]]) {
                 model = (DJHMessageModel *)obj;
                 if ([model.messageId isEqualToString:message.messageId]) {
                     model.message.isReadAcked = YES;
                     isHave = YES;
                     *stop = YES;
                 }
             }
         }];
        
        if(!isHave){
            return;
        }
        
        [self.tableView reloadData];
    }
}

- (void)didMessageStatusChanged:(EMMessage *)aMessage
                          error:(EMError *)aError;
{
    [self _updateMessageStatus:aMessage];
}

- (void)didMessageAttachmentsStatusChanged:(EMMessage *)message
                                     error:(EMError *)error{
    if (!error) {
        EMFileMessageBody *fileBody = (EMFileMessageBody*)[message body];
        if ([fileBody type] == EMMessageBodyTypeImage) {
            EMImageMessageBody *imageBody = (EMImageMessageBody *)fileBody;
            if ([imageBody thumbnailDownloadStatus] == EMDownloadStatusSuccessed)
            {
                [self _reloadTableViewDataWithMessage:message];
            }
        }else if([fileBody type] == EMMessageBodyTypeVideo){
            EMVideoMessageBody *videoBody = (EMVideoMessageBody *)fileBody;
            if ([videoBody thumbnailDownloadStatus] == EMDownloadStatusSuccessed)
            {
                [self _reloadTableViewDataWithMessage:message];
            }
        }else if([fileBody type] == EMMessageBodyTypeVoice){
            if ([fileBody downloadStatus] == EMDownloadStatusSuccessed)
            {
                [self _reloadTableViewDataWithMessage:message];
            }
        }
        
    }else{
        
    }
}

#pragma mark - public

- (NSArray *)formatMessages:(NSArray *)messages
{
    NSMutableArray *formattedArray = [[NSMutableArray alloc] init];
    if ([messages count] == 0) {
        return formattedArray;
    }
    
    for (EMMessage *message in messages) {
        //计算時間间隔
        CGFloat interval = (self.messageTimeIntervalTag - message.timestamp) / 1000;
        if (self.messageTimeIntervalTag < 0 || interval > 60 || interval < -60) {
            NSDate *messageDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
            NSString *timeStr = [messageDate formattedTime];
            [formattedArray addObject:timeStr];
            self.messageTimeIntervalTag = message.timestamp;
        }
        
        //构建数据模型
        DJHMessageModel *messageModel = [[DJHMessageModel alloc] initWithMessage:message];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(refreshMessageModel:)]) {
            [self.delegate refreshMessageModel:messageModel];
        }
        
        if (messageModel) {
            [formattedArray addObject:messageModel];
        }
    }
    
    return formattedArray;
}

-(void)addMessageToDataSource:(EMMessage *)message
                     progress:(id)progress
{
    [self.messsagesSource addObject:message];
    
    __weak DJHMessageViewController *weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSArray *messages = [weakSelf formatMessages:@[message]];
        NSMutableArray *moreMessageModels = [NSMutableArray array];
        for (id obj in messages) {
            if ([obj isKindOfClass:[DJHMessageModel class]]) {
                [moreMessageModels addObject:obj];
            }
        }
        
        //发送已读回执
        [self sendHasReadResponseForMessageModels:moreMessageModels isRead:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.dataArray addObjectsFromArray:messages];
            [weakSelf.tableView reloadData];
            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[weakSelf.dataArray count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    });
}

#pragma mark - private helper

- (void)_scrollViewToBottom:(BOOL)animated
{
    if (self.tableView.contentSize.height > self.tableView.frame.size.height) {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        [self.tableView setContentOffset:offset animated:animated];
    }
}

- (void)_downloadMessageAttachments:(EMMessage *)message
{
    __weak typeof(self) weakSelf = self;
    void (^completion)(EMMessage *aMessage, EMError *error) = ^(EMMessage *aMessage, EMError *error) {
        if (!error) {
            [weakSelf _reloadTableViewDataWithMessage:message];
        } else {
            NSLog(@"缩略图获取失败!");
        }
    };
    
    EMMessageBody *messageBody = message.body;
    if ([messageBody type] == EMMessageBodyTypeImage) {
        EMImageMessageBody *imageBody = (EMImageMessageBody *)messageBody;
        if (imageBody.thumbnailDownloadStatus > EMDownloadStatusSuccessed)
        {
            //下载缩略图
            [[[EMClient sharedClient] chatManager] asyncDownloadMessageThumbnail:message progress:nil completion:completion];
        }
    }
    else if ([messageBody type] == EMMessageBodyTypeVideo)
    {
        EMVideoMessageBody *videoBody = (EMVideoMessageBody *)messageBody;
        if (videoBody.thumbnailDownloadStatus > EMDownloadStatusSuccessed)
        {
            //下载缩略图
            [[[EMClient sharedClient] chatManager] asyncDownloadMessageThumbnail:message progress:nil completion:completion];
        }
    }
    else if ([messageBody type] == EMMessageBodyTypeVoice)
    {
        EMVoiceMessageBody *voiceBody = (EMVoiceMessageBody*)messageBody;
        if (voiceBody.downloadStatus > EMDownloadStatusSuccessed)
        {
            //下载语言
            [[EMClient sharedClient].chatManager asyncDownloadMessageAttachments:message progress:nil completion:completion];
        }
    }
}

- (void)sendHasReadResponseForMessageModels:(NSArray*)messageModels isRead:(BOOL)isRead
{
    NSMutableArray *unreadMessageModels = [NSMutableArray array];
    for (NSInteger i = 0; i < [messageModels count]; i++) {
        DJHMessageModel *messageModel = messageModels[i];
        BOOL isSend = [self shouldSendHasReadAckForMessageModel:messageModel isRead:isRead];
        
        if (isSend) {
            [unreadMessageModels addObject:messageModel];
        }
    }
    
    if ([unreadMessageModels count]) {
        for (DJHMessageModel *messageModel in unreadMessageModels) {
            [[EMClient sharedClient].chatManager asyncSendReadAckForMessage:messageModel.message];
        }
    }
}

- (BOOL)shouldSendHasReadAckForMessageModel:(DJHMessageModel *)messageModel isRead:(BOOL)isRead
{
    NSString *account = [[EMClient sharedClient] currentUsername];
    if (messageModel.messageType != EMChatTypeChat || messageModel.message.isReadAcked || [account isEqualToString:messageModel.message.from] || ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) || !_viewIsAppear) {
        return NO;
    }
    
    if (isRead) {
        return YES;
    }
    
    if ((messageModel.bodyType == DJHMessageBodyTypeVideo) ||
         (messageModel.bodyType == DJHMessageBodyTypeVoice) ||
         (messageModel.bodyType == DJHMessageBodyTypeImage) ||
        (messageModel.bodyType == DJHMessageBodyTypeShare)) {
        return NO;
    } else {
        return YES;
    }
}

- (EMChatType)_messageTypeFromConversationType
{
    EMChatType type = EMChatTypeChat;
    switch (self.conversation.type) {
        case EMConversationTypeChat:
            type = EMChatTypeChat;
            break;
        case EMConversationTypeGroupChat:
            type = EMChatTypeGroupChat;
            break;
        case EMConversationTypeChatRoom:
            type = EMChatTypeChatRoom;
            break;
        default:
            break;
    }
    return type;
}

- (NSURL *)_convert2Mp4:(NSURL *)movUrl
{
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:AVAssetExportPresetHighestQuality];
        mp4Url = [movUrl copy];
        mp4Url = [mp4Url URLByDeletingPathExtension];
        mp4Url = [mp4Url URLByAppendingPathExtension:@"mp4"];
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"failed, error:%@.", exportSession.error);
                } break;
                case AVAssetExportSessionStatusCancelled: {
                    NSLog(@"cancelled.");
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"completed.");
                } break;
                default: {
                    NSLog(@"others.");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            NSLog(@"timeout.");
        }
        if (wait) {
            //dispatch_release(wait);
            wait = nil;
        }
    }
    
    return mp4Url;
}

- (BOOL)_canRecord
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                bCanRecord = granted;
            }];
        }
    }
    
    return bCanRecord;
}

- (BOOL)_shouldMarkMessageAsRead
{
    BOOL isMark = YES;
    if (([UIApplication sharedApplication].applicationState == UIApplicationStateBackground))
    {
        isMark = NO;
    }
    
    return isMark;
}

#pragma mark - private

- (void)_reloadTableViewDataWithMessage:(EMMessage *)message{
    __weak DJHMessageViewController *weakSelf = self;
    dispatch_async(_messageQueue, ^{
        if ([weakSelf.conversation.conversationId isEqualToString:message.conversationId]) {
            for (int i = 0; i < weakSelf.dataArray.count; i ++) {
                id object = [weakSelf.dataArray objectAtIndex:i];
                if ([object isKindOfClass:[DJHMessageModel class]]) {
                    DJHMessageModel *messageModel = object;
                    if ([message.messageId isEqualToString:messageModel.messageId]) {
                        DJHMessageModel *messageModel = nil;
                        messageModel = [[DJHMessageModel alloc] initWithMessage:message];
                        
                        if (self.delegate && [self.delegate respondsToSelector:@selector(refreshMessageModel:)]) {
                            [self.delegate refreshMessageModel:messageModel];
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.tableView beginUpdates];
                            [weakSelf.dataArray replaceObjectAtIndex:i withObject:messageModel];
                            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                            [weakSelf.tableView endUpdates];
                            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                        });
                        break;
                    }
                }
            }
        }
    });
}

- (void)_updateMessageStatus:(EMMessage *)aMessage
{
    BOOL isChatting = [aMessage.conversationId isEqualToString:self.conversation.conversationId];
    if (aMessage && isChatting) {
        DJHMessageModel *model = nil;
        model = [[DJHMessageModel alloc] initWithMessage:aMessage];
        model.avatarImage = [UIImage imageNamed:@"user"];
        model.failImageName = @"imageDownloadFail";
        if (model) {
            __block NSUInteger index = NSNotFound;
            [self.dataArray enumerateObjectsUsingBlock:^(DJHMessageModel *model, NSUInteger idx, BOOL *stop){
                if ([model isKindOfClass:[DJHMessageModel class]]) {
                    if ([aMessage.messageId isEqualToString:model.message.messageId]) {
                        index = idx;
                        *stop = YES;
                    }
                }
            }];
            
            if (index != NSNotFound)
            {
                [self.dataArray replaceObjectAtIndex:index withObject:model];
                [self.tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
            }
        }
    }
}

#pragma mark - send message

- (void)_sendMessage:(EMMessage *)message
{
    if (self.conversation.type == EMConversationTypeGroupChat){
        message.chatType = EMChatTypeGroupChat;
    }
    else if (self.conversation.type == EMConversationTypeChatRoom){
        message.chatType = EMChatTypeChatRoom;
    }
    
    [self addMessageToDataSource:message
                        progress:nil];
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].chatManager asyncSendMessage:message progress:nil completion:^(EMMessage *aMessage, EMError *aError) {
        [weakself.tableView reloadData];
    }];
}

- (void)sendTextMessage:(NSString *)text
{
    [self sendTextMessage:text withExt:nil];
}

- (void)sendTextMessage:(NSString *)text withExt:(NSDictionary*)ext
{
    EMMessage *message = [EaseSDKHelper sendTextMessage:text
                                                     to:self.conversation.conversationId
                                            messageType:[self _messageTypeFromConversationType]
                                             messageExt:ext];
    [self _sendMessage:message];
}

- (void)sendLocationMessageLatitude:(double)latitude
                          longitude:(double)longitude
                         andAddress:(NSString *)address
{
    EMMessage *message = [EaseSDKHelper sendLocationMessageWithLatitude:latitude
                                                              longitude:longitude
                                                                address:address
                                                                     to:self.conversation.conversationId
                                                            messageType:[self _messageTypeFromConversationType]
                                                      requireEncryption:NO
                                                             messageExt:nil];
    [self _sendMessage:message];
}

- (void)sendImageMessageWithData:(NSData *)imageData
{
    id progress = self;
    
    EMMessage *message = [EaseSDKHelper sendImageMessageWithImageData:imageData
                                                                   to:self.conversation.conversationId
                                                          messageType:[self _messageTypeFromConversationType]
                                                    requireEncryption:NO
                                                           messageExt:nil
                                                             progress:progress];
    [self _sendMessage:message];
}

- (void)sendImageMessage:(UIImage *)image
{
    id progress = self;
    
    EMMessage *message = [EaseSDKHelper sendImageMessageWithImage:image
                                                               to:self.conversation.conversationId
                                                      messageType:[self _messageTypeFromConversationType]
                                                requireEncryption:NO
                                                       messageExt:nil
                                                         progress:progress];
    [self _sendMessage:message];
}

- (void)sendVoiceMessageWithLocalPath:(NSString *)localPath
                             duration:(NSInteger)duration
{
    id progress = self;
    
    EMMessage *message = [EaseSDKHelper sendVoiceMessageWithLocalPath:localPath
                                                             duration:duration
                                                                   to:self.conversation.conversationId
                                                          messageType:[self _messageTypeFromConversationType]
                                                    requireEncryption:NO
                                                           messageExt:nil
                                                             progress:progress];
    [self _sendMessage:message];
}

- (void)sendVideoMessageWithURL:(NSURL *)url
{
    id progress = self;
    
    EMMessage *message = [EaseSDKHelper sendVideoMessageWithURL:url
                                                             to:self.conversation.conversationId
                                                    messageType:[self _messageTypeFromConversationType]
                                              requireEncryption:NO
                                                     messageExt:nil
                                                       progress:progress];
    [self _sendMessage:message];
}

#pragma mark - ChatKeyBoardDataSource 

- (NSArray<MoreItem *> *)chatKeyBoardMorePanelItems
{
    [self.morePanelItems removeAllObjects];
    
    MoreItem *item1 = [MoreItem moreItemWithPicName:@"chatBar_colorMore_photo" highLightPicName:nil itemName:@"图片"];
    MoreItem *item2 = [MoreItem moreItemWithPicName:@"chatBar_colorMore_camera" highLightPicName:nil itemName:@"拍照"];
    MoreItem *item3 = [MoreItem moreItemWithPicName:@"chatBar_colorMore_video" highLightPicName:nil itemName:@"小视频"];
    MoreItem *item4 = [MoreItem moreItemWithPicName:@"chatBar_colorMore_location" highLightPicName:nil itemName:@"位置"];
    MoreItem *item5 = [MoreItem moreItemWithPicName:@"chatBar_colorMore_audioCall" highLightPicName:nil itemName:@"语音通话"];
    MoreItem *item6 = [MoreItem moreItemWithPicName:@"chatBar_colorMore_videoCall" highLightPicName:nil itemName:@"视频通话"];
    MoreItem *item7 = [MoreItem moreItemWithPicName:@"chatBar_colorMore_photo" highLightPicName:nil itemName:@"分享"];
    MoreItem *item8 = [MoreItem moreItemWithPicName:@"chatBar_colorMore_photo" highLightPicName:nil itemName:@"发红包"];
    MoreItem *item9 = [MoreItem moreItemWithPicName:@"chatBar_colorMore_photo" highLightPicName:nil itemName:@"文件"];
    if (self.conversation.type == EMConversationTypeChat) {
        [self.morePanelItems addObjectsFromArray:@[item1, item2, item3, item4, item5, item6, item7, item8, item9]];
    } else {
        [self.morePanelItems addObjectsFromArray:@[item1, item2, item3, item4, item7, item8, item9]];
    }
    
    return self.morePanelItems;
}

- (NSArray<ChatToolBarItem *> *)chatKeyBoardToolbarItems
{
    ChatToolBarItem *item1 = [ChatToolBarItem barItemWithKind:kBarItemFace normal:@"face" high:@"face_HL" select:@"keyboard"];
    
    ChatToolBarItem *item2 = [ChatToolBarItem barItemWithKind:kBarItemVoice normal:@"voice" high:@"voice_HL" select:@"keyboard"];
    
    ChatToolBarItem *item3 = [ChatToolBarItem barItemWithKind:kBarItemMore normal:@"more_ios" high:@"more_ios_HL" select:nil];
    
    ChatToolBarItem *item4 = [ChatToolBarItem barItemWithKind:kBarItemSwitchBar normal:@"switchDown" high:nil select:nil];
    
    return @[item1, item2, item3, item4];
}

- (NSArray<FaceThemeModel *> *)chatKeyBoardFacePanelSubjectItems
{
    return [FaceSourceManager loadFaceSource];
}

#pragma mark - ChatKeyBoardDelegate

- (void)chatKeyBoardSendText:(NSString *)text
{
    NSLog(@"发送");
    NSLog(@"%@", text);
    if (text && text.length > 0) {
        [self sendTextMessage:text];
    }
}

- (void)chatKeyBoard:(ChatKeyBoard *)chatKeyBoard didSelectMorePanelItemIndex:(NSInteger)index
{
    [self.chatKeyBoard keyboardDown];
    MoreItem *item = self.morePanelItems[index];
    if ([item.itemName isEqualToString:@"图片"]) {//图片
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        if (author == kCLAuthorizationStatusRestricted || author ==kCLAuthorizationStatusDenied){
            //无权限
            NSString *tips = @"请在iPhone的“设置-隐私-照片”选项中，允许彩虹在线访问你的照片";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
        
        // 弹出照片选择
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        [self presentViewController:self.imagePicker animated:YES completion:NULL];
    }
    
    if ([item.itemName isEqualToString:@"拍照"]) {//拍照
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied){
            //无权限
            NSString *tips = @"请在iPhone的“设置-隐私-相机”选项中，允许彩虹在线访问你的手机相机";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
        
        #if TARGET_IPHONE_SIMULATOR
        //[self showHint:@"模拟器不支持拍照"];
        #elif TARGET_OS_IPHONE
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        [self presentViewController:self.imagePicker animated:YES completion:NULL];
        #endif
    }

    if ([item.itemName isEqualToString:@"小视频"]) {//视频
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied){
            //无权限
            NSString *tips = @"请在iPhone的“设置-隐私-相机”选项中，允许彩虹在线访问你的手机相机";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
        
        #if TARGET_IPHONE_SIMULATOR
        //[self showHint:@"模拟器不支持拍照"];
        #elif TARGET_OS_IPHONE
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
        [self presentViewController:self.imagePicker animated:YES completion:NULL];
        #endif
    }
    
    if ([item.itemName isEqualToString:@"位置"]) {//位置
        self.hidesBottomBarWhenPushed = YES;
        DJHLocationViewController *locationVC = [[DJHLocationViewController alloc] init];
        locationVC.delegate = self;
        [self.navigationController pushViewController:locationVC animated:YES];
    }
    
    if ([item.itemName isEqualToString:@"语音通话"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CALL object:@{@"chatter":self.conversation.conversationId, @"type":[NSNumber numberWithInt:0]}];
    }
    
    if ([item.itemName isEqualToString:@"视频通话"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CALL object:@{@"chatter":self.conversation.conversationId, @"type":[NSNumber numberWithInt:1]}];
    }
    
    if ([item.itemName isEqualToString:@"分享"]) {
        NSDictionary *ext = @{@"title":@"彩虹在线-送给父母的礼物,彩虹在线-送给父母的礼物", @"content":@"我正在使用彩虹在线子女版，推荐你加入！", @"imageUrl":@"qqq", @"message_shareType":@"message_shareDefault"};
        [self addShareView:ext];
    }
    
    if ([item.itemName isEqualToString:@"发红包"]) {
        NSDictionary *ext = @{@"message_redMoney":@"message_redMoney"};
        [self sendTextMessage:@"messageRedMoney" withExt:ext];
    }
    
    if ([item.itemName isEqualToString:@"文件"]) {
        
    }
}

- (void)chatKeyBoardFacePicked:(ChatKeyBoard *)chatKeyBoard faceStyle:(NSInteger)faceStyle faceName:(NSString *)faceName delete:(BOOL)isDeleteKey
{
    
}

#pragma mark - DJHMessageTableViewCellDelegate

- (void)clickCellMessageContentViewWithMessageModel:(DJHMessageModel *)messageModel
{
    [self.chatKeyBoard keyboardDown];
    if (messageModel.bodyType == DJHMessageBodyTypeShare) {
        self.hidesBottomBarWhenPushed = YES;
        DJHShareUrlViewController *shareUrlVC = [[DJHShareUrlViewController alloc] init];
        shareUrlVC.title = messageModel.ext[@"title"];
        [self.navigationController pushViewController:shareUrlVC animated:YES];
    }
    
    if (messageModel.bodyType == DJHMessageBodyTypeRedMoney) {
        self.hidesBottomBarWhenPushed = YES;
        DJHShareUrlViewController *shareUrlVC = [[DJHShareUrlViewController alloc] init];
        shareUrlVC.title = messageModel.ext[@"title"];
        [self.navigationController pushViewController:shareUrlVC animated:YES];
    }
    
    if (messageModel.bodyType == DJHMessageBodyTypeImage) {
        [self selectImageWithMessageModel:messageModel];
    }
    
    if (messageModel.bodyType == DJHMessageBodyTypeVideo) {
        [self selectVideoWithMessageModel:messageModel];
    }
    
    if (messageModel.bodyType == DJHMessageBodyTypeLocation) {
        self.hidesBottomBarWhenPushed = YES;
        DJHLocationViewController *locationVC = [[DJHLocationViewController alloc] initWithLocation:CLLocationCoordinate2DMake(messageModel.latitude, messageModel.longitude)];
        locationVC.addressString = messageModel.address;
        [self.navigationController pushViewController:locationVC animated:YES];
    }
    
    if (messageModel.bodyType == DJHMessageBodyTypeVoice) {
        [self selectVoiceWithMessageModel:messageModel];
    }
    
    if (messageModel.bodyType == DJHMessageBodyTypeFile) {
        
    }
}

//头像被点击
- (void)clickCellHeadImageWithMessageModel:(DJHMessageModel *)messageModel
{
    [self.chatKeyBoard keyboardDown];
    NSLog(@"点击了头像");
}

- (void)longPressCellMessageContentViewWithMessageModel:(DJHMessageModel *)messageModel
{
    [self.chatKeyBoard keyboardDown];
    NSLog(@"长按了内容");
    DJHMessageTableViewCell *cell = [self.tableView cellForRowAtIndexPath:messageModel.indexPath];
    DJHImageMessageContentView *bubbleView = (DJHImageMessageContentView *)cell.bubbleView;
    [self becomeFirstResponder];
    
    NSArray *items = [self menusItems:messageModel];
    if ([items count]) {
        UIMenuController *controller = [UIMenuController sharedMenuController];
        controller.menuItems = items;
        _messageForMenu = messageModel;
        [controller setTargetRect:bubbleView.bounds inView:bubbleView];
        [controller setMenuVisible:YES animated:YES];
    }
}

//重新发送
- (void)reSendCellWithMessageModel:(DJHMessageModel *)messageModel
{
    if ((messageModel.messageStatus != EMMessageStatusFailed) && (messageModel.messageStatus != EMMessageStatusPending)) {
        return;
    }
    
    __weak typeof(self) weakself = self;
    [[[EMClient sharedClient] chatManager] asyncResendMessage:messageModel.message progress:nil completion:^(EMMessage *message, EMError *error) {
        [weakself.tableView reloadData];
    }];
    
    [self.tableView reloadData];
}

#pragma mark - 菜单

- (NSArray *)menusItems:(DJHMessageModel *)messageModel
{
    NSMutableArray *items = [NSMutableArray array];
    
    if (messageModel.bodyType == DJHMessageBodyTypeText) {
        [items addObject:[[UIMenuItem alloc] initWithTitle:@"复制"
                                                    action:@selector(copyText:)]];
    }
    
    if (messageModel.bodyType != DJHMessageBodyTypeVoice) {
        [items addObject:[[UIMenuItem alloc] initWithTitle:@"转发"
                                                    action:@selector(transpondMsg:)]];
    }
    
    [items addObject:[[UIMenuItem alloc] initWithTitle:@"删除"
                                                action:@selector(deleteMsg:)]];
    
    return items;
    
}

- (void)copyText:(id)sender
{
    DJHMessageModel *messageModel = [self messageForMenu];
    if (messageModel.text.length) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:messageModel.text];
    }
}

- (void)deleteMsg:(id)sender
{
    DJHMessageModel *messageModel = [self messageForMenu];
    [self.conversation deleteMessageWithId:messageModel.message.messageId];
    [self.messsagesSource removeObject:messageModel.message];
    [self.dataArray removeObjectAtIndex:messageModel.indexPath.row];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[messageModel.indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (void)transpondMsg:(id)sender
{
    
}

- (void)menuDidHide:(NSNotification *)notification
{
    [UIMenuController sharedMenuController].menuItems = nil;
}

- (DJHMessageModel *)messageForMenu
{
    return _messageForMenu;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    NSArray *items = [[UIMenuController sharedMenuController] menuItems];
    for (UIMenuItem *item in items) {
        if (action == [item action]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - SelectContent

- (void)selectImageWithMessageModel:(DJHMessageModel *)messageModel
{
    DJHMessageTableViewCell *cell = [self.tableView cellForRowAtIndexPath:messageModel.indexPath];
    DJHImageMessageContentView *bubbleView = (DJHImageMessageContentView *)cell.bubbleView;
    
    __weak DJHMessageViewController *weakSelf = self;
    EMImageMessageBody *imageBody = (EMImageMessageBody*)[messageModel.message body];
    
    if ([imageBody type] == EMMessageBodyTypeImage) {
        if (imageBody.thumbnailDownloadStatus == EMDownloadStatusSuccessed) {
            if (imageBody.downloadStatus == EMDownloadStatusSuccessed) {
                //发送已读回执
                [weakSelf sendHasReadResponseForMessageModels:@[messageModel] isRead:YES];
                NSString *localPath = messageModel.message == nil ? messageModel.fileLocalPath : [imageBody localPath];
                if (localPath && localPath.length > 0) {
                    [self showMessageImagesWithMessageModel:messageModel];
                    return;
                }
            }
            
            bubbleView.progressView.hidden = NO;
            bubbleView.enabled = NO;
            [[EMClient sharedClient].chatManager asyncDownloadMessageAttachments:messageModel.message progress:^(int progress) {
                NSLog(@"progress---%d", progress);
                bubbleView.progressView.progress = progress/100.00f;
            } completion:^(EMMessage *message, EMError *error) {
                bubbleView.enabled = YES;
                if (!error) {
                    //发送已读回执
                    [weakSelf sendHasReadResponseForMessageModels:@[messageModel] isRead:YES];
                    NSString *localPath = message == nil ? messageModel.fileLocalPath : [(EMImageMessageBody*)message.body localPath];
                    UIImage *image = [UIImage imageWithContentsOfFile:localPath];
                    messageModel.thumbnailImage = [self scaleImage:image toScale:0.5];
                    [weakSelf _reloadTableViewDataWithMessage:messageModel.message];
                    if (localPath && localPath.length > 0) {
                        [self showMessageImagesWithMessageModel:messageModel];
                        
                        return ;
                    }
                }
                bubbleView.progressView.progress = 1.0;
            }];
        } else {
            //获取缩略图
            [[EMClient sharedClient].chatManager asyncDownloadMessageThumbnail:messageModel.message progress:nil completion:^(EMMessage *message, EMError *error) {
                bubbleView.enabled = YES;
                bubbleView.progressView.progress = 1.0;
                if (!error) {
                    [weakSelf _reloadTableViewDataWithMessage:messageModel.message];
                }
            }];
        }
    }
}

- (void)showMessageImagesWithMessageModel:(DJHMessageModel *)messageModel
{
    [self.browseItemArray removeAllObjects];
    int i = 0;
    int currentIndex = 0;
    for (DJHMessageModel *model in self.dataArray) {
        if ([model isKindOfClass:[DJHMessageModel class]]) {
            if (model.bodyType == DJHMessageBodyTypeImage) {
                EMImageMessageBody *imageBody = (EMImageMessageBody*)[model.message body];
                NSString *localPath = model.message == nil ? model.fileLocalPath : [imageBody localPath];
                if (localPath.length > 0) {
                    MSSBrowseModel *browseItem = [[MSSBrowseModel alloc]init];
                    browseItem.bigImageLocalPath = localPath;
                    browseItem.smallImageView = nil;// 小图
                    [self.browseItemArray addObject:browseItem];
                    
                    if (messageModel.indexPath == model.indexPath) {
                        currentIndex = i;
                        DJHMessageTableViewCell *cell = [self.tableView cellForRowAtIndexPath:messageModel.indexPath];
                        DJHImageMessageContentView *bubbleView = (DJHImageMessageContentView *)cell.bubbleView;
                        browseItem.smallImageView = bubbleView.imageView;
                    }
                    
                    i++;
                }
            }
        }
    }
    
    MSSBrowseLocalViewController *bvc = [[MSSBrowseLocalViewController alloc]initWithBrowseItemArray:self.browseItemArray currentIndex:currentIndex];
    [bvc showBrowseViewController];
}

- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (void)selectVideoWithMessageModel:(DJHMessageModel *)messageModel
{
    EMVideoMessageBody *videoBody = (EMVideoMessageBody*)messageModel.message.body;
    
    //判断本地路劲是否存在
    NSString *localPath = [messageModel.fileLocalPath length] > 0 ? messageModel.fileLocalPath : videoBody.localPath;
    if ([localPath length] == 0) {
        [self showHint:@"视频获取失败!"];
        return;
    }
    
    dispatch_block_t block = ^{
        //发送已读回执
        [self sendHasReadResponseForMessageModels:@[messageModel] isRead:YES];
        
        NSURL *videoURL = [NSURL fileURLWithPath:localPath];
        MPMoviePlayerViewController *moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
        [moviePlayerController.moviePlayer prepareToPlay];
        moviePlayerController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
        [self presentMoviePlayerViewControllerAnimated:moviePlayerController];
    };
    
    __weak typeof(self) weakSelf = self;
    void (^completion)(EMMessage *aMessage, EMError *error) = ^(EMMessage *aMessage, EMError *error) {
        if (!error)
        {
            [weakSelf _reloadTableViewDataWithMessage:aMessage];
        }
        else
        {
            [weakSelf showHint:@"缩略图获取失败!"];
        }
    };
    
    if (videoBody.thumbnailDownloadStatus == EMDownloadStatusFailed || ![[NSFileManager defaultManager] fileExistsAtPath:videoBody.thumbnailLocalPath]) {
        [self showHint:@"begin downloading thumbnail image, click later"];
        [[EMClient sharedClient].chatManager asyncDownloadMessageThumbnail:messageModel.message progress:nil completion:completion];
        return;
    }
    
    if (videoBody.downloadStatus == EMDownloadStatusSuccessed && [[NSFileManager defaultManager] fileExistsAtPath:localPath])
    {
        block();
        return;
    }
    
    DJHMessageTableViewCell *cell = [self.tableView cellForRowAtIndexPath:messageModel.indexPath];
    DJHVideoMessageContentView *bubbleView = (DJHVideoMessageContentView *)cell.bubbleView;
    
    bubbleView.progressView.hidden = NO;
    bubbleView.enabled = NO;
    bubbleView.playVideoImageView.hidden = YES;
    [[EMClient sharedClient].chatManager asyncDownloadMessageAttachments:messageModel.message progress:^(int progress) {
        NSLog(@"progress---%d", progress);
        bubbleView.progressView.progress = progress/100.00f;
    } completion:^(EMMessage *message, EMError *error) {
        bubbleView.enabled = YES;
        bubbleView.playVideoImageView.hidden = NO;
        if (!error) {
            block();
        }else{
            [weakSelf showHint:@"视频获取失败!"];
        }
    }];
}

- (void)selectVoiceWithMessageModel:(DJHMessageModel *)messageModel
{
    EMVoiceMessageBody *body = (EMVoiceMessageBody*)messageModel.message.body;
    EMDownloadStatus downloadStatus = [body downloadStatus];
    if (downloadStatus == EMDownloadStatusDownloading) {
        [self showHint:@"正在下载语音，稍后点击"];
        return;
    } else if (downloadStatus == EMDownloadStatusFailed) {
        [self showHint:@"正在下载语音，稍后点击"];
        [[EMClient sharedClient].chatManager asyncDownloadMessageAttachments:messageModel.message progress:nil completion:NULL];
        return;
    }
    
    // 播放音频
    if (messageModel.bodyType == DJHMessageBodyTypeVoice) {
        //发送已读回执
        [self sendHasReadResponseForMessageModels:@[messageModel] isRead:YES];
        __weak DJHMessageViewController *weakSelf = self;
        BOOL isPrepare = [[DJHVoiceMessageHepler shareInstance] prepareMessageAudioModel:messageModel updateViewCompletion:^(DJHMessageModel *prevAudioModel, DJHMessageModel *currentAudioModel) {
            if (prevAudioModel || currentAudioModel) {
                [weakSelf.tableView reloadData];
            }
        }];
        
        if (isPrepare) {
            _isPlayingAudio = YES;
            __weak DJHMessageViewController *weakSelf = self;
            [[EMCDDeviceManager sharedInstance] enableProximitySensor];
            [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:messageModel.fileLocalPath completion:^(NSError *error) {
                [[DJHVoiceMessageHepler shareInstance] stopMessageAudioModel];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                    weakSelf.isPlayingAudio = NO;
                    [[EMCDDeviceManager sharedInstance] disableProximitySensor];
                });
            }];
        } else {
            _isPlayingAudio = NO;
        }
    }
}

#pragma mark - Recording

//开始录音
- (void)chatKeyBoardDidStartRecording:(ChatKeyBoard *)chatKeyBoard
{
    [(EaseRecordView *)self.recordView recordButtonTouchDown];
    if ([self _canRecord]) {
        self.recordView = [[EaseRecordView alloc] initWithFrame:CGRectMake(90, 130, 140, 140)];
        self.recordView.center = self.view.center;
        [self.view addSubview:self.recordView];
        [self.view bringSubviewToFront:self.recordView];
        int x = arc4random() % 100000;
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
        NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time,x];
        
        [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName completion:^(NSError *error)
         {
             if (error) {
                 NSLog(@"%@",@"开始录音失败");
             }
         }];
    }
}

//取消录音
- (void)chatKeyBoardDidCancelRecording:(ChatKeyBoard *)chatKeyBoard
{
    [(EaseRecordView *)self.recordView recordButtonTouchUpOutside];
    [self.recordView removeFromSuperview];
}

//完成录音
- (void)chatKeyBoardDidFinishRecoding:(ChatKeyBoard *)chatKeyBoard
{
    [(EaseRecordView *)self.recordView recordButtonTouchUpInside];
    [self.recordView removeFromSuperview];
    
    __weak typeof(self) weakSelf = self;
    [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
        if (!error) {
            [weakSelf sendVoiceMessageWithLocalPath:recordPath duration:aDuration];
        }
        else {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"录音时间太短了";
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [hud hide:YES];
            });
        }
    }];
}

//将要取消录音
- (void)chatKeyBoardWillCancelRecoding:(ChatKeyBoard *)chatKeyBoard
{
    [(EaseRecordView *)self.recordView recordButtonDragOutside];
}

//继续录音
- (void)chatKeyBoardContineRecording:(ChatKeyBoard *)chatKeyBoard
{
    [(EaseRecordView *)self.recordView recordButtonDragInside];
}

#pragma mark - EMCDDeviceManagerProximitySensorDelegate

- (void)proximitySensorChanged:(BOOL)isCloseToUser
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (isCloseToUser)
    {
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    } else {
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[EMCDDeviceManager sharedInstance] disableProximitySensor];
    }
    [audioSession setActive:YES error:nil];
}

#pragma mark - DJHLocationViewControllerDelegate

-(void)sendLocationLatitude:(double)latitude
                  longitude:(double)longitude
                 andAddress:(NSString *)address
{
    [self sendLocationMessageLatitude:latitude longitude:longitude andAddress:address];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {//视频
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        // video url:
        // file:///private/var/mobile/Applications/B3CDD0B2-2F19-432B-9CFA-158700F4DE8F/tmp/capture-T0x16e39100.tmp.9R8weF/capturedvideo.mp4
        // we will convert it to mp4 format
        NSURL *mp4 = [self _convert2Mp4:videoURL];
        NSFileManager *fileman = [NSFileManager defaultManager];
        if ([fileman fileExistsAtPath:videoURL.path]) {
            NSError *error = nil;
            [fileman removeItemAtURL:videoURL error:&error];
            if (error) {
                NSLog(@"failed to remove file, error:%@.", error);
            }
        }
        [self sendVideoMessageWithURL:mp4];
        
    } else {//图片
        NSURL *url = info[UIImagePickerControllerReferenceURL];
        if (url == nil) {
            UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
            NSData *imageData = UIImageJPEGRepresentation(orgImage, 1);
            UIImage *newImage = [UIImage imageWithData:imageData];
            [self sendImageMessage:newImage];
        } else {
            if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0f) {
                PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
                [result enumerateObjectsUsingBlock:^(PHAsset *asset , NSUInteger idx, BOOL *stop){
                    if (asset) {
                        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData *data, NSString *uti, UIImageOrientation orientation, NSDictionary *dic){
                            if (data.length > 10 * 1000 * 1000) {
                                NSLog(@"图片太大了，换个小点的");
                                return;
                            }
                            if (data != nil) {
                                [self sendImageMessageWithData:data];
                            } else {
                                NSLog(@"图片太大了，换个小点的");
                            }
                        }];
                    }
                }];
            } else {
                ALAssetsLibrary *alasset = [[ALAssetsLibrary alloc] init];
                [alasset assetForURL:url resultBlock:^(ALAsset *asset) {
                    if (asset) {
                        ALAssetRepresentation* assetRepresentation = [asset defaultRepresentation];
                        Byte* buffer = (Byte*)malloc([assetRepresentation size]);
                        NSUInteger bufferSize = [assetRepresentation getBytes:buffer fromOffset:0.0 length:[assetRepresentation size] error:nil];
                        NSData* fileData = [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:YES];
                        if (fileData.length > 10 * 1000 * 1000) {
                            NSLog(@"图片太大了，换个小点的");
                            return;
                        }
                        [self sendImageMessageWithData:fileData];
                    }
                } failureBlock:NULL];
            }
        }
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.dataArray objectAtIndex:indexPath.row];
    
    //时间cell
    if ([object isKindOfClass:[NSString class]]) {
        NSString *timeStr = object;
        
        static NSString *cellId = @"TimeCellId";
        DJHTimeMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[DJHTimeMessageTableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cellId];
        }
        
        cell.timeStr = timeStr;
        cell.timeLabel.text = timeStr;
        
        return cell;
    } else {
        DJHMessageModel *messageModel = object;
        messageModel.indexPath = indexPath;
        
        NSString *cellId = [DJHMessageTableViewCell cellIdentifierWithModel:messageModel];
        DJHMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[DJHMessageTableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cellId];
            cell.delegate = self;
        }
        
        [cell refreshData:messageModel];
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.dataArray objectAtIndex:indexPath.row];
    if ([object isKindOfClass:[NSString class]]) {
        return [DJHTimeMessageTableViewCell cellHeightWithTimeStr];
    } else {
        DJHMessageModel *messageModel = object;
        return [DJHMessageTableViewCell cellHeightWithModel:messageModel];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.chatKeyBoard keyboardDown];
}

#pragma mark - Notif

- (void)didBecomeActive
{
    NSArray *formatMessages = [self formatMessages:self.messsagesSource];
    NSMutableArray *moreMessageModels = [NSMutableArray array];
    for (id obj in formatMessages) {
        if ([obj isKindOfClass:[DJHMessageModel class]]) {
            [moreMessageModels addObject:obj];
        }
    }
    
    //发送已读回执
    [self sendHasReadResponseForMessageModels:moreMessageModels isRead:NO];
    
    [_conversation markAllMessagesAsRead];
}

#pragma mark - Getter

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    
    return _dataArray;
}

- (NSMutableArray *)browseItemArray
{
    if (_browseItemArray == nil) {
        _browseItemArray = [NSMutableArray array];
    }
    
    return _browseItemArray;
}

- (NSMutableArray *)morePanelItems
{
    if (_morePanelItems == nil) {
        _morePanelItems = [NSMutableArray array];
    }
    
    return _morePanelItems;
}

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
        _imagePicker.delegate = self;
        _imagePicker.navigationBar.barStyle = UIBarStyleBlack;
        _imagePicker.navigationBar.translucent = YES;
        _imagePicker.navigationBar.tintColor = [UIColor whiteColor];
    }
    
    return _imagePicker;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[EMCDDeviceManager sharedInstance] stopPlaying];
    [EMCDDeviceManager sharedInstance].delegate = nil;
    
    if (_imagePicker){
        [_imagePicker dismissViewControllerAnimated:NO completion:nil];
        _imagePicker = nil;
    }
}

- (BOOL)shouldAutorotate NS_AVAILABLE_IOS(6_0)//当前viewcontroller是否支持转屏
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientation//当前viewcontroller支持哪些转屏方向
{
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation//当前viewcontroller默认的屏幕方向
{
    return UIInterfaceOrientationLandscapeRight;
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
