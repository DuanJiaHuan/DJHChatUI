//
//  DJHMessageModel.m
//  DJHChatUI
//
//  Created by qch－djh on 16/7/13.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import "DJHMessageModel.h"

#import "EaseConvertToCommonEmoticonsHelper.h"

@implementation DJHMessageModel

- (instancetype)initWithMessage:(EMMessage *)message
{
    self = [super init];
    if (self) {
        _cellHeight = -1;
        _message = message;
        _firstMessageBody = message.body;
        _isMediaPlaying = NO;
        
        _nickname = message.from;
        _isSender = message.direction == EMMessageDirectionSend ? YES : NO;
        _ext = message.ext;
        
        switch (_firstMessageBody.type) {
            case EMMessageBodyTypeText:
            {
                if ([_ext[@"message_shareType"] isEqualToString:@"message_shareDefault"]) {
                    _bodyType = DJHMessageBodyTypeShare;
                    
                    self.title = _ext[@"title"];
                    self.text = _ext[@"content"];
                } else if ([_ext[@"message_redMoney"] isEqualToString:@"message_redMoney"]) {
                    _bodyType = DJHMessageBodyTypeRedMoney;
                } else {
                    _bodyType = DJHMessageBodyTypeText;
                    
                    EMTextMessageBody *textBody = (EMTextMessageBody *)_firstMessageBody;
                    // 表情映射。
                    NSString *didReceiveText = [EaseConvertToCommonEmoticonsHelper convertToSystemEmoticons:textBody.text];
                    self.text = didReceiveText;
                }
            }
                break;
            case EMMessageBodyTypeImage:
            {
                _bodyType = DJHMessageBodyTypeImage;
                
                EMImageMessageBody *imgMessageBody = (EMImageMessageBody *)_firstMessageBody;
                NSData *imageData = [NSData dataWithContentsOfFile:imgMessageBody.localPath];
                if (imageData.length) {
                    self.image = [UIImage imageWithData:imageData];
                    self.thumbnailImage = [self scaleImage:self.image toScale:0.5];
                }
                
                if (!self.thumbnailImage) {
                    self.thumbnailImage = [UIImage imageWithContentsOfFile:imgMessageBody.thumbnailLocalPath];
                }
                
                self.thumbnailImageSize = self.thumbnailImage.size;
                self.imageSize = imgMessageBody.size;
                self.fileLocalPath = imgMessageBody.localPath;
                if (!_isSender) {
                    self.fileURLPath = imgMessageBody.remotePath;
                }
            }
                break;
            case EMMessageBodyTypeLocation:
            {
                _bodyType = DJHMessageBodyTypeLocation;
                
                EMLocationMessageBody *locationBody = (EMLocationMessageBody *)_firstMessageBody;
                self.address = locationBody.address;
                self.latitude = locationBody.latitude;
                self.longitude = locationBody.longitude;
            }
                break;
            case EMMessageBodyTypeVoice:
            {
                _bodyType = DJHMessageBodyTypeVoice;
                
                EMVoiceMessageBody *voiceBody = (EMVoiceMessageBody *)_firstMessageBody;
                self.mediaDuration = voiceBody.duration;
                self.isMediaPlayed = NO;
                if (message.ext) {
                    self.isMediaPlayed = [[message.ext objectForKey:@"isPlayed"] boolValue];
                }
                
                // 音频路径
                self.fileLocalPath = voiceBody.localPath;
                self.fileURLPath = voiceBody.remotePath;
            }
                break;
            case EMMessageBodyTypeVideo:
            {
                _bodyType = DJHMessageBodyTypeVideo;
                
                EMVideoMessageBody *videoBody = (EMVideoMessageBody *)message.body;
                self.thumbnailImageSize = videoBody.thumbnailSize;
                if ([videoBody.thumbnailLocalPath length] > 0) {
                    NSData *thumbnailImageData = [NSData dataWithContentsOfFile:videoBody.thumbnailLocalPath];
                    if (thumbnailImageData.length) {
                        self.thumbnailImage = [UIImage imageWithData:thumbnailImageData];
                    }
                    self.image = self.thumbnailImage;
                }
                
                // 视频路径
                self.fileLocalPath = videoBody.localPath;
                self.fileURLPath = videoBody.remotePath;
            }
                break;
            case EMMessageBodyTypeFile:
            {
                _bodyType = DJHMessageBodyTypeFile;
                
                EMFileMessageBody *fileMessageBody = (EMFileMessageBody *)_firstMessageBody;
                self.fileIconName = @"chat_item_file";
                self.fileName = fileMessageBody.displayName;
                self.fileSize = fileMessageBody.fileLength;
                
                if (self.fileSize < 1024) {
                    self.fileSizeDes = [NSString stringWithFormat:@"%fB", self.fileSize];
                }
                else if(self.fileSize < 1024 * 1024){
                    self.fileSizeDes = [NSString stringWithFormat:@"%.2fkB", self.fileSize / 1024];
                }
                else if (self.fileSize < 2014 * 1024 * 1024){
                    self.fileSizeDes = [NSString stringWithFormat:@"%.2fMB", self.fileSize / (1024 * 1024)];
                }
            }
                break;
            default:
                break;
        }
    }
    
    return self;
}

- (NSString *)messageId
{
    return _message.messageId;
}

- (EMMessageStatus)messageStatus
{
    return _message.status;
}

- (EMChatType)messageType
{
    return _message.chatType;
}

- (BOOL)isMessageRead
{
    return _message.isReadAcked;
}

- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end
