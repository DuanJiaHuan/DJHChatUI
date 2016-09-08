//
//  EaseIMHelper.h
//  ColorfulineForChildren
//
//  Created by qch－djh on 16/4/20.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJHCallViewController.h"

#import "MainViewController.h"

@interface EaseIMHelper : NSObject <EMClientDelegate,EMChatManagerDelegate,EMContactManagerDelegate,EMGroupManagerDelegate,EMChatroomManagerDelegate,EMCallManagerDelegate>

@property (nonatomic, weak) MainViewController *mainVC;
@property (strong, nonatomic) EMCallSession *callSession;
@property (strong, nonatomic) DJHCallViewController *callController;

+ (instancetype)shareHelper;

- (void)asyncPushOptions;

- (void)asyncFriendFromServer;

- (void)asyncGroupFromServer;

- (void)asyncConversationFromDB;

- (void)makeCallWithUsername:(NSString *)aUsername
                     isVideo:(BOOL)aIsVideo;

- (void)hangupCallWithReason:(EMCallEndReason)aReason;

- (void)answerCall;

@end
