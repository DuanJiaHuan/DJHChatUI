//
//  DJHMessageModel.h
//  DJHChatUI
//
//  Created by qch－djh on 16/7/13.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import <Foundation/Foundation.h>

//头像
#define HeadImageHeight 40
#define HeadImageWidth 40

//昵称
#define NameLabelHeight 20
#define NameLabelWidth 200

//图片
#define ImageContentViewMinWidth 120
#define ImageContentViewMaxHeight 180

#define ImageContentViewMaxWidth 180
#define ImageContentViewMinHeight 120

#define ImageContentViewFailWidth 80
#define ImageContentViewFailHeight 60

//视频
#define VideoContentViewMinWidth 120
#define VideoContentViewMaxHeight 150

#define VideoContentViewMaxWidth 150
#define VideoContentViewMinHeight 120

//位置
#define LocationContentViewWidth 150
#define LocationContentViewHeight 150

//文件
#define FileContentViewWidth 200
#define FileContentViewHeight 60

//语音
#define VoiceContentViewWidth 100
#define VoiceContentViewHeight 50

//文字
#define TextContentViewMaxWidth 200

//分享
#define ShareContentViewWidth 230
#define ShareContentViewHeight 125

//红包
#define RedMoneyContentViewWidth 220
#define RedMoneyContentViewHeight 100

typedef enum {
    DJHMessageBodyTypeText   = 1,    /*文本类型*/
    DJHMessageBodyTypeImage,         /*图片类型*/
    DJHMessageBodyTypeVideo,         /*视频类型*/
    DJHMessageBodyTypeLocation,      /*位置类型*/
    DJHMessageBodyTypeVoice,         /*语音类型*/
    DJHMessageBodyTypeFile,          /*文件类型*/
    DJHMessageBodyTypeCmd,           /*命令类型*/
    DJHMessageBodyTypeShare,        /*分享类型*/
    DJHMessageBodyTypeRedMoney      /*红包类型*/
} DJHMessageBodyType;

@interface DJHMessageModel : NSObject

@property (strong, nonatomic) NSIndexPath *indexPath;

//缓存数据模型对应的cell的高度，只需要计算一次并赋值，以后就无需计算了
@property (nonatomic) CGFloat cellHeight;
@property (nonatomic) CGFloat contentHeight;
@property (nonatomic) CGFloat contentWidth;
//SDK中的消息
@property (strong, nonatomic, readonly) EMMessage *message;
//消息的第一个消息体
@property (strong, nonatomic, readonly) EMMessageBody *firstMessageBody;

//扩展
@property (strong, nonatomic) NSDictionary *ext;

//消息ID
@property (strong, nonatomic, readonly) NSString *messageId;
//消息类型
@property (nonatomic) DJHMessageBodyType bodyType;
//消息发送状态
@property (nonatomic, readonly) EMMessageStatus messageStatus;
// 消息类型（单聊，群里，聊天室）
@property (nonatomic, readonly) EMChatType messageType;

//是否已读
@property (nonatomic) BOOL isMessageRead;
//是否是当前登录者发送的消息
@property (nonatomic) BOOL isSender;
//消息显示的昵称
@property (strong, nonatomic) NSString *nickname;
//消息显示的头像的网络地址
@property (strong, nonatomic) NSString *avatarURLPath;
//消息显示的头像
@property (strong, nonatomic) UIImage *avatarImage;

//文本消息：文本
@property (strong, nonatomic) NSString *text;

@property (strong, nonatomic) NSString *title;

@property (strong, nonatomic) NSString *shareUrl;

@property (strong, nonatomic) NSString *shareIconUrl;

//文本消息：文本
@property (strong, nonatomic) NSAttributedString *attrBody;

//地址消息：地址描述
@property (strong, nonatomic) NSString *address;
//地址消息：地址经度
@property (nonatomic) double latitude;
//地址消息：地址纬度
@property (nonatomic) double longitude;

//获取图片失败后显示的图片
@property (strong, nonatomic) NSString *failImageName;
//图片消息：图片原图的宽高
@property (nonatomic) CGSize imageSize;
//图片消息：图片缩略图的宽高
@property (nonatomic) CGSize thumbnailImageSize;
//图片消息：图片原图
@property (strong, nonatomic) UIImage *image;
//图片消息：图片缩略图
@property (strong, nonatomic) UIImage *thumbnailImage;

//多媒体消息：是否正在播放
@property (nonatomic) BOOL isMediaPlaying;
//多媒体消息：是否播放过
@property (nonatomic) BOOL isMediaPlayed;
//多媒体消息：长度
@property (nonatomic) CGFloat mediaDuration;

//文件消息：文件图标
@property (strong, nonatomic) NSString *fileIconName;
//文件消息：文件名称
@property (strong, nonatomic) NSString *fileName;
//文件消息：文件大小描述
@property (strong, nonatomic) NSString *fileSizeDes;
//文件消息：文件大小
@property (nonatomic) CGFloat fileSize;

//带附件的消息的上传或下载进度
@property (nonatomic) float progress;

//消息：附件本地地址
@property (strong, nonatomic) NSString *fileLocalPath;
//消息：压缩附件本地地址
@property (strong, nonatomic) NSString *thumbnailFileLocalPath;
//消息：附件下载地址
@property (strong, nonatomic) NSString *fileURLPath;
//消息：压缩附件下载地址
@property (strong, nonatomic) NSString *thumbnailFileURLPath;

- (instancetype)initWithMessage:(EMMessage *)message;

@end
