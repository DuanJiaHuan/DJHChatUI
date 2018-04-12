# DJHChatUI
基于环信即时通讯写的聊天界面UI，代码考虑到了聊天界面的扩展，可按需自定义自己的MessageContentView，增加DJHMessageBodyType类型，即可加入自定义的聊天泡泡

 ![image](https://github.com/DuanJiaHuan/DJHChatUI/blob/master/8C932C3529D7443984AA852BE47566DD.png)
 
 ![image](https://github.com/DuanJiaHuan/DJHChatUI/blob/master/AAD1CED3E6C06C2F650783A1D0421049.png)
 
 ![image](https://github.com/DuanJiaHuan/DJHChatUI/blob/master/2.png)


需自己添加环信即时通讯SDK到DJHChatUI/DJHChatUI/Vendors/HyphenateSDK目录下

- (void)initEaseMobSDKWithApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

#warning 初始化环信SDK，详细内容在AppDelegate+EaseMob.m 文件中
#warning SDK注册 APNS文件的名字, 需要与后台上传证书时的名字一一对应
    NSString *apnsCertName = nil;
#if DEBUG
    apnsCertName = @"写自己的开发推送证书";
#else
    apnsCertName = @"写自己的发布推送证书";
#endif
    //这里您需要在环信后台获取自己的appkey，并且项目中有用到联系客服，您可以设置您的客服IM服务号
    [self easemobApplication:application didFinishLaunchingWithOptions:launchOptions appkey:@"写自己的环信appkey" apnsCertName:apnsCertName otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:YES]}];
    
}

 //客服IM服务号，查看环信的移动客服文档，获取IM服务号
 #define CustomerImUsername @"填写自己IM服务号"

