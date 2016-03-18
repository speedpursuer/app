//
//  YYWebImageExample.m
//  YYKitExample
//
//  Created by ibireme on 15/7/19.
//  Copyright (c) 2015 ibireme. All rights reserved.
//

#import "YYWebImageExample.h"
#import "YYWebImage.h"
#import "UIView+YYAdd.h"
#import "CALayer+YYAdd.h"
#import "UIGestureRecognizer+YYAdd.h"
#import "YYImageExampleHelper.h"
#import "ClipPlayController.h"
#import "DRImagePlaceholderHelper.h"

#define kCellHeight ceil((kScreenWidth) * 3.0 / 4.0)
#define kScreenWidth ((UIWindow *)[UIApplication sharedApplication].windows.firstObject).width

@interface YYWebImageExampleCell : UITableViewCell
@property (nonatomic, strong) YYAnimatedImageView *webImageView;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign) BOOL downLoaded;
@end

@implementation YYWebImageExampleCell

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
	
	_label = [UILabel new];
	_label.size = self.size;
	_label.textAlignment = NSTextAlignmentCenter;
	_label.text = @"下载异常, 点击重试";
	_label.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
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
	
	return self;
}

- (void)setImageURL:(NSURL *)url {
	
	_label.hidden = YES;
	_indicator.hidden = NO;
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
							  options:YYWebImageOptionProgressiveBlur | YYWebImageOptionShowNetworkActivity | YYWebImageOptionSetImageWithFadeAnimation
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
								   if (!image) _self.label.hidden = NO;
								   
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


@implementation YYWebImageExample {
	//	CGPoint lastOffset;
	//	BOOL hideBar;
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
	
	[self.tableView reloadData];
	[self scrollViewDidScroll:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	_fullScreen = false;
	//self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	//[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

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
	YYWebImageExampleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" ];
	
	if (!cell){
		cell = [[YYWebImageExampleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
	}
	
	[cell setImageURL:[NSURL URLWithString:_imageLinks[indexPath.row]]];
	
	[self addClickControlToAnimatedImageView: cell];

	return cell;
}

- (void)addClickControlToAnimatedImageView:(YYWebImageExampleCell *)cell {
	if (!cell) return;
	cell.webImageView.userInteractionEnabled = YES;
	__weak typeof(cell.webImageView) _view = cell.webImageView;
	__weak typeof(cell) _cell = cell;
	
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id sender) {
		if ([_view isAnimating]) [_view stopAnimating];
		else [_view startAnimating];
	}];
	
	singleTap.numberOfTapsRequired = 1;
	
	[_view addGestureRecognizer:singleTap];
	
	__weak typeof(self) _self = self;
	
	UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id sender) {
		
		if(!_cell.downLoaded) return;
		
		[_view stopAnimating];
		
		[_self showClipView:[[_view yy_imageURL] absoluteString]];
	}];
	
	doubleTap.numberOfTapsRequired = 2;
	
	[_view addGestureRecognizer:doubleTap];
	
	//		[singleTap requireGestureRecognizerToFail:doubleTap];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	CGFloat viewHeight = scrollView.height + scrollView.contentInset.top;
	for (YYWebImageExampleCell *cell in [self.tableView visibleCells]) {
		CGFloat y = cell.centerY - scrollView.contentOffset.y;
		CGFloat p = y - viewHeight / 2;
		CGFloat scale = cos(p / viewHeight * 0.8) * 0.95;
		[UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
			cell.webImageView.transform = CGAffineTransformMakeScale(scale, scale);
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

- (void)showClipView:(NSString*)url {

	self.fullScreen = true;
	
	ClipPlayController *_clipCtr = [ClipPlayController new];

	_clipCtr.clipURL = url;
	_clipCtr.favorite = TRUE;
	_clipCtr.showLike = FALSE;
	_clipCtr.standalone = false;

	_clipCtr.modalPresentationStyle = UIModalPresentationCurrentContext;
	_clipCtr.delegate = self;

	[self presentViewController:_clipCtr animated:YES completion:nil];
}
//
//- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
//	[self showBar];
//}

@end
