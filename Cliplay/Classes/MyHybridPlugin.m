//
//  MyHybridPlugin.m
//  Cliplay
//
//  Created by 邢磊 on 16/1/14.
//
//

#import "MyHybridPlugin.h"
#import "MainViewController.h"

@implementation MyHybridPlugin

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

-(void)showMessage:(CDVInvokedUrlCommand*) command {
	NSString* title = [command.arguments objectAtIndex:0];
	NSString* desc = [command.arguments objectAtIndex:1];
	NSString* retry = [command.arguments objectAtIndex:2];
	
	if(title && desc) {
		
		//MainViewController* mvc = (MainViewController*)[self viewController];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
														message:desc
													   delegate:[retry isEqual: @"true"]? self: nil
											  cancelButtonTitle:[retry isEqual: @"true"]? @"重试": @"好" 
											  otherButtonTitles:nil];
		[alert show];
		
		CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
		[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
	} else {
		CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
		[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
	}
}

-(void)dbString:(CDVInvokedUrlCommand*) command {
	CDVPluginResult* pluginResult =
		[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: @"http://app_viewer:Cliplay1234@121.40.197.226:4984/,ionic.min.css"];
	
	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	[self callJSFunction:@"retryInstall();"];
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
