//
//  ExternalShareMenu.m
//  ColorfulineForChildren
//
//  Created by qch－djh on 16/7/11.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import "ExternalShareMenu.h"
#import "UIImageView+WebCache.h"

@implementation ExternalShareMenu

+ (instancetype)sharedInstance
{
    static ExternalShareMenu *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[ExternalShareMenu alloc] init];
    });
    
    return _sharedInstance;
}

- (void)showWithShareType:(ExternalShareMenuType)shareType externalExt:(NSDictionary *)ext
{
    self.ext = ext;
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (shareType == ExternalShareMenuTypeDefault) {
        self.backView = [[UIView alloc] initWithFrame:keyWindow.frame];
        self.backView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
        [keyWindow addSubview:self.backView];
        
        UIView *shareView = [[UIView alloc] initWithFrame:CGRectMake(30, (keyWindow.bounds.size.height - 200)/2, keyWindow.bounds.size.width - 60, 190)];
        shareView.backgroundColor = [UIColor colorWithRed:249/255.0f green:247/255.0f blue:250/255.0f alpha:1];
        shareView.layer.cornerRadius = 8;
        shareView.layer.masksToBounds = YES;
        [self.backView addSubview:shareView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, shareView.bounds.size.width - 40, 45)];
        titleLabel.text = ext[@"title"];
        titleLabel.numberOfLines = 0;
        titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [shareView addSubview:titleLabel];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(titleLabel.frame) + 10, 60, 60)];
        [imgView sd_setImageWithURL:[NSURL URLWithString:ext[@"imageUrl"]] placeholderImage:[UIImage imageNamed:@"Icon-60@3x"]];
        [shareView addSubview:imgView];
        
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imgView.frame) + 5, CGRectGetMaxY(titleLabel.frame) + 10, shareView.bounds.size.width - 45 - imgView.bounds.size.width, 60)];
        contentLabel.numberOfLines = 0;
        contentLabel.text = ext[@"content"];
        contentLabel.textColor = [UIColor lightGrayColor];
        contentLabel.font = [UIFont systemFontOfSize:15];
        [shareView addSubview:contentLabel];
        
        UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(0, shareView.bounds.size.height - 50.5, shareView.bounds.size.width, 0.5)];
        lineView1.backgroundColor = [UIColor lightGrayColor];
        [shareView addSubview:lineView1];
        
        UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, shareView.bounds.size.height - 50, (shareView.bounds.size.width - 1)/2, 50)];
        [cancelBtn setTitle:@"取消" forState:(UIControlStateNormal)];
        [cancelBtn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
        [cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:(UIControlEventTouchUpInside)];
        [shareView addSubview:cancelBtn];
        
        UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(cancelBtn.frame), shareView.bounds.size.height - 50, 0.5, 50)];
        lineView2.backgroundColor = [UIColor lightGrayColor];
        [shareView addSubview:lineView2];
        
        UIButton *sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(cancelBtn.frame) + 1, shareView.bounds.size.height - 50, (shareView.bounds.size.width - 1)/2, 50)];
        [sendBtn setTitle:@"发送" forState:(UIControlStateNormal)];
        [sendBtn setTitleColor:[UIColor greenColor] forState:(UIControlStateNormal)];
        [sendBtn addTarget:self action:@selector(sendBtnClick) forControlEvents:(UIControlEventTouchUpInside)];
        [shareView addSubview:sendBtn];
    }
}

- (void)cancelBtnClick
{
    [self.backView removeFromSuperview];
    self.backView = nil;
    self.ext = nil;
}

- (void)sendBtnClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendExternalShareMenu:)]) {
        [self.delegate sendExternalShareMenu:self.ext];
    }
    [self cancelBtnClick];
}

@end
