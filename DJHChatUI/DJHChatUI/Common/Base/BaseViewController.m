//
//  BaseViewController.m
//  DJHChatUI
//
//  Created by qch－djh on 16/7/7.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController () <MBProgressHUDDelegate>

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.tintColor = RGBColor(0, 186, 10, 1);
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:RGBColor(0, 171, 10, 1), NSFontAttributeName:[UIFont systemFontOfSize:19]};
    self.view.backgroundColor = BgColor;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

#pragma mark - JDStatusBarNotification

- (void)showStatusBarErrorWithStatus:(NSString *)status
{
    [JDStatusBarNotification showWithStatus:status
                               dismissAfter:2.0
                                  styleName:JDStatusBarStyleError];
}

- (void)showStatusBarWarningWithStatus:(NSString *)status
{
    [JDStatusBarNotification showWithStatus:status
                               dismissAfter:2.0
                                  styleName:JDStatusBarStyleWarning];
}

- (void)showStatusBarSuccessWithStatus:(NSString *)status
{
    [JDStatusBarNotification showWithStatus:status
                               dismissAfter:2.0
                                  styleName:JDStatusBarStyleSuccess];
}

#pragma mark - MBProgressHUD

- (void)showHUDWithLabel:(NSString *)text
{
    _progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_progressHUD];
    _progressHUD.delegate = self;
    _progressHUD.labelText = text;
    [_progressHUD show:YES];
}

- (void)showHUDWithOnly:(NSString *)text
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = text;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:1.5];
}

- (void)showHUDWithCustomView:(NSString *)text imgName:(NSString *)imgName
{
    _progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_progressHUD];
    
    _progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
    
    // Set custom view mode
    _progressHUD.mode = MBProgressHUDModeCustomView;
    
    _progressHUD.delegate = self;
    _progressHUD.labelText = text;
    
    [_progressHUD show:YES];
    [_progressHUD hide:YES afterDelay:1];
}

- (void)hiddenHUD
{
    [_progressHUD hide:YES];
    self.isFirstLoad = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
