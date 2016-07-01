/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

//
//  AppDelegate.m
//  Cliplay
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "AppDelegate.h"
#import "ClipController.h"
#import "MainViewController.h"
#import "BPush.h"
#import <Cordova/CDVPlugin.h>
#import "DGTeaEncryptor.h"
#import "FavoriateMgr.h"

static BOOL isBackGroundActivateApplication;
static BOOL webViewLaunched;
static NSString *pushID;
static NSString *header;
static NSString *const dbURL = @"http://app_viewer:Cliplay1234@121.40.197.226:4984/";
static NSString *const dbName = @"cliplay_prod_new";
static NSString *const dumpFile = @"ionic.min";
static NSString *const dumpFileType = @"css";
static NSString *const encryptPWD = @"jordan";
static NSString *const pushApiKey = @"10YipKN8jSfOn0t5e1NbBwXl";
static NSString *const pushCat = @"cliplay";

@implementation AppDelegate

@synthesize window, viewController;

- (id)init
{
    /** If you need to do any extra app-specific initialization, you can do it here
     *  -jm
     **/
    NSHTTPCookieStorage* cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];

    [cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];

    int cacheSizeMemory = 8 * 1024 * 1024; // 8MB
    int cacheSizeDisk = 32 * 1024 * 1024; // 32MB
#if __has_feature(objc_arc)
        NSURLCache* sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
#else
        NSURLCache* sharedCache = [[[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"] autorelease];
#endif
    [NSURLCache setSharedURLCache:sharedCache];

    self = [super init];
    return self;
}

#pragma mark UIApplicationDelegate implementation


// this happens while we are running ( in the background, or from within our own app )
// only valid if Cliplay-Info.plist specifies a protocol to handle
- (BOOL)application:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation
{
    if (!url) {
        return NO;
    }

    // all plugins will get the notification, and their handlers will be called
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CDVPluginHandleOpenURLNotification object:url]];

    return YES;
}

// repost all remote and local notification using the default NSNotificationCenter so multiple plugins may respond
//- (void)            application:(UIApplication*)application
//    didReceiveLocalNotification:(UILocalNotification*)notification
//{
//    // re-post ( broadcast )
//    [[NSNotificationCenter defaultCenter] postNotificationName:CDVLocalNotification object:notification];
//}

#ifndef DISABLE_PUSH_NOTIFICATIONS

//    - (void)                                 application:(UIApplication*)application
//        didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
//    {
//        // re-post ( broadcast )
//        NSString* token = [[[[deviceToken description]
//            stringByReplacingOccurrencesOfString:@"<" withString:@""]
//            stringByReplacingOccurrencesOfString:@">" withString:@""]
//            stringByReplacingOccurrencesOfString:@" " withString:@""];
//
//        [[NSNotificationCenter defaultCenter] postNotificationName:CDVRemoteNotification object:token];
//    }
//
//    - (void)                                 application:(UIApplication*)application
//        didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
//    {
//        // re-post ( broadcast )
//        [[NSNotificationCenter defaultCenter] postNotificationName:CDVRemoteNotificationError object:error];
//    }
#endif

- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    // iPhone doesn't support upside down by default, while the iPad does.  Override to allow all orientations always, and let the root view controller decide what's allowed (the supported orientations mask gets intersected).
    NSUInteger supportedInterfaceOrientations = (1 << UIInterfaceOrientationPortrait) | (1 << UIInterfaceOrientationLandscapeLeft) | (1 << UIInterfaceOrientationLandscapeRight) | (1 << UIInterfaceOrientationPortraitUpsideDown);

    return supportedInterfaceOrientations;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication*)application
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[[FavoriateMgr sharedInstance] persistData];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	[[FavoriateMgr sharedInstance] persistData];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
		// iOS8 下需要使用新的 API
//	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
//		UIUserNotificationType myTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
//		
//		UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:myTypes categories:nil];
//		[[UIApplication sharedApplication] registerUserNotificationSettings:settings];
//	}else {
//		UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
//		[[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
//	}
	
	
	if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
		NSLog(@"Requesting permission for push notifications..."); // iOS 8
		UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:
		UIUserNotificationTypeAlert | UIUserNotificationTypeBadge |
		UIUserNotificationTypeSound categories:nil];
		[UIApplication.sharedApplication registerUserNotificationSettings:settings];
	} else {
		NSLog(@"Registering device for push notifications..."); // iOS 7 and earlier
		[UIApplication.sharedApplication registerForRemoteNotificationTypes:
		UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge |
		UIRemoteNotificationTypeSound];
	}
	
#warning 测试 开发环境 时需要修改BPushMode为BPushModeDevelopment 需要修改Apikey为自己的Apikey
	
	// 在 App 启动时注册百度云推送服务，需要提供 Apikey
	
	#ifdef DEBUG
	[BPush registerChannel:launchOptions apiKey:pushApiKey pushMode:BPushModeDevelopment withFirstAction:@"打开" withSecondAction:nil withCategory:pushCat useBehaviorTextInput:NO isDebug:YES];
	#else
	[BPush registerChannel:launchOptions apiKey:pushApiKey pushMode:BPushModeProduction withFirstAction:@"打开" withSecondAction:nil withCategory:pushCat useBehaviorTextInput:NO isDebug:NO];
	#endif
	
	// App 是用户点击推送消息启动
	NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
	if (userInfo) {
		[BPush handleNotification:userInfo];
	}

	//角标清0
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
	
	[self setUpNavBar];
	
	pushID = nil;
	/*
	 // 测试本地通知
	 [self performSelector:@selector(testLocalNotifi) withObject:nil afterDelay:1.0];
	 */
	return YES;
}

- (void) setUpNavBar {
	NSMutableDictionary *titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
	
	[titleBarAttributes setValue:[UIColor colorWithRed:68.0 / 255.0 green:68.0 / 255.0 blue:68.0 / 255.0 alpha:1.0] forKey:NSForegroundColorAttributeName];
	
	[titleBarAttributes setValue:[UIFont systemFontOfSize:16] forKey:NSFontAttributeName];
	
	[[UINavigationBar appearance] setTitleTextAttributes:titleBarAttributes];
}

// 此方法是 用户点击了通知，应用在前台 或者开启后台并且应用在后台 时调起
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
	completionHandler(UIBackgroundFetchResultNewData);
	// 打印到日志 textView 中
	NSLog(@"********** iOS7.0之后 background **********");
	
	NSLog(@"didReceiveRemoteNotification");
	
	pushID = userInfo[@"push_id"];
	header = userInfo[@"header"];
	
	// 应用在前台，不跳转页面，让用户选择。
	if (application.applicationState == UIApplicationStateActive) {
		NSLog(@"acitve ");
		UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:@"最新消息" message:userInfo[@"aps"][@"alert"] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"观看", nil];
		[alertView show];
	}
	//杀死状态下，直接跳转到跳转页面。
	if (application.applicationState == UIApplicationStateInactive && !isBackGroundActivateApplication && webViewLaunched)
	{
		
		[self fetchData];
		NSLog(@"applacation is unactive ===== %@",userInfo);
	}
	// 应用在后台。当后台设置aps字段里的 content-available 值为 1 并开启远程通知激活应用的选项
	if (application.applicationState == UIApplicationStateBackground) {
		NSLog(@"background is Activated Application ");
		// 此处可以选择激活应用提前下载邮件图片等内容。
		isBackGroundActivateApplication = YES;
		UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:@"最新消息" message:userInfo[@"aps"][@"alert"] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"观看", nil];
		[alertView show];
	}
	
	
	NSLog(@"%@",userInfo);
}

- (void)webViewLaunched {
	webViewLaunched = true;
}

- (void)fetchData{
	
	if(!pushID) return;
	
	UINavigationController *nv = ((UINavigationController*)self.window.rootViewController);
	
	UIViewController *top  = [nv topViewController];
	
	if([top isKindOfClass:[ClipController class]]) {
		[nv popViewControllerAnimated:NO];
	}
	
	__weak typeof(nv) _nv = nv;
	NSString *_header = header;
//	__weak typeof(header) _header = header;
	
	NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"%@%@/", dbURL, dbName]stringByAppendingString: pushID]];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[NSURLConnection sendAsynchronousRequest:request
									   queue:[NSOperationQueue mainQueue]
						   completionHandler:^(NSURLResponse *response,
											   NSData *data, NSError *connectionError)
	 {
		 if (data.length > 0 && connectionError == nil)
		 {
			 NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
																	  options:0
																		error:NULL];
			 
			 ClipController *vc = [ClipController new];
			 vc.header = _header;
			 vc.showInfo = false;
			 vc.articleDicts = dict[@"image"];
			 vc.summary = dict[@"summary"];
			 
			 [_nv pushViewController:vc animated:YES];
			 
			 [_nv setNavigationBarHidden:NO];
		 }
	}];
	
	pushID = nil;
	header = nil;
}

// 在 iOS8 系统中，还需要添加这个方法。通过新的 API 注册推送服务
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
	[application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	NSLog(@"test:%@",deviceToken);
	[BPush registerDeviceToken:deviceToken];
	[BPush bindChannelWithCompleteHandler:^(id result, NSError *error) {
		// 需要在绑定成功后进行 settag listtag deletetag unbind 操作否则会失败
		
		// 网络错误
		if (error) {
			return ;
		}
		if (result) {
			// 确认绑定成功
			if ([result[@"error_code"]intValue]!=0) {
				return;
			}
			// 获取channel_id
			NSString *myChannel_id = [BPush getChannelId];
			NSLog(@"==%@",myChannel_id);
			
			[BPush listTagsWithCompleteHandler:^(id result, NSError *error) {
				if (result) {
					NSLog(@"result ============== %@",result);
				}
			}];
			[BPush setTag:@"Mytag" withCompleteHandler:^(id result, NSError *error) {
				if (result) {
					NSLog(@"设置tag成功");
				}
			}];
		}
	}];
}

// 当 DeviceToken 获取失败时，系统会回调此方法
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
	NSLog(@"DeviceToken 获取失败，原因：%@",error);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
	NSLog(@"接收本地通知啦！！！");
	[BPush showLocalNotificationAtFront:notification identifierKey:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1) {
		[self fetchData];
	}
}

- (NSString*)getDBString {
	return [NSString stringWithFormat:@"%@,%@.%@,%@",
			dbURL, dumpFile, dumpFileType, dbName];
}

- (void)generateDBDump {
	NSString* libPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
	
	NSString* libPathNoSync = [libPath stringByAppendingPathComponent:@"NoCloud"];
	
	NSString *fileName = [NSString stringWithFormat:@"%@/%@.%@",
						  libPathNoSync, dumpFile, dumpFileType];
	
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fileName];
	
	//	[self encrypt];
	
	[self decrypt:fileExists fileName:fileName];
}

-(void)decrypt:(bool) fileExists fileName:(NSString*) fileName{
	if(!fileExists) {
		NSString *filePath = [[NSBundle mainBundle]
							  pathForResource: dumpFile ofType: dumpFileType];
		
		NSString *data = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error: nil];
		
		NSString *newData = [DGTeaEncryptor decrypt:data withPassword: encryptPWD];
		
		[newData writeToFile:fileName atomically:NO encoding:NSUTF8StringEncoding error:nil];
	}
}


-(void)encrypt {
	NSString *filePath = [[NSBundle mainBundle]
						  pathForResource: dumpFile ofType: dumpFileType];
	
	NSString *data = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error: nil];
	
	NSLog(@"file data = %@", data);
	
	NSString *newData = [DGTeaEncryptor encrypt:data withPassword: encryptPWD];
	
	NSLog(@"newData = %@", newData);
}

//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
//{
//	// App 收到推送的通知
//	[BPush handleNotification:userInfo];
//	NSLog(@"********** ios7.0之前 **********");
//	// 应用在前台 或者后台开启状态下，不跳转页面，让用户选择。
//	if (application.applicationState == UIApplicationStateActive || application.applicationState == UIApplicationStateBackground) {
//		NSLog(@"acitve or background");
//		UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:@"收到一条消息" message:userInfo[@"aps"][@"alert"] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//		[alertView show];
//	}
//	else//杀死状态下，直接跳转到跳转页面。
//	{
//		//		SkipViewController *skipCtr = [[SkipViewController alloc]init];
//		//		[_tabBarCtr.selectedViewController pushViewController:skipCtr animated:YES];
//	}
//
//	//	[self.viewController addLogString:[NSString stringWithFormat:@"Received Remote Notification :\n%@",userInfo]];
//
//	NSLog(@"%@",userInfo);
//}

//- (BOOL)application:(UIApplication *)application
//didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
//{
//	if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
//		NSLog(@"Requesting permission for push notifications..."); // iOS 8
//		UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:
//            UIUserNotificationTypeAlert | UIUserNotificationTypeBadge |
//            UIUserNotificationTypeSound categories:nil];
//		[UIApplication.sharedApplication registerUserNotificationSettings:settings];
//	} else {
//		NSLog(@"Registering device for push notifications..."); // iOS 7 and earlier
//		[UIApplication.sharedApplication registerForRemoteNotificationTypes:
//		 UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge |
//		 UIRemoteNotificationTypeSound];
//	}
//	return YES;
//}
//
//- (void)application:(UIApplication *)application
//didRegisterUserNotificationSettings:(UIUserNotificationSettings *)settings
//{
//	NSLog(@"Registering device for push notifications..."); // iOS 8
//	[application registerForRemoteNotifications];
//}
//
//- (void)application:(UIApplication *)application
//didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)token
//{
//	NSLog(@"Registration successful, bundle identifier: %@, mode: %@, device token: %@",
//		  [NSBundle.mainBundle bundleIdentifier], [self modeString], token);
//}
//
//- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier
//forRemoteNotification:(NSDictionary *)notification completionHandler:(void(^)())completionHandler
//{
//	NSLog(@"Received push notification: %@, identifier: %@", notification, identifier); // iOS 8
//	completionHandler();
//}
//
//- (void)application:(UIApplication *)application
//didReceiveRemoteNotification:(NSDictionary *)notification
//{
//	NSLog(@"Received push notification: %@", notification); // iOS 7 and earlier
//}
//
//- (NSString *)modeString
//{
//#if DEBUG
//	return @"Development (sandbox)";
//#else
//	return @"Production";
//#endif
//}

@end
