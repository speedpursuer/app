//
//  ClipPlayController.m
//  Cliplay
//
//  Created by 邢磊 on 16/1/14.
//
//

#import "ClipPlayController.h"
#import "YYImage.h"
#import "UIView+YYAdd.h"
#import "YYImageExampleHelper.h"
#import <sys/sysctl.h>
#import "MBCircularProgressBarView.h"
#import "MainViewController.h"
#import "FRDLivelyButton.h"
#import "SHA1.h"
#import "DOFavoriteButton.h"

@interface ClipPlayController()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) MBCircularProgressBarView *progressBar;
@property (nonatomic, strong) DOFavoriteButton *heartButton;
@property (nonatomic, strong) FRDLivelyButton *closeButton;
@end
@implementation ClipPlayController {
	YYAnimatedImageView *imageView;
	BOOL loaded;
	BOOL download;
	BOOL iniFavorite;
	CGSize imageSize;
}

- (void)viewDidLoad {

	[super viewDidLoad];
	
//	self.view.backgroundColor = [UIColor colorWithWhite:0.863 alpha:1.000];
	self.view.backgroundColor = [UIColor whiteColor];
	
	[self loadImage: self.clipURL];
	
	[self initButtons];
}

- (void)loadImage: (NSString *)url {
	
	imageView = [YYAnimatedImageView new];
	
	loaded = false;
	download = false;
	
//	imageView.height = self.view.size.height - self.navigationController.navigationBar.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height;

	//imageView.size = self.view.size;
	imageView.clipsToBounds = YES;
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	imageView.backgroundColor = [UIColor whiteColor];
	
//	_progressBar = [[MBCircularProgressBarView alloc] initWithFrame:CGRectMake((imageView.width-100)/2, (imageView.height-100)/2, 100, 100)];
	
	_progressBar = [[MBCircularProgressBarView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-100)/2, (self.view.bounds.size.height-100)/2, 100, 100)];

	
	_progressBar.backgroundColor = [UIColor clearColor];
	_progressBar.hidden = YES;
	
	
	[NSTimer scheduledTimerWithTimeInterval:0.3
									 target:self
								   selector:@selector(showProgress)
								   userInfo:nil
									repeats:NO];
	
	[imageView yy_setImageWithURL:[NSURL URLWithString:url]
		placeholder:nil
		options:YYWebImageOptionProgressiveBlur | YYWebImageOptionShowNetworkActivity | YYWebImageOptionSetImageWithFadeAnimation
		progress:^(NSInteger receivedSize, NSInteger expectedSize) {
			_progressBar.hidden = NO;
			if (expectedSize > 0 && receivedSize > 0) {
				CGFloat progress = (CGFloat)receivedSize / expectedSize;
				progress = progress < 0 ? 0 : progress > 1 ? 1 : progress;				
				if (_progressBar.hidden && progress != 1) _progressBar.hidden = NO;
				[_progressBar setValue: progress * 100 animateWithDuration:1];
			}
		}
		//transform:nil
		transform:^UIImage *(UIImage *image, NSURL *url) {
			
			UIImage *image1 = [image yy_imageByResizeToSize:CGSizeMake(80, 80) contentMode:UIViewContentModeCenter];
			
			NSString *ext = @".jpg";
			
			SHA1 *sha1 = [SHA1 sha1WithString: [url.absoluteString  stringByAppendingString: ext]];
			
			//NSLog(@"absoluteString = %@", url.absoluteString);
			
			//NSLog(@"sha1 = %@", sha1);
			
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			
			NSMutableString *string = [NSMutableString stringWithString:@"/imgcache/"];
			
			[string appendFormat: @"%@", sha1];
			
			[string appendString: ext];
			
			NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent: string];
			
			//NSLog(@"filePath = %@", filePath);
			
			[UIImageJPEGRepresentation(image1, 0.8f) writeToFile:filePath atomically:YES];
			
			image1 = nil;
			
			download = true;
			
			//[self performSelectorOnMainThread:@selector(updateClip) withObject:nil waitUntilDone:NO];
			
			return image;
		}
		completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error){
			
			if (stage == YYWebImageStageFinished) {
				if(!error) {
					[_progressBar setValue: 100 animateWithDuration:1];
					_progressBar.hidden = YES;
					imageSize = image.size;
					loaded = true;
					[self setImageViewSize];
				}else {
					
					NSString *title, *message;
					if(error.code == -1009){
						title = @"无法下载";
						message = @"请检查是否已连接互联网。";
					}else{
						title = @"下载出现异常";
						message = @"非常抱歉，请稍候再尝试。";
					}
					
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
																	message:message
																   delegate:nil
														  cancelButtonTitle:@"好"
														  otherButtonTitles:nil];
					[alert show];
				}
			}
		}
	];
	
	[self.view addSubview:imageView];
	[self.view addSubview:_progressBar];
	
	[YYImageExampleHelper addTapControlToAnimatedImageView:imageView];
	[YYImageExampleHelper addPanControlToAnimatedImageView:imageView];
	for (UIGestureRecognizer *g in imageView.gestureRecognizers) {
		g.delegate = self;
	}
}

- (void) setImageViewSize {
	
	if(!loaded) return;
	
	CGFloat imageWidthToHeight = imageSize.width / imageSize.height;
	CGFloat viewWidthToHeight = self.view.bounds.size.width / self.view.bounds.size.height;
	
	if(viewWidthToHeight > imageWidthToHeight) {
		CGFloat imageViewWidth = self.view.bounds.size.height * imageWidthToHeight;
		CGFloat left = (self.view.bounds.size.width - imageViewWidth) / 2;
		CGRect frame = CGRectMake(left, 0.0f, imageViewWidth, self.view.bounds.size.height);
		imageView.frame = frame;
		
	}else {
		
		if(self.interfaceOrientation == UIInterfaceOrientationPortrait) {
			CGRect frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height);
			imageView.frame = frame;
		}else {
			CGFloat imageViewHeight = self.view.bounds.size.width / imageWidthToHeight;
			CGFloat top = (self.view.bounds.size.height - imageViewHeight) / 2;
			CGRect frame = CGRectMake(0.0f, top, self.view.bounds.size.width, imageViewHeight);
			imageView.frame = frame;
		}
	}
}

- (void) setImageViewSize1 {
	
	if(!loaded) return;
	
	CGFloat imageWidthToHeight = imageSize.width / imageSize.height;
	CGFloat viewWidthToHeight = self.view.bounds.size.width / self.view.bounds.size.height;
	
	if(viewWidthToHeight > imageWidthToHeight) {
		CGFloat imageViewWidth = self.view.bounds.size.height * imageWidthToHeight;
		CGFloat left = (self.view.bounds.size.width - imageViewWidth) / 2;
		CGRect frame = CGRectMake(left, 0.0f, imageViewWidth, self.view.bounds.size.height);
		imageView.frame = frame;
		
	}else {
		CGRect frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height);
		imageView.frame = frame;
	}
	
	
}


- (void) setImageViewSize_ {
	
	if(!loaded) return;
	
	CGFloat imageWidthToHeight = imageSize.width / imageSize.height;
	CGFloat viewWidthToHeight = self.view.bounds.size.width / self.view.bounds.size.height;
	
	CGFloat imageViewHeight, imageViewWidth;
	
	if(viewWidthToHeight > imageWidthToHeight) {
		imageViewHeight = self.view.bounds.size.height;
		imageViewWidth = imageViewHeight * imageWidthToHeight;
		
	}else {
		imageViewWidth = self.view.bounds.size.width;
		imageViewHeight = imageViewWidth / imageWidthToHeight;
	}
	
	CGFloat top = (self.view.bounds.size.height - imageViewHeight) / 2;
	
	CGFloat left = (self.view.bounds.size.width - imageViewWidth) / 2;
	
	CGRect frame = CGRectMake(left, top, imageViewWidth, imageViewHeight);
	imageView.frame = frame;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (void) initButtons {
	
	iniFavorite = self.favorite;
	
	_closeButton = [[FRDLivelyButton alloc] initWithFrame:CGRectMake(6,[UIApplication sharedApplication].statusBarFrame.size.height+6,36,28)];
	[_closeButton setStyle:kFRDLivelyButtonStyleClose animated:NO];
	[_closeButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
	[_closeButton setOptions:@{ kFRDLivelyButtonLineWidth: @(2.0f),
							   kFRDLivelyButtonColor: [UIColor colorWithRed:68.0 / 255.0 green:68.0 / 255.0 blue:68.0 / 255.0 alpha:1.0]}];
	
	[self.view addSubview:_closeButton];
	
	if (self.showLike) {
		
		_heartButton = [[DOFavoriteButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 44,[UIApplication sharedApplication].statusBarFrame.size.height, 44, 44) image:[UIImage imageNamed:@"heart"]];
		
		_heartButton.imageColorOn = [UIColor colorWithRed:255.0 / 255.0 green:64.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
		_heartButton.circleColor = [UIColor colorWithRed:255.0 / 255.0 green:64.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
		_heartButton.lineColor = [UIColor colorWithRed:245.0 / 255.0 green:54.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
		
		/*
		heartButton.imageColorOn = [UIColor colorWithRed:56.0 / 255.0 green:126.0 / 255.0 blue:245.0 / 255.0 alpha:1.0];
		heartButton.circleColor = [UIColor colorWithRed:56.0 / 255.0 green:126.0 / 255.0 blue:245.0 / 255.0 alpha:1.0];
		heartButton.lineColor = [UIColor colorWithRed:40.0 / 255.0 green:120.0 / 255.0 blue:240.0 / 255.0 alpha:1.0];

		heartButton.imageColorOn = [UIColor colorWithRed:51.0 / 255.0 green:205.0 / 255.0 blue:95.0 / 255.0 alpha:1.0];
		heartButton.circleColor = [UIColor colorWithRed:51.0 / 255.0 green:205.0 / 255.0 blue:95.0 / 255.0 alpha:1.0];
		heartButton.lineColor = [UIColor colorWithRed:40.0 / 255.0 green:195.0 / 255.0 blue:85.0 / 255.0 alpha:1.0];
		*/
		
		[_heartButton addTarget:self action:@selector(tappedButton:) forControlEvents:UIControlEventTouchUpInside];
		
		if(self.favorite) [_heartButton select];
		[self.view addSubview:_heartButton];
	}
}

- (void)tappedButton:(DOFavoriteButton *)sender {
	self.favorite = !sender.selected;
	if (sender.selected) {
		[sender deselect];
	} else {
		[sender select];
	}
}

- (void)cancelAction{
	[imageView yy_cancelCurrentImageRequest];
	
	[self emitActionToJS];
	
	[[UIDevice currentDevice] setValue:
	 [NSNumber numberWithInteger: UIInterfaceOrientationPortrait]
								forKey:@"orientation"];
	
	[self dismissViewControllerAnimated:YES completion:nil];
	
	//[self destroy];
	
//	[NSTimer scheduledTimerWithTimeInterval:1
//									 target:self
//								   selector:@selector(destroy)
//								   userInfo:nil
//									repeats:NO];
}

- (void)showProgress{
	if (!loaded) {
		_progressBar.hidden = NO;
	}
}

- (void)emitActionToJS{
	
	NSString *favorite = @"", *load = @"", *from = @"";
	
	if (iniFavorite != self.favorite) {
		favorite = @"favorite";
	}
	
	if(download) {
		load = @"download";
	} else if (loaded) {
		load = @"load";
	}
	
	if (self.showLike) {
		from = @"clip";
	}
	
	[self callJSFunction: favorite load:load from:from];
}

- (void)callJSFunction: (NSString*) favorite load:(NSString*) load from:(NSString*) from  {
	[self.delegate.webView stringByEvaluatingJavaScriptFromString:
	 [NSString stringWithFormat:@"updateClip('%@', '%@', '%@')", favorite, load, from]];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	[self resetUIPosition];
	
	if(toInterfaceOrientation == UIInterfaceOrientationPortrait) {
		//[self showButton];
		[self setPortaitMode];
	} else {
		//[self hideButton];
		[self setLandscapeMode];
	}
}

- (void)showButton {
	_heartButton.hidden = FALSE;
	_closeButton.hidden = FALSE;
}

- (void)hideButton {
	_heartButton.hidden = TRUE;
	_closeButton.hidden = TRUE;
}

- (void)setPortaitMode {
	_heartButton.imageColorOff = [UIColor colorWithRed:136.0 / 255.0 green:153.0 / 255.0 blue:166.0 / 255.0 alpha:1.0];
	[_progressBar setEmptyLineColor:[UIColor lightGrayColor]];
	[_progressBar setFontColor:[UIColor darkGrayColor]];
	
	[_closeButton setOptions:@{
						  kFRDLivelyButtonLineWidth: @(2.0f),
						  kFRDLivelyButtonHighlightedColor: [UIColor lightGrayColor],
						  kFRDLivelyButtonColor: [UIColor colorWithRed:68.0 / 255.0 green:68.0 / 255.0 blue:68.0 / 255.0 alpha:1.0]
						  }];
	self.view.backgroundColor = [UIColor whiteColor];
}

- (void)setLandscapeMode {
	_heartButton.imageColorOff = [UIColor whiteColor];
	[_progressBar setEmptyLineColor:[UIColor whiteColor]];
	[_progressBar setFontColor:[UIColor whiteColor]];
	[_closeButton setOptions:@{
							   kFRDLivelyButtonLineWidth: @(2.0f),
							   kFRDLivelyButtonHighlightedColor: [UIColor colorWithRed:230.0 / 255.0 green:230.0 / 255.0 blue:230.0 / 255.0 alpha:1.0],
							   kFRDLivelyButtonColor: [UIColor whiteColor]
							   }];
	self.view.backgroundColor = [UIColor blackColor];
}

- (void)resetUIPosition {
	
	[self setImageViewSize];
	//imageView.size = self.view.bounds.size;
	
	CGRect f1 = CGRectMake((self.view.bounds.size.width-100)/2, (self.view.bounds.size.height-100)/2, 100, 100);
	_progressBar.frame = f1;
	
	CGFloat statusBarHeight;
	
	if(IsAtLeastiOSVersion(@"7.0") && UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
		if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
			statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
		}else{
			statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.width;
		}
	}else{
		statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
	}
	
	CGRect f2 = CGRectMake(self.view.bounds.size.width - 44, statusBarHeight, 44, 44);
	_heartButton.frame = f2;
	
	CGRect f3 = CGRectMake(6, statusBarHeight + 6,36,28);
	_closeButton.frame = f3;
	
	[_progressBar setValue: _progressBar.value animateWithDuration:1];
}

-(void)changeOrientation {
	[[UIDevice currentDevice] setValue:
	 [NSNumber numberWithInteger: UIDeviceOrientationLandscapeRight]
								forKey:@"orientation"];
}

- (void) destroy {
	[_closeButton removeFromSuperview];
	[_progressBar removeFromSuperview];
	[_heartButton removeFromSuperview];
	[imageView removeFromSuperview];
	_closeButton = nil;
	_progressBar = nil;
	_heartButton = nil;
	imageView = nil;
}


//-(void) viewWillDisappear:(BOOL)animated {
//	[[UIDevice currentDevice] setValue:
//	 [NSNumber numberWithInteger: UIInterfaceOrientationPortrait]
//								forKey:@"orientation"];
//	[super viewWillDisappear:animated];
//}


/*
 //- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration {
 //
 //	[super willAnimateSecondHalfOfRotationFromInterfaceOrientation:fromInterfaceOrientation duration:duration];
 //
 //	imageView.size = self.view.size;
 //}
 
 //- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
 //	//[super didRotateFromInterfaceOrientation:fromInterfaceOrientation duration:duration];
 //	imageView.size = self.view.size;
 //}
 
 
 //- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
 //	imageView.size = self.view.size;
 //	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
 //	imageView.size = self.view.size;
 //}
 //
 //- (void)viewWillLayoutSubviews{
 //	imageView.size = self.view.size;
 //}
 //
 //- (void)viewDidLayoutSubviews{
 //	imageView.size = self.view.size;
 //}
 

 -(void) viewWillDisappear:(BOOL)animated {
	if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
		// back button was pressed.  We know this is true because self is no longer
		// in the navigation stack.
		[self.navigationController setNavigationBarHidden:YES];
	}
	[super viewWillDisappear:animated];
}
- (void)updateLikeButton: (BOOL) isInit{
	if(!isInit) self.favorite = !self.favorite;
	if(self.favorite) {
		[_likeButton setBackgroundImage:likeImamge forState:UIControlStateNormal];
	}else {
		[_likeButton setBackgroundImage:notLikeImage forState:UIControlStateNormal];
	}
}
- (void)addFavorite{
	[self callJSFunction:@"updateClipFavorite();"];
	[self updateLikeButton: FALSE];
}
 - (void)callJSFunction: (NSString*) fun {
	[self.delegate.webView stringByEvaluatingJavaScriptFromString:fun];
 }
 
 - (void)callJSFunction__: (NSString*) input {
	[self.delegate.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"test_test('%@')", input]];
}

 - (void) updateClip {
	if (self.showLike) {
 [self callJSFunction:@"updateClipThumb();"];
	}else {
 [self callJSFunction:@"updateClipThumbForFavorite();"];
	}
 }
 - (void)emitActionToJS{
	
	if (loaded) {
 if (iniFavorite != self.favorite) {
 [self callJSFunction:@"updateClipBoth();"];
 
 } else {
 [self updateClip];
 }
	} else if (iniFavorite != self.favorite) {
 [self callJSFunction:@"updateClipFavorite();"];
	}
 }

*/
@end
