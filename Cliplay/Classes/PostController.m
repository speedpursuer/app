//
//  PostController.m
//  YYKitExample
//
//  Created by ibireme on 15/7/19.
//  Copyright (c) 2015 ibireme. All rights reserved.
//

#import "PostController.h"
#import <YYWebImage/YYWebImage.h>
#import "UIView+YYAdd.h"
#import "CALayer+YYAdd.h"
#import "UIGestureRecognizer+YYAdd.h"
#import "YYImageExampleHelper.h"
#import "ClipPlayController.h"
#import "DRImagePlaceholderHelper.h"
#import "DOFavoriteButton.h"

#define kCellHeight ceil((kScreenWidth) * 3.0 / 4.0)
#define kScreenWidth ((UIWindow *)[UIApplication sharedApplication].windows.firstObject).width

@interface PostControllerCell : UITableViewCell
@property (nonatomic, strong) YYAnimatedImageView *webImageView;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign) BOOL downLoaded;
//@property (nonatomic, strong) UIImageView *errPage;
@property (nonatomic, assign) CGFloat scale;
@end

@implementation PostControllerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	self.backgroundColor = [UIColor whiteColor];
	//	self.backgroundColor = [UIColor clearColor];
	//  self.contentView.backgroundColor = [UIColor clearColor];
	self.contentView.backgroundColor = [UIColor whiteColor];
	self.size = CGSizeMake(kScreenWidth, kCellHeight);
	self.contentView.size = self.size;
	_webImageView = [YYAnimatedImageView new];
	_webImageView.size = self.size;
	_webImageView.clipsToBounds = YES;
	_webImageView.contentMode = UIViewContentModeScaleAspectFill;
	_webImageView.backgroundColor = [UIColor whiteColor];
	[self.contentView addSubview:_webImageView];
	
	
	_indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	_indicator.center = CGPointMake(self.width / 2, self.height / 2);
	_indicator.hidden = YES;
	//    [self.contentView addSubview:_indicator]; //use progress bar instead..
	
//	UIImage *img = [[DRImagePlaceholderHelper sharedInstance] placerholderImageWithSize:CGSizeMake(self.width, self.height) text:@""];
//	_errPage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
//	_errPage.image = img;
//	_errPage.hidden = YES;
//	[self.contentView addSubview:_errPage];
	
	_label = [UILabel new];
	_label.size = self.size;
	_label.textAlignment = NSTextAlignmentCenter;
	_label.text = @"下载异常, 点击重试";
	_label.centerX = self.centerX;
	_label.centerY = _webImageView.centerY + 50;
//	_label.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
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
	//    _progressLayer.strokeColor = [UIColor colorWithRed:0.000 green:0.640 blue:1.000 alpha:0.720].CGColor;
	
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
	
	return self;
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

	
	UIImage *placeholderImage = [[DRImagePlaceholderHelper sharedInstance] placerholderImageWithSize:CGSizeMake(self.width, self.height) text: @"球路"];
	
	[_webImageView yy_setImageWithURL:url
	                           placeholder:placeholderImage
//						  placeholder: nil
							  options:YYWebImageOptionProgressiveBlur |YYWebImageOptionSetImageWithFadeAnimation | YYWebImageOptionShowNetworkActivity
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
								   }
							   }
						   }];
}

- (void)prepareForReuse {
	//nothing
}

@end


@implementation PostController {
	//	CGPoint lastOffset;
	//	BOOL hideBar;
	DOFavoriteButton *infoButton;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.view.backgroundColor = [UIColor whiteColor];
	self.navigationController.navigationBar.tintColor = [UIColor blackColor];
	
	//hideBar = false;
	
	//UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Reload" style:UIBarButtonItemStylePlain target:self action:@selector(reload)];
	//self.navigationItem.rightBarButtonItem = button;
	//self.view.backgroundColor = [UIColor colorWithWhite:0.217 alpha:1.000];
	
	[self addInfoIcon];
	
	if(_showInfo) {
		[self showPopup];
	}
	
	[self.tableView reloadData];
	[self scrollViewDidScroll:self.tableView];
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
	return _imageLinks.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return kCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	PostControllerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" ];
	
	if (!cell){
		cell = [[PostControllerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
	}
	
	[cell setImageURL:[NSURL URLWithString:_imageLinks[indexPath.row]]];
	
	[self addClickControlToAnimatedImageView: cell];

	return cell;
}

- (void)addClickControlToAnimatedImageView:(PostControllerCell *)cell {
	if (!cell) return;
	cell.webImageView.userInteractionEnabled = YES;
	__weak typeof(cell.webImageView) _view = cell.webImageView;
	__weak typeof(cell) _cell = cell;
	__weak typeof(self) _self = self;
	
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id sender) {
		
		if(!_cell.downLoaded || _self.fullScreen) return;
		
		if ([_view isAnimating]) [_view stopAnimating];
		else [_view startAnimating];
		
		UIViewAnimationOptions op = UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState;
		[UIView animateWithDuration:0.1 delay:0 options:op animations:^{
			_view.layer.transformScale = 0.97 * _cell.scale;
		} completion:^(BOOL finished) {
			[UIView animateWithDuration:0.1 delay:0 options:op animations:^{
				_view.layer.transformScale = 1.008 * _cell.scale;
			} completion:^(BOOL finished) {
				[UIView animateWithDuration:0.1 delay:0 options:op animations:^{
					_view.layer.transformScale = 1 * _cell.scale;
				} completion:NULL];
			}];
		}];
	}];
	
	singleTap.numberOfTapsRequired = 1;
	
	[_view addGestureRecognizer:singleTap];
	
	UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id sender) {
		
		if(!_cell.downLoaded) return;
		
		[_view stopAnimating];
		
//		[_self showClipView:[[_view yy_imageURL] absoluteString]];
		
		[_self showClipView:_view];
	}];
	
	doubleTap.numberOfTapsRequired = 2;
	
	[_view addGestureRecognizer:doubleTap];
	
//	[singleTap requireGestureRecognizerToFail:doubleTap];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	CGFloat viewHeight = scrollView.height + scrollView.contentInset.top;
	for (PostControllerCell *cell in [self.tableView visibleCells]) {
		CGFloat y = cell.centerY - scrollView.contentOffset.y;
		CGFloat p = y - viewHeight / 2;
		CGFloat scale = cos(p / viewHeight * 0.8) * 0.95;
		cell.scale = scale;
		[UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
			cell.webImageView.transform = CGAffineTransformMakeScale(scale, scale);
//			cell.errPage.transform = CGAffineTransformMakeScale(scale, scale);
		} completion:NULL];
	}
}


//-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//	if (scrollView.contentOffset.y < lastOffset.y) {
//		[self hideBar];
//	} else if (scrollView.contentOffset.y > lastOffset.y){
//		[self showBar];
//	}
//}
//
//-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView
//				 willDecelerate:(BOOL)decelerate {
//	if (scrollView.contentOffset.y < lastOffset.y) {
//		[self hideBar];
//	} else{
//		[self showBar];
//	}
//}
//
//- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
//	lastOffset = scrollView.contentOffset;
//}
//
//- (BOOL)prefersStatusBarHidden {
//	return hideBar;
//}

//- (void)showBar {
//	[[[self navigationController] navigationBar] setHidden:NO];
//	hideBar = false;
//	[self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
//}
//
//- (void)hideBar {
//	[[[self navigationController] navigationBar] setHidden:YES];
//	hideBar = true;
//	[self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
//}

- (void)showClipView:(YYAnimatedImageView*)view {
	
	self.fullScreen = true;
	
	ClipPlayController *_clipCtr = [ClipPlayController new];
	
	_clipCtr.clipURL = [[view yy_imageURL] absoluteString];
	_clipCtr.favorite = TRUE;
	_clipCtr.showLike = FALSE;
	_clipCtr.standalone = false;
	
	_clipCtr.modalPresentationStyle = UIModalPresentationCurrentContext;
	_clipCtr.delegate = self;
	
	[view stopAnimating];
	
	[self presentViewController:_clipCtr animated:YES completion:nil];
}


//- (void)showClipView1:(NSString*)url {
//
//	self.fullScreen = true;
//	
//	ClipPlayController *_clipCtr = [ClipPlayController new];
//
//	_clipCtr.clipURL = url;
//	_clipCtr.favorite = TRUE;
//	_clipCtr.showLike = FALSE;
//	_clipCtr.standalone = false;
//
//	_clipCtr.modalPresentationStyle = UIModalPresentationCurrentContext;
//	_clipCtr.delegate = self;
//
//	[self presentViewController:_clipCtr animated:YES completion:nil];
//}
//
//- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
//	[self showBar];
//}

@end
