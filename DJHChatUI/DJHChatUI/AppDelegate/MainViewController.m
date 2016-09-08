//
//  MainViewController.m
//  DJHChatUI
//
//  Created by qch－djh on 16/7/7.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import "MainViewController.h"

#import "ViewController1.h"
#import "ViewController2.h"
#import "ViewController3.h"
#import "ViewController4.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setViewControllrs];
}

//设置底部viewcontroller
- (void)setViewControllrs
{
    //控制器
    NSArray *vcNameArr = @[@"ViewController1", @"ViewController2", @"ViewController3", @"ViewController4"];
    //控制器名称
    NSArray *vcTitleArr = @[@"消息", @"我的好友", @"我的群组", @"设置"];
    //tabBarItem未选中时的图片
    NSArray *vcImgArr = @[@"tabbar_mainframe", @"tabbar_contacts", @"tabbar_discover", @"tabbar_me"];
    //tabBarItem选中时的图片
    NSArray *vcSelectedImgArr = @[@"tabbar_mainframeHL", @"tabbar_contactsHL", @"tabbar_discoverHL", @"tabbar_meHL"];
    //tabBarItem未选中时的文字颜色
    UIColor *titleColor = [UIColor colorWithRed:103.00/255.00 green:107.00/255.00 blue:112.00/255.00 alpha:1];
    //tabBarItem选中时的文字颜色
    UIColor *selectedTitleColor = [UIColor colorWithRed:26.00/255.00 green:178.00/255.00 blue:10.00/255.00 alpha:1];
    
    //放置viewControllers
    NSMutableArray *vcArr = [NSMutableArray array];
    //设置tabBar的viewControllers
    for (int i = 0; i < vcNameArr.count; i++) {
        Class cl = NSClassFromString(vcNameArr[i]);
        UIViewController *viewController = [[cl alloc] init];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        viewController.navigationItem.title = vcTitleArr[i];
        [vcArr addObject:navigationController];
        
        //tabBarItem
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] init];
        viewController.tabBarItem = tabBarItem;
        
        //设置图片
        tabBarItem.image = [[UIImage imageNamed:vcImgArr[i]] imageWithRenderingMode:(UIImageRenderingModeAlwaysOriginal)];
        tabBarItem.selectedImage = [[UIImage imageNamed:vcSelectedImgArr[i]] imageWithRenderingMode:(UIImageRenderingModeAlwaysOriginal)];
        
        //设置文字
        tabBarItem.title = vcTitleArr[i];
        [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:titleColor, NSForegroundColorAttributeName, nil] forState:(UIControlStateNormal)];
        [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:selectedTitleColor, NSForegroundColorAttributeName, nil] forState:(UIControlStateSelected)];
    }
    
    self.viewControllers = vcArr;
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
