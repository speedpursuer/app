//
//  ClipController.h
//  YYKitExample
//
//  Created by ibireme on 15/7/19.
//  Copyright (c) 2015 ibireme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNPPopupController.h"
#import "YYWebImage.h"

@interface ClipController : UITableViewController
@property (nonatomic, strong) NSArray *articleDicts;
@property (nonatomic, strong) NSArray *articleURLs;
@property (nonatomic, strong) NSString *header;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, assign) BOOL fullScreen;
@property (nonatomic, assign) BOOL showInfo;
@property (nonatomic, assign) BOOL favorite;
- (void)popupControllerDidDismiss:(CNPPopupController *)controller;
@end
