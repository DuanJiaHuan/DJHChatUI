//
//  DJHVideoMessageContentView.m
//  DJHChatUI
//
//  Created by qch－djh on 16/7/14.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import "DJHVideoMessageContentView.h"
#import "UIImageView+WebCache.h"

@implementation DJHVideoMessageContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _videoImageView = [[UIImageView alloc] init];
        _videoImageView.contentMode = UIViewContentModeScaleAspectFill;
        _videoImageView.layer.masksToBounds = YES;
        _videoImageView.layer.cornerRadius = 5;
        [self addSubview:_videoImageView];
        
        _playVideoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        _playVideoImageView.image = [UIImage imageNamed:@"icon_play_normal"];
        [self addSubview:_playVideoImageView];
        
        _progressView = [[UCZProgressView alloc] init];
        _progressView.showsText = YES;
        _progressView.tintColor = [UIColor blueColor];
        _progressView.alpha = 0.5;
        _progressView.hidden = YES;
        [_videoImageView addSubview:_progressView];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.messageModel.isSender) {//右边
        _videoImageView.frame = CGRectMake(8, 4, self.messageModel.contentWidth - 8 - 13, self.messageModel.contentHeight - 4 - 13);
    } else {//左边
        _videoImageView.frame = CGRectMake(13, 4, self.messageModel.contentWidth - 13 - 8, self.messageModel.contentHeight - 4 - 13);
    }
    
    _playVideoImageView.center = self.videoImageView.center;
    _progressView.frame = self.videoImageView.bounds;
}

- (void)refreshData:(DJHMessageModel *)messageModel
{
    [super refreshData:messageModel];
    UIImage *image = messageModel.isSender ? messageModel.image : messageModel.thumbnailImage;
    if (!image) {
        image = messageModel.image;
        if (!image) {
            [_videoImageView sd_setImageWithURL:[NSURL URLWithString:messageModel.fileURLPath] placeholderImage:[UIImage imageNamed:@"friend_head_default"]];
        } else {
            _videoImageView.image = image;
        }
    } else {
        _videoImageView.image = image;
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
