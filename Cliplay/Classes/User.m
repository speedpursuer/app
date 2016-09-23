//
//  Client.m
//  Cliplay
//
//  Created by 邢磊 on 16/8/4.
//
//

#import "User.h"

@implementation User
- (instancetype)init {
	if (self = [super init]) {
		self.name = @"";
		self.avatar = @"";
		self.wbRefreshToken = @"";
		self.wbAccessToken = @"";
	}
	return self;
}
//- (instancetype)initWithType:(NSString *)type {
//	if (self = [super init]) {
//		self.type = type;
//		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//		NSDictionary *dict = [userDefaults dictionaryForKey:self.type];
//		
//		if(dict) {
//			[self setUserWith:[dict objectForKey:@"platform"]
//					   openID:[dict objectForKey:@"openID"]
//						 name:[dict objectForKey:@"name"]
//					   avatar:[dict objectForKey:@"avatar"]
//				wbAccessToken:[dict objectForKey:@"wbAccessToken"]
//			   wbRefreshToken:[dict objectForKey:@"wbRefreshToken"]
//				lbAccessToken:[dict objectForKey:@"lbAccessToken"]
//			 ];
//		}
//	}
//	return self;
//}
//- (void)updateUserWith:(NSString *)platform
//				openID:(NSString *)openID
//				  name:(NSString *)name
//				avatar:(NSString *)avatar
//		 wbAccessToken:(NSString *)wbAccessToken
//		wbRefreshToken:(NSString *)wbRefreshToken
//		 lbAccessToken:(NSString *)lbAccessToken
//{
//	
//	NSDictionary *dict = @{
//							@"platform":platform,
//							@"open":openID,
//							@"name":name,
//							@"avatar":avatar,
//							@"wbAccessToken":wbAccessToken,
//							@"wbRefreshToken":wbRefreshToken,
//							@"lbAccessToken":lbAccessToken
//						 };
//	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//	[userDefaults setObject:[dict copy] forKey:self.type];
//	[userDefaults synchronize];
//	[self setUserWith:platform
//			   openID:openID
//				 name:name
//			   avatar:avatar
//		wbAccessToken:wbAccessToken
//	   wbRefreshToken:wbRefreshToken
//		lbAccessToken:lbAccessToken];
//}
//- (void)setUserWith:(NSString *)platform
//			 openID:(NSString *)openID
//			   name:(NSString *)name
//			 avatar:(NSString *)avatar
//	  wbAccessToken:(NSString *)wbAccessToken
//	 wbRefreshToken:(NSString *)wbRefreshToken
//	  lbAccessToken:(NSString *)lbAccessToken
//{
//	[self setPlatform:platform];
//	[self setOpenID:openID];
//	[self setName:name];
//	[self setAvatar:avatar];
//	[self setWbAccessToken:wbAccessToken];
//	[self setWbRefreshToken:wbRefreshToken];
//	[self setLbAccessToken:lbAccessToken];
//}
@end
