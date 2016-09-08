//
//  DJHFileMessageContentView.m
//  DJHChatUI
//
//  Created by qch－djh on 16/7/14.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import "DJHFileMessageContentView.h"

@implementation DJHFileMessageContentView

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
        
        _markImgView = [[UIImageView alloc] init];
        _markImgView.image = [UIImage imageNamed:@"chat_item_file"];
        [_bgView addSubview:_markImgView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.contentMode = UIViewContentModeTop;
        [_bgView addSubview:_titleLabel];
        
        _sizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _sizeLabel.font = [UIFont systemFontOfSize:12];
        _sizeLabel.textAlignment = NSTextAlignmentLeft;
        _sizeLabel.textColor = [UIColor whiteColor];
        _sizeLabel.contentMode = UIViewContentModeTop;
        _sizeLabel.text = @"3.38M";
        [_bgView addSubview:_sizeLabel];
        
        _markImgView = [[UIImageView alloc] init];
        _markImgView.image = [UIImage imageNamed:@"Icon-60@3x"];
        [_bgView addSubview:_markImgView];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.messageModel.isSender) {//右边
        _bgView.frame = CGRectMake(8, 3, self.messageModel.contentWidth - 8 - 13, self.messageModel.contentHeight - 3 - 7);
    } else {//左边
        _bgView.frame = CGRectMake(13, 3, self.messageModel.contentWidth - 13 - 8, self.messageModel.contentHeight - 3 - 7);
    }
}

- (void)refreshData:(DJHMessageModel *)messageModel
{
    [super refreshData:messageModel];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
