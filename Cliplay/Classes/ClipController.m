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
#import "AlbumInfoViewController.h"
#import <STPopup/STPopup.h>
#import "CBLService.h"

#define cellMargin 10
//#define kCellHeight ceil((kScreenWidth) * 10.0 / 16.0)
#define kScreenWidth ((UIWindow *)[UIApplication sharedApplication].windows.firstObject).width - cellMargin * 2
#define sHeight [UIScreen mainScreen].bounds.size.height
#define topBottomAdjust 10.0
#define tableViewYoffset -64.0
#define ratio16_9   (double)9/16
#define ratio4_3    (double)3/4
#define ratio16_10  (double)10/16
#define ratioSettings "ratioSettings"

@interface ClipController ()
@property (nonatomic, strong) STPopupController *popCtr;
@property CBLService *cblService;
@property Album *albumToAdd;
@property NSInteger indexOfSelectedClip;
@property clipActionType actionType;
@property NSString *clipCellID;
@property CGFloat correction;
@property NSDictionary *collectionList;
@property CGFloat cellHeight;
//@property (nonatomic, copy) NSString *clipToAdd;
//@property BOOL isAddAll;
@end

@implementation ClipController {
	NSMutableArray *data;
	MyLBService *lbService;
	NSDictionary* commentList;
//	NSString *shareText;
}

#pragma mark - Public API
- (void)formActionForCell:(UITableViewCell *)cell withActionType:(clipActionType)type {
	_actionType = type;
	
	if(cell) {
		_indexOfSelectedClip = [self.tableView indexPathForCell:cell].row;
	}
	
	switch (type) {
		case addToAlbum:
			[self showBottomAlbumPopup];
			break;
		case addAllToAlbum:
			[self showBottomAlbumPopup];
			break;
		case editClip:
			[self showAlbumActionsheet];
			break;
		default:
			break;
	}
}

#pragma mark - (UIViewContoller & Init)
- (void)viewDidLoad {
	[super viewDidLoad];
	
	lbService = [MyLBService sharedManager];
	_cblService = [CBLService sharedManager];
	
	[self setDownloadLimit:YES];
	
	[self setUpCollectionList];
	
	[self setClipRatio:[self getRatioSetting]];
	
	_correction = 0;
	
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.view.backgroundColor = [UIColor whiteColor];
	self.navigationController.navigationBar.tintColor = [UIColor blackColor];
	
//	[self setFavorite];
	
//	[self fetchPostComments:[self postID]];
	
	[self.navigationItem setTitle: _header];
	
	self.tableView.fd_debugLogEnabled = NO;
	
	[self registerReusableCell];
	
	[self addInfoIcon];
	
	if(_showInfo) {
		[self showPopup];
	}
	
	[self initData];
	
	[self initHeader];
	
	[self.tableView reloadData];
}

-(void)registerReusableCell {
	
	[self.tableView registerClass:[TitleCell class] forCellReuseIdentifier:TitleCellIdentifier];
	
	_clipCellID = [self isInAlbum]? AlbumCellIdentifier: ClipCellIdentifier;
	
	[self.tableView registerClass:[ClipCell class] forCellReuseIdentifier:_clipCellID];
}

-(void)setDownloadLimit:(BOOL)hasLimit {
	
	if(hasLimit) {
		Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
		NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
		
		if (networkStatus == ReachableViaWWAN) {
			[YYWebImageManager sharedManager].queue.maxConcurrentOperationCount = 1;
		} else {
			[YYWebImageManager sharedManager].queue.maxConcurrentOperationCount = 2;
		}
	}else{
		[YYWebImageManager sharedManager].queue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
	}
}

//- (void)setFavorite {
//	if(self.favorite) {
////		self.header = @"我的收藏";
////		self.articleURLs = [[FavoriateMgr sharedInstance] getFavoriateImages];
//	}
//}

- (void)initData {
	NSMutableArray *entities = @[].mutableCopy;
	if(_album) {
		NSMutableArray *pureURL = @[].mutableCopy;
		[_album.clips enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			ArticleEntity *entity = (ArticleEntity *)obj;
			NSString *desc = entity.desc;
			NSString *url = entity.url;
			if(desc && [desc length] != 0) {
				[entities addObject:[[ArticleEntity alloc] initWithData:@"" desc:desc]];
			}
			[entities addObject:[[ArticleEntity alloc] initWithData:url desc:@"" tag:idx]];
			[pureURL addObject:url];
		}];
		_articleURLs = [pureURL copy];

	}else if(_articleDicts) {
		[_articleDicts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			NSString *desc = obj[@"desc"];
			NSString *url = obj[@"url"];
			if(desc && [desc length] != 0) {
				[entities addObject:[[ArticleEntity alloc] initWithData:@"" desc:desc]];
			}
			[entities addObject:[[ArticleEntity alloc] initWithData:url desc:@""]];
		}];
	}else if(_articleURLs) {
		for (NSString *url in _articleURLs) {
			[entities addObject:[[ArticleEntity alloc] initWithData:url desc: @""]];
		}
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
	
	if(_fetchMode) {
//		UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(prepareToSaveAll)];
		UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"收藏全部" style:UIBarButtonItemStyleBordered target:self action:@selector(prepareToSaveAll)];
		
		button.tintColor = [UIColor colorWithRed:255.0 / 255.0 green:64.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
		
		self.navigationItem.rightBarButtonItem = button;
		return;
	}else if([self isInAlbum]) {
//		UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(prepareForAlbumInfo)];
		UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"信息" style:UIBarButtonItemStyleBordered target:self action:@selector(prepareForAlbumInfo)];

		button.tintColor = [UIColor colorWithRed:255.0 / 255.0 green:64.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
		
		self.navigationItem.rightBarButtonItem = button;
		return;
	}else {
		UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStyleBordered target:self action:@selector(showRatioActionsheet)];
		
		button.tintColor = [UIColor colorWithRed:255.0 / 255.0 green:64.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
		
		self.navigationItem.rightBarButtonItem = button;
		return;
	}
	
	
	
	/*
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
	*/
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if(_fullScreen) {
		[self autoPlayFullyVisibleImages];
		_fullScreen = false;
	}else{
		[self fetchPostComments:NO];
	}
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
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	if(![self isVisible]){
		[self stopPlayingAllImages];
		if(![self presentedViewController]){
			[[YYWebImageManager sharedManager].queue cancelAllOperations];
			[[YYImageCache sharedCache].memoryCache removeAllObjects];
		}
	}
}

- (BOOL)isVisible {
	return [self isViewLoaded] && self.view.window;
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
	
	if([entity.url length] == 0) {
		TitleCell *cell = [tableView dequeueReusableCellWithIdentifier:TitleCellIdentifier];
		[self configureTitleCell:cell atIndexPath:indexPath isForHeight:false];
		return cell;
	}else {
		ClipCell *cell = [tableView dequeueReusableCellWithIdentifier:_clipCellID];
		[self configureCell:cell atIndexPath:indexPath isForHeight:false];
		return cell;
	}
}

- (void)configureCell:(ClipCell *)cell atIndexPath:(NSIndexPath *)indexPath isForHeight:(BOOL)isForHeight {
	cell.fd_enforceFrameLayout = YES; // Enable to use "-sizeThatFits:"
	cell.delegate = self;
	cell.cellHeight = _cellHeight;
	[cell setCellData: data[indexPath.row] isForHeight:isForHeight];
}

- (void)configureTitleCell:(TitleCell *)cell atIndexPath:(NSIndexPath *)indexPath isForHeight:(BOOL)isForHeight {
	cell.fd_enforceFrameLayout = YES; // Enable to use "-sizeThatFits:"
	[cell setCellData: data[indexPath.row] isForHeight:isForHeight];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

	ArticleEntity *entity = data[indexPath.row];
	
	if([entity.url length] == 0) {
		return [tableView fd_heightForCellWithIdentifier:TitleCellIdentifier cacheByIndexPath:indexPath configuration:^(id cell) {
			[self configureTitleCell:cell atIndexPath:indexPath isForHeight:true];
		}];
	}else{
		return [tableView fd_heightForCellWithIdentifier:_clipCellID cacheByIndexPath:indexPath configuration:^(id cell) {
			[self configureCell:cell atIndexPath:indexPath isForHeight:true];
		}];
	}
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
	
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	CGFloat height = scrollView.frame.size.height;
	CGFloat contentYoffset = scrollView.contentOffset.y;
	CGFloat distanceFromBottom = scrollView.contentSize.height - contentYoffset;
	
	if(contentYoffset <= tableViewYoffset + topBottomAdjust) {
		_correction = 100;
	}else if(distanceFromBottom <= height + topBottomAdjust) {
		_correction = -110;
	}else {
		_correction = 0;
	}
	
	[self autoPlayFullyVisibleImages];
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//	if(indexPath.row == data.count - 1) {
//		_correction = -200;
//	}else if (indexPath.row == 0) {
//		_correction = 70;
//	}else {
//		_correction = 0;
//	}
//}

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
	
	return (rectOfCellInSuperview.origin.y <= sHeight - _cellHeight && rectOfCellInSuperview.origin.y >= 64);
}

- (BOOL)needToPlay:(UITableViewCell *)cell {
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
	
	CGRect rectOfCellInTableView = [self.tableView rectForRowAtIndexPath: indexPath];
	CGRect rectOfCellInSuperview = [self.tableView convertRect: rectOfCellInTableView toView: self.tableView.superview];
	
	CGFloat harfY = sHeight/2 - _correction;
	CGFloat topY = harfY - 5.005;
	CGFloat bottomY = harfY + 5.005;
	CGFloat cellTop = rectOfCellInSuperview.origin.y;
	CGFloat cellBottom = rectOfCellInSuperview.origin.y + _cellHeight;
	
//	if(cellTop <= topY && cellBottom >= bottomY) {
//		NSLog(@"Need to play - start");
//		NSLog(@"row = %ld", indexPath.row);
//		NSLog(@"correction = %f", _correction);
//		NSLog(@"cellTop = %f", cellTop);
//		NSLog(@"topY = %f", topY);
//		NSLog(@"cellBottom = %f", cellBottom);
//		NSLog(@"bottomY = %f", bottomY);
//		NSLog(@"Need to play - end");
//	}
	
//	return (cellTop <= topY && cellBottom >= bottomY);
	return (cellBottom > topY && cellTop < bottomY);
}

- (void)autoPlayFullyVisibleImages {
	for (UITableViewCell *cell in [self.tableView visibleCells]) {
		if([cell isKindOfClass:[ClipCell class]]) {
			ClipCell *_cell = (ClipCell *) cell;
			if([self needToPlay: _cell]) {
				[_cell.webImageView startAnimating];
				[_cell setBorder];
//				if(!_cell.webImageView.isAnimating) {
//					[_cell.webImageView startAnimating];
//				}
			}else{
				[_cell.webImageView stopAnimating];
				[_cell unSetBorder];
//				if(_cell.webImageView.isAnimating) {
//					
//				}
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
//	[lbService recordFavoriteWithClipID:url postID:_postID];
	[_cblService setFavoriate:url];
}
- (void)unsetFavoriate:(NSString *)url {
//	[[FavoriateMgr sharedInstance] unsetFavoriate:url];
	[_cblService unsetFavoriate:url];
}
- (BOOL)isFavoriate:(NSString *)url {
//	return [[FavoriateMgr sharedInstance] isFavoriate:url];
	return [_cblService isFavoriate:url];
}

#pragma mark - Comments

- (void)fetchPostComments:(BOOL)isRefresh {
	
	NSString *id_post = [self postID];
	
	if(self.articleURLs.count > 0) {
		[lbService getCommentsSummaryByClipIDs:[_articleURLs copy] isRefresh:isRefresh success:^(NSArray *list) {
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
	if(commentList == nil) {
		return nil;
	}
	
	NSString *qty = [[commentList objectForKey:clipID] stringValue];
	return qty? qty: @"";
}

- (void)showComments:(NSString *)clipID {
	EBCommentsViewController *clipCtr = [[EBCommentsViewController alloc] init];
	[clipCtr setClipID:clipID];
	[clipCtr setDelegate:self];
	[self setDownloadLimit:NO];
	clipCtr.modalPresentationStyle = UIModalPresentationOverFullScreen;
	[self presentViewController:clipCtr animated:YES completion:nil];
}

- (void)closeCommentView {
	[self setDownloadLimit:YES];
}

#pragma mark - Share

- (void)shareClip:(NSURL *)clipID {
	[lbService shareWithClipID:clipID];
}

#pragma mark - Album & Favorite

- (void)showBottomAlbumPopup {
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
	UIAlertView* alert= [[UIAlertView alloc] initWithTitle:@"新建收藏夹"
												   message:@"请输入名称:"
												  delegate:self
										 cancelButtonTitle:@"取消"
										 otherButtonTitles:@"确定", nil];
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	[alert show];
}

- (void)saveClipToAlbumWithDesc:(NSString *)desc {
	if([_cblService addClip:[self urlForSeletedClip] toAlum:_albumToAdd withDesc:desc]) {
		[self setCollected:[self urlForSeletedClip]];
		[((ClipCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_indexOfSelectedClip inSection:0]]) selectAlbumButton];
	}
	
//	if([_cblService addClip:[self urlForSeletedClip] toAlum:_albumToAdd withDesc:desc]) {
//		[JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"已加入\"%@\"", _albumToAdd.title] dismissAfter:2.0 styleName:JDStatusBarStyleSuccess];
//	}else{
//		[JDStatusBarNotification showWithStatus:@"操作失败，请重试" dismissAfter:2.0 styleName:JDStatusBarStyleWarning];
//	}
}

- (NSString *)urlForSeletedClip {
	ArticleEntity *entity = data[_indexOfSelectedClip];
	return entity.url;
}

- (void)createNewAlbumWithTitle:(NSString *)title {
	Album *album = [_cblService creatAlubmWithTitle:title];
	if(album) {
		_albumToAdd = album;
		if(_actionType == addAllToAlbum) {
			[self saveAllClips];
		}else{
			[self showClipDescPopup:@""];
		}
	}
}

- (void)prepareToSaveAll{
	[self formActionForCell:nil withActionType:addAllToAlbum];
}

- (void)saveAllClips {
	[_cblService addClips:_articleURLs toAlum:_albumToAdd];
//	if([_cblService addClips:_articleURLs toAlum:_albumToAdd]){
//		[JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"已加入\"%@\"", _albumToAdd.title] dismissAfter:2.0 styleName:JDStatusBarStyleSuccess];
//	}
}

- (IBAction)unwindBack:(UIStoryboardSegue *)segue {

	UIViewController *source = [segue sourceViewController];
	
	if([source isKindOfClass:[AlbumAddClipDescViewController class]]){
		AlbumAddClipDescViewController *ctr = ((AlbumAddClipDescViewController *)source);
		if(ctr.shouldSave) {
			if(_actionType == addToAlbum) {
				[self saveClipToAlbumWithDesc:ctr.desc.text];
			}else if(_actionType == modifyDesc) {
				[self modifyClipDesc:ctr.desc.text];
			}
		}
	}else if([source isKindOfClass:[AlbumSelectBottomSheetViewController class]]) {
		AlbumSelectBottomSheetViewController *ctr = ((AlbumSelectBottomSheetViewController *)source);
		_albumToAdd = ctr.selectedAlbum;
		if(_actionType == addAllToAlbum) {
			if(_albumToAdd){
				[self saveAllClips];
			}else {
				[self showNewAlbumForm];
			}
		}else{
			if(_albumToAdd){
				[self showClipDescPopup:@""];
			}else {
				[self showNewAlbumForm];
			}
		}
	}else if([source isKindOfClass:[AlbumInfoViewController class]]) {
		AlbumInfoViewController *ctr = ((AlbumInfoViewController *)source);
		if(ctr.shouldSave) {
			[self updateAlbumInfoWithTitle:ctr.name withDesc:ctr.desc];
		}
	}
}

- (void)modifyClipDesc:(NSString *)newDesc {
	NSInteger clipIndexInAlbum = ((ArticleEntity *)data[_indexOfSelectedClip]).tag;
	NSString *origDesc = ((ArticleEntity *)_album.clips[clipIndexInAlbum]).desc;
	
	//No need to change if not changed
	if([origDesc isEqualToString:newDesc]) {
		return;
	}
	
	if([_cblService modifyClipDesc:newDesc withIndex:clipIndexInAlbum forAlbum:_album]) {
		[self refreshScreen];
	}
}

- (void)deleteClip {
	NSInteger clipIndexInAlbum = ((ArticleEntity *)data[_indexOfSelectedClip]).tag;
	if([_cblService deleteClipWithIndex:clipIndexInAlbum forAlbum:_album]) {
		[self refreshScreen];
	}
}

- (void)showClipDescPopup:(NSString *)desc {
	AlbumAddClipDescViewController *ctr = [[UIStoryboard storyboardWithName:@"favorite" bundle:nil] instantiateViewControllerWithIdentifier:@"addDesc"];
	
	[ctr setUrl:[self urlForSeletedClip]];
	ctr.currDesc = desc;
	ctr.modalPresentationStyle = UIModalPresentationCurrentContext;
	
	_fullScreen = true;
	
	UINavigationController *navigationController =
	[[UINavigationController alloc] initWithRootViewController:ctr];
	navigationController.navigationBar.tintColor = [UIColor blackColor];
	
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)prepareForDescModify {
	NSString *curDesc = @"";
	if(_indexOfSelectedClip != 0) {
		ArticleEntity *entity = data[_indexOfSelectedClip - 1];
		curDesc = entity.desc;
	}
	
	[self showClipDescPopup:curDesc];
}

- (BOOL)isInAlbum {
	return _album? YES: NO;
}

- (void)performAlbumAction:(clipActionType)type{
	_actionType = type;
	switch (type) {
		case addToAlbum:
			[self showBottomAlbumPopup];
			break;
		case modifyDesc:
			[self prepareForDescModify];
			break;
		case deleteClip:
			[self deleteClip];
			break;
		default:
			break;
	}
}

-(void)prepareForAlbumInfo {
	AlbumInfoViewController *ctr = [[UIStoryboard storyboardWithName:@"favorite" bundle:nil] instantiateViewControllerWithIdentifier:@"albumInfo"];
	ctr.modalPresentationStyle = UIModalPresentationCurrentContext;
	ctr.name = _album.title;
	ctr.desc = _album.desc;
	
	_fullScreen = true;
	
	UINavigationController *navigationController =
	[[UINavigationController alloc] initWithRootViewController:ctr];
	navigationController.navigationBar.tintColor = [UIColor blackColor];
	
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)updateAlbumInfoWithTitle:(NSString *)title withDesc:(NSString *)desc {
//	NSLog(@"from album info, title = %@, desc = %@", title, desc);
	if([_cblService updateAlbumInfo:title withDesc:desc forAlbum:_album]) {
		[self setTitle:title];
		[self setSummary:desc];
		[self initHeader];
		[self refreshScreen];
	}
}

- (void)setUpCollectionList {
	_collectionList = [NSMutableDictionary new];
}

- (void)setCollected:(NSString *)url{
	[_collectionList setValue:@"YES" forKey:url];
}

- (BOOL)isCollected:(NSString *)url {	
	if([_collectionList objectForKey:url]) {
		return YES;
	}
	return NO;
}

#pragma mark - Action Sheet for album operation

- (void)showAlbumActionsheet {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"操作此动图"
															 delegate:self
													cancelButtonTitle:@"取消"
											   destructiveButtonTitle:@"删除动图"
													otherButtonTitles:@"修改描述", @"加入其他收藏夹", nil];
	actionSheet.tag = 1;
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if(actionSheet.tag == 1) {
		clipActionType type = noAction;
		switch (buttonIndex) {
			case 0:
				type = deleteClip;
				break;
			case 1:
				type = modifyDesc;
				break;
			case 2:
				type = addToAlbum;
				break;
			default:
				break;
		}
		[self performAlbumAction:type];
	}else if (actionSheet.tag == 2){
		switch (buttonIndex) {
			case 0:
				[self changeClipRatio:ratio4_3];
				break;
			case 1:
				[self changeClipRatio:ratio16_10];
				break;
			case 2:
				[self changeClipRatio:ratio16_9];
				break;
			default:
				break;
		}
	}
}

- (void)setClipWidth:(CGFloat)width withHeight:(CGFloat)height {
	[self setCellHeight:ceil((kScreenWidth) * height / width)];
}

- (void)setClipRatio:(double)ratio {
	[self setCellHeight:ceil((kScreenWidth) * ratio)];
}

- (void)changeClipRatioWithWidth:(CGFloat)width withHeight:(CGFloat)height {
	[self setClipWidth:width withHeight:height];
	[self.tableView reloadData];
	[self autoPlayFullyVisibleImages];
}

- (void)changeClipRatio:(double)ratio {
	[self setRatioSetting:ratio];
	[self setClipRatio:ratio];
	[self.tableView reloadData];
	[self autoPlayFullyVisibleImages];
}

- (void)showRatioActionsheet {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"设置动图比例"
															 delegate:self
													cancelButtonTitle:@"取消"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"4:3", @"16:10", @"16:9", nil];
	actionSheet.tag = 2;
	[actionSheet showInView:self.view];
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

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
	UITextField *textField = [alertView textFieldAtIndex:0];
	if ([textField.text length] == 0){
		return NO;
	}
	return YES;
}

#pragma mark - Help
- (void)refreshScreen {
	[self initData];
	[self.tableView reloadData];
	[self autoPlayFullyVisibleImages];
}

- (void)setRatioSetting:(double)ratio {
	NSUserDefaults *nud = [NSUserDefaults standardUserDefaults];
	[nud setObject:[NSNumber numberWithDouble:ratio] forKey:@ratioSettings];
	[nud synchronize];
}

- (double)getRatioSetting {
	NSUserDefaults *nud = [NSUserDefaults standardUserDefaults];
	NSNumber *ratio = [nud objectForKey:@ratioSettings];
	if(!ratio){
		return ratio4_3;
	}
	return [ratio doubleValue];
}

@end

