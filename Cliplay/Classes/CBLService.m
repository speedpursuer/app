//
//  CBLService.m
//  Cliplay
//
//  Created by 邢磊 on 2016/11/23.
//
//

#import "CBLService.h"
#import <YYWebImage/YYWebImage.h>

@interface CBLService()
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
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString *applicationSupportDirectory = [paths firstObject];
	NSLog(@"applicationSupportDirectory: '%@'", applicationSupportDirectory);
	
	return self;
}

- (Album*)creatAlubmWithTitle:(NSString*)title {
	Album* album = [Album modelForNewDocumentInDatabase:_database];
	album.title = title;
	
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
	CBLDocument* doc = self.database[@"favorite"];
	Favorite *favorite = [Favorite modelForDocument: doc];
	favorite.autosaves = YES;
	if(favorite.isNew) {
		NSError *error;
		favorite.clips = @[];
		favorite.title = @"我的最爱";
		[favorite save:&error];
	}
	return favorite;
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

- (void)getAllDocument1 {
	CBLQuery* query = [_database createAllDocumentsQuery];
	
	NSError *error;
	CBLQueryEnumerator *myLists = [query run:&error];
	if (!myLists) {
		return;
	}
	
	NSLog(@"count of docs = %@", [NSNumber numberWithUnsignedInteger:[myLists count]]);
	
	for (CBLQueryRow* row in myLists) {
		
		CBLDocument *doc = row.document;
//		List* list = [List modelForDocument: row.document];
//		list.owner = owner;
//		if (![list save:error]) {
//			return;
//		}
	}
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
//		NSLog(@"album's type = %@", album.type);
		NSLog(@"album's clips = %ld", album.clips.count);
		
		if(album.clips.count > 0) {
			NSEnumerator *list = album.clips.objectEnumerator;
			for (ArticleEntity *clip in list) {
				NSLog(@"clip's url = %@", clip.image);
				NSLog(@"clip's desc = %@", clip.desc);
			}
		}
//		NSLog(@"album's type = %@", album.type);
	}
}

@end
