//
//  AppMacro.h
//  DJHChatUI
//
//  Created by qch－djh on 16/7/7.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#ifndef AppMacro_h
#define AppMacro_h

//屏幕尺寸宽
#define MainScreenWidth [UIScreen mainScreen].bounds.size.width
//屏幕尺寸高
#define MainScreenHeight [UIScreen mainScreen].bounds.size.height

//字体
#define FontSize(size) [UIFont systemFontOfSize:size];
//粗字体
#define BoldFontSize(size) [UIFont boldSystemFontOfSize:size]

//颜色
#define RGBColor(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
//控制器背景颜色
#define BgColor RGBColor(240, 239, 244, 1)

#define GrayFontColor RGBColor(105, 105, 105, 1)

//客服IM服务号，查看环信的移动客服文档，获取IM服务号
#define CustomerImUsername @"13724272004"


#endif /* AppMacro_h */
