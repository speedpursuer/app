//
//  Favorite.m
//  Cliplay
//
//  Created by 邢磊 on 2016/12/1.
//
//

#import "Favorite.h"

@implementation Favorite

@dynamic clips;


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

+ (Favorite*) getFavoriteInDatabase:(CBLDatabase*) database withUUID:(NSString *)uuid {
	
	NSString *docID = [NSString stringWithFormat:@"favorite_%@", uuid];
	Favorite* favorite = [Favorite modelForDocument: database[docID]];
	
	favorite.uuid = uuid;
	favorite.autosaves = YES;
	
	if(favorite.isNew) {
		NSError *error;
		favorite.clips = @[];
		favorite.title = @"我的最爱";
		[favorite save:&error];
	}

	return favorite;
}

@end
