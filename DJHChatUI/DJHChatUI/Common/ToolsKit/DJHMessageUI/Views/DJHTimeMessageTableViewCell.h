//
//  DJHTimeMessageTableViewCell.h
//  DJHChatUI
//
//  Created by qch－djh on 16/7/13.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DJHTimeMessageTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *timeBGView;

@property (strong, nonatomic) UILabel *timeLabel;

@property (strong, nonatomic) NSString *timeStr;

+ (CGFloat)cellHeightWithTimeStr;

@end
