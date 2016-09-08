//
//  DJHShareMessageContentView.m
//  DJHChatUI
//
//  Created by qch－djh on 16/7/14.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import "DJHShareMessageContentView.h"

@implementation DJHShareMessageContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor clearColor];
        _bgView.layer.cornerRadius = 5;
        _bgView.layer.masksToBounds = YES;
        _bgView.userInteractionEnabled = NO;
        [self addSubview:_bgView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.contentMode = UIViewContentModeTop;
        [_bgView addSubview:_titleLabel];
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel.numberOfLines = 0;
        _contentLabel.font = [UIFont systemFontOfSize:13];
        _contentLabel.textColor = [UIColor lightGrayColor];
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.contentMode = UIViewContentModeTop;
        [_bgView addSubview:_contentLabel];
        
        _imgView = [[UIImageView alloc] init];
        _imgView.image = [UIImage imageNamed:@"Icon-60@3x"];
        [_bgView addSubview:_imgView];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.messageModel.isSender) {//右边
        _bgView.frame = CGRectMake(8, 4, self.messageModel.contentWidth - 8 - 13, self.messageModel.contentHeight - 4 - 13);
    } else {//左边
        _bgView.frame = CGRectMake(13, 4, self.messageModel.contentWidth - 13 - 8, self.messageModel.contentHeight - 4 - 13);
    }
    
    _titleLabel.frame = CGRectMake(8, 5, _bgView.bounds.size.width - 16, 40);
    _imgView.frame = CGRectMake(8, CGRectGetMaxY(_titleLabel.frame) + 5, 50, 50);
    _contentLabel.frame = CGRectMake(CGRectGetMaxX(_imgView.frame) + 5, CGRectGetMaxY(_titleLabel.frame) + 5, _bgView.bounds.size.width - 16 - 50 - 5, 50);
}

- (void)refreshData:(DJHMessageModel *)messageModel
{
    [super refreshData:messageModel];
    _titleLabel.text = messageModel.ext[@"title"];
    _contentLabel.text = messageModel.ext[@"content"];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
