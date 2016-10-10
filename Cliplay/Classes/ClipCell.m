//
//  ClipCell.m
//  Cliplay
//
//  Created by 邢磊 on 16/8/18.
//
//

#import "ClipCell.h"
#import "ClipPlayController.h"
#import "DRImagePlaceholderHelper.h"
#import <FontAwesomeKit/FAKFontAwesome.h>

#define cellMargin 10
#define kCellHeight ceil((kScreenWidth) * 3.0 / 4.0)
#define kScreenWidth ((UIWindow *)[UIApplication sharedApplication].windows.firstObject).width - cellMargin * 2
#define sHeight [UIScreen mainScreen].bounds.size.height


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
	
//	CGFloat lineHeight = 4;
//	_progressLayer = [CAShapeLayer layer];
//	_progressLayer.size = CGSizeMake(_webImageView.width, lineHeight);
//	UIBezierPath *path = [UIBezierPath bezierPath];
//	[path moveToPoint:CGPointMake(0, _progressLayer.height / 2)];
//	[path addLineToPoint:CGPointMake(_webImageView.width, _progressLayer.height / 2)];
//	_progressLayer.lineWidth = lineHeight;
//	_progressLayer.path = path.CGPath;
//	_progressLayer.strokeColor = [UIColor colorWithRed:255.0 / 255.0 green:64.0 / 255.0 blue:0.0 / 255.0 alpha:1.0].CGColor;
//	_progressLayer.lineCap = kCALineCapButt;
//	_progressLayer.strokeStart = 0;
//	_progressLayer.strokeEnd = 0;
//	[_webImageView.layer addSublayer:_progressLayer];
	

//	_progressView = [[MRCircularProgressView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
//	_progressView.centerX = _webImageView.centerX;
//	_progressView.centerY = _webImageView.centerY;
//	[self.contentView addSubview:_progressView];
	
	_progressView = [MRProgressOverlayView showOverlayAddedTo:_webImageView animated:YES];
	_progressView.tintColor = [UIColor colorWithRed:255.0 / 255.0 green:64.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
//	_progressView.titleLabelText = @"下载中";
	_progressView.titleLabelText = @"";
//	_progressView.mode = MRProgressOverlayViewModeDeterminateHorizontalBar;
	_progressView.mode = MRProgressOverlayViewModeDeterminateCircular;
	
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
	
	UIImage* commentsImage = [self getCommentIcon: -1];
	
	_commentBtn = [UIButton buttonWithType:UIButtonTypeSystem];
	_commentBtn.frame = CGRectMake(0, 0, 45, 45);
	
	[_commentBtn setImage:commentsImage forState:UIControlStateNormal];
	[_commentBtn setImage:commentsImage forState:UIControlStateHighlighted];
	[_commentBtn setTintColor:[UIColor colorWithRed:255.0 / 255.0 green:255.0 / 255.0 blue:255.0 / 255.0 alpha:0.6]];
	
	[self.contentView addSubview:_commentBtn];
	
	_commentBtn.top = _webImageView.top;
	_commentBtn.right = _webImageView.right;
	
	[_commentBtn addTarget:self action:@selector(displayComment) forControlEvents:UIControlEventTouchUpInside];
	
	
	FAKFontAwesome *shareIcon = [FAKFontAwesome weiboIconWithSize:20];
	
	UIImage *shareImage = [shareIcon imageWithSize:CGSizeMake(20, 20)];
	
	_shareBtn = [UIButton buttonWithType:UIButtonTypeSystem];
	_shareBtn.frame = CGRectMake(0, 0, 40, 40);
	
	[_shareBtn setImage:shareImage forState:UIControlStateNormal];
	[_shareBtn setImage:shareImage forState:UIControlStateHighlighted];
//	[_shareBtn setTintColor:[UIColor whiteColor]];
	[_shareBtn setTintColor:[UIColor colorWithRed:255.0 / 255.0 green:255.0 / 255.0 blue:255.0 / 255.0 alpha:0.6]];
	
	[self.contentView addSubview:_shareBtn];
	
	_shareBtn.bottom = _webImageView.bottom;
	_shareBtn.right = _webImageView.right;
	
	[_shareBtn addTarget:self action:@selector(shareClip) forControlEvents:UIControlEventTouchUpInside];
	
	return self;
}

- (void)tappedButton:(DOFavoriteButton *)sender {
	ClipController* ctr = [self getViewCtr];
	if (sender.selected) {
		[sender deselect];
		[ctr unsetFavoriate:[[_webImageView yy_imageURL] absoluteString]];
	} else {
		[sender select];
		[ctr setFavoriate:[[_webImageView yy_imageURL] absoluteString]];
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
	
//	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id sender) {
//		
//		ClipController* tc = [_self getViewCtr];
//		
//		if(!_self.downLoaded || tc.fullScreen) return;
//		
//		if ([_view isAnimating]) [_view stopAnimating];
//		else [_view startAnimating];
//		
//		UIViewAnimationOptions op = UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState;
//		[UIView animateWithDuration:0.1 delay:0 options:op animations:^{
//			_view.layer.transformScale = 0.97;
//		} completion:^(BOOL finished) {
//			[UIView animateWithDuration:0.1 delay:0 options:op animations:^{
//				_view.layer.transformScale = 1.008;
//			} completion:^(BOOL finished) {
//				[UIView animateWithDuration:0.1 delay:0 options:op animations:^{
//					_view.layer.transformScale = 1;
//				} completion:NULL];
//			}];
//		}];
//	}];
//	
//	singleTap.numberOfTapsRequired = 1;
//	
//	[_view addGestureRecognizer:singleTap];
	
	UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id sender) {
		
		if(!_self.downLoaded) return;
//		[_view stopAnimating];
		
		ClipController* tc = [_self getViewCtr];
		ClipPlayController *clipCtr = [ClipPlayController new];
		tc.fullScreen = true;
		clipCtr.clipURL = [[_view yy_imageURL] absoluteString];
		clipCtr.favorite = TRUE;
		clipCtr.showLike = FALSE;
		clipCtr.standalone = false;
		clipCtr.modalPresentationStyle = UIModalPresentationCurrentContext;
		clipCtr.delegate = _self;
		[tc recordSlowPlayWithUrl:[[_view yy_imageURL] absoluteString]];
		
		[tc presentViewController:clipCtr animated:YES completion:nil];
		
	}];
	
	doubleTap.numberOfTapsRequired = 1;
	
	[_view addGestureRecognizer:doubleTap];
}

- (void)showClipView:(NSString*)url{
	
	ClipController* tc = [self getViewCtr];
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

- (void)setThumb:(NSURL *)url gifUrl:(NSURL *)gifUrl placeholder:(UIImage *)placeholder{
	[_webImageView yy_setImageWithURL:url
						  placeholder:placeholder
							  options:YYWebImageOptionProgressiveBlur |YYWebImageOptionSetImageWithFadeAnimation | YYWebImageOptionShowNetworkActivity
							 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
							 }
							transform:nil
						   completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
							   if (stage == YYWebImageStageFinished) {
								   [self setGIF:gifUrl placeholder:image];
							   }
						   }
	 ];
}

- (void)setGIF:(NSURL *)gifUrl placeholder:(UIImage *)placeholder {
	
	__weak typeof(self) _self = self;
	_label.hidden = YES;
	
//	[CATransaction begin];
//	[CATransaction setDisableActions: YES];
//	self.progressLayer.hidden = YES;
//	self.progressLayer.strokeEnd = 0;
//	[CATransaction commit];
	
	_self.downLoaded = FALSE;
	
	_webImageView.autoPlayAnimatedImage = FALSE;
	
	_heartButton.hidden = true;
	_commentBtn.hidden = true;
	_shareBtn.hidden = true;
	
//	[_self.progressView setProgress:0.0 animated:NO];
	
	[_webImageView yy_setImageWithURL:gifUrl
						  placeholder:placeholder
							  options:YYWebImageOptionProgressiveBlur |YYWebImageOptionSetImageWithFadeAnimation | YYWebImageOptionShowNetworkActivity
	 //| YYWebImageOptionRefreshImageCache
							 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
								 if (expectedSize > 0 && receivedSize > 0) {
									 CGFloat progress = (CGFloat)receivedSize / expectedSize;
									 progress = progress < 0 ? 0 : progress > 1 ? 1 : progress;
//									 if (_self.progressLayer.hidden) _self.progressLayer.hidden = NO;
//									 _self.progressLayer.strokeEnd = progress;
									 
									 if(_self.progressView.hidden) _self.progressView.hidden = NO;
									 [_self.progressView setProgress:progress animated:YES];
								 }
							 }
							transform:nil
						   completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
							   if (stage == YYWebImageStageFinished) {
//								   _self.progressLayer.hidden = YES;
								   
								   _self.progressView.hidden = YES;
								   
								   if (!image) {
									   _self.label.hidden = NO;
								   }else {
									   _self.downLoaded = TRUE;
									   if ([_self isFullyVisible]) {
										   [_self.webImageView startAnimating];
									   }
									   ClipController* ctr = [_self getViewCtr];
									   if([ctr isFavoriate:[url absoluteString]]) {
										   [_self.heartButton selectWithNoAnim];
									   }else {
										   [_self.heartButton deselectWithNoAnim];
									   }
									   
									   [_self updateCommentQty];
									   
									   _self.heartButton.hidden = NO;
									   _self.commentBtn.hidden = NO;
									   _self.shareBtn.hidden = NO;
								   }
							   }
						   }
	 ];
}

- (void)setImageURL:(NSURL *)imgUrl {
	
//	__weak typeof(self) _self = self;
	_progressView.hidden = YES;
	
	UIImage *placeholderImage = [[DRImagePlaceholderHelper sharedInstance] placerholderImageWithSize:_webImageView.size text: @"球路"];
	
	if([self isImageCached:imgUrl]) {
		[self setGIF:imgUrl placeholder:placeholderImage];
	}else {
		[self setThumb:[NSURL URLWithString:@"http://ww1.sinaimg.cn/large/006p1Rrsgw1f7hf0r0ndbj318g0xc46r.jpg"] gifUrl:imgUrl placeholder:placeholderImage];
	}
}

- (BOOL)isImageCached:(NSURL *)url {
	YYImageCache *cache = [YYWebImageManager sharedManager].cache;
	NSString *key = [[YYWebImageManager sharedManager] cacheKeyForURL:url];
	return [cache containsImageForKey:key];
}

- (ClipController *) getViewCtr {
	return self.delegate;
}

- (BOOL)isFullyVisible {
	ClipController* ctr = [self getViewCtr];	
	return [ctr isFullyVisible:self];
}

- (void)updateCommentQty {
	ClipController* ctr = [self getViewCtr];
	NSString *qty = [ctr getCommentQty:[self.webImageView.yy_imageURL absoluteString]];
	if(qty == nil) {
		return;
	}
	UIImage* commentsImage = [self getCommentIcon: [qty intValue]];
	[_commentBtn setImage:commentsImage forState:UIControlStateNormal];
	[_commentBtn setImage:commentsImage forState:UIControlStateHighlighted];
	//	[_imgView setImage:commentsImage];
}

- (void)displayComment {
	ClipController* ctr = [self getViewCtr];
	[ctr showComments:[self.webImageView.yy_imageURL absoluteString]];
}

- (void)shareClip {
	ClipController* ctr = [self getViewCtr];
	[ctr shareClip:self.webImageView.yy_imageURL];
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
	
	if(count == -1){
		labelString = @"";
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
