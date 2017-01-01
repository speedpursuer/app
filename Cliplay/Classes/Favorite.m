//
//  Favorite.m
//  Cliplay
//
//  Created by 邢磊 on 2016/12/1.
//
//

#import "Favorite.h"

#define kFavoriteDocType @"favorite"

@implementation Favorite

@dynamic clips;

+ (NSString*) docType {
	return kFavoriteDocType;
}

+ (NSString*) docID:(NSString *)uuid {
	return [NSString stringWithFormat:@"favorite_%@", uuid];
}

+ (Favorite*) getFavoriteInDatabase:(CBLDatabase*) database withUUID:(NSString *)uuid {	
	Favorite *favorite = (Favorite *)[super getModelInDatabase:database withUUID:uuid];
	return favorite;
}

//Object initialization
- (void)awakeFromInitializer{
	[super awakeFromInitializer];
//	self.autosaves = YES;
	if(self.isNew) {
		self.clips = @[];
		self.title = @"我的最爱";
//		NSError *error;
//		[self save:&error];
	}
}

- (BOOL)isFavoriate:(NSString *)url {
	return ([self.clips indexOfObject:url] != NSNotFound);
}

- (void)setFavoriate:(NSString *)url {
	if(![self isFavoriate:url]) {
		NSMutableArray *list = [self.clips mutableCopy];
		[list insertObject:url atIndex: 0];
		self.clips = [list copy];
		NSError* error;
		[self save: &error];
	}
}

- (void)unsetFavoriate:(NSString *)url {
	if([self isFavoriate:url]) {
		NSMutableArray *list = [self.clips mutableCopy];
		[list removeObject:url];
		self.clips = [list copy];
		NSError* error;
		[self save: &error];
	}
}

@end
