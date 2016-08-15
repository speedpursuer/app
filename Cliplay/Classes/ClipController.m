//
//  ClipController.m
//
//  Created by Lee Xing.
//

#import "ClipController.h"
#import "YYWebImage.h"
#import "UIView+YYAdd.h"
#import "CALayer+YYAdd.h"
#import "UIGestureRecognizer+YYAdd.h"
#import "ClipPlayController.h"
#import "DRImagePlaceholderHelper.h"
#import "DOFavoriteButton.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "ArticleEntity.h"
#import "TTTAttributedLabel.h"
#import "Reachability.h"
#import "FavoriateMgr.h"
#import "AppDelegate.h"
#import "Client.h"
#import <JSBadgeView.h>
#import "MyLBAdapter.h"
#import "EBCommentsView.h"
#import "EBCommentsTableView.h"
#import "EBCommentCell.h"
#import "EBCommentsViewController.h"
#import "ModelComment.h"


#define cellMargin 10
#define kCellHeight ceil((kScreenWidth) * 3.0 / 4.0)
#define kScreenWidth ((UIWindow *)[UIApplication sharedApplication].windows.firstObject).width - cellMargin * 2
#define sHeight [UIScreen mainScreen].bounds.size.height


@interface ClipCell : UITableViewCell
@property (nonatomic, strong) YYAnimatedImageView *webImageView;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign) BOOL downLoaded;
@property (nonatomic, strong) DOFavoriteButton *heartButton;
@property (nonatomic, strong) JSBadgeView *badgeView;
@property (nonatomic, strong) UIButton *commentBtn;
//@property (nonatomic, strong) UIImageView *imgView;
@end

@interface TitleCell : UITableViewCell
@property (nonatomic, strong) TTTAttributedLabel *imageLabel;
@end

@implementation TitleCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	self.backgroundColor = [UIColor whiteColor];
	self.contentView.backgroundColor = [UIColor whiteColor];
	self.contentView.bounds = [UIScreen mainScreen].bounds;
	self.size = CGSizeMake(kScreenWidth, 0);
	self.contentView.size = self.size;
	
	_imageLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
	_imageLabel = [TTTAttributedLabel new];
	_imageLabel.textAlignment = NSTextAlignmentLeft;
	_imageLabel.numberOfLines = 0;
	[_imageLabel setTextColor:[UIColor darkGrayColor]];
	[self.contentView addSubview:_imageLabel];
	
	return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
	return CGSizeMake(kScreenWidth, self.imageLabel.size.height + cellMargin * 2);
}

- (void)setCellData:(ArticleEntity*) entity isForHeight:(BOOL)isForHeight {
	
	NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
	style.lineSpacing = 10;
	style.paragraphSpacing = 11;
	
	NSAttributedString *attString = [[NSAttributedString alloc] initWithString:entity.desc
							        attributes:@{
										(id)kCTForegroundColorAttributeName : (id)[UIColor darkGrayColor].CGColor,
										NSFontAttributeName : [UIFont systemFontOfSize:16],
										(id)kCTParagraphStyleAttributeName : style,
									}];
	
	self.imageLabel.text = attString;
	self.imageLabel.frame = CGRectMake(cellMargin, cellMargin, kScreenWidth, 0);
	[self.imageLabel sizeToFit];
}
@end

@implementation ClipCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	self.backgroundColor = [UIColor whiteColor];
	self.contentView.backgroundColor = [UIColor whiteColor];
	self.contentView.bounds = [UIScreen mainScreen].bounds;
	self.size = CGSizeMake(kScreenWidth, kCellHeight);
	self.contentView.size = self.size;
	
	_webImageView = [YYAnimatedImageView new];
	_webImageView.size = CGSizeMake(kScreenWidth, kCellHeight);
	_webImageView.left = cellMargin;
	_webImageView.clipsToBounds = YES;
	_webImageView.contentMode = UIViewContentModeScaleAspectFill;
	_webImageView.backgroundColor = [UIColor whiteColor];
	
	[self.contentView addSubview:_webImageView];
	
	_label = [UILabel new];
	_label.size = _webImageView.size;
	_label.textAlignment = NSTextAlignmentCenter;
	_label.text = @"下载异常, 点击重试";
	_label.textColor = [UIColor whiteColor];
	_label.hidden = YES;
	_label.userInteractionEnabled = YES;
	[self.contentView addSubview:_label];
	
	_label.centerX = _webImageView.centerX;
	_label.centerY = _webImageView.centerY + _webImageView.height * 0.2;
	
	CGFloat lineHeight = 4;
	_progressLayer = [CAShapeLayer layer];
	_progressLayer.size = CGSizeMake(_webImageView.width, lineHeight);
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:CGPointMake(0, _progressLayer.height / 2)];
	[path addLineToPoint:CGPointMake(_webImageView.width, _progressLayer.height / 2)];
	_progressLayer.lineWidth = lineHeight;
	_progressLayer.path = path.CGPath;
	_progressLayer.strokeColor = [UIColor colorWithRed:255.0 / 255.0 green:64.0 / 255.0 blue:0.0 / 255.0 alpha:1.0].CGColor;
	_progressLayer.lineCap = kCALineCapButt;
	_progressLayer.strokeStart = 0;
	_progressLayer.strokeEnd = 0;
	[_webImageView.layer addSublayer:_progressLayer];
	
	__weak typeof(self) _self = self;
	UITapGestureRecognizer *g = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id sender) {
		[_self setImageURL:_self.webImageView.yy_imageURL];
	}];
	[_label addGestureRecognizer:g];
	
	
	_heartButton = [[DOFavoriteButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40) image:[UIImage imageNamed:@"heart"] selected: false];
	
	_heartButton.imageColorOn = [UIColor colorWithRed:255.0 / 255.0 green:64.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
	_heartButton.circleColor = [UIColor colorWithRed:255.0 / 255.0 green:64.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
	_heartButton.lineColor = [UIColor colorWithRed:245.0 / 255.0 green:54.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
	
	[_heartButton addTarget:self action:@selector(tappedButton:) forControlEvents:UIControlEventTouchUpInside];
	
	[self.contentView addSubview:_heartButton];
	
	_heartButton.top = _webImageView.top;
	_heartButton.left = _webImageView.left;
	
	[_self addClickControlToAnimatedImageView];
	
	[[JSBadgeView appearance] setBadgePositionAdjustment:CGPointMake(-15, 15)];
	
	_badgeView = [[JSBadgeView alloc] initWithParentView:_webImageView alignment:JSBadgeViewAlignmentTopRight];
	
	UITapGestureRecognizer *g1 = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id sender) {
//		[_self setImageURL:_self.webImageView.yy_imageURL];
//		NSLog(@"url of the clicked image is %@", _self.webImageView.yy_imageURL);
		[_self displayComment];
	}];

	[_badgeView addGestureRecognizer:g1];
	
	UIImage* commentsImage = [self getCommentIcon: 0];
	
//	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	
//	UIButton *button =[[UIButton alloc]init];
//	
//	[button setFrame:CGRectMake(135,120,60,30)];
	
	
	_commentBtn = [UIButton buttonWithType:UIButtonTypeSystem];
	_commentBtn.frame = CGRectMake(0, 0, 45, 45);
	
	[_commentBtn setImage:commentsImage forState:UIControlStateNormal];
	[_commentBtn setImage:commentsImage forState:UIControlStateHighlighted];
	[_commentBtn setTintColor:[UIColor colorWithRed:255.0 / 255.0 green:255.0 / 255.0 blue:255.0 / 255.0 alpha:0.4]];
//	[_commentBtn setTintColor:[UIColor whiteColor]];
//	[_commentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//	[_commentBtn setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
	
	
	[self.contentView addSubview:_commentBtn];
	
	_commentBtn.top = _webImageView.top;
	_commentBtn.right = _webImageView.right;
	
	[_commentBtn addTarget:self action:@selector(displayComment) forControlEvents:UIControlEventTouchUpInside];
	

//	_imgView = 	[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
//	
//	_imgView.clipsToBounds = YES;
//	
//	_imgView.tintColor = [UIColor whiteColor];
//	_imgView.backgroundColor = [UIColor whiteColor];
//	
//	[self.contentView addSubview:_imgView];
//	
//	_imgView.bottom = _webImageView.bottom;
//	_imgView.right = _webImageView.right;
	
	return self;
}

- (void)tappedButton:(DOFavoriteButton *)sender {
	if (sender.selected) {
		[sender deselect];
		[[FavoriateMgr sharedInstance] unsetFavoriate:[[_webImageView yy_imageURL] absoluteString]];
	} else {
		[sender select];
		[[FavoriateMgr sharedInstance] setFavoriate:[[_webImageView yy_imageURL] absoluteString]];
	}
}

- (CGSize)sizeThatFits:(CGSize)size {
	CGFloat totalHeight = 0;
	totalHeight += self.webImageView.size.height;
	totalHeight += cellMargin; // margins
	return CGSizeMake(kScreenWidth, totalHeight);
}


- (void)addClickControlToAnimatedImageView{
	
	self.webImageView.userInteractionEnabled = YES;
	
	__weak typeof(self.webImageView) _view = self.webImageView;
	__weak typeof(self) _self = self;
	
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id sender) {
		
		ClipController* tc = (ClipController* )[_self viewController];
		
		if(!_self.downLoaded || tc.fullScreen) return;
		
		if ([_view isAnimating]) [_view stopAnimating];
		else [_view startAnimating];
		
		UIViewAnimationOptions op = UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState;
		[UIView animateWithDuration:0.1 delay:0 options:op animations:^{
			_view.layer.transformScale = 0.97;
		} completion:^(BOOL finished) {
			[UIView animateWithDuration:0.1 delay:0 options:op animations:^{
				_view.layer.transformScale = 1.008;
			} completion:^(BOOL finished) {
				[UIView animateWithDuration:0.1 delay:0 options:op animations:^{
					_view.layer.transformScale = 1;
				} completion:NULL];
			}];
		}];
	}];
	
	singleTap.numberOfTapsRequired = 1;
	
	[_view addGestureRecognizer:singleTap];
	
	UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id sender) {
		
		if(!_self.downLoaded) return;
		[_view stopAnimating];
		
		ClipController* tc = (ClipController* )[_self viewController];
		ClipPlayController *clipCtr = [ClipPlayController new];
		tc.fullScreen = true;
		clipCtr.clipURL = [[_view yy_imageURL] absoluteString];
		clipCtr.favorite = TRUE;
		clipCtr.showLike = FALSE;
		clipCtr.standalone = false;
		clipCtr.modalPresentationStyle = UIModalPresentationCurrentContext;
		clipCtr.delegate = _self;
		
		[tc presentViewController:clipCtr animated:YES completion:nil];
		
	}];
	
	doubleTap.numberOfTapsRequired = 2;
	
	[_view addGestureRecognizer:doubleTap];
}

- (void)showClipView:(NSString*)url{
	
	ClipController* tc = (ClipController* )[self viewController];
	
	tc.fullScreen = true;
	
	ClipPlayController *clipCtr = [ClipPlayController new];
	
	clipCtr.clipURL = url;
	clipCtr.favorite = TRUE;
	clipCtr.showLike = FALSE;
	clipCtr.standalone = false;
	
	clipCtr.modalPresentationStyle = UIModalPresentationCurrentContext;
	clipCtr.delegate = self;
	
	[tc presentViewController:clipCtr animated:YES completion:nil];
}

- (void)setCellData:(ArticleEntity*) entity isForHeight:(BOOL)isForHeight {
	
	if(!isForHeight) [self setImageURL:[NSURL URLWithString:entity.image]];
}

- (void)setImageURL:(NSURL *)url {
	
	__weak typeof(self) _self = self;
	
	_label.hidden = YES;
	
	[CATransaction begin];
	[CATransaction setDisableActions: YES];
	self.progressLayer.hidden = YES;
	self.progressLayer.strokeEnd = 0;
	[CATransaction commit];
	
	_self.downLoaded = FALSE;
	
	_webImageView.autoPlayAnimatedImage = FALSE;
	
	_heartButton.hidden = true;
	_commentBtn.hidden = true;
	
//	_badgeView.hidden = true;

	UIImage *placeholderImage = [[DRImagePlaceholderHelper sharedInstance] placerholderImageWithSize:_webImageView.size text: @"球路"];
	
	[_webImageView yy_setImageWithURL:url
	                           placeholder:placeholderImage
							  options:YYWebImageOptionProgressiveBlur |YYWebImageOptionSetImageWithFadeAnimation | YYWebImageOptionShowNetworkActivity
	 //| YYWebImageOptionRefreshImageCache
							 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
								 if (expectedSize > 0 && receivedSize > 0) {
									 CGFloat progress = (CGFloat)receivedSize / expectedSize;
									 progress = progress < 0 ? 0 : progress > 1 ? 1 : progress;
									 if (_self.progressLayer.hidden) _self.progressLayer.hidden = NO;
									 _self.progressLayer.strokeEnd = progress;
								 }
							 }
							transform:nil
						   completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
							   if (stage == YYWebImageStageFinished) {
								   _self.progressLayer.hidden = YES;

								   if (!image) {
									   _self.label.hidden = NO;
								   }
								   
								   if(!error) {
									   _self.downLoaded = TRUE;
									   if ([_self isFullyInView]) {
										   [_self.webImageView startAnimating];
										}
									   if([[FavoriateMgr sharedInstance] isFavoriate:[url absoluteString]]) {
										   [_self.heartButton selectWithNoAnim];
									   }else {
										   [_self.heartButton deselectWithNoAnim];
									   }
									   
									   NSString* qty = (NSString *)[_self getCommentQty: [url absoluteString]];
									   
									   [_self updateCommentQty:qty];
									   
//									   NSLog(@"Qty of clip %@ is %@", [url absoluteString], qty);
									   
//									   _self.badgeView.badgeText = qty;
									   
									   _self.heartButton.hidden = false;
									   _self.commentBtn.hidden = false;
									   
//									   _self.badgeView.hidden = false;
								   }
							   }
						   }];
}

- (ClipController *) getViewCtr {
	ClipController* tc = (ClipController* )[self viewController];
	return tc;
}

- (BOOL)isFullyInView {
	ClipController* ctr = [self getViewCtr];

	 NSIndexPath *indexPath = [ctr.tableView indexPathForCell:self];

	 CGRect rectOfCellInTableView = [ctr.tableView rectForRowAtIndexPath: indexPath];
	 CGRect rectOfCellInSuperview = [ctr.tableView convertRect: rectOfCellInTableView toView: ctr.tableView.superview];

	return (rectOfCellInSuperview.origin.y <= sHeight - kCellHeight && rectOfCellInSuperview.origin.y >= 64);
}

- (NSString *)getCommentQty:(NSString *)url {
	ClipController* ctr = [self getViewCtr];
	NSString *qty = [ctr getCommentQty:url];
	return qty? qty: @"0";
}

- (void)displayComment {
	ClipController* ctr = [self getViewCtr];
	
	[ctr showComments:[self.webImageView.yy_imageURL absoluteString]];
	
//	[ctr getCommentDetail:[self.webImageView.yy_imageURL absoluteString] callback:^(NSArray* list) {
//		NSLog(@"count of comments = %li", list.count);
////		[ctr setComments:list];
////		[ctr setCommentsHidden:NO];
//	}];
}

- (void)updateCommentQty:(NSString*)qty {
	UIImage* commentsImage = [self getCommentIcon: [qty intValue]];
	[_commentBtn setImage:commentsImage forState:UIControlStateNormal];
	[_commentBtn setImage:commentsImage forState:UIControlStateHighlighted];
//	[_imgView setImage:commentsImage];
}

- (UIImage *)getCommentIcon:(NSInteger)count {
	
	CGSize iconSize = CGSizeMake(25, 27);
	
	UIGraphicsBeginImageContextWithOptions(iconSize, NO, 0.0);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
	CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
	
	CGRect bubbleRect = CGRectMake(1, 1+iconSize.height*0.05, iconSize.width-2, (iconSize.height*0.69)-2);
	
	CGFloat minx = CGRectGetMinX(bubbleRect), midx = CGRectGetMidX(bubbleRect), maxx = CGRectGetMaxX(bubbleRect);
	CGFloat miny = CGRectGetMinY(bubbleRect), midy = CGRectGetMidY(bubbleRect), maxy = CGRectGetMaxY(bubbleRect);
	
	CGFloat radius = 3.0;
	// Start at 1
	CGContextMoveToPoint(context, minx, midy);
	// Add an arc through 2 to 3
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	// Add an arc through 4 to 5
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	
	// Add an arc through 6 to 7
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	
	CGContextAddLineToPoint(context, midx, maxy);
	CGContextAddLineToPoint(context, midx-5, maxy+5);
	CGContextAddLineToPoint(context, midx-5, maxy);
	
	// Add an arc through 8 to 9
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	// Close the path
	CGContextClosePath(context);
	
	// Fill & stroke the path
	CGRect countLabelRect = CGRectOffset(bubbleRect, 0, -1);
	UILabel *countLabel = [[UILabel alloc] initWithFrame:countLabelRect];
	NSString *fontName = @"HelveticaNeue-Bold";
	[countLabel setFont:[UIFont fontWithName:fontName size:12]];
	NSString *labelString;
	
	if(count == 0){
		labelString = @"0";
	} else if (count > 99) {
		labelString = @"99+";
	} else {
		labelString = [NSString stringWithFormat:@"%li", (long)count];
	}
	
	[countLabel setText:labelString];
	[countLabel setTextAlignment:NSTextAlignmentCenter];
	if(true){
		CGContextFillPath(context);
		CGContextSaveGState(context);
		CGContextSetBlendMode(context, kCGBlendModeSourceOut);
		[countLabel drawTextInRect:countLabelRect];
		CGContextRestoreGState(context);
	} else {
		CGContextStrokePath(context);
		[countLabel drawTextInRect:countLabelRect];
	}
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}

@end


@implementation ClipController {
	DOFavoriteButton *infoButton;
	NSArray *data;
	TencentOAuth *oauth;
//	ClientModelRepository *repository;
	MyLBAdapter *adapter;
	LBModelRepository *clientRep;
	LBPersistedModelRepository *commentRep;
	LBModelRepository *postRep;
	NSString* newCommentClipID;
	NSString* newCommentText;
	NSDictionary* commentList;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	oauth = [[TencentOAuth alloc] initWithAppId:@"1105320149"
									andDelegate:self];
	
	adapter = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).adapter;
	
//	repository = (ClientModelRepository *)[adapter repositoryWithClass:[ClientModelRepository class]];

	commentRep = [adapter repositoryWithPersistedModelName:@"comments"];
	clientRep = [adapter repositoryWithModelName:@"clients"];
	postRep = [adapter repositoryWithModelName:@"posts"];
	
	[self fetchPostComments:[self postID]];
	
	Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
	NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
	if (networkStatus == ReachableViaWWAN) {
		[YYWebImageManager sharedManager].queue.maxConcurrentOperationCount = 1;
	} else {
		[YYWebImageManager sharedManager].queue.maxConcurrentOperationCount = 2;
	}
	
	self.tableView.fd_debugLogEnabled = NO;
	
	[self.tableView registerClass:[ClipCell class] forCellReuseIdentifier:@"clipCell"];
	[self.tableView registerClass:[TitleCell class] forCellReuseIdentifier:@"titleCell"];
	
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.view.backgroundColor = [UIColor whiteColor];
	self.navigationController.navigationBar.tintColor = [UIColor blackColor];
	
	[self setFavorite];
	
	[self.navigationItem setTitle: _header];
	
	[self addInfoIcon];
	
	if(_showInfo) {
		[self showPopup];
	}
	
	[self initData];
	
	[self initHeader];
	
//	[self loadCommentsView:baseView];
	
	[self.tableView reloadData];
}

- (void)login {
	NSArray* permissions = [NSArray arrayWithObjects:
							kOPEN_PERMISSION_GET_USER_INFO,
							kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
							kOPEN_PERMISSION_ADD_ALBUM,
							kOPEN_PERMISSION_ADD_ONE_BLOG,
							kOPEN_PERMISSION_ADD_SHARE,
							kOPEN_PERMISSION_ADD_TOPIC,
							kOPEN_PERMISSION_CHECK_PAGE_FANS,
							kOPEN_PERMISSION_GET_INFO,
							kOPEN_PERMISSION_GET_OTHER_INFO,
							kOPEN_PERMISSION_LIST_ALBUM,
							kOPEN_PERMISSION_UPLOAD_PIC,
							kOPEN_PERMISSION_GET_VIP_INFO,
							kOPEN_PERMISSION_GET_VIP_RICH_INFO,
							nil];
	
	[oauth authorize:permissions inSafari:NO];
}

// 登录成功后的回调
- (void)tencentDidLogin {
	
//	[oauth accessToken];
//	[oauth openId];
//	[oauth expirationDate];
//	[oauth getUserInfo];
	
	if (oauth.accessToken && 0 != [oauth.accessToken length])
	{
//		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"openId"
//															message:oauth.openId delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
//		[alertView show];
		[oauth getUserInfo];
	}
}

- (void)getUserInfoResponse:(APIResponse*) response {
	if (URLREQUEST_SUCCEED == response.retCode
		&& kOpenSDKErrorSuccess == response.detailRetCode) {
//		NSMutableString *str = [NSMutableString stringWithFormat:@""];
//		for (id key in response.jsonResponse) {
//			[str appendString: [NSString stringWithFormat:
//								@"%@:%@\n", key, [response.jsonResponse objectForKey:key]]];
//		}
//		
////		NSLog([NSString stringWithFormat:@"%@",str]);
//		
//		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"操作成功"
//														message:[NSString stringWithFormat:@"%@",str]
//													   delegate:self
//											  cancelButtonTitle:@"我知道啦"
//											  otherButtonTitles: nil];
//		[alert show];
		
//		[adapter setAccessToken:@"RP9j4swbggEjMreP1xSGSOotyM1n51VdAbxcRSQh0DXUa4mAMBu9trL6fDjjlLOl"];
		
		
//		LBPersistedModel *model = (LBPersistedModel*)[commentRep modelWithDictionary:@{
//																@"id_clip": @"http://3.gif",
//																@"text": @"太酷了！"
//																}];
//		[model saveWithSuccess:^{
//			NSLog(@"Successfully saved %@", model);
//		} failure:^(NSError *error) {
//			NSLog(@"Failed to save %@ with %@", model, error);
//		}];
		
		
//		[clientRep invokeStaticMethod:@"register"
//							parameters:@{
//											@"platform": @"qq",
//											@"openID": oauth.openId,
//											@"name": [response.jsonResponse objectForKey:@"nickname"],
//											@"avatar": [response.jsonResponse objectForKey:@"figureurl_qq_1"]
//										 }
//							   success:^(id value) {
//								   NSLog(@"Successfully loaded all Client models.");
//							   }
//							   failure:^(NSError *error) {
//								   NSLog(@"Successfully loaded all Client models.");
//							   }];
		[self registerClient:@"qq" userName:[response.jsonResponse objectForKey:@"nickname"] avatar:[response.jsonResponse objectForKey:@"figureurl_qq_2"]];
		
	} else {
		NSString *errMsg = [NSString stringWithFormat:@"errorMsg:%@\n%@",
							response.errorMsg, [response.jsonResponse objectForKey:@"msg"]];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"操作失败"
														message:errMsg
													   delegate:self
											  cancelButtonTitle:@"我知道啦"
											  otherButtonTitles: nil];
		[alert show];
	}
}

// 登录失败后的回调
- (void)tencentDidNotLogin:(BOOL)cancelled {
	if (!cancelled) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"结果" message:@"登录失败" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
		[alertView show];
	}
}

// 登录时网络有问题的回调
- (void)tencentDidNotNetWork{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"结果" message:@"登录失败" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
	[alertView show];
	
}
- (void)setFavorite {
	if(self.favorite) {
		self.header = @"我的收藏";
		self.articleURLs = [[FavoriateMgr sharedInstance] getFavoriateImages];
	}
}

- (void)initData {
	NSMutableArray *entities = @[].mutableCopy;
	
	if(_articleURLs) {
		for (NSString *url in _articleURLs) {
			[entities addObject:[[ArticleEntity alloc] initWithData:url desc: @""]];
		}
	}else if(_articleDicts) {
		
		[_articleDicts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			NSString *desc = obj[@"desc"];
			NSString *url = obj[@"url"];
			if(desc && [desc length] != 0) {
				[entities addObject:[[ArticleEntity alloc] initWithData:@"" desc:desc]];
			}
			[entities addObject:[[ArticleEntity alloc] initWithData:url desc:@""]];
		}];
	}
	
	data = [entities mutableCopy];
}

- (void)initHeader {
	
	UIView *header = [UIView new];
	
	if(_summary && [_summary length] != 0)  {

		TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
		label.backgroundColor = [UIColor clearColor];
		label.frame = CGRectMake(cellMargin, 15, kScreenWidth, 60);
		
		label.textAlignment = NSTextAlignmentLeft;
		label.numberOfLines = 0;
		
		NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
		style.lineSpacing = 13;
		
		NSAttributedString *attString = [[NSAttributedString alloc] initWithString:_summary
																		attributes:@{
																					 NSFontAttributeName : [UIFont boldSystemFontOfSize:16],
																					 (id)kCTParagraphStyleAttributeName : style,
																					 }];
		
		label.text = attString;
		
		[label sizeToFit];
		
		[header addSubview:label];
		
		UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, label.bottom + cellMargin, self.view.width, 0.5)];
		lineView.backgroundColor = [UIColor lightGrayColor];
		[header addSubview:lineView];
		
		header.size = CGSizeMake(self.view.width, lineView.bottom + cellMargin);
		
	}else {
		header.size = CGSizeMake(self.view.width, cellMargin);
	}
	
	UIView *footer = [UIView new];
	footer.size = CGSizeMake(self.view.width, 0);
	
	self.tableView.tableHeaderView = header;
	self.tableView.tableFooterView = footer;
}

- (void)showPopup {
	
	NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
	paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
	paragraphStyle.alignment = NSTextAlignmentCenter;
	
	NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"操作说明" attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:24], NSParagraphStyleAttributeName : paragraphStyle}];
	NSAttributedString *lineOne = [[NSAttributedString alloc] initWithString:@"单击短片播放/暂停" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSParagraphStyleAttributeName : paragraphStyle}];
	
	NSAttributedString *lineTwo = [[NSAttributedString alloc] initWithString:@"双击进入滑屏慢放模式" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSForegroundColorAttributeName : [UIColor colorWithRed:255.0 / 255.0 green:64.0 / 255.0 blue:0.0 / 255.0 alpha:1.0], NSParagraphStyleAttributeName : paragraphStyle}];
	
	CNPPopupButton *button = [[CNPPopupButton alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
	[button setTitle:@"知道了" forState:UIControlStateNormal];
	button.backgroundColor = [UIColor colorWithRed:255.0 / 255.0 green:64.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
	button.layer.cornerRadius = 4;
	
	UILabel *titleLabel = [[UILabel alloc] init];
	titleLabel.numberOfLines = 0;
	titleLabel.attributedText = title;
	
	UILabel *lineOneLabel = [[UILabel alloc] init];
	lineOneLabel.numberOfLines = 0;
	lineOneLabel.attributedText = lineOne;
	
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tip"]];
	
	UILabel *lineTwoLabel = [[UILabel alloc] init];
	lineTwoLabel.numberOfLines = 0;
	lineTwoLabel.attributedText = lineTwo;
	
	CNPPopupController *popupController = [[CNPPopupController alloc] initWithContents:@[titleLabel, lineOneLabel, lineTwoLabel, imageView, button]];
	popupController.theme = [CNPPopupTheme defaultTheme];
	popupController.theme.popupStyle = CNPPopupStyleCentered;
	popupController.theme.cornerRadius = 10.0f;
	
	popupController.delegate = self;
	
	button.selectionHandler = ^(CNPPopupButton *button){
		[popupController dismissPopupControllerAnimated:YES];
	};
	
	[popupController presentPopupControllerAnimated:YES];
}

- (void)popupControllerDidDismiss:(CNPPopupController *)controller {
	if(!infoButton.selected) [infoButton select];
}

- (void)addInfoIcon {
	
	if(!_showInfo) {
		infoButton = [[DOFavoriteButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 64,[UIApplication sharedApplication].statusBarFrame.size.height, 44, 44) image:[UIImage imageNamed:@"info"] selected: true];
	}else {
		infoButton = [[DOFavoriteButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 64,[UIApplication sharedApplication].statusBarFrame.size.height, 44, 44) image:[UIImage imageNamed:@"info"] selected: false];
	}
	
	infoButton.imageColorOn = [UIColor colorWithRed:255.0 / 255.0 green:64.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
	infoButton.circleColor = [UIColor colorWithRed:255.0 / 255.0 green:64.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
	infoButton.lineColor = [UIColor colorWithRed:245.0 / 255.0 green:54.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
	
	[infoButton addTarget:self action:@selector(tappedButton:) forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
	
	self.navigationItem.rightBarButtonItem = button;
}

- (void)tappedButton:(DOFavoriteButton *)sender {
//	[self showPopup];
//	[self login];
	[self submitComment:@"http://2.gif" comment:@"太酷了太酷了太酷了！"];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	_fullScreen = false;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
		// back button was pressed.  We know this is true because self is no longer
		// in the navigation stack.
		[self.navigationController setNavigationBarHidden:YES];
	}
	
	if(!_fullScreen) {
		[[YYWebImageManager sharedManager].queue cancelAllOperations];
		[[YYImageCache sharedCache].memoryCache removeAllObjects];
	}
}

- (void)reload {
	[[YYImageCache sharedCache].memoryCache removeAllObjects];
	[[YYImageCache sharedCache].diskCache removeAllObjectsWithBlock:nil];
	[self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	ArticleEntity *entity = data[indexPath.row];
	
	if([entity.image length] == 0) {
		TitleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"titleCell" ];
		[self configureTitleCell:cell atIndexPath:indexPath isForHeight:false];
		return cell;
	}else {
		ClipCell *cell = [tableView dequeueReusableCellWithIdentifier:@"clipCell" ];
		[self configureCell:cell atIndexPath:indexPath isForHeight:false];
		return cell;
	}
}

- (void)configureCell:(ClipCell *)cell atIndexPath:(NSIndexPath *)indexPath isForHeight:(BOOL)isForHeight {
	cell.fd_enforceFrameLayout = YES; // Enable to use "-sizeThatFits:"
	[cell setCellData: data[indexPath.row] isForHeight:isForHeight];
}

- (void)configureTitleCell:(TitleCell *)cell atIndexPath:(NSIndexPath *)indexPath isForHeight:(BOOL)isForHeight {
	cell.fd_enforceFrameLayout = YES; // Enable to use "-sizeThatFits:"
	[cell setCellData: data[indexPath.row] isForHeight:isForHeight];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

	ArticleEntity *entity = data[indexPath.row];
	
	if([entity.image length] == 0) {
		return [tableView fd_heightForCellWithIdentifier:@"titleCell" cacheByIndexPath:indexPath configuration:^(id cell) {
			[self configureTitleCell:cell atIndexPath:indexPath isForHeight:true];
		}];
	}else{
		return [tableView fd_heightForCellWithIdentifier:@"clipCell" cacheByIndexPath:indexPath configuration:^(id cell) {
			[self configureCell:cell atIndexPath:indexPath isForHeight:true];
		}];
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

	for (UITableViewCell *cell in [self.tableView visibleCells]) {
		
		if([cell isKindOfClass:[ClipCell class]]) {
			ClipCell *_cell = (ClipCell *) cell;
			if([self isFullyInView: _cell]) {
				if(!_cell.webImageView.isAnimating) [_cell.webImageView startAnimating];
			}else{
				if(_cell.webImageView.isAnimating) [_cell.webImageView stopAnimating];
			}
		}
	}
}

- (BOOL)isFullyInView:(ClipCell *)cell {
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

	CGRect rectOfCellInTableView = [self.tableView rectForRowAtIndexPath: indexPath];
	CGRect rectOfCellInSuperview = [self.tableView convertRect: rectOfCellInTableView toView: self.tableView.superview];
	
	return (rectOfCellInSuperview.origin.y <= sHeight - kCellHeight && rectOfCellInSuperview.origin.y >= 64);
}

- (void)registerClient:(NSString *)platform userName:(NSString *)name avatar:(NSString *)avatar {
	[clientRep invokeStaticMethod:@"register"
							parameters:@{
											@"platform": platform,
											@"openID": oauth.openId,
											@"name": name,
											@"avatar": avatar
										 }
							success:^(id value) {
								NSLog(@"Successfully loaded all Client models.");
								[adapter setAccessToken:[[value objectForKey:@"data"] objectForKey:@"accesstoken"]];
								[self submitComment:newCommentClipID comment:newCommentText];
							}
							failure:^(NSError *error) {
								NSLog(@"failed loaded all Client models.");
							}];
}

- (void)submitComment:(NSString *)id_clip comment:(NSString *)text {
	LBPersistedModel *model = (LBPersistedModel*)[commentRep modelWithDictionary:@{
																						  @"id_clip": id_clip,
																						  @"text": text
																						  }];
	[model saveWithSuccess:^{
		NSLog(@"Successfully saved %@", model);
		newCommentClipID = @"";
		newCommentText = @"";
		[self displayAll];
	} failure:^(NSError *error) {
		NSLog(@"Failed to save %@ with %@", model, error);
		newCommentClipID = id_clip;
		newCommentText = text;
		[self login];
	}];
}

- (void)fetchPostComments:(NSString *)id_post {
	[postRep invokeStaticMethod:@"getCommentQty"
					   parameters:@{@"id_post": id_post}
						  success:^(id value) {
//							  commentList = [[value objectForKey:@"data"] objectForKey:@"commentQtyList"];
							  [self generateCommentList:[[value objectForKey:@"data"] objectForKey:@"commentQtyList"]];
							  NSLog(@"Successfully loaded all comments.");
						  }
						  failure:^(NSError *error) {
							  NSLog(@"failed loaded all comments.");
						  }];
}

- (void)generateCommentList:(NSArray *)comments {
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
	
	for (NSDictionary *comment in comments) {
		[dict setObject:[comment objectForKey:@"comment_quantity"] forKey:[comment objectForKey:@"id_clip"]];
	}
	
	commentList = [dict copy];
}

- (NSString *)getCommentQty:(NSString *)clipID {
	return [[commentList objectForKey:clipID] stringValue];
}

- (void)getCommentDetail:(NSString *)clipID callback: (void(^)(NSArray*))handler {
	[commentRep invokeStaticMethod:@"commentsByClip"
					 parameters:@{@"id_clip": clipID}
						success:^(id value) {
							NSArray *list = (NSArray*)[[value objectForKey:@"data"] objectForKey:@"commentsList"];
//							[self.delegate setComments:list];
//							[self.delegate loadComments:list];
							[self.delegate showComments];
							handler(list);
							NSLog(@"Successfully loaded all comments.");
						}
						failure:^(NSError *error) {
							NSLog(@"failed loaded all comments.");
						}];
}

- (void)showComments:(NSString *)clipID {
	[commentRep invokeStaticMethod:@"commentsByClip"
					 parameters:@{@"id_clip": clipID}
						   success:^(id value) {
							   NSArray *list = (NSArray*)[[value objectForKey:@"data"] objectForKey:@"commentsList"];
							   //							[self.delegate setComments:list];
							   //							[self.delegate loadComments:list];
//							   [self.delegate showComments];
							   [self showCommentsView:list];
							   NSLog(@"Successfully loaded all comments.");
						   }
						   failure:^(NSError *error) {
							   NSLog(@"failed loaded all comments.");
						   }];
}

- (void) displayAll {
	
}

- (void)showCommentsView: (NSArray *)list {
	
	NSMutableArray* comments = [[NSMutableArray alloc] init];
	
	for(NSDictionary *dict in list) {
		ModelComment *comment = [ModelComment commentWithProperties:dict];
		[comments addObject:comment];
	}
	
	EBCommentsViewController *clipCtr = [[EBCommentsViewController alloc] initWithComments:[comments copy]];
	clipCtr.modalPresentationStyle = UIModalPresentationOverFullScreen;
	[self presentViewController:clipCtr animated:YES completion:nil];
}

//- (void)loadCommentsView {
//	EBCommentsViewController *ctr = [[EBCommentsViewController alloc] initWithScreenSize: self.view.size];
//	[self setDelegate:ctr];
//}

@end

