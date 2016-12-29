//
//  AlbumSeq.h
//  Cliplay
//
//  Created by 邢磊 on 2016/12/29.
//
//

#import "CBLBaseModel.h"
#define AlbumSeqModelType @"albumSeq"
@interface AlbumSeq : CBLBaseModel
@property (readwrite) NSArray *albumIDs;
+ (AlbumSeq*) getAlbumSeqInDatabase:(CBLDatabase*) database withUUID:(NSString *)uuid;
@end
