//
//  DJHLocationMessageContentView.m
//  DJHChatUI
//
//  Created by qch－djh on 16/7/14.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import "DJHLocationMessageContentView.h"

@implementation DJHLocationMessageContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *image = [UIImage imageNamed:@"icon_map"];
        _imageView  = [[UIImageView alloc] initWithImage:image];
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.cornerRadius = 5;
        [self addSubview:_imageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:13.f];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 0;
        [_imageView addSubview:_titleLabel];
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
    
    _titleLabel.frame = CGRectMake(5, _imageView.bounds.size.height - 45, _imageView.bounds.size.width - 10, 40);
}

- (void)refreshData:(DJHMessageModel *)messageModel
{
    [super refreshData:messageModel];
    _titleLabel.text = messageModel.address;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
