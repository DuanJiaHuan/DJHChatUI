//
//  ConversationEntity.h
//  ColorfulineForChildren
//
//  Created by qch－djh on 16/7/26.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConversationEntity : NSObject

@property (strong, nonatomic, readonly) EMConversation *conversation;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *iconUrl;
@property (strong, nonatomic) UIImage *defaultImage;

- (instancetype)initWithConversation:(EMConversation *)conversation;

@end
