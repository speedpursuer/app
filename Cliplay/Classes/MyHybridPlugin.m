//
//  MyHybridPlugin.m
//  Cliplay
//
//  Created by 邢磊 on 16/1/14.
//
//

#import "MyHybridPlugin.h"
#import "MainViewController.h"
#import <YYWebImage/YYWebImage.h>
#import "AppDelegate.h"
#import "MyLBService.h"

@implementation MyHybridPlugin

-(void)showLoader:(CDVInvokedUrlCommand*) command {
	
	MyLBService *service = [MyLBService sharedManager];
	
	[service showProgressViewWithText:(NSString *)[command.arguments objectAtIndex: 0]];
	
	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)hideLoader:(CDVInvokedUrlCommand*) command {
	
	MyLBService *service = [MyLBService sharedManager];
	
	[service hideProgressView];
	
	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)checkPush:(CDVInvokedUrlCommand*) command {
	
	AppDelegate *app = [[UIApplication sharedApplication] delegate];
	[app webViewLaunched];
	[app fetchData];
	
	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


-(void)play:(CDVInvokedUrlCommand*) command {
	
	if(command.arguments.count > 1) {
		
		MainViewController* mvc = (MainViewController*)[self viewController];
		
		[mvc showPostView: command.arguments];
		
		
		CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
		[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
	} else {
		CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
		[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
	}
}

-(void)playClip:(CDVInvokedUrlCommand*) command {
	
	
	if(command.arguments.count > 1) {
		
		MainViewController* mvc = (MainViewController*)[self viewController];
		
		if(command.arguments.count == 2) {
			[mvc showClipView: [command.arguments objectAtIndex: 1]];
		}else {					
			[mvc showPostView: command.arguments];
		}
		
		CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
		[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
	} else {
		CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
		[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
	}
}

-(void)playPlay:(CDVInvokedUrlCommand*) command {
	
	
	if(command.arguments.count > 1) {
		
		MainViewController* mvc = (MainViewController*)[self viewController];
		
		if(command.arguments.count == 2) {
			[mvc showClipView: [command.arguments objectAtIndex: 1]];
		}else {
			[mvc showPlayView: command.arguments];
		}
		
		CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
		[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
	} else {
		CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
		[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
	}
}

-(void)showArticle:(CDVInvokedUrlCommand*) command {
	
//	NSLog(@"showArticle in MyPlugin");
	if(command.arguments.count > 1) {
		MainViewController* mvc = (MainViewController*)[self viewController];
		[mvc showArticleView: command.arguments];
		
	} else {
		CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
		[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
	}
}

-(void)showMessage:(CDVInvokedUrlCommand*) command {
	NSString* title = [command.arguments objectAtIndex:0];
	NSString* desc = [command.arguments objectAtIndex:1];
	NSString* clean = [command.arguments objectAtIndex:2];
	
	if(title && desc) {
		
		//MainViewController* mvc = (MainViewController*)[self viewController];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
														message:desc
													   delegate:[clean isEqual: @"true"]? self: nil
											  cancelButtonTitle:[clean isEqual: @"true"]? @"清除": @"好"
											  otherButtonTitles:[clean isEqual: @"true"]? @"取消": nil, nil];
		[alert show];
		
		CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
		[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
	} else {
		CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
		[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
	}
}

-(void)dbString:(CDVInvokedUrlCommand*) command {
	
	AppDelegate *app = [[UIApplication sharedApplication] delegate];
	
	CDVPluginResult* pluginResult =
		[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: [app getDBString]];
	
	[app generateDBDump];
	
	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)showFavorite:(CDVInvokedUrlCommand*) command {
	
	MainViewController* mvc = (MainViewController*)[self viewController];
	
	[mvc showFavoriteView];
	
	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
	
	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
//	[self callJSFunction:@"retryInstall();"];
//}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0:{
			[[YYImageCache sharedCache].memoryCache removeAllObjects];
			[[YYImageCache sharedCache].diskCache removeAllObjects];
		}break;
		default:
		break;
	}
}

- (void)callJSFunction: (NSString*) fun {
	MainViewController* mvc = (MainViewController*)[self viewController];
	[mvc.webView stringByEvaluatingJavaScriptFromString:fun];
}

-(void)changeOrientation {
	[[UIDevice currentDevice] setValue:
	 [NSNumber numberWithInteger: UIDeviceOrientationLandscapeRight]
								forKey:@"orientation"];
}

/*
 - (void)alertViewCancel:(UIAlertView *)alertView {
	NSLog(@"alertViewCancel");
 }
 -(void)playClip_:(CDVInvokedUrlCommand*) command {
 NSString* clipURL = [command.arguments objectAtIndex:0];
 
 if(clipURL) {
 
 MainViewController* mvc = (MainViewController*)[self viewController];
 
 ClipPlayController *vc = [ClipPlayController new];
 
 vc.clipURL = clipURL;
 
 [mvc.navigationController pushViewController:vc animated:YES];
 [mvc.navigationController setNavigationBarHidden:NO];
 mvc.navigationController.navigationBar.tintColor = [UIColor blackColor];
 mvc.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
 
 CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
 [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
 } else {
 CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
 [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
 }
 }
*/
@end
