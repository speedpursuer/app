//
//  MyLBService.h
//  Cliplay
//
//  Created by 邢磊 on 16/8/18.
//
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentOAuthObject.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import <WeiboSDK/WeiboSDK.h>
#import "MyLBAdapter.h"
#import "MyLBDelegate.h"
#import "AAShareBubbles.h"
#import "REComposeViewController.h"

#define weiboAppID         @"2203696031"
#define tencentAppID       @"1105320149"
#define weibo_SCHEME       @"wb2203696031"
#define tencent_SCHEME     @"tencent1105320149"
#define serverAPIRoot      @"http://121.40.197.226:3001/api"
#define kRedirectURI	   @"https://api.weibo.com/oauth2/default.html"
#define WEIBO_BUTTON_ID    100
#define QQ_BUTTON_ID       101
#define COMMENT_USER       @"COMMENT_USER"
#define SHARE_USER         @"SAHRE_USER"
#define ERROR_CODE_LOGIN_CANCELLED         1
#define ERROR_CODE_ACTOIN_FAILED           2
#define ERROR_CODE_SHARE_EXCEED_LIMIT      3


@interface MyLBService : NSObject<TencentSessionDelegate, TencentApiInterfaceDelegate, TencentLoginDelegate, WeiboSDKDelegate, AAShareBubblesDelegate, WBHttpRequestDelegate, REComposeViewControllerDelegate, UIAlertViewDelegate>
@property (weak) id<CommentDelegate> commentdelegate;
//@property (weak) id<ShareDelegate> shareDelegate;

+ (id)sharedManager;
- (BOOL)handleOpenURL:(NSURL *)url;
- (void)getCommentsByClipID:(NSString *)clipID
					 offset:(NSInteger)offset
				    success:(void(^)(NSArray *results, BOOL haveMoreData))success
					failure:(void(^)())failure;

- (void)getCommentsSummaryByPostID:(NSString *)postID
						   success:(void(^)(NSArray*))success
						   failure:(void(^)())failure;

- (void)commentWithClipID:(NSString *)clipID
					  withText:(NSString *)text;

- (void)shareWithClipID:(NSURL *)clipID;

- (void)showProgressViewWithText:(NSString *)text;

- (void)hideProgressView;

@end

@interface LBPersistedModel (Cliplay)
typedef void (^MyLBPersistedModelSaveSuccessBlock)(id newData);
- (void)saveWithSuccess:(MyLBPersistedModelSaveSuccessBlock)success
				failure:(SLFailureBlock)failure;
@end
