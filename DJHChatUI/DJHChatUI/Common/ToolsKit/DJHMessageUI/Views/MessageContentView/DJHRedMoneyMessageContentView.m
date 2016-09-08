//
//  DJHRedMoneyMessageContentView.m
//  DJHChatUI
//
//  Created by qch－djh on 16/7/18.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import "DJHRedMoneyMessageContentView.h"

@implementation DJHRedMoneyMessageContentView

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
        
        _redImgView = [[UIImageView alloc] init];
        _redImgView.image = [UIImage imageNamed:@"RedBag@2x"];
        [_bgView addSubview:_redImgView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.contentMode = UIViewContentModeTop;
        [_bgView addSubview:_titleLabel];
        
        _checkLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _checkLabel.font = [UIFont systemFontOfSize:12];
        _checkLabel.textAlignment = NSTextAlignmentLeft;
        _checkLabel.textColor = [UIColor whiteColor];
        _checkLabel.contentMode = UIViewContentModeTop;
        _checkLabel.text = @"查看红包";
        [_bgView addSubview:_checkLabel];
        
        _markLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _markLabel.font = [UIFont systemFontOfSize:12];
        _markLabel.textColor = [UIColor lightGrayColor];
        _markLabel.textAlignment = NSTextAlignmentLeft;
        _markLabel.contentMode = UIViewContentModeTop;
        _markLabel.text = @"彩虹在线红包";
        [_bgView addSubview:_markLabel];
        
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
    
    _redImgView.frame = CGRectMake(10, 17, 75.0/82.0*40, 40);
    _titleLabel.frame = CGRectMake(CGRectGetMaxX(_redImgView.frame) + 10, 17, _bgView.bounds.size.width - _redImgView.bounds.size.width - 30, 20);
    _checkLabel.frame = CGRectMake(CGRectGetMaxX(_redImgView.frame) + 10, CGRectGetMaxY(_titleLabel.frame), _bgView.bounds.size.width - _redImgView.bounds.size.width - 30, 20);
    _markLabel.frame = CGRectMake(10, _bgView.bounds.size.height - 20, 80, 20);
    _markImgView.frame = CGRectMake(_bgView.bounds.size.width - 25, _bgView.bounds.size.height - 17, 15, 15);    
}

- (void)refreshData:(DJHMessageModel *)messageModel
{
    [super refreshData:messageModel];
    _titleLabel.text = @"恭喜发财，大吉大利";
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
