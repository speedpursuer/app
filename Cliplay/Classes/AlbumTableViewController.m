//
//  FavoriteTableViewController.m
//  Cliplay
//
//  Created by 邢磊 on 2016/11/3.
//
//

#import "AlbumTableViewController.h"
#import "AlbumListTableViewCell.h"
#import "Album.h"
#import "ClipController.h"
#import "CBLService.h"
#import <FontAwesomeKit/FAKFontAwesome.h>
#import "MyLBService.h"
#import "MRProgress.h"

#define kFavoriteTitle "我的最爱"

@interface AlbumTableViewController ()
@property CBLService *service;
@property CBLLiveQuery *liveQuery;
@property Favorite *favorite;
@property UIImage *deFaultFavoriteThumb;
@property UIImage *deFaultAlbumThumb;
@property (nonatomic, strong) NSMutableArray *albums;
@property MRProgressOverlayView *progressView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionButton;
//@property Album *albumToDelete;
//@property NSArray *listsResult;
@end

@implementation AlbumTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setNavBar];
	[self setup];
	[_service syncFromRemote];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self resetNavBar];
}

- (void)setNavBar {
	self.navigationController.navigationBar.tintColor = [UIColor blackColor];
}

- (void)resetNavBar {
	if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
		[self.navigationController setNavigationBarHidden:YES];
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
//	[self.liveQuery removeObserver:self forKeyPath:@"rows"];
//	[self.favorite removeObserver:self forKeyPath:@"clips"];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kAlbumListChange object:nil];
}

- (void)setup {
	_service = [CBLService sharedManager];
	_favorite = [_service favorite];
	_albums = [NSMutableArray arrayWithArray:[_service getAllAlbums]];
	
//	self.liveQuery = [_service queryAllAlbums].asLiveQuery;
//	[self.liveQuery addObserver:self forKeyPath:@"rows" options:0 context:nil];
//	[self.favorite addObserver:self forKeyPath:@"clips" options:0 context:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updateAlumbList:)
												 name:kAlbumListChange
											   object:nil];
	[self setupThumbs];
	
//	NSArray *buttons = self.navigationItem.rightBarButtonItems;
//	NSMutableArray *newButtons = [NSMutableArray arrayWithArray:buttons];
//	self.editButtonItem.tintColor = [UIColor colorWithRed:255.0 / 255.0 green:64.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
//	[newButtons insertObject:self.editButtonItem atIndex:1];
//	self.navigationItem.rightBarButtonItems = [newButtons copy];
}

#pragma mark - Observers
- (void)updateAlumbList:(NSNotification*)note {
	_albums = [NSMutableArray arrayWithArray:[_service getAllAlbums]];
	[self.tableView reloadData];
}

#pragma mark - Create and delete albums

- (void)createListWithTitle:(NSString*)title {
	[_service creatAlubmWithTitle:title];
}

- (void)deleteAlubm:(Album *)album {
	[_service deleteAlbum:album];
}

- (void)deleteAlubmWithIndex:(NSIndexPath *)indexPath {
	Album *album = [self getAlbumWithIndex:indexPath];
	[_service deleteAlbum:album];
}

#pragma mark - Helpers

- (Album *)getAlbumWithIndex:(NSIndexPath *)indexPath {
	return (self.albums)[indexPath.row];
//	CBLQueryRow* row = [self.listsResult objectAtIndex:indexPath.row];
//	return [Album modelForDocument:row.document];
}

- (void)setupThumbs {
	
	CGSize imageSize = CGSizeMake(65, 65);
	
	FAKFontAwesome *FavoriteIcon = [FAKFontAwesome heartOIconWithSize:20];
	[FavoriteIcon addAttribute:NSForegroundColorAttributeName value:[UIColor redColor]];
	_deFaultFavoriteThumb = [FavoriteIcon imageWithSize:imageSize];
	
	FAKFontAwesome *albumIcon = [FAKFontAwesome folderOIconWithSize:30];
	[albumIcon addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor]];
	FAKFontAwesome *fileIcon = [FAKFontAwesome filmIconWithSize:8];
	[fileIcon addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor]];
	_deFaultAlbumThumb = [UIImage imageWithStackedIcons:@[albumIcon, fileIcon] imageSize:imageSize];
}

- (void)showAlertMessage:(NSString *)title withMessage:(NSString *)message {
	[[[UIAlertView alloc] initWithTitle:title
								message:message
							   delegate:nil
					  cancelButtonTitle:@"知道了"
					  otherButtonTitles:nil] show];
}

- (void)showActionMessage:(NSString *)title withMessage:(NSString *)message withTag:(NSInteger)tag withStyle:(UIAlertViewStyle)style{
	UIAlertView* alert= [[UIAlertView alloc] initWithTitle:title
												   message:message
												  delegate:self
										 cancelButtonTitle:@"取消"
										 otherButtonTitles:@"确定", nil];
	alert.alertViewStyle = style;
	alert.tag = tag;
	[alert show];
}

- (void)showProgress {
	if(_progressView) {
		_progressView = nil;
	}
	
	MRProgressOverlayView *view = [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow animated:NO];
	
	view.mode = MRProgressOverlayViewModeIndeterminateSmallDefault;
	
	NSAttributedString *title = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"读取中...", nil) attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15], NSForegroundColorAttributeName : [UIColor darkGrayColor]}];
	
	view.titleLabelAttributedText = title;
	
	view.tintColor = [UIColor colorWithRed:255.0 / 255.0 green:64.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
	
	_progressView = view;
}

- (void)hideProgress {
	[_progressView dismiss:YES];
}

- (BOOL)isValidURL:(NSString *)url{
	NSURL *candidateURL = [NSURL URLWithString:url];
	if (candidateURL && candidateURL.scheme && candidateURL.host) {
		return YES;
	}else{
		return NO;
	}
}

#pragma mark - Action Sheet for album operations
- (IBAction)showActionSheet:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:@"取消"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"新建收藏夹", @"整理收藏夹", @"从链接获取动图", nil];
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0:
			[self showActionMessage:@"新建收藏夹" withMessage:@"请输入名称:" withTag:1 withStyle:UIAlertViewStylePlainTextInput];
			break;
		case 1:
			[self toggleEditMode];
			break;
		case 2:
			[self fetchClips];
			break;
		default:
			break;
	}
}

- (void)toggleEditMode{
	UIBarButtonItem *item = nil;
	if (self.tableView.editing) {
//		[self.tableView setEditing:NO];
		[self setEditing:NO];
		item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionSheet:)];
	}
	else {
//		[self.tableView setEditing:YES];
		[self setEditing:YES];
		item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toggleEditMode)];
	}
//	item.tintColor = [UIColor colorWithRed:255.0 / 255.0 green:64.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
	self.navigationItem.rightBarButtonItem = item;
}

#pragma mark - Fetch Clips
- (void)fetchClips {
	if([self isValidURL:[UIPasteboard generalPasteboard].string]) {
		[self showActionMessage:@"查看这里的动图？" withMessage:[UIPasteboard generalPasteboard].string withTag:3 withStyle:UIAlertViewStyleDefault];
	}else{
		[self showAlertMessage:@"请复制正确的链接" withMessage:@""];
	}
}

- (void)doFetch {
	NSString *url = [UIPasteboard generalPasteboard].string;
	
	if([[url pathExtension] caseInsensitiveCompare:@"gif"] == NSOrderedSame) {
		ClipController *vc = [ClipController new];
		vc.fetchMode = true;
//		vc.header = @"单图下载";
		vc.articleURLs = @[url];
		[self.navigationController pushViewController:vc animated:YES];
	}else {
		MyLBService *service = [MyLBService sharedManager];
		[self showProgress];
		[service fetchClipsFromURL:url success:^(NSArray *images, NSString *title) {
			[self hideProgress];
			if(images.count > 0){
				ClipController *vc = [ClipController new];
				vc.fetchMode = true;
//				vc.header = title? title: @"多图下载";
				vc.articleURLs = images;
				[self.navigationController pushViewController:vc animated:YES];
			}else{
				[self showAlertMessage:@"此页面无法获取动图：" withMessage:url];
			}
			
		} failure:^{
			[self hideProgress];
			[self showAlertMessage:@"获得动图失败" withMessage:@"请检查网络后重试"];
		}];
	}
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alert didDismissWithButtonIndex:(NSInteger)buttonIndex {
	
	switch (alert.tag) {
			
		case 1:
			if (buttonIndex > 0) {
				NSString* title = [alert textFieldAtIndex:0].text;
				if (title.length > 0) {
					[self createListWithTitle:title];
				}
			}
			break;
			
		case 2:
//			if (buttonIndex > 0) {
//				[self deleteAlubm:_albumToDelete];
//			}else {
//				[self toggleEditMode];
//			}
			break;
			
		case 3:
			if (buttonIndex > 0) {
				[self doFetch];
			}
			break;
		
		default:
			break;
		 
	}
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
	if(alertView.tag == 1){
		UITextField *textField = [alertView textFieldAtIndex:0];
		if ([textField.text length] == 0){
			return NO;
		}else{
			return YES;
		}
	}else{
		return YES;
	}
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)style
forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (style == UITableViewCellEditingStyleDelete) {
		[self deleteAlubmWithIndex:indexPath];
//		_albumToDelete = [self getAlbumWithIndex:indexPath];
//		[self showActionMessage:@"确定删除此收藏夹?" withMessage:[NSString stringWithFormat:@"\"%@\"", _albumToDelete.title] withTag:2 withStyle:UIAlertViewStyleDefault];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section == 0) {
		return 1;
	}else{
		return [_albums count];
//		return _listsResult.count;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
//	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"album_favorite"];
	
	AlbumListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"favorite"];
	
	if(indexPath.section == 0) {
		cell.title.text = @kFavoriteTitle;
		cell.badge.text = [NSString stringWithFormat: @"%ld", _favorite.clips.count];
		[cell.thumb setImage:_deFaultFavoriteThumb];
//		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else {
		Album *album = [self getAlbumWithIndex:indexPath];
		cell.title.text = album.title;
		cell.badge.text = [NSString stringWithFormat: @"%ld", album.clips.count];
		UIImage *thumb = [album getThumb];
		if(thumb == nil) {
			thumb =	_deFaultAlbumThumb;
		}
		[cell.thumb setImage:thumb];
//		cell.showsReorderControl = YES;
//		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 0) {
		return NO;
	}else{
		return YES;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	ClipController *vc = [ClipController new];
	if(indexPath.section == 0) {
//		Favorite *favorite = _service.favorite;
		vc.favorite = true;
		vc.header = @kFavoriteTitle;
		vc.articleURLs = _favorite.clips;
	}else {
		Album *album = [self getAlbumWithIndex:indexPath];
		vc.header = album.title;
		vc.album = album;
		vc.summary = album.desc;
	}
	
	[self.navigationController pushViewController:vc animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return nil;
	}else{
		return @"我的收藏夹";
	}
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath.section != 0? YES: NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
//	NSLog(@"%ld moved to %ld", sourceIndexPath.row, destinationIndexPath.row);
	if(sourceIndexPath.row != destinationIndexPath.row) {
		id row = [_albums objectAtIndex:sourceIndexPath.row];
		[_albums removeObjectAtIndex:sourceIndexPath.row];
		[_albums insertObject:row atIndex:destinationIndexPath.row];
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Detemine if it's in editing mode
	if (self.tableView.editing)
	{
		return UITableViewCellEditingStyleDelete;
	}
	return UITableViewCellEditingStyleNone;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	[self.tableView setEditing:editing animated:animated];
	if(!editing) {
		NSMutableArray *orderedAlbumID = [NSMutableArray new];
		for(Album *album in _albums) {
			[orderedAlbumID addObject:[album docID]];
		}
		[_service saveAlbumSeq:orderedAlbumID];
	}
}

- (NSIndexPath *)tableView:(UITableView *)tableView
targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath
	   toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	if (proposedDestinationIndexPath.section == 0) {
		return [NSIndexPath indexPathForRow:0 inSection:sourceIndexPath.section];
	}	
	return proposedDestinationIndexPath;
	
//	if (sourceIndexPath.section != proposedDestinationIndexPath.section) {
//		NSInteger row = 0;
//		if (sourceIndexPath.section < proposedDestinationIndexPath.section) {
//			row = [tableView numberOfRowsInSection:sourceIndexPath.section] - 1;
//		}
//		return [NSIndexPath indexPathForRow:row inSection:sourceIndexPath.section];
//	}
//	
//	return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
	UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
	
//	header.textLabel.textColor = [UIColor redColor];
	header.textLabel.font = [UIFont boldSystemFontOfSize:16];
//	CGRect headerFrame = header.frame;
//	header.textLabel.frame = headerFrame;
//	header.textLabel.textAlignment = NSTextAlignmentCenter;
}

@end
