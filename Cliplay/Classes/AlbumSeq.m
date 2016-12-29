//
//  AlbumSeq.m
//  Cliplay
//
//  Created by 邢磊 on 2016/12/29.
//
//

#import "AlbumSeq.h"

@implementation AlbumSeq
@dynamic albumIDs;
+ (AlbumSeq*) getAlbumSeqInDatabase:(CBLDatabase*) database withUUID:(NSString *)uuid {
	NSString *docID = [NSString stringWithFormat:@"album_%@_seq", uuid];
	AlbumSeq* albumSeq = [AlbumSeq modelForDocument: database[docID]];
	albumSeq.type = AlbumSeqModelType;
	albumSeq.uuid = uuid;
	return albumSeq;
}
@end
