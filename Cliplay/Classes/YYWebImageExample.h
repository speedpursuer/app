//
//  YYWebImageExample.h
//  YYKitExample
//
//  Created by ibireme on 15/7/19.
//  Copyright (c) 2015 ibireme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYWebImageExample : UITableViewController
@property (nonatomic, strong) NSArray *imageLinks;
@property (nonatomic, assign) BOOL fullScreen;
- (void) showBar;
@end
