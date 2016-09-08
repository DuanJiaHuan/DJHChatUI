//
//  LoginViewController.m
//  DJHChatUI
//
//  Created by qch－djh on 16/7/19.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import "LoginViewController.h"
#import "JDStatusBarNotification.h"

@interface LoginViewController ()

@property (strong, nonatomic) UITextField *phoneTextField;
@property (strong, nonatomic) UITextField *passwordTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgImgView.image = [UIImage imageNamed:@"loginBg.jpg"];
    bgImgView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:bgImgView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 70, MainScreenWidth - 60, 60)];
    label.text = @"DJHChatUI";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:45];
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    
    self.phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(label.frame) + 50, MainScreenWidth - 100, 40)];
    self.phoneTextField.layer.masksToBounds = YES;
    self.phoneTextField.layer.cornerRadius = 5;
    self.phoneTextField.placeholder = @"亲输入登录环信号";
    self.phoneTextField.clearsOnBeginEditing = YES;
    self.phoneTextField.borderStyle = UITextBorderStyleNone;
    self.phoneTextField.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.phoneTextField];
    
    self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(self.phoneTextField.frame) + 30, MainScreenWidth - 100, 40)];
    self.passwordTextField.layer.masksToBounds = YES;
    self.passwordTextField.layer.cornerRadius = 5;
    self.passwordTextField.placeholder = @"亲输入登录环信密码";
    self.passwordTextField.clearsOnBeginEditing = YES;
    self.passwordTextField.borderStyle = UITextBorderStyleNone;
    self.passwordTextField.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.passwordTextField];
    
    UIButton *makeBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(self.passwordTextField.frame) + 30, MainScreenWidth - 100, 45)];
    makeBtn.backgroundColor = [UIColor whiteColor];
    makeBtn.layer.masksToBounds = YES;
    makeBtn.layer.cornerRadius = 5;
    [makeBtn setTitle:@"登  陆" forState:(UIControlStateNormal)];
    [makeBtn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    [makeBtn addTarget:self action:@selector(makeBtnClick) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:makeBtn];
}

- (void)makeBtnClick
{
    [self userImLogin];
}

- (void)userImLogin
{
    [self.phoneTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    
    NSString *imUsername = self.phoneTextField.text;
    NSString *imPassword = self.passwordTextField.text;
    
    [self showHUDWithLabel:@"正在登录"];
    //异步登陆账号
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = [[EMClient sharedClient] loginWithUsername:imUsername password:imPassword];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hiddenHUD];
            if (!error) {
                //设置是否自动登录
                [[EMClient sharedClient].options setIsAutoLogin:YES];
                
                //获取数据库中数据
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [[EMClient sharedClient] dataMigrationTo3];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
                    });
                });
                [JDStatusBarNotification showWithStatus:@"登陆成功" dismissAfter:0.5 styleName:JDStatusBarStyleWarning];
            } else {
                [JDStatusBarNotification showWithStatus:@"登陆失败" dismissAfter:0.5 styleName:JDStatusBarStyleWarning];
            }
        });
    });
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
