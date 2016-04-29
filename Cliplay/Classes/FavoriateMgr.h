//
//  FavoriateMgr.h
//  Cliplay
//
//  Created by 邢磊 on 16/4/29.
//
//

#import <Foundation/Foundation.h>

@interface FavoriateMgr : NSObject
{
	NSMutableArray *images;
}

+ (id)sharedInstance;
- (void)setFavoriate:(NSString *)url;
- (void)unsetFavoriate:(NSString *)url;
- (BOOL)isFavoriate:(NSString *)url;

@end

