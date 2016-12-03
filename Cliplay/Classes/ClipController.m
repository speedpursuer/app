//
//  ClipController.m
//
//  Created by Lee Xing.
//

#import "ClipController.h"
#import "ClipPlayController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "Reachability.h"
#import "AppDelegate.h"
#import "MyLBAdapter.h"
#import "EBCommentsViewController.h"
#import "ModelComment.h"
#import "ClipCell.h"
#import "ArticleEntity.h"
#import "FavoriateMgr.h"
#import "MyLBService.h"
#import "AlbumAddClipDescViewController.h"
#import "AlbumSelectBottomSheetViewController.h"
#import <STPopup/STPopup.h>
#include "JDStatusBarNotification.h"
//#import "Album.h"
#import "CBLService.h"

#define cellMargin 10
#define kCellHeight ceil((kScreenWidth) * 3.0 / 4.0)
#define kScreenWidth ((UIWindow *)[UIApplication sharedApplication].windows.firstObject).width - cellMargin * 2
#define sHeight [UIScreen mainScreen].bounds.size.height

@interface ClipController ()
@property (nonatomic, strong) STPopupController *popCtr;
@property CBLService *cblService;
@property (nonatomic, copy) NSString *clipToAdd;
@property BOOL shouldAddDesc;
@property BOOL shouldAddAlbum;
@property Album *albumToAdd;
@end

@implementation ClipController {
	NSArray *data;
	MyLBService *lbService;
	NSDictionary* commentList;
//	NSString *shareText;
}

#pragma mark - (UIViewContoller & Init)
- (void)viewDidLoad {
	[super viewDidLoad];
		
	lbService = [MyLBService sharedManager];
	_cblService = [CBLService sharedManager];
	
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
	
//	[self setFavorite];
	
//	[self fetchPostComments:[self postID]];
	
	[self.navigationItem setTitle: _header];
	
	[self addInfoIcon];
	
	if(_showInfo) {
		[self showPopup];
	}
	
	[self initData];
	
	[self initHeader];
	
	[self.tableView reloadData];
}

- (void)setFavorite {
	if(self.favorite) {
//		self.header = @"我的收藏";
//		self.articleURLs = [[FavoriateMgr sharedInstance] getFavoriateImages];
	}
}

- (void)initData {
	NSMutableArray *entities = @[].mutableCopy;
	
	if(_articleURLs) {
		if(_favorite) {
			for (NSString *url in _articleURLs) {
				[entities addObject:[[ArticleEntity alloc] initWithData:url desc: @""]];
			}			
		}else {
			[_articleURLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				
				ArticleEntity *entity = (ArticleEntity *)obj;
				
				NSString *desc = entity.desc;
				NSString *url = entity.image;
				if(desc && [desc length] != 0) {
					[entities addObject:[[ArticleEntity alloc] initWithData:@"" desc:desc]];
				}
				[entities addObject:[[ArticleEntity alloc] initWithData:url desc:@""]];
			}];
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
	
	[self.tableView setTableHeaderView:header];
	[self.tableView setTableFooterView:footer];
}

- (void)addInfoIcon {
	
	if(!_showInfo) {
		self.infoButton = [[DOFavoriteButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 64,[UIApplication sharedApplication].statusBarFrame.size.height, 44, 44) image:[UIImage imageNamed:@"info"] selected: true];
	}else {
		self.infoButton = [[DOFavoriteButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 64,[UIApplication sharedApplication].statusBarFrame.size.height, 44, 44) image:[UIImage imageNamed:@"info"] selected: false];
	}
	
	self.infoButton.imageColorOn = [UIColor colorWithRed:255.0 / 255.0 green:64.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
	self.infoButton.circleColor = [UIColor colorWithRed:255.0 / 255.0 green:64.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
	self.infoButton.lineColor = [UIColor colorWithRed:245.0 / 255.0 green:54.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
	
	[self.infoButton addTarget:self action:@selector(tappedButton:) forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:self.infoButton];
	
	self.navigationItem.rightBarButtonItem = button;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if(_fullScreen) {
		[self autoPlayFullyVisibleImages];
		_fullScreen = false;
	}else{
		[self fetchPostComments:NO];
	}
	
	if(_shouldAddAlbum){
		[self showNewAlbumForm];
		_shouldAddAlbum = NO;
	}
	
	if(_shouldAddDesc) {
		[self addToExistingAlbum];
		_shouldAddDesc = NO;
	}
}

- (void)viewDidAppear:(BOOL)animated {
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if(_articleDicts) {
		if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
			// back button was pressed.  We know this is true because self is no longer
			// in the navigation stack.
			[self.navigationController setNavigationBarHidden:YES];
		}
	}
	
	if(_fullScreen) {
		[self stopPlayingAllImages];
	}else {
		[[YYWebImageManager sharedManager].queue cancelAllOperations];
		[[YYImageCache sharedCache].memoryCache removeAllObjects];
	}
}

#pragma mark - (User Interaction)
- (void)showPopup {
	
	NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
	paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
	paragraphStyle.alignment = NSTextAlignmentCenter;
	
	NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"操作说明" attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:24], NSParagraphStyleAttributeName : paragraphStyle}];
	
	NSAttributedString *lineOne= [[NSAttributedString alloc] initWithString:@"点击图片进入滑屏慢放模式" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSForegroundColorAttributeName : [UIColor colorWithRed:255.0 / 255.0 green:64.0 / 255.0 blue:0.0 / 255.0 alpha:1.0], NSParagraphStyleAttributeName : paragraphStyle}];
	
	NSAttributedString *lineTwo = [[NSAttributedString alloc] initWithString:@"点击播放/暂停，滑屏拖动播放" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSParagraphStyleAttributeName : paragraphStyle}];
	
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
	if(!self.infoButton.selected) [self.infoButton select];
}

- (void)tappedButton:(DOFavoriteButton *)sender {
	[self showPopup];
}

#pragma mark - (TableView Delegate)

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
	cell.delegate = self;
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
	[self autoPlayFullyVisibleImages];
}

- (void)reload {
	[[YYImageCache sharedCache].memoryCache removeAllObjects];
	[[YYImageCache sharedCache].diskCache removeAllObjects];
	[self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
}


#pragma mark - Slow Play

- (BOOL)isFullyVisible:(UITableViewCell *)cell {
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

	CGRect rectOfCellInTableView = [self.tableView rectForRowAtIndexPath: indexPath];
	CGRect rectOfCellInSuperview = [self.tableView convertRect: rectOfCellInTableView toView: self.tableView.superview];
	
	return (rectOfCellInSuperview.origin.y <= sHeight - kCellHeight && rectOfCellInSuperview.origin.y >= 64);
}

- (void)autoPlayFullyVisibleImages {
	for (UITableViewCell *cell in [self.tableView visibleCells]) {
		if([cell isKindOfClass:[ClipCell class]]) {
			ClipCell *_cell = (ClipCell *) cell;
			if([self isFullyVisible: _cell]) {
				if(!_cell.webImageView.isAnimating) [_cell.webImageView startAnimating];
			}else{
				if(_cell.webImageView.isAnimating) [_cell.webImageView stopAnimating];
			}
		}
	}
}

- (void)stopPlayingAllImages {
	for (UITableViewCell *cell in [self.tableView visibleCells]) {
		if([cell isKindOfClass:[ClipCell class]]) {
			ClipCell *_cell = (ClipCell *) cell;
			if(_cell.webImageView.isAnimating) [_cell.webImageView stopAnimating];
		}
	}
}

- (void)recordSlowPlayWithUrl:(NSString *)url {
	[lbService recordSlowPlayWithClipID:url];
}

#pragma mark - Favorite
- (void)setFavoriate:(NSString *)url {
//	[[FavoriateMgr sharedInstance] setFavoriate:url];
	[_cblService setFavoriate:url];
	[lbService recordFavoriteWithClipID:url postID:_postID];
}
- (void)unsetFavoriate:(NSString *)url {
//	[[FavoriateMgr sharedInstance] unsetFavoriate:url];
	[_cblService unsetFavoriate:url];
}
- (BOOL)isFavoriate:(NSString *)url {
	return [_cblService isFavoriate:url];
//	return [[FavoriateMgr sharedInstance] isFavoriate:url];
}

#pragma mark - Comments

- (void)fetchPostComments:(BOOL)isRefresh {
	
	NSString *id_post = [self postID];
	
	if(self.articleURLs.count > 0) {
		
		NSMutableArray *urlList = [NSMutableArray new];
		
		if(self.favorite) {
			[urlList addObjectsFromArray:self.articleURLs];
		}else {
			for (ArticleEntity *entity in _articleURLs) {
				[urlList addObject:entity.image];
			}
		}
			
		[lbService getCommentsSummaryByClipIDs:[urlList copy] isRefresh:isRefresh success:^(NSArray *list) {
			[self generateCommentList:list];
		} failure:^{
		}];
	}else if(id_post){
		[lbService getCommentsSummaryByPostID:id_post isRefresh:isRefresh success:^(NSArray *list) {
			[self generateCommentList:list];
		} failure:^{
		}];
	}
}

- (void)generateCommentList:(NSArray *)comments {
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
	
	for (NSDictionary *comment in comments) {
		[dict setObject:[comment objectForKey:@"comment_quantity"] forKey:[comment objectForKey:@"id_clip"]];
	}
	
	commentList = [dict copy];
	
	[self updateCellQty];
}

- (void)updateCellQty {
	
	for (UITableViewCell *cell in [self.tableView visibleCells]) {
		if([cell isKindOfClass:[ClipCell class]]) {
			ClipCell *_cell = (ClipCell *) cell;
			[_cell updateCommentQty];
		}
	}
}

- (NSString *)getCommentQty:(NSString *)clipID {
	if(commentList == nil || commentList.count == 0) {
		return nil;
	}
	return [[commentList objectForKey:clipID] stringValue];
}

- (void)showComments:(NSString *)clipID {
	EBCommentsViewController *clipCtr = [[EBCommentsViewController alloc] init];
	[clipCtr setClipID:clipID];
	[clipCtr setDelegate:self];
	clipCtr.modalPresentationStyle = UIModalPresentationOverFullScreen;
	[self presentViewController:clipCtr animated:YES completion:nil];
}

#pragma mark - Share

- (void)shareClip:(NSURL *)clipID {
	[lbService shareWithClipID:clipID];
}

#pragma mark - Album
- (void)addToAlbum:(NSString *)url {
	
	_clipToAdd = url;
	
	STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:[[UIStoryboard storyboardWithName:@"favorite" bundle:nil] instantiateViewControllerWithIdentifier:@"addList"]];
	
	_popCtr = popupController;
	popupController.style = STPopupStyleBottomSheet;
	
	[popupController.backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundViewDidTap)]];
	
	[STPopupNavigationBar appearance].tintColor = [UIColor colorWithRed:255.0 / 255.0 green:64.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
	
	[popupController presentInViewController:self];
}

- (void)backgroundViewDidTap {
	[self.popCtr dismiss];
}

- (void)showNewAlbumForm {
	UIAlertView* alert= [[UIAlertView alloc] initWithTitle:@"New Album"
												   message:@"Title for new list:"
												  delegate:self
										 cancelButtonTitle:@"Cancel"
										 otherButtonTitles:@"Create", nil];
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	[alert show];
}

- (void)addToExistingAlbum {
	
	AlbumAddClipDescViewController *ctr = [[UIStoryboard storyboardWithName:@"favorite" bundle:nil] instantiateViewControllerWithIdentifier:@"addDesc"];
	
	UINavigationController *navigationController =
	[[UINavigationController alloc] initWithRootViewController:ctr];
	
	[ctr setUrl:_clipToAdd];
	
	_fullScreen = true;
	
	navigationController.navigationBar.tintColor = [UIColor blackColor];
	
	ctr.modalPresentationStyle = UIModalPresentationCurrentContext;
	
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)saveClipToAlbumWithDesc:(NSString *)desc {
	if([_cblService saveClip:_clipToAdd toAlum:_albumToAdd withDesc:desc]) {
		[JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"已加入\"%@\"", _albumToAdd.title] dismissAfter:2.0 styleName:JDStatusBarStyleSuccess];
	}else{
		[JDStatusBarNotification showWithStatus:@"操作失败，请重试" dismissAfter:2.0 styleName:JDStatusBarStyleWarning];
	}
}

- (void)createNewAlbumWithTitle:(NSString *)title {
	Album *album = [_cblService creatAlubmWithTitle:title];
	if(album) {
		_albumToAdd = album;
		[self addToExistingAlbum];
	}
}

- (IBAction)unwindBack:(UIStoryboardSegue *)segue {

	UIViewController *source = [segue sourceViewController];
	
	if([source isKindOfClass:[AlbumAddClipDescViewController class]]){
		AlbumAddClipDescViewController *ctr = ((AlbumAddClipDescViewController *)source);
		if(ctr.shouldSave) {
			[self saveClipToAlbumWithDesc:ctr.desc.text];
		}
	}else if([source isKindOfClass:[AlbumSelectBottomSheetViewController class]]) {
		AlbumSelectBottomSheetViewController *ctr = ((AlbumSelectBottomSheetViewController *)source);
		_albumToAdd = ctr.selectedAlbum;
		if (!_albumToAdd) {
			_shouldAddAlbum = YES;
		}else {
			_shouldAddDesc = YES;
		}
	}
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alert didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex > 0) {
		NSString* title = [alert textFieldAtIndex:0].text;
		if (title.length > 0) {
			[self createNewAlbumWithTitle:title];
		}
	}
}
@end

