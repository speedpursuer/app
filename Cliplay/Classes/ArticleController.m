//
//  ArticleController.m
//  YYKitExample
//
//  Created by ibireme on 15/8/9.
//  Copyright (c) 2015 ibireme. All rights reserved.
//

#import "ArticleController.h"
#import "YYImage.h"
#import "UIView+YYAdd.h"
#import "YYImageExampleHelper.h"
#import <sys/sysctl.h>

@interface ArticleController()<UIGestureRecognizerDelegate>

@end
@implementation ArticleController {
    UIScrollView *_scrollView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _scrollView = [UIScrollView new];
    _scrollView.frame = self.view.bounds;
    [self.view addSubview:_scrollView];
    
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    label.size = CGSizeMake(self.view.width, 60);
    label.top = 20;
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.text = @"Tap the image to pause/play\n Slide on the image to forward/rewind";
	
    [_scrollView addSubview:label];
    
    [self addImageWithName:@"niconiconi" text:@"Animated GIF"];
    [self addImageWithName:@"wall-e" text:@"Animated WebP"];
    [self addImageWithName:@"pia" text:@"Animated PNG (APNG)"];
	
    _scrollView.panGestureRecognizer.cancelsTouchesInView = YES;
}

- (void)addImageWithName:(NSString *)name text:(NSString *)text {
    YYImage *image = [YYImage imageNamed:name];
    [self addImage:image size:CGSizeZero text:text];
}

- (void)addImageWithURL:(NSString *)url text:(NSString *)text {
	//YYImage *image = [YYImage imageNamed:name];
	//[self addImage:image size:CGSizeZero text:text];
	
//	YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithImage:image];
//	
//	if (size.width > 0 && size.height > 0) imageView.size = size;
//	imageView.centerX = self.view.width / 2;
//	imageView.top = [(UIView *)[_scrollView.subviews lastObject] bottom] + 30;
//	[_scrollView addSubview:imageView];
//	[YYImageExampleHelper addTapControlToAnimatedImageView:imageView];
//	[YYImageExampleHelper addPanControlToAnimatedImageView:imageView];
//	for (UIGestureRecognizer *g in imageView.gestureRecognizers) {
//		g.delegate = self;
//	}
//	
//	UILabel *imageLabel = [UILabel new];
//	imageLabel.backgroundColor = [UIColor clearColor];
//	imageLabel.frame = CGRectMake(0, 0, self.view.width, 20);
//	imageLabel.top = imageView.bottom + 10;
//	imageLabel.textAlignment = NSTextAlignmentCenter;
//	imageLabel.text = text;
//	[_scrollView addSubview:imageLabel];
//	
//	_scrollView.contentSize = CGSizeMake(self.view.width, imageLabel.bottom + 20);
//	
//	
	
}

- (void)addImage:(UIImage *)image size:(CGSize)size text:(NSString *)text {
    YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithImage:image];
    
    if (size.width > 0 && size.height > 0) imageView.size = size;
    imageView.centerX = self.view.width / 2;
    imageView.top = [(UIView *)[_scrollView.subviews lastObject] bottom] + 30;
    [_scrollView addSubview:imageView];
    [YYImageExampleHelper addTapControlToAnimatedImageView:imageView];
    [YYImageExampleHelper addPanControlToAnimatedImageView:imageView];
    for (UIGestureRecognizer *g in imageView.gestureRecognizers) {
        g.delegate = self;
    }
    
    UILabel *imageLabel = [UILabel new];
    imageLabel.backgroundColor = [UIColor clearColor];
    imageLabel.frame = CGRectMake(0, 0, self.view.width, 20);
    imageLabel.top = imageView.bottom + 10;
    imageLabel.textAlignment = NSTextAlignmentCenter;
    imageLabel.text = text;
    [_scrollView addSubview:imageLabel];
    
    _scrollView.contentSize = CGSizeMake(self.view.width, imageLabel.bottom + 20);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
}

//- (void)setImageURL:(NSURL *)url {
//	
//	_label.hidden = YES;
//	_indicator.hidden = NO;
//	_errPage.hidden = YES;
//	[_indicator startAnimating];
//	__weak typeof(self) _self = self;
//	
//	[CATransaction begin];
//	[CATransaction setDisableActions: YES];
//	self.progressLayer.hidden = YES;
//	self.progressLayer.strokeEnd = 0;
//	[CATransaction commit];
//	
//	_self.downLoaded = FALSE;
//	
//	_webImageView.autoPlayAnimatedImage = FALSE;
//	
//	
//	UIImage *placeholderImage = [[DRImagePlaceholderHelper sharedInstance] placerholderImageWithSize:CGSizeMake(self.width, self.height) text: @"球路"];
//	
//	[_webImageView yy_setImageWithURL:url
//						  placeholder:placeholderImage
//	 //						  placeholder: nil
//							  options:YYWebImageOptionProgressiveBlur |YYWebImageOptionSetImageWithFadeAnimation | YYWebImageOptionShowNetworkActivity
//							 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//								 if (expectedSize > 0 && receivedSize > 0) {
//									 CGFloat progress = (CGFloat)receivedSize / expectedSize;
//									 progress = progress < 0 ? 0 : progress > 1 ? 1 : progress;
//									 if (_self.progressLayer.hidden) _self.progressLayer.hidden = NO;
//									 _self.progressLayer.strokeEnd = progress;
//								 }
//							 }
//							transform:nil
//						   completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
//							   if (stage == YYWebImageStageFinished) {
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
//							   }
//						   }];
//}

@end
