//
//  DJHTextMessageContentView.m
//  DJHChatUI
//
//  Created by qch－djh on 16/7/13.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import "DJHTextMessageContentView.h"

@implementation DJHTextMessageContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.numberOfLines = 0;
        _textLabel.font = [UIFont systemFontOfSize:15];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_textLabel];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_textLabel sizeToFit];
    
    if (self.messageModel.isSender) {//右边
        _textLabel.frame = CGRectMake(15, 10, self.messageModel.contentWidth - 20 - 15, self.messageModel.contentHeight - 10 - 20);
        _textLabel.textColor = [UIColor whiteColor];
    } else {//左边
        _textLabel.frame = CGRectMake(18, 10, self.messageModel.contentWidth - 20 - 15, self.messageModel.contentHeight - 10 - 20);
        _textLabel.textColor = [UIColor blackColor];
    }
}

- (void)refreshData:(DJHMessageModel *)messageModel
{
    [super refreshData:messageModel];
    _textLabel.text = messageModel.text;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
