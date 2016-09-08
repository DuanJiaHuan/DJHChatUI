//
//  BaseViewController.h
//  DJHChatUI
//
//  Created by qch－djh on 16/7/7.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

@property (strong, nonatomic) MBProgressHUD *progressHUD;

@property (assign, nonatomic) BOOL isFirstLoad;

- (void)showHUDWithLabel:(NSString *)text;
- (void)showHUDWithOnly:(NSString *)text;
- (void)hiddenHUD;
- (void)showHUDWithCustomView:(NSString *)text imgName:(NSString *)imgName;

- (void)showStatusBarErrorWithStatus:(NSString *)status;
- (void)showStatusBarWarningWithStatus:(NSString *)status;
- (void)showStatusBarSuccessWithStatus:(NSString *)status;

@end
