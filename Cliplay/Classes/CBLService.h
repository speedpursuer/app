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

#define kDBName @"cliplay"
#define kStorageType kCBLForestDBStorage
#define kDidSynced @"didSynced"

@interface CBLService : NSObject
@property (strong, nonatomic, readonly) CBLDatabase *database;
@property (strong, nonatomic, readonly) Favorite *favorite;
+ (id)sharedManager;
- (NSArray *)getAllAlbums;
- (Album *)creatAlubmWithTitle:(NSString*)title;
- (BOOL)deleteAlbum:(Album *)album;
- (BOOL)addClip:(NSString *)url toAlum:(Album *)album withDesc:(NSString *)desc;
- (BOOL)isFavoriate:(NSString *)url;
- (void)setFavoriate:(NSString *)url;
- (void)unsetFavoriate:(NSString *)url;

//- (BOOL)getAllDocument;
- (CBLQuery *)queryAllAlbums;
- (void)syncToRemote;
- (void)syncFromRemote;
@end
