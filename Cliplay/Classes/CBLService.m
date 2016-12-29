//
//  CBLService.m
//  Cliplay
//
//  Created by 邢磊 on 2016/11/23.
//
//

#import "CBLService.h"
#import <YYWebImage/YYWebImage.h>
#import "FCUUID.h"
#import "MRProgress.h"
#import "JDStatusBarNotification.h"

//#define cbserverURL   @"http://localhost:4984/cliplay_user_data"
#define cbserverURL @"http://121.40.197.226:8000/cliplay_user_data"
#define didSyncedFlag @"didSynced"


@interface CBLService()
@property (nonatomic) CBLReplication *push;
@property (nonatomic) CBLReplication *pull;
@property (nonatomic) BOOL isSynced;
@property (nonatomic) NSError *lastSyncError;
@property MRProgressOverlayView *progressView;
@property NSString *uuid;
@end
@implementation CBLService

#pragma mark - Init
+ (id)sharedManager {
	static CBLService *sharedMyManager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedMyManager = [[self alloc] init];
	});
	return sharedMyManager;
}

- (instancetype)init {
	if (self = [super init]) {
		NSString *dbName = kDBName;
		
		CBLDatabaseOptions *option = [[CBLDatabaseOptions alloc] init];
		option.create = YES;
		option.storageType = kStorageType;
		//	option.encryptionKey = kEncryptionEnabled ? kEncryptionKey : nil;
		
		NSError *error;
		_database = [[CBLManager sharedInstance] openDatabaseNamed:dbName
													   withOptions:option
															 error:&error];
		if (error)
			NSLog(@"Cannot create database with an error : %@", [error description]);
	}
	
//	[self enableLogging];
	
	CBLModelFactory* factory = _database.modelFactory;
	[factory registerClass:[Album class] forDocumentType:@"album"];
	[factory registerClass:[Favorite class] forDocumentType:@"favorite"];
	[factory registerClass:[AlbumSeq class] forDocumentType:@"albumSeq"];
	
	[self loadFavorite];
	[self didSynced];
	[self loadAlbumSeq];
	[self syncToRemote];
	
	
	//For test ONLY
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString *applicationSupportDirectory = [paths firstObject];
	NSLog(@"applicationSupportDirectory: '%@'", applicationSupportDirectory);
	
	return self;
}

#pragma mark - Logging
- (void)enableLogging {
	//        [CBLManager enableLogging:@"Database"];
	//        [CBLManager enableLogging:@"View"];
	//        [CBLManager enableLogging:@"ViewVerbose"];
	//        [CBLManager enableLogging:@"Query"];
	[CBLManager enableLogging:@"Sync"];
	[CBLManager enableLogging:@"SyncVerbose"];
	//        [CBLManager enableLogging:@"ChangeTracker"];
}

#pragma mark - Sync
- (void)syncToRemote {
	NSURL *syncUrl = [NSURL URLWithString:cbserverURL];
	
	_push = [_database createPushReplication:syncUrl];
	
	[_database setFilterNamed: @"syncedFlag" asBlock: FILTERBLOCK({
		return ![revision[@"_id"] isEqual:didSyncedFlag];
	})];
	
	id<CBLAuthenticator> auth;
	auth = [CBLAuthenticator basicAuthenticatorWithName: @"cliplay_user"
											   password: @"Cliplay_nba"];
	_push.authenticator = auth;
	_push.filter = @"syncedFlag";
//	_push.continuous = YES;
	
	[_push start];
}

- (void)syncFromRemote {
	
	if(_isSynced) return;
	
	NSURL *syncUrl = [NSURL URLWithString:cbserverURL];
	
	_pull = [_database createPullReplication:syncUrl];
	
	id<CBLAuthenticator> auth;
	auth = [CBLAuthenticator basicAuthenticatorWithName: @"cliplay_user"
											   password: @"Cliplay_nba"];
	_pull.authenticator = auth;
	_pull.channels = @[[NSString stringWithFormat:@"user_%@", _uuid]];
	
	NSNotificationCenter *nctr = [NSNotificationCenter defaultCenter];
	[nctr addObserver:self selector:@selector(myReplicationProgress:)
				 name:kCBLReplicationChangeNotification object:_pull];
	
	[self showProgress];
	
	[self performBlock:^{
		[_pull start];
	} afterDelay:0.5];
}


- (void)myReplicationProgress:(NSNotification *)notification {
	NSError* error = _pull.lastError;
	
	if(error){
		_lastSyncError = error;
	}
//	if (error != _lastSyncError) {
//		_lastSyncError = error;
//		if (error.code == 401) {
//			[self showMessage:@"Authentication failed" withTitle:@"Sync Error"];
//		} else
//			[self showMessage:error.description withTitle:@"Sync Error"];
//	}
	
	if (_pull.status == kCBLReplicationActive){
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		
		double progress = 0.0;
		double total = _pull.changesCount;
		if (total > 0.0) {
			progress = _pull.completedChangesCount/ total;
		}
		
		[_progressView setProgress:progress];
	}
	else {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}
	
	if(_pull.status == kCBLReplicationStopped) {
//		NSLog(@"Really stopped");
		if(_pull.changesCount > 0.0 && _pull.changesCount == _pull.completedChangesCount) {
//			NSLog(@"Really has docs synced");
			[_progressView setProgress:1.0];
			//If success, process conflict solving and mark did synced
			if(!_lastSyncError) {
//				NSLog(@"Really need to resolve confilict");
				if([self processFavoriteConflict]) {
					[self setDidSynced];
				};
			}
		}else if(_lastSyncError){
			[JDStatusBarNotification showWithStatus:@"获取历史数据失败，请检查网络" dismissAfter:2.0 styleName:JDStatusBarStyleWarning];
		}
	}
	
	if(!_pull.running){
		[self performBlock:^{
			[_progressView dismiss:NO];
		} afterDelay:0.8];
	}
}

- (void)didSynced {
	_isSynced = ([_database existingDocumentWithID: didSyncedFlag] != nil);
}

- (void)setDidSynced {
	CBLDocument* doc = [_database documentWithID: didSyncedFlag];
	NSError* error;
	if ([doc putProperties: @{@"synced": @true} error: &error]) {
		_isSynced = YES;
	}
}

- (void)showProgress {
	
	MRProgressOverlayView *view = [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow animated:NO];
	
	view.mode = MRProgressOverlayViewModeDeterminateHorizontalBar;
	
	NSAttributedString *title = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"初始化", nil) attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15], NSForegroundColorAttributeName : [UIColor darkGrayColor]}];
	
	view.titleLabelAttributedText = title;
	
	view.tintColor = [UIColor colorWithRed:255.0 / 255.0 green:64.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
	
	_progressView = view;
}

- (BOOL)processFavoriteConflict {
	
	NSError *error;
	NSArray* conflicts = [_favorite.document getConflictingRevisions: &error];
	
	if(conflicts.count <= 1) {
		return YES;
	}
	
	CBLSavedRevision* current = _favorite.document.currentRevision;
	NSMutableArray *local = [NSMutableArray new];
	NSMutableArray *remote = [NSMutableArray new];
	
	for (CBLSavedRevision* rev in conflicts) {
		
		NSArray *clips = [rev propertyForKey:@"clips"];
		bool isFromLocal = [[rev propertyForKey:@"isFromLocal"] boolValue];
		
		if(isFromLocal == YES){
			[local addObjectsFromArray:clips];
		}else{
			[remote addObjectsFromArray:clips];
		}
		
		if (rev != current) {
			CBLUnsavedRevision *newRev = [rev createRevision];
			newRev.isDeletion = YES;
			if(![newRev saveAllowingConflict: &error]) {
				return NO;
			}
		}
	}
	
	NSMutableOrderedSet *set = [NSMutableOrderedSet new];
	[set addObjectsFromArray:[local copy]];
	[set addObjectsFromArray:[remote copy]];
	
	CBLUnsavedRevision *newRev = [current createRevision];
	[newRev setObject:[set array] forKeyedSubscript:@"clips"];
	
	if(![newRev saveAllowingConflict: &error]) {
		return NO;
	}
	
	return YES;
}

#pragma mark - Album

-(void)loadAlbumSeq {
	_albumSeq = [AlbumSeq getAlbumSeqInDatabase:_database withUUID:_uuid];
}

- (Album*)creatAlubmWithTitle:(NSString*)title {
	Album* album = [Album getAlbumInDatabase:_database withTitle:title withUUID:_uuid];
	
	NSError *error;
	if ([album save:&error]) {
		[JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"已新建\"%@\"", album.title] dismissAfter:2.0 styleName:JDStatusBarStyleSuccess];
		return album;
	}else {
		[JDStatusBarNotification showWithStatus:@"操作失败，请重试" dismissAfter:2.0 styleName:JDStatusBarStyleWarning];
		return nil;
	}
}

- (BOOL)deleteAlbum:(Album *)album {
	NSError *error;
	NSString *albumName = album.title;
	if ([album deleteDocument:&error]){
		[JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"已删除\"%@\"", albumName] dismissAfter:2.0 styleName:JDStatusBarStyleSuccess];
		return YES;
	}else{
		[JDStatusBarNotification showWithStatus:@"操作失败，请重试" dismissAfter:2.0 styleName:JDStatusBarStyleWarning];
		return NO;
	}
}

- (BOOL)addClip:(NSString *)url toAlum:(Album *)album withDesc:(NSString *)desc {
	
	NSMutableArray *existingClips = [NSMutableArray arrayWithArray:album.clips];
	ArticleEntity *clip = [[ArticleEntity alloc] initWithData:url desc:desc];
	
	[existingClips addObject:clip];
	album.clips = [existingClips copy];
	
	return [self saveAlbum:album];
}

- (BOOL)addClips:(NSArray *)urls toAlum:(Album *)album{
	
	NSMutableArray *existingClips = [NSMutableArray arrayWithArray:album.clips];
	
	for(NSString *url in urls) {
		ArticleEntity *clip = [[ArticleEntity alloc] initWithData:url desc:@""];
		[existingClips addObject:clip];
	}
	
	album.clips = [existingClips copy];
	
	return [self saveAlbum:album];
}

- (BOOL)saveAlbum:(Album *)album {
	
	[self setThumbForAlbum:album];
	
	NSError* error;
	if ([album save: &error]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"albumModified" object:nil];
		[JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"已加入\"%@\"", album.title] dismissAfter:2.0 styleName:JDStatusBarStyleSuccess];
		return YES;
	}else {
		[JDStatusBarNotification showWithStatus:@"操作失败，请重试" dismissAfter:2.0 styleName:JDStatusBarStyleWarning];
		return NO;
	}
}

- (void)setThumbForAlbum:(Album *)album {
	if(!album.getThumb) {
		ArticleEntity *firstClip = album.clips[0];
		if(firstClip){
			[album setThumb:[self getThumb:firstClip.url]];
		}
	}
}

- (BOOL)modifyClipDesc:(NSString *)newDesc withIndex:(NSInteger)index forAlbum:(Album *)album {
	
	NSMutableArray *clipsToModify = [album.clips mutableCopy];
	ArticleEntity *clip = clipsToModify[index];
	ArticleEntity *newClip = [[ArticleEntity alloc] initWithCopy:clip];
	newClip.desc = newDesc;
	[clipsToModify replaceObjectAtIndex:index withObject:newClip];
	album.clips = [clipsToModify copy];
	
	NSError* error;
	if ([album save: &error]) {
		[JDStatusBarNotification showWithStatus:@"描述修改成功" dismissAfter:1.2 styleName:JDStatusBarStyleSuccess];
		return YES;
	}else {
		[JDStatusBarNotification showWithStatus:@"操作失败，请重试" dismissAfter:2.0 styleName:JDStatusBarStyleWarning];
		return NO;
	}
}

- (BOOL)deleteClipWithIndex: (NSInteger)index forAlbum:(Album *)album {
	
	NSMutableArray *clipsToModify = [album.clips mutableCopy];
	[clipsToModify removeObjectAtIndex:index];
	if(clipsToModify.count == 0) {
		[album removeThumb];
	}else if(index == 0) {
		//Change thumb if the first clip is switched
		ArticleEntity *currFirstClip = clipsToModify[0];
		[album setThumb:[self getThumb:currFirstClip.url]];
	}
	album.clips = [clipsToModify copy];
	
	NSError* error;
	if ([album save: &error]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"albumModified" object:nil];
		[JDStatusBarNotification showWithStatus:@"动图删除成功" dismissAfter:1.2 styleName:JDStatusBarStyleSuccess];
		return YES;
	}else {
		[JDStatusBarNotification showWithStatus:@"操作失败，请重试" dismissAfter:2.0 styleName:JDStatusBarStyleWarning];
		return NO;
	}
}

- (BOOL)updateAlbumInfo:(NSString *)newTitle withDesc:(NSString *)newDesc forAlbum:(Album *)album {
	if([album.title isEqualToString:newTitle] && [album.desc isEqualToString:newDesc]){
		return NO;
	}
	album.title = newTitle;
	album.desc = newDesc;
	
	NSError* error;
	if ([album save: &error]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"albumModified" object:nil];
		[JDStatusBarNotification showWithStatus:@"信息修改成功" dismissAfter:1.2 styleName:JDStatusBarStyleSuccess];
		return YES;
	}else {
		[JDStatusBarNotification showWithStatus:@"操作失败，请重试" dismissAfter:2.0 styleName:JDStatusBarStyleWarning];
		return NO;
	}
}

- (NSArray *)getAllAlbumsWithoutOrder {
	CBLQuery* query = [self queryAllAlbums];
	
	NSError *error;
	NSMutableArray *albums = [[NSMutableArray alloc] init];
	
	CBLQueryEnumerator* result = [query run: &error];
	for (CBLQueryRow* row in result) {
		CBLDocument *doc = row.document;
		Album *album = [Album modelForDocument:doc];
		[albums addObject:album];
	}
	
	return [albums copy];
}

- (NSArray *)getAllAlbums {
	
	if(!_albumSeq.albumIDs) {
		return [self getAllAlbumsWithoutOrder];
	}
	
	CBLQuery* query = [self queryAllAlbums];
	
	NSError *error;
	NSMutableArray *albums = [[NSMutableArray alloc] init];
	NSMutableDictionary *dict = [NSMutableDictionary new];
	
	CBLQueryEnumerator* result = [query run: &error];
	for (CBLQueryRow* row in result) {
		CBLDocument *doc = row.document;
		Album *album = [Album modelForDocument:doc];
		[dict setObject:album forKey:doc.documentID];
	}
	
//	NSArray *order = @[@"album_c0b358cb90244a54a2f28df968be1086_504440879",					   	   @"album_c0b358cb90244a54a2f28df968be1086_504439694",
//					   @"album_c0b358cb90244a54a2f28df968be1086_504448234"
//					   ];
	
	NSArray *order = _albumSeq.albumIDs;
	
	for(NSString *key in order) {
		[albums addObject:[dict objectForKey:key]];
	}
	
	return [albums copy];
}

- (BOOL)saveAlbumSeq:(NSArray *)albumIDs {
	_albumSeq.albumIDs = albumIDs;
	NSError* error;
	if ([_albumSeq save: &error]) {
		return YES;
	}else {
		return NO;
	}
}

- (CBLQuery *)queryAllAlbums {
	CBLView* view = [_database viewNamed: @"albums"];
	
	view.documentType = @"album";
	[view setMapBlock: MAPBLOCK({
		emit(doc[@"_id"], nil);
	}) version: @"1"];
	
	CBLQuery* query = [view createQuery];
	query.descending = YES;
	
	return query;
}

#pragma mark - Favorite
- (void)loadFavorite {
	_uuid = [FCUUID uuidForDevice];
	_favorite = [Favorite getFavoriteInDatabase:_database withUUID:_uuid];
}

- (BOOL)isFavoriate:(NSString *)url {
	return [_favorite isFavoriate:url];
}

- (void)setFavoriate:(NSString *)url {
	[_favorite setFavoriate:url];
}

- (void)unsetFavoriate:(NSString *)url {
	[_favorite unsetFavoriate:url];
}

- (BOOL)saveFavoriteWithClip:(NSString *)url {
	
	NSMutableArray *existingClips = [NSMutableArray arrayWithArray:_favorite.clips];
	
	ArticleEntity *clip = [[ArticleEntity alloc] initWithData:url desc:@""];
	
	NSError* error;
	[existingClips insertObject:clip atIndex:0];
	
	_favorite.clips = [existingClips copy];
	
	if ([_favorite save: &error]) {
		return YES;
	}else {
		return NO;
	}
}

#pragma mark - Helper
- (UIImage *)getThumb:(NSString *)url{
	return [[YYImageCache sharedCache] getImageForKey:[[YYWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:url]]];
}

- (void)performBlock:(void(^)())block afterDelay:(NSTimeInterval)delay {
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), block);
}

- (void)showMessage:(NSString *)text withTitle:(NSString *)title {
	[[[UIAlertView alloc] initWithTitle:title
								message:text
							   delegate:nil
					  cancelButtonTitle:@"OK"
					  otherButtonTitles:nil] show];
}

#pragma mark - For test
- (void)getAllDocument {
	CBLQuery* query = [_database createAllDocumentsQuery];
	query.allDocsMode = kCBLAllDocs;
	NSError *error;
	CBLQueryEnumerator* result = [query run: &error];
	for (CBLQueryRow* row in result) {
		CBLDocument *doc = row.document;
		NSString *isFromLocal = [doc propertyForKey:@"isFromLocal"];
		NSLog(@"isFromLocal = %@",isFromLocal);
	}
}
@end
