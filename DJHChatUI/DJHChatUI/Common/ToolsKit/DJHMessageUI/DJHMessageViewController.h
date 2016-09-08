//
//  DJHMessageViewController.h
//  DJHChatUI
//
//  Created by qch－djh on 16/7/12.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import "BaseViewController.h"

#import "DJHMessageModel.h"
#import "ChatKeyBoard.h"

#import <MapKit/MapKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "EaseRecordView.h"
#import "EMCDDeviceManager+Media.h"
#import "EMCDDeviceManager+ProximitySensor.h"
#import "MBProgressHUD.h"
#import "UIViewController+HUD.h"

@protocol DJHMessageViewControllerDelegate <NSObject>

@optional

//刷新messageModel
- (void)refreshMessageModel:(DJHMessageModel *)messageModel;

@end

@interface DJHMessageViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource, EMChatManagerDelegate, EMCDDeviceManagerDelegate>

@property (assign, nonatomic) id <DJHMessageViewControllerDelegate> delegate;

@property (nonatomic,strong,readwrite) UITableView *tableView;

@property (nonatomic) BOOL showExternal;//是否显示分享的view

@property (strong, nonatomic) NSDictionary *externalExt;//分享的字典

@property (strong, nonatomic) EMConversation *conversation;//聊天的会话对象

@property (nonatomic) NSTimeInterval messageTimeIntervalTag;//时间间隔标记

@property (strong, nonatomic) NSMutableArray *messsagesSource;//显示的EMMessage类型的消息列表

@property (nonatomic) NSInteger messageCountOfPage; //加载的每页message的条数 default 50

@property (strong, nonatomic) NSMutableArray *dataArray;//消息数据模型列表

@property (nonatomic, strong) ChatKeyBoard *chatKeyBoard;//聊天键盘

@property(strong, nonatomic) EaseRecordView *recordView;//底部录音控件

- (instancetype)initWithConversationChatter:(NSString *)conversationChatter
                           conversationType:(EMConversationType)conversationType messageExt:(NSDictionary*)externalExt;

- (void)loadMessageDataSource;

@end
