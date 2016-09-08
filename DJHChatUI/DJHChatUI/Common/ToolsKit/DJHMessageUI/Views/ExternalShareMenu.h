//
//  ExternalShareMenu.h
//  ColorfulineForChildren
//
//  Created by qch－djh on 16/7/11.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ExternalShareMenuType) {
    ExternalShareMenuTypeDefault//默认（标题：title，内容：content，图片：imageUrl，类型：type）
};

@protocol ExternalShareMenuDelegate <NSObject>

- (void)sendExternalShareMenu:(NSDictionary *)ext;

@end

@interface ExternalShareMenu : NSObject

+ (instancetype)sharedInstance;
- (void)showWithShareType:(ExternalShareMenuType)shareType externalExt:(NSDictionary *)ext;

@property (strong, nonatomic) UIView *backView;

@property (strong, nonatomic) NSDictionary *ext;

@property (assign, nonatomic) id <ExternalShareMenuDelegate> delegate;

@end
