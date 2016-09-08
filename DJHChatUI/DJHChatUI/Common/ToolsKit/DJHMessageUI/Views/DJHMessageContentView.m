//
//  DJHMessageContentView.m
//  DJHChatUI
//
//  Created by qch－djh on 16/7/13.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import "DJHMessageContentView.h"

@implementation DJHMessageContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addTarget:self action:@selector(onTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizer:)];
        longPressGestureRecognizer.minimumPressDuration = 0.8;
        [self addGestureRecognizer:longPressGestureRecognizer];
        
        _bgImgView = [[UIImageView alloc] init];
        _bgImgView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_bgImgView];
    }
    
    return self;
}

//点击
- (void)onTouchUpInside:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickMessageContentViewWithMessageModel:)]) {
        [self.delegate clickMessageContentViewWithMessageModel:self.messageModel];
    }
}

//长按
- (void)longPressGestureRecognizer:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(longPressMessageContentViewWithMessageModel:)]) {
            [self.delegate longPressMessageContentViewWithMessageModel:self.messageModel];
        }
    }
}

- (void)refreshData:(DJHMessageModel *)messageModel
{
    self.messageModel = messageModel;
    
    UIImage *image = nil;
    if (self.messageModel.isSender) {
        if (self.messageModel.bodyType == DJHMessageBodyTypeShare) {
            image = [UIImage imageNamed:@"SenderAppNodeBkg.png"];
        } else if (self.messageModel.bodyType == DJHMessageBodyTypeRedMoney) {
            image = [UIImage imageNamed:@"c2cSenderMsgNodeBG.png"];
        } else {
            image = [UIImage imageNamed:@"icon_sender_text_node_normal.png"];
        }
    } else {
        if (self.messageModel.bodyType == DJHMessageBodyTypeShare) {
            image = [UIImage imageNamed:@"ReceiverAppNodeBkg.png"];
        } else if (self.messageModel.bodyType == DJHMessageBodyTypeRedMoney){
            image = [UIImage imageNamed:@"c2cReceiverMsgNodeBG.png"];
        } else {
            image = [UIImage imageNamed:@"icon_receiver_node_normal.png"];
        }
    }
    
    self.bgImgView.image = [image stretchableImageWithLeftCapWidth:image.size.width/2 topCapHeight:image.size.height/2];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.bgImgView.frame = self.bounds;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
