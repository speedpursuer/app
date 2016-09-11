//
//  Client.h
//  Cliplay
//
//  Created by 邢磊 on 16/8/4.
//
//

#import <Foundation/Foundation.h>

@interface User : NSObject
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *platform;
@property (nonatomic, copy) NSString *openID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *wbAccessToken;
@property (nonatomic, copy) NSString *wbRefreshToken;
@property (nonatomic, copy) NSString *lbAccessToken;

- (instancetype)initWithType:(NSString *)type;

- (void)updateUserWith:(NSString *)platform
				openID:(NSString *)openID
				  name:(NSString *)name
				avatar:(NSString *)avatar
		 wbAccessToken:(NSString *)wbAccessToken
		wbRefreshToken:(NSString *)wbRefreshToken
		 lbAccessToken:(NSString *)lbAccessToken;
@end
