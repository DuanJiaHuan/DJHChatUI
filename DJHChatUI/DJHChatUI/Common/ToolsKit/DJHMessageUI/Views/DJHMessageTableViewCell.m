//
//  DJHMessageTableViewCell.m
//  DJHChatUI
//
//  Created by qch－djh on 16/7/12.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import "DJHMessageTableViewCell.h"

//接受者
NSString *const DJHMessageCellIdentifierRecvText = @"DJHMessageCellRecvText";
NSString *const DJHMessageCellIdentifierRecvLocation = @"DJHMessageCellRecvLocation";
NSString *const DJHMessageCellIdentifierRecvVoice = @"DJHMessageCellRecvVoice";
NSString *const DJHMessageCellIdentifierRecvVideo = @"DJHMessageCellRecvVideo";
NSString *const DJHMessageCellIdentifierRecvImage = @"DJHMessageCellRecvImage";
NSString *const DJHMessageCellIdentifierRecvFile = @"DJHMessageCellRecvFile";
NSString *const DJHMessageCellIdentifierRecvShare = @"DJHMessageCellRecvShare";
NSString *const DJHMessageCellIdentifierRecvRedMoney = @"DJHMessageCellRecvRedMoney";

//发送者
NSString *const DJHMessageCellIdentifierSendText = @"DJHMessageCellSendText";
NSString *const DJHMessageCellIdentifierSendLocation = @"DJHMessageCellSendLocation";
NSString *const DJHMessageCellIdentifierSendVoice = @"DJHMessageCellSendVoice";
NSString *const DJHMessageCellIdentifierSendVideo = @"DJHMessageCellSendVideo";
NSString *const DJHMessageCellIdentifierSendImage = @"DJHMessageCellSendImage";
NSString *const DJHMessageCellIdentifierSendFile = @"DJHMessageCellSendFile";
NSString *const DJHMessageCellIdentifierSendShare = @"DJHMessageCellRecvShare";
NSString *const DJHMessageCellIdentifierSendRedMoney = @"DJHMessageCellRecvRedMoney";

@implementation DJHMessageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1];
        [self makeComponents];
    }
    return self;
}

- (void)makeComponents
{
    //头像
    self.headImageView = [[UIImageView alloc] init];
    self.headImageView.image = [UIImage imageNamed:@"friend_head_default"];
    self.headImageView.layer.masksToBounds = YES;
    self.headImageView.layer.cornerRadius = 5;
    self.headImageView.userInteractionEnabled = YES;
    self.headImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.headImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headTapGestureRecognizer)]];
    [self.contentView addSubview:self.headImageView];
    
    //昵称
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.textColor = [UIColor lightGrayColor];
    self.nameLabel.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:self.nameLabel];
    
    //已读
    self.hasReadLabel = [[UILabel alloc] init];
    self.hasReadLabel.textColor = [UIColor lightGrayColor];
    self.hasReadLabel.font = [UIFont systemFontOfSize:13];
    self.hasReadLabel.text = @"已读";
    self.hasReadLabel.hidden = YES;
    self.hasReadLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.hasReadLabel];
    
    //重新发送
    self.reSendBtn = [[UIButton alloc] init];
    self.reSendBtn.hidden = YES;
    [self.reSendBtn setImage:[UIImage imageNamed:@"messageSendFail"] forState:(UIControlStateNormal)];
    [self.reSendBtn addTarget:self action:@selector(reSendBtnClick) forControlEvents:(UIControlEventTouchUpInside)];
    [self.contentView addSubview:self.reSendBtn];
    
    //正在发送
    self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activity.backgroundColor = [UIColor clearColor];
    self.activity.hidden = YES;
    [self.contentView addSubview:self.activity];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.messageModel.isSender) {//是主人，在右边
        //头像
        self.headImageView.frame = CGRectMake(MainScreenWidth - 10 - HeadImageWidth, 5, HeadImageWidth, HeadImageHeight);
        //昵称
        self.nameLabel.hidden = YES;
        //气泡
        self.bubbleView.frame = CGRectMake(MainScreenWidth - 10 - HeadImageWidth - self.messageModel.contentWidth - 5, 5, self.messageModel.contentWidth, self.messageModel.contentHeight);
        //已读
        self.hasReadLabel.frame = CGRectMake(_bubbleView.frame.origin.x - 30, CGRectGetMaxY(_bubbleView.frame) - 30, 30, 20);
        //重新发送
        self.reSendBtn.frame = CGRectMake(_bubbleView.frame.origin.x - 30, (_bubbleView.bounds.size.height - 30)/2, 30, 30);
        //正在发送
        self.activity.frame = CGRectMake(_bubbleView.frame.origin.x - 20, (_bubbleView.bounds.size.height - 20)/2, 20, 20);
        
        if (self.messageModel.messageType != EMChatTypeChat) {
            self.hasReadLabel.hidden = YES;
        }
    } else {//是好友，在左边
        //头像
        self.headImageView.frame = CGRectMake(10, 5, HeadImageWidth, HeadImageHeight);
        self.hasReadLabel.hidden = YES;
        self.reSendBtn.hidden = YES;
        self.activity.hidden = YES;
        
        if (self.messageModel.messageType == EMChatTypeChat) {
            self.nameLabel.hidden = YES;
            _bubbleView.frame = CGRectMake(10 + HeadImageWidth + 5, 5, self.messageModel.contentWidth, self.messageModel.contentHeight);
        } else {
            self.nameLabel.hidden = NO;
            //昵称
            self.nameLabel.frame = CGRectMake(CGRectGetMaxX(self.headImageView.frame) + 10, 5, NameLabelWidth, NameLabelHeight);
            self.nameLabel.textAlignment = NSTextAlignmentLeft;
            _bubbleView.frame = CGRectMake(10 + HeadImageWidth + 5, 5 + NameLabelHeight + 5, self.messageModel.contentWidth, self.messageModel.contentHeight);
        }
    }
}

- (void)refreshData:(DJHMessageModel *)messageModel
{
    self.messageModel = messageModel;
    if (_bubbleView == nil) {
        if (messageModel.bodyType == DJHMessageBodyTypeText) {
            _bubbleView =  [[DJHTextMessageContentView alloc] init];
        }
        
        if (messageModel.bodyType == DJHMessageBodyTypeShare) {
            _bubbleView = [[DJHShareMessageContentView alloc] init];
        }
        
        if (messageModel.bodyType == DJHMessageBodyTypeRedMoney) {
            _bubbleView =  [[DJHRedMoneyMessageContentView alloc] init];
        }
        
        if (messageModel.bodyType == DJHMessageBodyTypeImage) {
            _bubbleView =  [[DJHImageMessageContentView alloc] init];
        }
        
        if (messageModel.bodyType == DJHMessageBodyTypeVideo) {
            _bubbleView =  [[DJHVideoMessageContentView alloc] init];
        }
        
        if (messageModel.bodyType == DJHMessageBodyTypeLocation) {
            _bubbleView =  [[DJHLocationMessageContentView alloc] init];
        }
        
        if (messageModel.bodyType == DJHMessageBodyTypeVoice) {
            _bubbleView =  [[DJHVoiceMessageContentView alloc] init];
        }
        
        if (messageModel.bodyType == DJHMessageBodyTypeFile) {
            _bubbleView =  [[DJHFileMessageContentView alloc] init];
        }
    
        _bubbleView.delegate = self;
        [self.contentView addSubview:_bubbleView];
    }
    
    _nameLabel.text = messageModel.nickname;
    [_bubbleView refreshData:messageModel];
    
    switch (self.messageModel.messageStatus) {
        case EMMessageStatusDelivering:
        {
            _reSendBtn.hidden = YES;
            [_activity setHidden:NO];
            [_activity startAnimating];
        }
            break;
        case EMMessageStatusSuccessed:
        {
            _reSendBtn.hidden = YES;
            [_activity stopAnimating];
            if (self.messageModel.isMessageRead) {
                _hasReadLabel.hidden = NO;
            } else {
                _hasReadLabel.hidden = YES;
            }
        }
            break;
        case EMMessageStatusPending:
        case EMMessageStatusFailed:
        {
            [_activity stopAnimating];
            [_activity setHidden:YES];
            _reSendBtn.hidden = NO;
        }
            break;
        default:
            break;
    }
}

- (void)reSendBtnClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(reSendCellWithMessageModel:)]) {
        [self.delegate reSendCellWithMessageModel:self.messageModel];
    }
}

//点击头像
- (void)headTapGestureRecognizer
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickCellHeadImageWithMessageModel:)]) {
        [self.delegate clickCellHeadImageWithMessageModel:self.messageModel];
    }
}

#pragma mark - DJHMessageContentViewDelegate

- (void)clickMessageContentViewWithMessageModel:(DJHMessageModel *)messageModel
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickCellMessageContentViewWithMessageModel:)]) {
        [self.delegate clickCellMessageContentViewWithMessageModel:messageModel];
    }
}

- (void)longPressMessageContentViewWithMessageModel:(DJHMessageModel *)messageModel
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(longPressCellMessageContentViewWithMessageModel:)]) {
        [self.delegate longPressCellMessageContentViewWithMessageModel:self.messageModel];
    }
}

#pragma mark - Method

+ (CGFloat)cellHeightWithModel:(DJHMessageModel *)messageModel
{
    if (messageModel.cellHeight > 0) {
        return messageModel.cellHeight;
    }
    
    CGFloat contentWidth = 0;
    CGFloat contentHeight = 0;
    
    switch (messageModel.bodyType) {
        case DJHMessageBodyTypeText:
        {
            CGSize textSize = [messageModel.text boundingRectWithSize:CGSizeMake(TextContentViewMaxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
            contentWidth += 20 + textSize.width + 15;
            contentHeight += 10 + textSize.height + 20;
        }
            break;
        case DJHMessageBodyTypeShare:
        {
            contentWidth += ShareContentViewWidth;
            contentHeight += ShareContentViewHeight;
        }
            break;
        case DJHMessageBodyTypeRedMoney:
        {
            contentWidth += RedMoneyContentViewWidth;
            contentHeight += RedMoneyContentViewHeight;
        }
            break;
        case DJHMessageBodyTypeImage:
        {
            if (messageModel.thumbnailImageSize.width == 0) {
                contentWidth += ImageContentViewFailWidth;
                contentHeight += ImageContentViewFailHeight;
            } else {
                if (messageModel.thumbnailImageSize.width > messageModel.thumbnailImageSize.height) {
                    contentWidth += ImageContentViewMaxWidth;
                    contentHeight += ImageContentViewMinHeight;
                } else {
                    contentWidth += ImageContentViewMinWidth;
                    contentHeight += ImageContentViewMaxHeight;
                }
            }
        }
            break;
        case DJHMessageBodyTypeVideo:
        {
            if (messageModel.thumbnailImageSize.width > messageModel.thumbnailImageSize.height) {
                contentWidth += VideoContentViewMaxWidth;
                contentHeight += VideoContentViewMinHeight;
            } else {
                contentWidth += VideoContentViewMinWidth;
                contentHeight += VideoContentViewMaxHeight;
            }
        }
            break;
        case DJHMessageBodyTypeLocation:
        {
            contentWidth += LocationContentViewWidth;
            contentHeight += LocationContentViewHeight;
        }
            break;
        case DJHMessageBodyTypeVoice:
        {
            contentWidth += VoiceContentViewWidth;
            contentHeight += VoiceContentViewHeight;
        }
            break;
        case DJHMessageBodyTypeFile:
        {
            contentWidth += FileContentViewWidth;
            contentHeight += FileContentViewHeight;
        }
            break;
        default:
            break;
    }
    
    CGFloat minHeight = 5 + 50 + 5;
    CGFloat height = 5 + contentHeight + 5;
    
    if (height < minHeight) {
        height = minHeight;
        contentHeight = 50;
    }
    
    if (contentWidth < 60) {
        contentWidth = 60;
    }
    
    if (messageModel.messageType != EMChatTypeChat) {
        if (!messageModel.isSender) {
            height += (NameLabelHeight + 5);
        }
    }
    
    messageModel.cellHeight = height;
    messageModel.contentWidth = contentWidth;
    messageModel.contentHeight = contentHeight;
    
    return height;
}

+ (NSString *)cellIdentifierWithModel:(DJHMessageModel *)messageModel
{
    NSString *cellIdentifier = nil;
    if (messageModel.isSender) {//发送者
        switch (messageModel.bodyType) {
            case DJHMessageBodyTypeText:
                cellIdentifier = DJHMessageCellIdentifierSendText;
                break;
            case DJHMessageBodyTypeShare:
                cellIdentifier = DJHMessageCellIdentifierSendShare;
                break;
            case DJHMessageBodyTypeRedMoney:
                cellIdentifier = DJHMessageCellIdentifierSendRedMoney;
                break;
            case DJHMessageBodyTypeImage:
                cellIdentifier = DJHMessageCellIdentifierSendImage;
                break;
            case DJHMessageBodyTypeVideo:
                cellIdentifier = DJHMessageCellIdentifierSendVideo;
                break;
            case DJHMessageBodyTypeLocation:
                cellIdentifier = DJHMessageCellIdentifierSendLocation;
                break;
            case DJHMessageBodyTypeVoice:
                cellIdentifier = DJHMessageCellIdentifierSendVoice;
                break;
            case DJHMessageBodyTypeFile:
                cellIdentifier = DJHMessageCellIdentifierSendFile;
                break;
            default:
                break;
        }
    } else {
        switch (messageModel.bodyType) {
            case DJHMessageBodyTypeText:
                cellIdentifier = DJHMessageCellIdentifierRecvText;
                
                break;
            case DJHMessageBodyTypeShare:
                cellIdentifier = DJHMessageCellIdentifierRecvShare;
                break;
            case DJHMessageBodyTypeRedMoney:
                cellIdentifier = DJHMessageCellIdentifierRecvRedMoney;
                break;
            case DJHMessageBodyTypeImage:
                cellIdentifier = DJHMessageCellIdentifierRecvImage;
                break;
            case DJHMessageBodyTypeVideo:
                cellIdentifier = DJHMessageCellIdentifierRecvVideo;
                break;
            case DJHMessageBodyTypeLocation:
                cellIdentifier = DJHMessageCellIdentifierRecvLocation;
                break;
            case DJHMessageBodyTypeVoice:
                cellIdentifier = DJHMessageCellIdentifierRecvVoice;
                break;
            case DJHMessageBodyTypeFile:
                cellIdentifier = DJHMessageCellIdentifierRecvFile;
                break;
            default:
                break;
        }
    }
    
    return cellIdentifier;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
