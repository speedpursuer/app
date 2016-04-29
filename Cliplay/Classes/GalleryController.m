//
//  GalleryController.m
//  YYKitExample
//
//  Created by ibireme on 15/7/19.
//  Copyright (c) 2015 ibireme. All rights reserved.
//

#import "GalleryController.h"
#import "YYWebImage.h"
#import "UIView+YYAdd.h"
#import "CALayer+YYAdd.h"
#import "UIGestureRecognizer+YYAdd.h"
#import "YYImageExampleHelper.h"
#import "ClipPlayController.h"
#import "DRImagePlaceholderHelper.h"
#import "DOFavoriteButton.h"
//#import "UITableView+FDTemplateLayoutCell.h"
#import "ArticleEntity.h"
#import "TTTAttributedLabel.h"
#import "Reachability.h"
#import "FavoriateMgr.h"

//#define kCellHeight ceil((kScreenWidth) * 3.0 * 0.9 / 4.0)
#define kCellHeight ceil((kScreenWidth) * 3.0 * 0.9/ 4.0)
#define kScreenWidth ((UIWindow *)[UIApplication sharedApplication].windows.firstObject).width
#define sHeight [UIScreen mainScreen].bounds.size.height

@interface GalleryControllerCell : UITableViewCell
@property (nonatomic, strong) YYAnimatedImageView *webImageView;
//@property (nonatomic, strong) UILabel *imageLabel;
//@property (nonatomic, strong) TTTAttributedLabel *imageLabel;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign) BOOL downLoaded;
//@property (nonatomic, strong) UIImageView *errPage;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, strong) DOFavoriteButton *heartButton;
@end

@implementation GalleryControllerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	self.backgroundColor = [UIColor whiteColor];
	self.contentView.backgroundColor = [UIColor whiteColor];
	self.contentView.bounds = [UIScreen mainScreen].bounds;
	self.size = CGSizeMake(kScreenWidth, kCellHeight + 20);
	self.contentView.size = self.size;
//	self.backgroundView.size = CGSizeMake(kScreenWidth, kCellHeight + 50);
	
	
//	_imageLabel = [UILabel new];
//	_imageLabel.backgroundColor = [UIColor clearColor];
//	_imageLabel.frame = CGRectMake(15, 0, self.size.width - 30, 20);
//	_imageLabel.textAlignment = NSTextAlignmentLeft;
//	_imageLabel.numberOfLines = 0;
//	[_imageLabel setTextColor:[UIColor darkGrayColor]];
//	[self.contentView addSubview:_imageLabel];

	
//	_imageLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
//	_imageLabel.textAlignment = NSTextAlignmentLeft;
//	_imageLabel.numberOfLines = 0;
//	[_imageLabel setTextColor:[UIColor darkGrayColor]];
//	[self.contentView addSubview:_imageLabel];
	
	_webImageView = [YYAnimatedImageView new];
	
	_webImageView.translatesAutoresizingMaskIntoConstraints = NO;
	
	_webImageView.size = CGSizeMake(kScreenWidth * 0.9, kCellHeight);
	_webImageView.centerX = self.width / 2;
	_webImageView.clipsToBounds = YES;
//	_webImageView.top = 20;
	_webImageView.contentMode = UIViewContentModeScaleAspectFill;
	_webImageView.backgroundColor = [UIColor whiteColor];
	
	[self.contentView addSubview:_webImageView];
	
//	[NSLayoutConstraint constraintWithItem:_webImageView
//								 attribute:NSLayoutAttributeTop
//								 relatedBy:NSLayoutRelationEqual
//									toItem:_imageLabel
//								 attribute:NSLayoutAttributeBottom
//								multiplier:1
//								  constant:10].active = true;
//	
//	[NSLayoutConstraint constraintWithItem:_webImageView
//									attribute:NSLayoutAttributeCenterX
//									relatedBy:NSLayoutRelationEqual
//										toItem:self.contentView
//									attribute:NSLayoutAttributeCenterX
//									multiplier:1
//									  constant:0].active = true;
//	
//	[NSLayoutConstraint constraintWithItem:_webImageView
//								 attribute:NSLayoutAttributeHeight
//								 relatedBy:NSLayoutRelationEqual
//									toItem:nil
//								 attribute:NSLayoutAttributeNotAnAttribute
//								multiplier:1
//								  constant:kCellHeight].active = true;
//	
//	[NSLayoutConstraint constraintWithItem:_webImageView
//								 attribute:NSLayoutAttributeWidth
//								 relatedBy:NSLayoutRelationEqual
//									toItem:nil
//								 attribute:NSLayoutAttributeNotAnAttribute
//								multiplier:1
//								  constant:kScreenWidth].active = true;
	
	
	_indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	_indicator.center = CGPointMake(self.width / 2, self.height / 2);
	_indicator.hidden = YES;
	
//	UIImage *img = [[DRImagePlaceholderHelper sharedInstance] placerholderImageWithSize: _webImageView.size text:@""];
//	_errPage = [UIImageView new];
//	_errPage.size = _webImageView.size;
//	_errPage.centerX = self.width / 2;
////	_errPage.top = 20;
//	
//	_errPage.image = img;
//	_errPage.hidden = YES;
//	[self.contentView addSubview:_errPage];
	
	_label = [UILabel new];
	_label.size = _webImageView.size;
	_label.textAlignment = NSTextAlignmentCenter;
	_label.text = @"下载异常, 点击重试";
	_label.centerX = self.centerX;
	_label.centerY = _webImageView.centerY + _webImageView.height * 0.2;
	_label.textColor = [UIColor whiteColor];
	_label.hidden = YES;
	_label.userInteractionEnabled = YES;
	[self.contentView addSubview:_label];
	
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
	
	_scale = 1;
	
	[self addClickControlToAnimatedImageView];
	
	return self;
}

- (void)addClickControlToAnimatedImageView{
	
//	NSLog(@"addClickControlToAnimatedImageView");
	
	self.webImageView.userInteractionEnabled = YES;
	__weak typeof(self.webImageView) _view = self.webImageView;
	__weak typeof(self) _self = self;
	
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id sender) {
		
		GalleryController* _tc = (GalleryController* )[_self viewController];
		
		if(!_self.downLoaded || _tc.fullScreen) return;
		
		if ([_view isAnimating]) [_view stopAnimating];
		else [_view startAnimating];
		
		UIViewAnimationOptions op = UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState;
		[UIView animateWithDuration:0.1 delay:0 options:op animations:^{
			_view.layer.transformScale = 0.97 * _self.scale;
		} completion:^(BOOL finished) {
			[UIView animateWithDuration:0.1 delay:0 options:op animations:^{
				_view.layer.transformScale = 1.008 * _self.scale;
			} completion:^(BOOL finished) {
				[UIView animateWithDuration:0.1 delay:0 options:op animations:^{
					_view.layer.transformScale = 1 * _self.scale;
				} completion:NULL];
			}];
		}];
	}];
	
	singleTap.numberOfTapsRequired = 1;
	
	[_view addGestureRecognizer:singleTap];
	
	UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id sender) {
		
		[[FavoriateMgr sharedInstance] setFavoriate:[[_view yy_imageURL] absoluteString]];
		
		if(!_self.downLoaded) return;
		[_view stopAnimating];
//		[_self showClipView:[[_view yy_imageURL] absoluteString]];
		GalleryController* tc = (GalleryController* )[_self viewController];
		
		tc.fullScreen = true;
		
		ClipPlayController *_clipCtr = [ClipPlayController new];
		
		_clipCtr.clipURL = [[_view yy_imageURL] absoluteString];
		_clipCtr.favorite = TRUE;
		_clipCtr.showLike = FALSE;
		_clipCtr.standalone = false;
		
		_clipCtr.modalPresentationStyle = UIModalPresentationCurrentContext;
		_clipCtr.delegate = _self;
		
		[tc presentViewController:_clipCtr animated:YES completion:nil];
	}];
	
	doubleTap.numberOfTapsRequired = 2;
	
	[_view addGestureRecognizer:doubleTap];
	
	//	[singleTap requireGestureRecognizerToFail:doubleTap];
}

- (void)showClipView:(NSString*)url{
	
	GalleryController* tc = (GalleryController* )[self viewController];
	
	tc.fullScreen = true;
	
	ClipPlayController *_clipCtr = [ClipPlayController new];
	
	_clipCtr.clipURL = url;
	_clipCtr.favorite = TRUE;
	_clipCtr.showLike = FALSE;
	_clipCtr.standalone = false;
	
	_clipCtr.modalPresentationStyle = UIModalPresentationCurrentContext;
	_clipCtr.delegate = self;
	
	[tc presentViewController:_clipCtr animated:YES completion:nil];
}

- (void)setImageURL:(NSURL *)url {
	
	_label.hidden = YES;
	_indicator.hidden = NO;
//	_errPage.hidden = YES;
	[_indicator startAnimating];
	__weak typeof(self) _self = self;
	
	[CATransaction begin];
	[CATransaction setDisableActions: YES];
	self.progressLayer.hidden = YES;
	self.progressLayer.strokeEnd = 0;
	[CATransaction commit];
	
	_self.downLoaded = FALSE;
	
	_webImageView.autoPlayAnimatedImage = FALSE;

	
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
								   [_self.indicator stopAnimating];
								   _self.indicator.hidden = YES;
								   if (!image) {
									   _self.label.hidden = NO;
//									   _self.errPage.hidden = NO;
								   }
								   
								   if(!error) {
									   _self.downLoaded = TRUE;
									   if ([_self isFullyInView]) {
										   [_self.webImageView startAnimating];
										}
								   }
								   
								   if([[FavoriateMgr sharedInstance] isFavoriate:[url absoluteString]]) {
									   NSLog(@"favoriate is %@", [url absoluteString]);
								   }
							   }
						   }];
}

- (GalleryController *) getViewCtr {
	GalleryController* tc = (GalleryController* )[self viewController];
	return tc;
}

- (BOOL)isFullyInView {
	GalleryController* ctr = [self getViewCtr];

	NSIndexPath *indexPath = [ctr.tableView indexPathForCell:self];
	
//	if(indexPath.row ==1) {
//		[YYWebImageManager sharedManager].queue.maxConcurrentOperationCount = 2;
//	}
	
//	if(indexPath.row ==1) {
//		[YYWebImageManager sharedManager].queue.maxConcurrentOperationCount = 2;
//	}

	CGRect rectOfCellInTableView = [ctr.tableView rectForRowAtIndexPath: indexPath];
	CGRect rectOfCellInSuperview = [ctr.tableView convertRect: rectOfCellInTableView toView: ctr.tableView.superview];

//	CGFloat h = self.imageLabel.height + 10;
	CGFloat h = 0;
	return (rectOfCellInSuperview.origin.y <= sHeight - kCellHeight - h && rectOfCellInSuperview.origin.y >= 64 - h);
	
}

- (void)prepareForReuse {
	//nothing
}

@end


@implementation GalleryController {
	DOFavoriteButton *infoButton;
	NSArray *data;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
	NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
	if (networkStatus == ReachableViaWWAN) {
		[YYWebImageManager sharedManager].queue.maxConcurrentOperationCount = 1;
	} else {
		[YYWebImageManager sharedManager].queue.maxConcurrentOperationCount = 2;
	}
	
//	self.tableView.fd_debugLogEnabled = NO;
	
//	[self.tableView registerClass:[GalleryControllerCell class] forCellReuseIdentifier:@"cell"];
	
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.view.backgroundColor = [UIColor whiteColor];
	self.navigationController.navigationBar.tintColor = [UIColor blackColor];
		
	[self.navigationItem setTitle: _headerText];
	
	[self addInfoIcon];
	
	if(_showInfo) {
		[self showPopup];
	}
	
	[self initData];
	
	[self initHeader];
	
//	if(_headerText) [self initHeader];
	
//	[[[self navigationController] navigationBar] setHidden:YES];
	
//	[self.tableView reloadData];
	//	[self scrollViewDidScroll:self.tableView];
}

- (void)initData {
	NSMutableArray *entities = @[].mutableCopy;
	
	if(_articleURLs) {
		for (NSString *url in _articleURLs) {
			[entities addObject:[[ArticleEntity alloc] initWithURL:url]];
		}
	}else if(_articleDicts) {
		
		[_articleDicts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			[entities addObject:[[ArticleEntity alloc] initWithDictionary:obj]];
		}];
	}
	
	data = [entities mutableCopy];
}

- (void)initHeader {
	
	UIView *header = [UIView new];
	
	header.size = CGSizeMake(self.view.width, 20);
	
	self.tableView.tableHeaderView = header;
}

- (void)showPopup {
	
	NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
	paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
	paragraphStyle.alignment = NSTextAlignmentCenter;
	
	NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"操作说明" attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:24], NSParagraphStyleAttributeName : paragraphStyle}];
	NSAttributedString *lineOne = [[NSAttributedString alloc] initWithString:@"单击短片播放/暂停" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSParagraphStyleAttributeName : paragraphStyle}];
	
//	NSAttributedString *lineOne1 = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSParagraphStyleAttributeName : paragraphStyle}];
	
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
	
//	UILabel *lineOneLabel1 = [[UILabel alloc] init];
//	lineOneLabel1.numberOfLines = 0;
//	lineOneLabel1.attributedText = lineOne1;
	
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
		infoButton = [[DOFavoriteButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 44,[UIApplication sharedApplication].statusBarFrame.size.height, 44, 44) image:[UIImage imageNamed:@"info"] selected: true];
	}else {
		infoButton = [[DOFavoriteButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 44,[UIApplication sharedApplication].statusBarFrame.size.height, 44, 44) image:[UIImage imageNamed:@"info"] selected: false];
	}
	
	//	infoButton = [[DOFavoriteButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 44,[UIApplication sharedApplication].statusBarFrame.size.height, 44, 44) image:[UIImage imageNamed:@"info"]];
	
	infoButton.imageColorOn = [UIColor colorWithRed:255.0 / 255.0 green:64.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
	infoButton.circleColor = [UIColor colorWithRed:255.0 / 255.0 green:64.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
	infoButton.lineColor = [UIColor colorWithRed:245.0 / 255.0 green:54.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
	
	[infoButton addTarget:self action:@selector(tappedButton:) forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
	
	self.navigationItem.rightBarButtonItem = button;
}

- (void)tappedButton:(DOFavoriteButton *)sender {
	[self showPopup];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	_fullScreen = false;
	//self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	//[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

//- (void)viewDidAppear:(BOOL)animated {
//	[infoButton select];
//}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	//    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
	//    self.navigationController.navigationBar.tintColor = nil;
	//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
	
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

//- (void) viewDidDisappear:(BOOL)animated {
//	[super viewDidDisappear:animated];
//
//}

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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return kCellHeight + 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	GalleryControllerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" ];
	
	if (!cell){
		cell = [[GalleryControllerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
	}
	
	ArticleEntity *entity = data[indexPath.row];
	
	[cell setImageURL:[NSURL URLWithString:entity.image]];
	
	return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

	for (GalleryControllerCell *cell in [self.tableView visibleCells]) {
		if(!cell.downLoaded) continue;
		if([self isFullyInView: cell]) {
			if(!cell.webImageView.isAnimating) [cell.webImageView startAnimating];
		}else{
			if(cell.webImageView.isAnimating) [cell.webImageView stopAnimating];
		}
	}
}

- (BOOL)isFullyInView:(GalleryControllerCell *)cell {
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

	CGRect rectOfCellInTableView = [self.tableView rectForRowAtIndexPath: indexPath];
	CGRect rectOfCellInSuperview = [self.tableView convertRect: rectOfCellInTableView toView: self.tableView.superview];
	
	CGFloat h = 0;
	
	return (rectOfCellInSuperview.origin.y <= sHeight - kCellHeight - h && rectOfCellInSuperview.origin.y >= 64 - h);
}

@end
