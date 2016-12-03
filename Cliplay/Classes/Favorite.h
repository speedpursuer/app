//
//  Favorite.h
//  Cliplay
//
//  Created by 邢磊 on 2016/12/1.
//
//

#import <CouchbaseLite/CouchbaseLite.h>

@interface Favorite : CBLModel
@property NSString *title;
@property NSArray *clips;
- (BOOL)isFavoriate:(NSString *)url;
- (void)setFavoriate:(NSString *)url;
- (void)unsetFavoriate:(NSString *)url;
@end
