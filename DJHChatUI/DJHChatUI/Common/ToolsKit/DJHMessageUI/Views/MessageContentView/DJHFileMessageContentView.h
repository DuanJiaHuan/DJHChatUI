//
//  DJHFileMessageContentView.h
//  DJHChatUI
//
//  Created by qch－djh on 16/7/14.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//  文件

#import "DJHMessageContentView.h"

@interface DJHFileMessageContentView : DJHMessageContentView

@property (strong, nonatomic) UIView *bgView;

@property (strong, nonatomic) UIImageView *markImgView;

@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) UILabel *sizeLabel;

@property (strong, nonatomic) UIImageView *progressImgView;

@property (strong, nonatomic) UIButton *cancelBtn;

@end
