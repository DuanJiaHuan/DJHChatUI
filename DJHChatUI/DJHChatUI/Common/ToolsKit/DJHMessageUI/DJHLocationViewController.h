//
//  DJHLocationViewController.h
//  DJHChatUI
//
//  Created by qch－djh on 16/7/15.
//  Copyright © 2016年 DuanJiaHuan. All rights reserved.
//

#import "BaseViewController.h"
#import "MBProgressHUD.h"

#import <MapKit/MapKit.h>

@protocol DJHLocationViewControllerDelegate <NSObject>

-(void)sendLocationLatitude:(double)latitude
                  longitude:(double)longitude
                 andAddress:(NSString *)address;
@end

@interface DJHLocationViewController : BaseViewController

@property (nonatomic, assign) id<DJHLocationViewControllerDelegate> delegate;

@property (strong, nonatomic) NSString *addressString;

- (instancetype)initWithLocation:(CLLocationCoordinate2D)locationCoordinate;

@end
