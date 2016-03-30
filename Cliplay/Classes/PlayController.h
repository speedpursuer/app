//
//  PlayController.h
//  YYKitExample
//
//  Created by ibireme on 15/7/19.
//  Copyright (c) 2015 ibireme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNPPopupController.h"

@interface PlayController : UITableViewController
@property (nonatomic, strong) NSArray *imageLinks;
@property (nonatomic, assign) BOOL fullScreen;
@property (nonatomic, assign) BOOL showInfo;
- (void)showClipView:(NSString*)url;
- (void)popupControllerDidDismiss:(CNPPopupController *)controller;
@end
