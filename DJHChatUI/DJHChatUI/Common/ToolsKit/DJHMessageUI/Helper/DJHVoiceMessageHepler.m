//
//  DJHVoiceMessageHepler.m
//  DJHChatUI
//
//  Created by qch－djh on 16/7/15.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import "DJHVoiceMessageHepler.h"
#import "EMCDDeviceManager.h"

static DJHVoiceMessageHepler *shareInstance = nil;

@implementation DJHVoiceMessageHepler

+ (instancetype)shareInstance
{
    @synchronized(self){
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{
            shareInstance = [[self alloc] init];
        });
    }
    
    return shareInstance;
}

- (BOOL)prepareMessageAudioModel:(DJHMessageModel *)messageModel
            updateViewCompletion:(void (^)(DJHMessageModel *prevAudioModel, DJHMessageModel *currentAudioModel))updateCompletion
{
    BOOL isPrepare = NO;
    
    if(messageModel.bodyType == EMMessageBodyTypeVoice)
    {
        DJHMessageModel *prevAudioModel = self.audioMessageModel;
        DJHMessageModel *currentAudioModel = messageModel;
        self.audioMessageModel = messageModel;
        
        BOOL isPlaying = messageModel.isMediaPlaying;
        if (isPlaying) {
            messageModel.isMediaPlaying = NO;
            self.audioMessageModel = nil;
            currentAudioModel = nil;
            [[EMCDDeviceManager sharedInstance] stopPlaying];
        }
        else {
            messageModel.isMediaPlaying = YES;
            prevAudioModel.isMediaPlaying = NO;
            isPrepare = YES;
            
            if (!messageModel.isMediaPlayed) {
                messageModel.isMediaPlayed = YES;
                EMMessage *chatMessage = messageModel.message;
                if (chatMessage.ext) {
                    NSMutableDictionary *dict = [chatMessage.ext mutableCopy];
                    if (![[dict objectForKey:@"isPlayed"] boolValue]) {
                        [dict setObject:@YES forKey:@"isPlayed"];
                        chatMessage.ext = dict;
                        [[EMClient sharedClient].chatManager updateMessage:chatMessage];
                    }
                } else {
                    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:chatMessage.ext];
                    [dic setObject:@YES forKey:@"isPlayed"];
                    chatMessage.ext = dic;
                    [[EMClient sharedClient].chatManager updateMessage:chatMessage];
                }
            }
        }
        
        if (updateCompletion) {
            updateCompletion(prevAudioModel, currentAudioModel);
        }
    }
    
    return isPrepare;
}

- (DJHMessageModel *)stopMessageAudioModel
{
    DJHMessageModel *model = nil;
    if (self.audioMessageModel.bodyType == EMMessageBodyTypeVoice) {
        if (self.audioMessageModel.isMediaPlaying) {
            model = self.audioMessageModel;
        }
        self.audioMessageModel.isMediaPlaying = NO;
        self.audioMessageModel = nil;
    }
    
    return model;
}

@end
