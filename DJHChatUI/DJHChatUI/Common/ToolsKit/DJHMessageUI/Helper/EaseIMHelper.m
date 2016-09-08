//
//  EaseIMHelper.m
//  ColorfulineForChildren
//
//  Created by qch－djh on 16/4/20.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import "EaseIMHelper.h"
#import "MBProgressHUD.h"

@interface EaseIMHelper()<EMCallManagerDelegate>
{
    NSTimer *_callTimer;
}

@end

static EaseIMHelper *helper = nil;

@implementation EaseIMHelper

+ (instancetype)shareHelper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[EaseIMHelper alloc] init];
    });
    return helper;
}

- (void)dealloc
{
    [[EMClient sharedClient] removeDelegate:self];
    [[EMClient sharedClient].groupManager removeDelegate:self];
    [[EMClient sharedClient].contactManager removeDelegate:self];
    [[EMClient sharedClient].roomManager removeDelegate:self];
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[EMClient sharedClient].callManager removeDelegate:self];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initHelper];
    }
    return self;
}

- (void)initHelper
{
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].roomManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].callManager addDelegate:self delegateQueue:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeCall:) name:KNOTIFICATION_CALL object:nil];
}

- (void)asyncPushOptions
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = nil;
        [[EMClient sharedClient] getPushOptionsFromServerWithError:&error];
    });
}

- (void)asyncGroupFromServer
{
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[EMClient sharedClient].groupManager loadAllMyGroupsFromDB];
        EMError *error = nil;
        [[EMClient sharedClient].groupManager getMyGroupsFromServerWithError:&error];
        if (!error) {
            
        }
    });
}

- (void)asyncFriendFromServer
{
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[EMClient sharedClient].contactManager getContactsFromDB];
        EMError *error = nil;
        [[EMClient sharedClient].contactManager getContactsFromServerWithError:&error];
        if (!error) {
            
        }
    });
}

- (void)asyncConversationFromDB
{
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *array = [[EMClient sharedClient].chatManager loadAllConversationsFromDB];
        [array enumerateObjectsUsingBlock:^(EMConversation *conversation, NSUInteger idx, BOOL *stop){
            if(conversation.latestMessage == nil){
                [[EMClient sharedClient].chatManager deleteConversation:conversation.conversationId deleteMessages:NO];
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    });
}

#pragma mark - EMClientDelegate (此协议提供了一些实用工具类的回调)

// 网络状态变化回调
- (void)didConnectionStateChanged:(EMConnectionState)connectionState
{
    
}

//自动登录失败时的回调
- (void)didAutoLoginWithError:(EMError *)error
{
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"自动登录失败，请重新登录" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alertView.tag = 100;
        [alertView show];
    } else if([[EMClient sharedClient] isConnected]){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL flag = [[EMClient sharedClient] dataMigrationTo3];
            if (flag) {
                [self asyncGroupFromServer];
                [self asyncConversationFromDB];
            }
        });
    }
}

//当前登录账号在其它设备登录时会接收到该回调
- (void)didLoginFromOtherDevice
{
    [self _clearHelper];
}

//当前登录账号已经被从服务器端删除时会收到该回调
- (void)didRemovedFromServer
{
    [self _clearHelper];
}

#pragma mark - EMChatManagerDelegate (聊天相关回调)

//会话列表发生变化
- (void)didUpdateConversationList:(NSArray *)aConversationList
{
    
}

//收到Cmd消息
- (void)didReceiveCmdMessages:(NSArray *)aCmdMessages
{
    
}

//收到消息
- (void)didReceiveMessages:(NSArray *)aMessages
{
    
}

#pragma mark - EMGroupManagerDelegate (群组相关的回调)

/*!
 *  离开群组回调
 *
 *  @param aGroup    群组实例
 *  @param aReason   离开原因
 */
- (void)didReceiveLeavedGroup:(EMGroup *)aGroup
                       reason:(EMGroupLeaveReason)aReason
{
    
}

/*!
 *  群组的群主收到用户的入群申请，群的类型是EMGroupStylePublicJoinNeedApproval
 *
 *  @param aGroup     群组实例
 *  @param aApplicant 申请者
 *  @param aReason    申请者的附属信息
 */
- (void)didReceiveJoinGroupApplication:(EMGroup *)aGroup
                             applicant:(NSString *)aApplicant
                                reason:(NSString *)aReason
{
    
}

/*!
 *  SDK自动同意了用户A的加B入群邀请后，用户B接收到该回调，需要设置EMOptions的isAutoAcceptGroupInvitation为YES
 *
 *  @param aGroup    群组实例
 *  @param aInviter  邀请者
 *  @param aMessage  邀请消息
 */
- (void)didJoinedGroup:(EMGroup *)aGroup
               inviter:(NSString *)aInviter
               message:(NSString *)aMessage
{
    
}

/*!
 *  群主拒绝用户A的入群申请后，用户A会接收到该回调，群的类型是EMGroupStylePublicJoinNeedApproval
 *
 *  @param aGroupId    群组ID
 *  @param aReason     拒绝理由
 */
- (void)didReceiveDeclinedJoinGroup:(NSString *)aGroupId
                             reason:(NSString *)aReason
{
    
}

/*!
 *  群主同意用户A的入群申请后，用户A会接收到该回调，群的类型是EMGroupStylePublicJoinNeedApproval
 *
 *  @param aGroup   通过申请的群组
 */
- (void)didReceiveAcceptedJoinGroup:(EMGroup *)aGroup
{
    
}

/*!
 *  用户A邀请用户B入群,用户B接收到该回调(别人邀请)
 *
 *  @param aGroupId    群组ID
 *  @param aInviter    邀请者
 *  @param aMessage    邀请信息
 */
- (void)didReceiveGroupInvitation:(NSString *)aGroupId
                          inviter:(NSString *)aInviter
                          message:(NSString *)aMessage
{
    
}

/*!
 *  用户B同意用户A的入群邀请后，用户A接收到该回调
 *
 *  @param aGroup    群组实例
 *  @param aInvitee  被邀请者
 */
- (void)didReceiveAcceptedGroupInvitation:(EMGroup *)aGroup
                                  invitee:(NSString *)aInvitee
{
    
}

/*!
 *  群组列表发生变化
 *
 *  @param aGroupList  群组列表<EMGroup>
 */
- (void)didUpdateGroupList:(NSArray *)groupList
{
    
}

#pragma mark - EMContactManagerDelegate (好友相关的回调)

/*!
 *  用户B同意用户A的加好友请求后，用户A会收到这个回调
 *
 *  @param aUsername   用户B
 */
- (void)didReceiveAgreedFromUsername:(NSString *)aUsername
{
    
}

/*!
 *  用户B拒绝用户A的加好友请求后，用户A会收到这个回调
 *
 *  @param aUsername   用户B
 */
- (void)didReceiveDeclinedFromUsername:(NSString *)aUsername
{
    
}

/*!
 *  用户B删除与用户A的好友关系后，用户A会收到这个回调
 *
 *  @param aUsername   用户B
 */
- (void)didReceiveDeletedFromUsername:(NSString *)aUsername
{
    
}

/*!
 *  用户B同意用户A的好友申请后，用户A和用户B都会收到这个回调
 *
 *  @param aUsername   用户好友关系的另一方
 */
- (void)didReceiveAddedFromUsername:(NSString *)aUsername
{
    
}

/*!
 *  用户B申请加A为好友后，用户A会收到这个回调
 *
 *  @param aUsername   用户B
 *  @param aMessage    好友邀请信息
 */
- (void)didReceiveFriendInvitationFromUsername:(NSString *)aUsername
                                       message:(NSString *)aMessage
{
    
}

#pragma mark - EMChatroomManagerDelegate (聊天室相关的回调)

- (void)didReceiveUserJoinedChatroom:(EMChatroom *)aChatroom
                            username:(NSString *)aUsername
{
    
}

- (void)didReceiveUserLeavedChatroom:(EMChatroom *)aChatroom
                            username:(NSString *)aUsername
{
    
}

- (void)didReceiveKickedFromChatroom:(EMChatroom *)aChatroom
                              reason:(EMChatroomBeKickedReason)aReason
{
    
}

#pragma mark - EMCallManagerDelegate (实时语音/视频相关的回调)

/*!
 *  \~chinese
 *  用户A拨打用户B，用户B会收到这个回调
 */
- (void)didReceiveCallIncoming:(EMCallSession *)aSession
{
    if(_callSession && _callSession.status != EMCallSessionStatusDisconnected){
        [[EMClient sharedClient].callManager endCall:aSession.sessionId reason:EMCallEndReasonBusy];
        return;
    }
    
    _callSession = aSession;
    if(_callSession){
        [self _startCallTimer];
        
        _callController = [[DJHCallViewController alloc] initWithSession:_callSession isCaller:NO status:@"连接完成"];
        _callController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [_mainVC presentViewController:_callController animated:NO completion:nil];
        
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        switch (state) {
            case UIApplicationStateActive:
                [_callController _beginRing];
                break;
            case UIApplicationStateInactive:
                
                break;
            case UIApplicationStateBackground:
                
                break;
            default:
                break;
        }
    }
}

/*!
 *  \~chinese
 *  通话通道建立完成，用户A和用户B都会收到这个回调
 *
 *  @param aSession  会话实例
 */
- (void)didReceiveCallConnected:(EMCallSession *)aSession
{
    if ([aSession.sessionId isEqualToString:_callSession.sessionId]) {
        _callController.statusLabel.text = @"连接完成";
        [_callController _stopRing];
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [audioSession setActive:YES error:nil];
    }
}

/*!
 *  \~chinese
 *  用户B同意用户A拨打的通话后，用户A会收到这个回调
 *
 *  @param aSession  会话实例
 */
- (void)didReceiveCallAccepted:(EMCallSession *)aSession
{
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        [[EMClient sharedClient].callManager endCall:aSession.sessionId reason:EMCallEndReasonFailed];
    }
    
    if ([aSession.sessionId isEqualToString:_callSession.sessionId]) {
        [self _stopCallTimer];
        
        //NSString *connectStr = aSession.connectType == EMCallConnectTypeRelay ? @"Relay" : @"Direct";
        _callController.statusLabel.text = @"通话中...";
        _callController.timeLabel.hidden = NO;
        [_callController startTimer];
        _callController.cancelButton.hidden = NO;
        _callController.rejectButton.hidden = YES;
        _callController.answerButton.hidden = YES;
    }
}

/*!
 *  \~chinese
 *  1. 用户A或用户B结束通话后，对方会收到该回调
 *  2. 通话出现错误，双方都会收到该回调
 *
 *  @param aSession  会话实例
 *  @param aReason   结束原因
 *  @param aError    错误
 */
- (void)didReceiveCallTerminated:(EMCallSession *)aSession
                          reason:(EMCallEndReason)aReason
                           error:(EMError *)aError
{
    if ([aSession.sessionId isEqualToString:_callSession.sessionId]) {
        [self _stopCallTimer];
        
        _callSession = nil;
        
        [_callController close];
        _callController = nil;
        
        NSString *reasonStr = @"";
        switch (aReason) {
            case EMCallEndReasonHangup:
            {
                reasonStr = @"对方已取消通话";
            }
                break;
            case EMCallEndReasonNoResponse:
            {
                reasonStr = @"对方未接听";
            }
                break;
            case EMCallEndReasonDecline:
            {
                reasonStr = @"对方已拒绝";
            }
                break;
            case EMCallEndReasonBusy:
            {
                reasonStr = @"对方正在通话中";
            }
                break;
            case EMCallEndReasonFailed:
            {
                reasonStr = @"连接失败";
            }
                break;
            default:
                break;
        }
        
        if (aError) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"对方不在线" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:reasonStr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}

#pragma mark - public

- (void)makeCall:(NSNotification*)notify
{
    if (notify.object) {
        [self makeCallWithUsername:[notify.object valueForKey:@"chatter"] isVideo:[[notify.object objectForKey:@"type"] boolValue]];
    }
}

- (void)_startCallTimer
{
    _callTimer = [NSTimer scheduledTimerWithTimeInterval:50 target:self selector:@selector(_cancelCall) userInfo:nil repeats:NO];
}

- (void)_stopCallTimer
{
    if (_callTimer == nil) {
        return;
    }
    
    [_callTimer invalidate];
    _callTimer = nil;
}

- (void)_cancelCall
{
    [self hangupCallWithReason:EMCallEndReasonNoResponse];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"对方未接听" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)makeCallWithUsername:(NSString *)aUsername
                     isVideo:(BOOL)aIsVideo
{
    if ([aUsername length] == 0) {
        return;
    }
    
    if (aIsVideo) {
        _callSession = [[EMClient sharedClient].callManager makeVideoCall:aUsername error:nil];
    }
    else{
        _callSession = [[EMClient sharedClient].callManager makeVoiceCall:aUsername error:nil];
    }
    
    if(_callSession){
        [self _startCallTimer];
        
        _callController = [[DJHCallViewController alloc] initWithSession:_callSession isCaller:YES status:@"正在建立连接..."];
        [_mainVC presentViewController:_callController animated:NO completion:nil];
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"通话建立失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)hangupCallWithReason:(EMCallEndReason)aReason
{
    [self _stopCallTimer];
    
    if (_callSession) {
        [[EMClient sharedClient].callManager endCall:_callSession.sessionId reason:EMCallEndReasonHangup];
    }
    
    _callSession = nil;
    [_callController close];
    _callController = nil;
}

- (void)answerCall
{
    if (_callSession) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            EMError *error = [[EMClient sharedClient].callManager answerCall:_callSession.sessionId];
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error.code == EMErrorNetworkUnavailable) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"network.disconnection", @"Network disconnection") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
                        [alertView show];
                    }
                    else{
                        [self hangupCallWithReason:EMCallEndReasonFailed];
                    }
                });
            }
        });
    }
}

#pragma mark - private

- (BOOL)_needShowNotification:(NSString *)fromChatter
{
    BOOL ret = YES;
    NSArray *igGroupIds = [[EMClient sharedClient].groupManager getAllIgnoredGroupIds];
    for (NSString *str in igGroupIds) {
        if ([str isEqualToString:fromChatter]) {
            ret = NO;
            break;
        }
    }
    return ret;
}

- (void)_clearHelper
{
    [[EMClient sharedClient] logout:NO];
    [self hangupCallWithReason:EMCallEndReasonFailed];
}

@end
