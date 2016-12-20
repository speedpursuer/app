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

@interface AlbumTableViewController ()
@property CBLService *service;
@property CBLLiveQuery *liveQuery;
@property Favorite *favorite;
@property UIImage *favoriteThumb;
@property UIImage *albumThumb;
@property Album *albumToDelete;
//@property (nonatomic, strong) NSMutableArray *albums;
@property NSArray *listsResult;
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
	[self.liveQuery removeObserver:self forKeyPath:@"rows"];
	[self.favorite removeObserver:self forKeyPath:@"clips"];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"addClipToAlbum" object:nil];
}

- (void)setup {
	_service = [CBLService sharedManager];
	_favorite = [_service favorite];
//	_albums = [NSMutableArray arrayWithArray:[_service getAllAlbums]];
	
	self.liveQuery = [_service queryAllAlbums].asLiveQuery;
	[self.liveQuery addObserver:self forKeyPath:@"rows" options:0 context:nil];
	[self.favorite addObserver:self forKeyPath:@"clips" options:0 context:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updateAlumbList:)
												 name:@"addClipToAlbum"
											   object:nil];
	[self setupThumbs];
}

#pragma mark - Observers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change
					   context:(void *)context {
	
	if([object isKindOfClass:[CBLLiveQuery class]]) {
		self.listsResult = self.liveQuery.rows.allObjects;
	}
	
	[self.tableView reloadData];
}

- (void)updateAlumbList:(NSNotification*)note {
	self.listsResult = self.liveQuery.rows.allObjects;
	[self.tableView reloadData];
}

#pragma mark - Create and delete albums

- (void)createListWithTitle:(NSString*)title {
	[_service creatAlubmWithTitle:title];
//	if(album) {
//		[_albums insertObject:album atIndex:0];
		
//		[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationLeft];
//	}
}

- (void)deleteAlubm:(Album *)album {
	[_service deleteAlbum:album];
}

- (void)deleteAlubmWithIndex:(NSIndexPath *)indexPath {
	Album *album = [self getAlbumWithIndex:indexPath];
	[_service deleteAlbum:album];
//	if([_service deleteAlbum:album]) {
//		[_albums removeObjectAtIndex:indexPath.row];
//		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//	}
}

#pragma mark - Helpers

- (Album *)getAlbumWithIndex:(NSIndexPath *)indexPath {
	//	return (self.albums)[indexPath.row];
	CBLQueryRow* row = [self.listsResult objectAtIndex:indexPath.row];
	return [Album modelForDocument:row.document];
}

- (void)setupThumbs {
	
	CGSize imageSize = CGSizeMake(65, 65);
	
	FAKFontAwesome *FavoriteIcon = [FAKFontAwesome heartOIconWithSize:20];
	[FavoriteIcon addAttribute:NSForegroundColorAttributeName value:[UIColor redColor]];
	_favoriteThumb = [FavoriteIcon imageWithSize:imageSize];
	
	FAKFontAwesome *albumIcon = [FAKFontAwesome folderOIconWithSize:30];
	[albumIcon addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor]];
	FAKFontAwesome *fileIcon = [FAKFontAwesome filmIconWithSize:8];
	[fileIcon addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor]];
	_albumThumb = [UIImage imageWithStackedIcons:@[albumIcon, fileIcon] imageSize:imageSize];
}

#pragma mark - Buttons
- (IBAction)addAlbum:(id)sender {
	UIAlertView* alert= [[UIAlertView alloc] initWithTitle:@"新建收藏夹"
												   message:@"请输入名称:"
												  delegate:self
										 cancelButtonTitle:@"取消"
										 otherButtonTitles:@"确定", nil];
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	alert.tag = 1;
	[alert show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alert didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if(alert.tag == 1){
		if (buttonIndex > 0) {
			NSString* title = [alert textFieldAtIndex:0].text;
			if (title.length > 0) {
				[self createListWithTitle:title];
			}
		}
	}else {
		if (buttonIndex > 0) {
			[self deleteAlubm:_albumToDelete];
		}else {
			[self.tableView setEditing:NO animated:NO];
		}
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
//		[self deleteAlubmWithIndex:indexPath];
		_albumToDelete = [self getAlbumWithIndex:indexPath];
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"确定删除此收藏夹?"
													   message:[NSString stringWithFormat:@"\"%@\"", _albumToDelete.title]
													  delegate:self
											 cancelButtonTitle:@"取消"
											 otherButtonTitles:@"删除", nil];
		alert.alertViewStyle = UIAlertViewStyleDefault;
		alert.tag = 2;
		[alert show];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section == 0) {
		return 1;
	}else{
//		return [_albums count];
		return _listsResult.count;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
//	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"album_favorite"];
	
	AlbumListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"favorite"];
	
	if(indexPath.section == 0) {
		cell.title.text = @"我的最爱";
		cell.badge.text = [NSString stringWithFormat: @"%ld", _favorite.clips.count];
		[cell.thumb setImage:_favoriteThumb];
//		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else {
		Album *album = [self getAlbumWithIndex:indexPath];
		cell.title.text = album.title;
		cell.badge.text = [NSString stringWithFormat: @"%ld", album.clips.count];
		UIImage *thumb = [album getImage];
		if(thumb == nil) {
			thumb =	_albumThumb;
		}
		[cell.thumb setImage:thumb];
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
		vc.header = _favorite.title;
		vc.articleURLs = _favorite.clips;
	}else {
		Album *album = [self getAlbumWithIndex:indexPath];
		vc.header = album.title;
		vc.articleURLs = album.clips;
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

@end
