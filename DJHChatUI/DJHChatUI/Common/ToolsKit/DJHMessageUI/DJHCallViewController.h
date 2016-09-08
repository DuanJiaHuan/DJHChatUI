//
//  DJHCallViewController.h
//  DJHChatUI
//
//  Created by qch－djh on 16/7/19.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import "BaseViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@class EMCallSession;

@interface DJHCallViewController : BaseViewController

{
    NSTimer *_timeTimer;
    AVAudioPlayer *_ringPlayer;
    
    UIView *_topView;
    UILabel *_statusLabel;
    UILabel *_timeLabel;
    UILabel *_nameLabel;
    UIImageView *_headerImageView;
    
    //操作按钮显示
    UIView *_actionView;
    UIButton *_silenceButton;
    UILabel *_silenceLabel;
    UIButton *_speakerOutButton;
    UILabel *_speakerOutLabel;
    UIButton *_rejectButton;
    UIButton *_answerButton;
    UIButton *_cancelButton;
}

@property (strong, nonatomic) UILabel *statusLabel;

@property (strong, nonatomic) UILabel *timeLabel;

@property (strong, nonatomic) UIButton *rejectButton;

@property (strong, nonatomic) UIButton *answerButton;

@property (strong, nonatomic) UIButton *cancelButton;

- (instancetype)initWithSession:(EMCallSession *)session
                       isCaller:(BOOL)isCaller
                         status:(NSString *)statusString;

+ (BOOL)canVideo;

- (void)startTimer;

- (void)close;

- (void)_beginRing;

- (void)_stopRing;

@end
