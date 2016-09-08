//
//  DJHMessageContentView.h
//  DJHChatUI
//
//  Created by qch－djh on 16/7/13.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DJHMessageModel.h"

@protocol DJHMessageContentViewDelegate <NSObject>

@optional

- (void)clickMessageContentViewWithMessageModel:(DJHMessageModel *)messageModel;
- (void)longPressMessageContentViewWithMessageModel:(DJHMessageModel *)messageModel;

@end

@interface DJHMessageContentView : UIControl

@property (assign, nonatomic) id <DJHMessageContentViewDelegate> delegate;

@property (nonatomic,strong) UIImageView * bgImgView;

@property (nonatomic, strong) DJHMessageModel *messageModel;

- (void)refreshData:(DJHMessageModel *)messageModel;

@end
