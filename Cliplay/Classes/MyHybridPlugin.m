//
//  MyHybridPlugin.m
//  HybridIOSApp
//
//  Created by 邢磊 on 16/1/14.
//
//

#import "MyHybridPlugin.h"
#import "MainViewController.h"
#import "ClipPlayController.h"

@implementation MyHybridPlugin

-(void)playClip:(CDVInvokedUrlCommand*) command {
	NSString* clipURL = [command.arguments objectAtIndex:0];
	NSString* favorite = [command.arguments objectAtIndex:1];
	NSString* showLike = [command.arguments objectAtIndex:2];
	
	if(clipURL) {
		
		MainViewController* mvc = (MainViewController*)[self viewController];
				
		
		ClipPlayController *vc = [[ClipPlayController alloc] init];
		
		vc.clipURL = clipURL;
		vc.favorite = [favorite isEqual: @"true"];
		vc.showLike = [showLike isEqual: @"true"];
		//vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		//vc.modalPresentationStyle = UIModalPresentationPageSheet;
		vc.modalPresentationStyle = UIModalPresentationCurrentContext;
		
		vc.delegate = mvc;
		
		[mvc presentViewController:vc animated:YES completion:nil];
		
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

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	[self callJSFunction:@"retryInstall();"];
}

- (void)callJSFunction: (NSString*) fun {
	MainViewController* mvc = (MainViewController*)[self viewController];
	[mvc.webView stringByEvaluatingJavaScriptFromString:fun];
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
