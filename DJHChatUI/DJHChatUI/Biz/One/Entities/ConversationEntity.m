//
//  ConversationEntity.m
//  ColorfulineForChildren
//
//  Created by qch－djh on 16/7/26.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import "ConversationEntity.h"

@implementation ConversationEntity

- (instancetype)initWithConversation:(EMConversation *)conversation
{
    self = [super init];
    if (self) {
        _conversation = conversation;
        NSString *title = @"";
        UIImage *image = nil;
        
        if (conversation.type == EMConversationTypeChat) {
            title = _conversation.conversationId;
            image = [UIImage imageNamed:@"friend_head_default"];
        } else {
            EMError *error1 = nil;
            NSArray *groups = [[EMClient sharedClient].groupManager getMyGroupsFromServerWithError:&error1];
            for (EMGroup *group in groups) {
                if ([group.groupId isEqualToString:_conversation.conversationId]) {
                    title = group.subject;
                    break;
                }
            }
            image = [UIImage imageNamed:@"group_head_default"];
        }
        
        _defaultImage = image;
        _title = title;
    }
    
    return self;
}

@end
