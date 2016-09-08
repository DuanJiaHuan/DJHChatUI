//
//  MessageListTableViewCell.h
//  ColorfulineForChildren
//
//  Created by qch－djh on 16/4/13.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *badgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (strong, nonatomic) NSIndexPath *indexPath;

@end
