//
//  ClipPlayController.m
//  HybridIOSApp
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
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) MBCircularProgressBarView *progressBar;
@property (nonatomic, strong) UIButton *likeButton;
@end
@implementation ClipPlayController {
	YYAnimatedImageView *imageView;
	BOOL loaded;
	BOOL download;
	BOOL iniFavorite;
}

- (void)viewDidLoad {

	[super viewDidLoad];
	
	self.view.backgroundColor = [UIColor colorWithWhite:0.863 alpha:1.000];
	
	[self loadImage: self.clipURL];
	
	[self initButtons];
}

- (void)loadImage: (NSString *)url {
	
	imageView = [YYAnimatedImageView new];
	
	loaded = false;
	download = false;
	
//	imageView.height = self.view.size.height - self.navigationController.navigationBar.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height;

	imageView.size = self.view.size;
	imageView.clipsToBounds = YES;
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	imageView.backgroundColor = [UIColor whiteColor];
	
	_progressBar = [[MBCircularProgressBarView alloc] initWithFrame:CGRectMake((imageView.width-100)/2, (imageView.height-100)/2, 100, 100)];
	_progressBar.backgroundColor = [UIColor clearColor];
	_progressBar.hidden = YES;
	
	
	[NSTimer scheduledTimerWithTimeInterval:0.1
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
			
			download = true;
			
			//[self performSelectorOnMainThread:@selector(updateClip) withObject:nil waitUntilDone:NO];
			
			return image;
		}
		completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error){
			
			if (stage == YYWebImageStageFinished) {
				if(!error) {
					[_progressBar setValue: 100 animateWithDuration:1];
					_progressBar.hidden = YES;
					loaded = true;
				}else {
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法下载"
																	message:@"请您检查是否已连接网络."
																   delegate:nil
														  cancelButtonTitle:@"确定"
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (void) initButtons {
	
	iniFavorite = self.favorite;
	
	FRDLivelyButton *closeButton = [[FRDLivelyButton alloc] initWithFrame:CGRectMake(6,[UIApplication sharedApplication].statusBarFrame.size.height+6,36,28)];
	[closeButton setStyle:kFRDLivelyButtonStyleClose animated:NO];
	[closeButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
	[closeButton setOptions:@{ kFRDLivelyButtonLineWidth: @(2.0f),
							   kFRDLivelyButtonColor: [UIColor colorWithRed:68.0 / 255.0 green:68.0 / 255.0 blue:68.0 / 255.0 alpha:1.0]}];
	
	[self.view addSubview:closeButton];
	
	if (self.showLike) {
		
		DOFavoriteButton *heartButton = [[DOFavoriteButton alloc] initWithFrame:CGRectMake(self.view.size.width - 44,[UIApplication sharedApplication].statusBarFrame.size.height, 44, 44) image:[UIImage imageNamed:@"heart"]];
		
		heartButton.imageColorOn = [UIColor colorWithRed:255.0 / 255.0 green:64.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
		heartButton.circleColor = [UIColor colorWithRed:255.0 / 255.0 green:64.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
		heartButton.lineColor = [UIColor colorWithRed:245.0 / 255.0 green:54.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
		
		/*
		heartButton.imageColorOn = [UIColor colorWithRed:56.0 / 255.0 green:126.0 / 255.0 blue:245.0 / 255.0 alpha:1.0];
		heartButton.circleColor = [UIColor colorWithRed:56.0 / 255.0 green:126.0 / 255.0 blue:245.0 / 255.0 alpha:1.0];
		heartButton.lineColor = [UIColor colorWithRed:40.0 / 255.0 green:120.0 / 255.0 blue:240.0 / 255.0 alpha:1.0];

		heartButton.imageColorOn = [UIColor colorWithRed:51.0 / 255.0 green:205.0 / 255.0 blue:95.0 / 255.0 alpha:1.0];
		heartButton.circleColor = [UIColor colorWithRed:51.0 / 255.0 green:205.0 / 255.0 blue:95.0 / 255.0 alpha:1.0];
		heartButton.lineColor = [UIColor colorWithRed:40.0 / 255.0 green:195.0 / 255.0 blue:85.0 / 255.0 alpha:1.0];
		*/
		
		[heartButton addTarget:self action:@selector(tappedButton:) forControlEvents:UIControlEventTouchUpInside];
		
		if(self.favorite) [heartButton select];
		[self.view addSubview:heartButton];
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
	
	[self dismissViewControllerAnimated:YES completion:nil];
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

/*
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
