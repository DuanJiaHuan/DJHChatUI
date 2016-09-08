//
//  MessageListTableViewCell.m
//  ColorfulineForChildren
//
//  Created by qch－djh on 16/4/13.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import "MessageListTableViewCell.h"

@implementation MessageListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.badgeLabel.layer.masksToBounds = YES;
    self.badgeLabel.layer.cornerRadius = 10;
    self.headImgView.layer.masksToBounds = YES;
    self.headImgView.layer.cornerRadius = 5;
    self.detailLabel.textColor = GrayFontColor;
    self.timeLabel.textColor = GrayFontColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
