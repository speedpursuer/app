//
//  ClipController.h
//  YYKitExample
//
//  Created by ibireme on 15/7/19.
//  Copyright (c) 2015 ibireme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNPPopupController.h"
#import <YYWebImage/YYWebImage.h>
#import "EBCommentsViewDelegate.h"
#import "EBCommentsViewController.h"
#import "DOFavoriteButton.h"
#import "MyLBDelegate.h"

@interface ClipController : UITableViewController
@property (nonatomic, strong) NSArray *articleDicts;
@property (nonatomic, strong) NSArray *articleURLs;
@property (nonatomic, strong) NSString *header;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, assign) BOOL fullScreen;
@property (nonatomic, assign) BOOL showInfo;
@property (nonatomic, strong) NSString *postID;
@property (nonatomic, assign) BOOL favorite;
@property (weak) EBCommentsViewController *delegate;
@property (strong) DOFavoriteButton *infoButton;

- (void)popupControllerDidDismiss:(CNPPopupController *)controller;
- (NSString *)getCommentQty:(NSString *)clipID;
- (void)showComments:(NSString *)clipID;
- (void)shareClip:(NSURL *)clipID;
//- (void)getCommentDetail:(NSString *)clipID callback: (void(^)(NSArray*))handler;
@end

//@interface ClipController (Comments) <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate,EBCommentsViewDelegate>
//
//@property (weak, readwrite) EBCommentsView *commentsView;
//@property (strong) NSArray *comments;
//
//- (void)deleteCellWithNotification:(NSNotification *)notification;
//- (void)setCommentsHidden:(BOOL)commentsHidden;
//- (void)loadComments:(NSArray *)comments;
//- (void)setCommentingEnabled:(BOOL)enableCommenting;
//- (void)startCommenting;
//- (void)hideComments;
//- (void)showComments;
//- (void)cancelCommentingWithNotification:(NSNotification *)notification;
//
//@end
