//
//  DJHVoiceMessageContentView.h
//  DJHChatUI
//
//  Created by qch－djh on 16/7/14.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//  语音

#import "DJHMessageContentView.h"

@interface DJHVoiceMessageContentView : DJHMessageContentView

@property (nonatomic,strong) UILabel *durationLabel;//语音时长
@property (nonatomic,strong) UIImageView *voiceImageView;
@property (nonatomic,strong) UIView *redView;

@end
