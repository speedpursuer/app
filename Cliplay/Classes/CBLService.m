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
	
	_favorite = [self loadFavorite];
	_isSynced = [self didSynced];
	
	[self syncToRemote];
	
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
//
//	if(!_pull.running){
//		
//		[_progressView setProgress:1.0];
//		
//		[self performBlock:^{
//			[_progressView dismiss:NO];
//		} afterDelay:0.8];
//		
//		if(_pull.changesCount > 0.0 && _pull.changesCount == _pull.completedChangesCount) {
//			NSLog(@"Really has docs synced");
//			//If success, process conflict solving and mark did synced
//			if(!error) {
//				NSLog(@"Really need to resolve confilict");
//				if([self processFavoriteConflict]) {
//					[self setDidSynced];
//				};
//			}
//		}
//	}
}

- (BOOL)didSynced {
	return ([_database existingDocumentWithID: didSyncedFlag] != nil);
}

- (void)setDidSynced {
	CBLDocument* doc = [_database documentWithID: didSyncedFlag];
	NSError* error;
	if ([doc putProperties: @{@"synced": @true} error: &error]) {
		_isSynced = YES;
	}
}

- (void)showProgress {
	_progressView = [MRProgressOverlayView showOverlayAddedTo:[[UIApplication sharedApplication] keyWindow] title:@"初始化" mode:MRProgressOverlayViewModeDeterminateHorizontalBar animated:NO];
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
	
	[local addObjectsFromArray:remote];
	
	CBLUnsavedRevision *newRev = [current createRevision];
	[newRev setObject:[local copy] forKeyedSubscript:@"clips"];
	
	if(![newRev saveAllowingConflict: &error]) {
		return NO;
	}
	
	return YES;
}

#pragma mark - Album
- (Album*)creatAlubmWithTitle:(NSString*)title {
	Album* album = [Album getAlbumInDatabase:_database withTitle:title withUUID:_uuid];
	
	NSError *error;
	if ([album save:&error]) {
		return album;
	}else {
		return nil;
	}
}

- (BOOL)deleteAlbum:(Album *)album {
	NSError *error;
	if ([album deleteDocument:&error]){
		return YES;
	}else{
		return NO;
	}
}

- (BOOL)addClip:(NSString *)url toAlum:(Album *)album withDesc:(NSString *)desc {
	
	NSMutableArray *existingClips = [NSMutableArray arrayWithArray:album.clips];
	ArticleEntity *clip = [[ArticleEntity alloc] initWithData:url desc:desc];
	
	NSError* error;
	
	if(existingClips.count == 0) {
		[album setImage:[self getThumb:url]];
	}
	
//	[existingClips insertObject:clip atIndex:0];
	[existingClips addObject:clip];
	album.clips = [existingClips copy];
	
	if ([album save: &error]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"addClipToAlbum" object:nil];
		return YES;
	}else {
		return NO;
	}
}

- (NSArray *)getAllAlbums {
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
- (Favorite *)loadFavorite {
	_uuid = [FCUUID uuidForDevice];
	return [Favorite getFavoriteInDatabase:_database withUUID:_uuid];
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
