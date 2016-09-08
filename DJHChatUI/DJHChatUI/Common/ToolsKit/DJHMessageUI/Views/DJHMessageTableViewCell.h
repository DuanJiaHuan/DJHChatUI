//
//  DJHMessageTableViewCell.h
//  DJHChatUI
//
//  Created by qch－djh on 16/7/12.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DJHMessageModel.h"
#import "DJHMessageContentView.h"
#import "DJHTextMessageContentView.h"
#import "DJHFileMessageContentView.h"
#import "DJHLocationMessageContentView.h"
#import "DJHVideoMessageContentView.h"
#import "DJHVoiceMessageContentView.h"
#import "DJHImageMessageContentView.h"
#import "DJHShareMessageContentView.h"
#import "DJHRedMoneyMessageContentView.h"

@protocol DJHMessageTableViewCellDelegate <NSObject>

@optional

- (void)clickCellMessageContentViewWithMessageModel:(DJHMessageModel *)messageModel;
- (void)clickCellHeadImageWithMessageModel:(DJHMessageModel *)messageModel;
- (void)longPressCellMessageContentViewWithMessageModel:(DJHMessageModel *)messageModel;
- (void)reSendCellWithMessageModel:(DJHMessageModel *)messageModel;

@end

@interface DJHMessageTableViewCell : UITableViewCell <DJHMessageContentViewDelegate>

@property (assign, nonatomic) id <DJHMessageTableViewCellDelegate> delegate;

@property (nonatomic, strong) UIImageView *headImageView;//头像
@property (nonatomic, strong) UILabel *nameLabel;//昵称
@property (strong, nonatomic) UILabel *hasReadLabel;//已读
@property (strong, nonatomic) UIButton *reSendBtn;//重新发送
@property (nonatomic, strong) UIActivityIndicatorView *activity;//正在发送
@property (nonatomic, strong) DJHMessageContentView *bubbleView;//内容区域

@property (strong, nonatomic) DJHMessageModel *messageModel;//消息模型


+ (CGFloat)cellHeightWithModel:(DJHMessageModel *)messageModel;

+ (NSString *)cellIdentifierWithModel:(DJHMessageModel *)messageModel;

- (void)refreshData:(DJHMessageModel *)messageModel;

@end
