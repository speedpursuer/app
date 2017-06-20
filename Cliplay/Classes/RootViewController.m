//
//  ViewController.m
//  Cliplay
//
//  Created by 邢磊 on 16/1/14.
//
//

#import "RootViewController.h"
#import "MainViewController.h"
#import "YYImageExample.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
	
	NSLog(@"viewDidLoad");
    [super viewDidLoad];
	
    MainViewController *vc = [MainViewController new];
//	YYImageExample *vc = [YYImageExample new];
//	[self.interactivePopGestureRecognizer setEnabled:NO];
    [self pushViewController:vc animated:NO];
    [self setNavigationBarHidden:YES];
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskPortrait;
}

@end
