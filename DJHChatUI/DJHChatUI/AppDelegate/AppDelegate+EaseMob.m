//
//  AppDelegate+EaseMob.m
//  DJHChatUI
//
//  Created by qch－djh on 16/7/7.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import "AppDelegate+EaseMob.h"

@implementation AppDelegate (EaseMob)

- (void)easemobApplication:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
                    appkey:(NSString *)appkey
              apnsCertName:(NSString *)apnsCertName
               otherConfig:(NSDictionary *)otherConfig
{
    //注册登录状态监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStateChange:) name:KNOTIFICATION_LOGINCHANGE object:nil];
    
    //初始化SDK
    [[EaseSDKHelper shareHelper] easemobApplication:application didFinishLaunchingWithOptions:launchOptions appkey:appkey apnsCertName:apnsCertName otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:YES]}];
    
    [EaseIMHelper shareHelper];
    
    BOOL isAutoLogin = [EMClient sharedClient].isAutoLogin;
    if (isAutoLogin){
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
    }
}

#pragma mark - login changed

- (void)loginStateChange:(NSNotification *)notification
{
    BOOL loginSuccess = [notification.object boolValue];
    if (loginSuccess) {//登陆成功加载主窗口控制器
        self.mainViewController = [[MainViewController alloc] init];
        [EaseIMHelper shareHelper].mainVC = self.mainViewController;
        self.window.rootViewController = self.mainViewController;
    } else {//登陆失败加载登陆页面控制器
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        self.window.rootViewController = loginVC;
    }
}

#pragma mark - App Delegate

// 将得到的deviceToken传给SDK
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSMutableString *deviceTokenString1 = [NSMutableString string];
    
    const char *bytes = deviceToken.bytes;
    
    NSUInteger iCount = deviceToken.length;
    
    for (int i = 0; i < iCount; i++) {
        
        [deviceTokenString1 appendFormat:@"%02x", bytes[i]&0x000000FF];
        
    }
    
    [[EMClient sharedClient] bindDeviceToken:deviceToken];
}

// 注册deviceToken失败，此处失败，与环信SDK无关，一般是您的环境配置或者证书配置有误
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    
}


@end
