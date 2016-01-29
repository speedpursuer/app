//
//  ClipPlayController.h
//  HybridIOSApp
//
//  Created by 邢磊 on 16/1/14.
//
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@interface ClipPlayController : UIViewController
@property (nonatomic, strong) NSString *clipURL;
@property (nonatomic, assign) BOOL favorite;
@property (nonatomic, assign) BOOL showLike;
@property (nonatomic, assign) MainViewController *delegate;
- (void) cancelAction;
@end
