//
//  AlbumSeq.m
//  Cliplay
//
//  Created by 邢磊 on 2016/12/29.
//
//

#import "AlbumSeq.h"

#define kAlbumSeqDocType @"albumSeq"

@implementation AlbumSeq
@dynamic albumIDs;
+ (NSString*) docType {
	return kAlbumSeqDocType;
}

+ (NSString*) docID:(NSString *)uuid {
	return [NSString stringWithFormat:@"album_%@_seq", uuid];
}

+ (AlbumSeq*) getAlbumSeqInDatabase:(CBLDatabase*) database withUUID:(NSString *)uuid {
	AlbumSeq *albumSeq = (AlbumSeq *)[super getModelInDatabase:database withUUID:uuid];
	return albumSeq;
}
@end
