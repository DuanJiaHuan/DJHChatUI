//
//  DJHImageMessageContentView.m
//  DJHChatUI
//
//  Created by qch－djh on 16/7/14.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import "DJHImageMessageContentView.h"
#import "UIImageView+WebCache.h"

@implementation DJHImageMessageContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.cornerRadius = 5;
        [self addSubview:_imageView];
        
        _progressView = [[UCZProgressView alloc] init];
        _progressView.showsText = YES;
        _progressView.tintColor = [UIColor blueColor];
        _progressView.alpha = 0.5;
        _progressView.hidden = YES;
        [_imageView addSubview:_progressView];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.messageModel.isSender) {//右边
        _imageView.frame = CGRectMake(8, 4, self.messageModel.contentWidth - 8 - 13, self.messageModel.contentHeight - 4 - 13);
    } else {//左边
        _imageView.frame = CGRectMake(13, 4, self.messageModel.contentWidth - 13 - 8, self.messageModel.contentHeight - 4 - 13);
    }
    
    _progressView.frame = _imageView.bounds;
}

- (void)refreshData:(DJHMessageModel *)messageModel
{
    [super refreshData:messageModel];
    UIImage *image = messageModel.thumbnailImage;
    _imageView.image = image;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
