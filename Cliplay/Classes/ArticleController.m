//
//  ArticleController.m
//  YYKitExample
//
//  Created by ibireme on 15/8/9.
//  Copyright (c) 2015 ibireme. All rights reserved.
//

#import "ArticleController.h"
#import <YYWebImage/YYWebImage.h>
#import "UIView+YYAdd.h"
#import "YYImageExampleHelper.h"
#import <sys/sysctl.h>
#import "DRImagePlaceholderHelper.h"
#import "ClipPlayController.h"
#import "UIGestureRecognizer+YYAdd.h"
#import "UIView+YYAdd.h"
#import "CALayer+YYAdd.h"
#define kScreenWidth ((UIWindow *)[UIApplication sharedApplication].windows.firstObject).width * 0.9
#define kCellHeight ceil((kScreenWidth) * 3.0 / 4.0) * 0.9


@interface ArticleController()<UIGestureRecognizerDelegate>
@property (nonatomic, assign) BOOL fullscreen;
@end
@implementation ArticleController {
    UIScrollView *_scrollView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationController.navigationBar.tintColor = [UIColor blackColor];
	
    self.view.backgroundColor = [UIColor whiteColor];
    
    _scrollView = [UIScrollView new];
    _scrollView.frame = self.view.bounds;
    [self.view addSubview:_scrollView];
    
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
	label.frame = CGRectMake(15, 20, self.view.width - 30, 60);
	

    label.textAlignment = NSTextAlignmentLeft;
    label.numberOfLines = 0;
	
	NSString *text = @"学明星投篮姿势，最重要的是学大体，大体决定的风格，而不是细节";
	
	NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:text];

	NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	[paragraphStyle setLineSpacing:15];
	
	[attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [text length])];
	
	
	label.attributedText = attributedString;

	[label sizeToFit];
	
    [_scrollView addSubview:label];
	
	UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(15, label.bottom + 20, self.view.width - 30, 1)];
	lineView.backgroundColor = [UIColor lightGrayColor];
	[_scrollView addSubview:lineView];
    
    [self addImageWithURL:@"http://i1.hoopchina.com.cn/u/1403/30/941/15988941/94e95616big.gif" text:@"\u2022 科比传球"];
    [self addImageWithURL:@"http://i1.hoopchina.com.cn/u/1402/23/941/15988941/0fc696ccbig.gif" text:@"\u2022 勒布朗持球进攻"];
    [self addImageWithURL:@"http://i1.hoopchina.com.cn/u/1402/16/941/15988941/ea83bddabig.gif" text:@"\u2022 学明星投篮姿势，最重要的是学大体，大体决定的风格，而不是细节。韦德拿到球，但是很犹豫。"];
	
    _scrollView.panGestureRecognizer.cancelsTouchesInView = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
		// back button was pressed.  We know this is true because self is no longer
		// in the navigation stack.
		[self.navigationController setNavigationBarHidden:YES];
	}
	
	if(!_fullscreen) {
		[[YYWebImageManager sharedManager].queue cancelAllOperations];
		[[YYImageCache sharedCache].memoryCache removeAllObjects];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	_fullscreen = false;
}


- (void)addClickControlToAnimatedImageView:(YYAnimatedImageView *)view {
	if (!view) return;
	view.userInteractionEnabled = YES;
	__weak typeof(view) _view = view;
	__weak typeof(self) _self = self;
	
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id sender) {
		
//		if(!_cell.downLoaded) return;
		
		if(_self.fullscreen) return;
		
		if ([_view isAnimating]) [_view stopAnimating];
		else [_view startAnimating];
		
		UIViewAnimationOptions op = UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState;
		[UIView animateWithDuration:0.1 delay:0 options:op animations:^{
			_view.layer.transformScale = 0.97 ;
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
		
//		if(!_cell.downLoaded) return;
		[_view stopAnimating];
		[_self showClipView: _view];
	}];
	
	doubleTap.numberOfTapsRequired = 2;
	
	[_view addGestureRecognizer:doubleTap];
}

- (void)showClipView:(YYAnimatedImageView*)view {
	
	self.fullscreen = true;
	
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

- (void)addImageWithURL:(NSString *)url text:(NSString *)text {
	
//	YYAnimatedImageView *_webImageView = [YYAnimatedImageView new];
//	_webImageView.size = self.view.size;
//	_webImageView.clipsToBounds = YES;
//	_webImageView.contentMode = UIViewContentModeScaleAspectFill;
//	_webImageView.backgroundColor = [UIColor whiteColor];
//	[self.view addSubview:_webImageView];
//	
//	UIImage *img = [[DRImagePlaceholderHelper sharedInstance] placerholderImageWithSize:CGSizeMake(self.view.size.width, self.view.size.height) text:@""];
//	UIImageView *_errPage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.size.width, self.view.size.height)];
//	_errPage.image = img;
//	_errPage.hidden = YES;
//	[self.view addSubview:_errPage];
//	
//	UILabel *_label = [UILabel new];
//	_label.size = self.view.size;
//	_label.textAlignment = NSTextAlignmentCenter;
//	_label.text = @"下载异常, 点击重试";
//	//	_label.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
//	_label.textColor = [UIColor whiteColor];
//	_label.hidden = YES;
//	_label.userInteractionEnabled = YES;
//	[self.view addSubview:_label];
	
//	CGFloat lineHeight = 4;
//	CAShapeLayer *_progressLayer = [CAShapeLayer layer];
//	_progressLayer.size = CGSizeMake(_webImageView.width, lineHeight);
//	UIBezierPath *path = [UIBezierPath bezierPath];
//	[path moveToPoint:CGPointMake(0, _progressLayer.height / 2)];
//	[path addLineToPoint:CGPointMake(_webImageView.width, _progressLayer.height / 2)];
//	_progressLayer.lineWidth = lineHeight;
//	_progressLayer.path = path.CGPath;
//	//    _progressLayer.strokeColor = [UIColor colorWithRed:0.000 green:0.640 blue:1.000 alpha:0.720].CGColor;
//	
//	_progressLayer.strokeColor = [UIColor colorWithRed:255.0 / 255.0 green:64.0 / 255.0 blue:0.0 / 255.0 alpha:1.0].CGColor;
//	_progressLayer.lineCap = kCALineCapButt;
//	_progressLayer.strokeStart = 0;
//	_progressLayer.strokeEnd = 0;
//	[_webImageView.layer addSublayer:_progressLayer];
//	
//	__weak typeof(self) _self = self;
//	UITapGestureRecognizer *g = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id sender) {
//		[_self setImageURL:_self.webImageView.yy_imageURL];
//	}];
//	[_label addGestureRecognizer:g];
//	
//	_scale = 1;
//
	
	UILabel *imageLabel = [UILabel new];
	imageLabel.backgroundColor = [UIColor clearColor];
	imageLabel.frame = CGRectMake(15, 0, self.view.width - 30, 20);
	imageLabel.top = [(UIView *)[_scrollView.subviews lastObject] bottom] + 30;
	imageLabel.textAlignment = NSTextAlignmentLeft;
	imageLabel.text = text;
	imageLabel.numberOfLines = 0;
	[imageLabel setTextColor:[UIColor darkGrayColor]];
	[imageLabel sizeToFit];
	[_scrollView addSubview:imageLabel];
	
	YYAnimatedImageView *imageView = [YYAnimatedImageView new];
	
	imageView.size = CGSizeMake(kScreenWidth, kCellHeight);
	
	imageView.centerX = self.view.width / 2;
	imageView.top = imageLabel.bottom + 10;
	
	[_scrollView addSubview:imageView];
	[self addClickControlToAnimatedImageView:imageView];

	for (UIGestureRecognizer *g in imageView.gestureRecognizers) {
		g.delegate = self;
	}
	
	_scrollView.contentSize = CGSizeMake(self.view.width, imageView.bottom + 20);
	
	UIImage *placeholderImage = [[DRImagePlaceholderHelper sharedInstance] placerholderImageWithSize:imageView.size text: @"球路"];
	
	imageView.autoPlayAnimatedImage = FALSE;
	
	[imageView yy_setImageWithURL:[NSURL URLWithString:url]
						  placeholder:placeholderImage
							  options:YYWebImageOptionProgressiveBlur |YYWebImageOptionSetImageWithFadeAnimation | YYWebImageOptionShowNetworkActivity | YYWebImageOptionRefreshImageCache
							 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//								 if (expectedSize > 0 && receivedSize > 0) {
//									 CGFloat progress = (CGFloat)receivedSize / expectedSize;
//									 progress = progress < 0 ? 0 : progress > 1 ? 1 : progress;
//									 if (_self.progressLayer.hidden) _self.progressLayer.hidden = NO;
//									 _self.progressLayer.strokeEnd = progress;
//								 }
							 }
							transform:nil
						   completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
							   if (stage == YYWebImageStageFinished) {
//								   _self.progressLayer.hidden = YES;
//								   [_self.indicator stopAnimating];
//								   _self.indicator.hidden = YES;
//								   if (!image) {
//									   _self.label.hidden = NO;
//									   _self.errPage.hidden = NO;
//								   }
//								   
//								   if(!error) {
//									   _self.downLoaded = TRUE;
//								   }
							   }
						   }];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

@end
