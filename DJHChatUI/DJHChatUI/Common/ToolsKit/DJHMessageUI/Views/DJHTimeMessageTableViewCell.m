//
//  DJHTimeMessageTableViewCell.m
//  DJHChatUI
//
//  Created by qch－djh on 16/7/13.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import "DJHTimeMessageTableViewCell.h"

@implementation DJHTimeMessageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1];
        
        _timeBGView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_timeBGView];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.font = [UIFont boldSystemFontOfSize:10.f];
        _timeLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:_timeLabel];
        
        [_timeBGView setImage:[[UIImage imageNamed:@"icon_session_time_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(8,20,8,20) resizingMode:UIImageResizingModeStretch]];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_timeLabel sizeToFit];
    
    CGSize maximumLabelSize = CGSizeMake(200, 20);//labelsize的最大值
    CGSize timeSize = [_timeLabel sizeThatFits:maximumLabelSize];
    
    _timeLabel.frame = CGRectMake((self.bounds.size.width - timeSize.width)/2, 10, timeSize.width, 20);
    
    _timeBGView.frame = CGRectMake((self.bounds.size.width - timeSize.width - 14)/2, 10, timeSize.width + 14, 20);
}

+ (CGFloat)cellHeightWithTimeStr
{
    return 40;
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
