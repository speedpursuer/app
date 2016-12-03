//
//  Favorite.m
//  Cliplay
//
//  Created by 邢磊 on 2016/12/1.
//
//

#import "Favorite.h"

@implementation Favorite

@dynamic title, clips;

//+(Class)clipsItemClass {
//	return [NSString class];
//}

- (BOOL)isFavoriate:(NSString *)url {
	return ([self.clips indexOfObject:url] != NSNotFound);
}
- (void)setFavoriate:(NSString *)url {
	if(![self isFavoriate:url]) {
		NSMutableArray *list = [self.clips mutableCopy];
		[list insertObject:url atIndex: 0];
		self.clips = [list copy];
	}
}
- (void)unsetFavoriate:(NSString *)url {
	if([self isFavoriate:url]) {
		NSMutableArray *list = [self.clips mutableCopy];
		[list removeObject:url];
		self.clips = [list copy];
	}
}
@end
