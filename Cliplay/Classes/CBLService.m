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

@interface CBLService()
@property (nonatomic) CBLReplication *push;
@property (nonatomic) CBLReplication *pull;
@property (nonatomic) BOOL isSynced;
@property (nonatomic) NSError *lastSyncError;
@property MRProgressOverlayView *progressView;
@property NSString *uuid;
@end
@implementation CBLService
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
	
	CBLModelFactory* factory = _database.modelFactory;
	[factory registerClass:[Album class] forDocumentType:@"album"];
	[factory registerClass:[Favorite class] forDocumentType:@"favorite"];
	
	_favorite = [self loadFavorite];
	_isSynced = [self didSynced];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString *applicationSupportDirectory = [paths firstObject];
	NSLog(@"applicationSupportDirectory: '%@'", applicationSupportDirectory);
	
	return self;
}

- (void)syncToRemote {
	NSURL *syncUrl = [NSURL URLWithString:@"http://localhost:4984/cliplay_user_data"];
	
	_push = [_database createPushReplication:syncUrl];
	
	id<CBLAuthenticator> auth;
	auth = [CBLAuthenticator basicAuthenticatorWithName: @"cliplay_user"
											   password: @"Cliplay_nba"];
	_push.authenticator = auth;
		
	[_push start];
}

- (void)syncFromRemote {
	
	if(_isSynced) return;
	
	NSURL *syncUrl = [NSURL URLWithString:@"http://localhost:4984/cliplay_user_data"];
	
	_pull = [_database createPullReplication:syncUrl];
	
	id<CBLAuthenticator> auth;
	auth = [CBLAuthenticator basicAuthenticatorWithName: @"cliplay_user"
											   password: @"Cliplay_nba"];
	_pull.authenticator = auth;
	_pull.channels = @[[NSString stringWithFormat:@"user_%@", _uuid]];
	
	// Observe replication progress changes, in both directions:
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
	if (error != _lastSyncError) {
		_lastSyncError = error;
		if (error.code == 401) {
			[self showMessage:@"Authentication failed" withTitle:@"Sync Error"];
		} else
			[self showMessage:error.description withTitle:@"Sync Error"];
	}
	
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
		
		[_progressView setProgress:1.0];
		
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		
		
		[self performBlock:^{
			[_progressView dismiss:NO];
		} afterDelay:0.8];
		
		if(!error) {
			[self setDidSynced];
		}
	}
}

- (void)performBlock:(void(^)())block afterDelay:(NSTimeInterval)delay {
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), block);
}


- (BOOL)didSynced {
	return [[NSUserDefaults standardUserDefaults] boolForKey:kDidSynced];
}

- (void)setDidSynced {
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDidSynced];
	_isSynced = YES;
}

- (void)showProgress {
	_progressView = [MRProgressOverlayView showOverlayAddedTo:[[UIApplication sharedApplication] keyWindow] title:@"获取数据" mode:MRProgressOverlayViewModeDeterminateHorizontalBar animated:NO];
}

#pragma mark - Message

- (void)showMessage:(NSString *)text withTitle:(NSString *)title {
	[[[UIAlertView alloc] initWithTitle:title
								message:text
							   delegate:nil
					  cancelButtonTitle:@"OK"
					  otherButtonTitles:nil] show];
}

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

- (BOOL)saveClip:(NSString *)url toAlum:(Album *)album withDesc:(NSString *)desc {
	
	NSMutableArray *existingClips = [NSMutableArray arrayWithArray:album.clips];
	ArticleEntity *clip = [[ArticleEntity alloc] initWithData:url desc:desc];
	
	NSError* error;
	
	if(existingClips.count == 0) {
		[album setImage:[self getThumb:url]];
	}
	
	[existingClips insertObject:clip atIndex:0];
	album.clips = [existingClips copy];
	
	if ([album save: &error]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"addClipToAlbum" object:nil];
		return YES;
	}else {
		return NO;
	}
}

- (UIImage *)getThumb:(NSString *)url{
	return [[YYImageCache sharedCache] getImageForKey:[[YYWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:url]]];
}

- (NSArray *)getAllAlbums {
	CBLView* view = [_database viewNamed: @"albums"];
	
	view.documentType = @"album";
	[view setMapBlock: MAPBLOCK({
		emit(doc[@"_id"], nil);
	}) version: @"3"];
	
	CBLQuery* query = [view createQuery];
	query.descending = YES;
	
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

- (CBLQuery *)queryAllAlbums {
	CBLView* view = [_database viewNamed: @"albums"];
	
	view.documentType = @"album";
	[view setMapBlock: MAPBLOCK({
		emit(doc[@"_id"], nil);
	}) version: @"3"];
	
	CBLQuery* query = [view createQuery];
	query.descending = YES;
	
	return query;
}

- (void)getAllDocument {
	CBLView* view = [_database viewNamed: @"phones"];
	
	view.documentType = @"album";
	[view setMapBlock: MAPBLOCK({
		emit(doc[@"type"], doc[@"title"]);
	}) version: @"3"];
	
	CBLQuery* query = [view createQuery];
	
	NSError *error;
	CBLQueryEnumerator* result = [query run: &error];
	for (CBLQueryRow* row in result) {
		NSLog(@"key = %@", row.key);
		NSLog(@"value = %@", row.value);
		
		CBLDocument *doc = row.document;
		Album *album = [Album modelForDocument:doc];
		NSLog(@"album's title = %@", album.title);
		NSLog(@"album's clips = %ld", album.clips.count);
		
		if(album.clips.count > 0) {
			NSEnumerator *list = album.clips.objectEnumerator;
			for (ArticleEntity *clip in list) {
				NSLog(@"clip's url = %@", clip.image);
				NSLog(@"clip's desc = %@", clip.desc);
			}
		}
	}
}

@end
