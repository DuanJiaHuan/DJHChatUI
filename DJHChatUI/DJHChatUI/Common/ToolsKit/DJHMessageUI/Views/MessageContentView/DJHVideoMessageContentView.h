//
//  DJHVideoMessageContentView.h
//  DJHChatUI
//
//  Created by qch－djh on 16/7/14.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//  视频

#import "DJHMessageContentView.h"
#import "UCZProgressView.h"

@interface DJHVideoMessageContentView : DJHMessageContentView

@property (strong, nonatomic) UIImageView *videoImageView;

@property (strong, nonatomic) UIImageView *playVideoImageView;

@property (strong, nonatomic) UCZProgressView *progressView;

@end
