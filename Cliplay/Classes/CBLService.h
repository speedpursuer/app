//
//  CBLService.h
//  Cliplay
//
//  Created by 邢磊 on 2016/11/23.
//
//

#import <Foundation/Foundation.h>
#import <CouchbaseLite/CouchbaseLite.h>
#import "Album.h"
#import "Favorite.h"
#import "AlbumSeq.h"

#define kDBName @"cliplay"
#define kStorageType kCBLForestDBStorage
#define kDidSynced @"didSynced"
#define kAlbumListChange @"albumModified"

@interface CBLService : NSObject
@property (strong, nonatomic, readonly) CBLDatabase *database;
@property (strong, nonatomic, readonly) Favorite *favorite;
@property (strong, nonatomic, readonly) AlbumSeq *albumSeq;
+ (id)sharedManager;

#pragma mark - Album
- (Album *)creatAlubmWithTitle:(NSString*)title;
- (BOOL)deleteAlbum:(Album *)album;
- (BOOL)addClip:(NSString *)url toAlum:(Album *)album withDesc:(NSString *)desc;
- (BOOL)addClips:(NSArray *)urls toAlum:(Album *)album;
- (BOOL)modifyClipDesc:(NSString *)newDesc withIndex:(NSInteger)index forAlbum:(Album *)album;
- (BOOL)updateAlbumInfo:(NSString *)newTitle withDesc:(NSString *)newDesc forAlbum:(Album *)album;
- (BOOL)deleteClipWithIndex: (NSInteger)index forAlbum:(Album *)album;
- (NSArray *)getAllAlbums;

#pragma mark - Album order
- (BOOL)saveAlbumSeq:(NSArray *)albumIDs;

#pragma mark - Favorite
- (BOOL)isFavoriate:(NSString *)url;
- (void)setFavoriate:(NSString *)url;
- (void)unsetFavoriate:(NSString *)url;

#pragma mark - Sync
- (void)syncToRemote;
- (void)syncFromRemote;
- (BOOL)didSyced;

#pragma mark - for test
- (void)getAllDocument;
- (CBLQuery *)queryAllAlbums;
@end
