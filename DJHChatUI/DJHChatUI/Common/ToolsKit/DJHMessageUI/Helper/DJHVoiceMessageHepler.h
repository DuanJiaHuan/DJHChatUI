//
//  DJHVoiceMessageHepler.h
//  DJHChatUI
//
//  Created by qch－djh on 16/7/15.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DJHMessageModel.h"

@interface DJHVoiceMessageHepler : NSObject

@property (strong, nonatomic) DJHMessageModel *audioMessageModel;

+ (instancetype)shareInstance;

- (BOOL)prepareMessageAudioModel:(DJHMessageModel *)messageModel
            updateViewCompletion:(void (^)(DJHMessageModel *prevAudioModel, DJHMessageModel *currentAudioModel))updateCompletion;

- (DJHMessageModel *)stopMessageAudioModel;

@end
