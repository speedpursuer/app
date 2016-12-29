//
//  Album.m
//  Cliplay
//
//  Created by 邢磊 on 2016/11/3.
//
//

#import "Album.h"

@implementation Album

@dynamic clips, desc;

+ (Album*) getAlbumInDatabase:(CBLDatabase*) database withTitle:(NSString *)title withUUID:(NSString *)uuid {
	
	NSString *docID = [NSString stringWithFormat:@"album_%@_%d", uuid, (int)[NSDate date].timeIntervalSinceReferenceDate];
	Album* album = [Album modelForDocument: database[docID]];
	
	album.type = AlbumModelType;
	album.uuid = uuid;
	album.title = title;
	album.desc = @"";
	
	return album;
}

-(void)setThumb: (UIImage*)image {
	[self setAttachmentNamed:kTaskImageName withContentType:ImageDataContentType content:[self dataForThumb:image]];
}

-(void)removeThumb {
	[self removeAttachmentNamed:kTaskImageName];
}

-(UIImage *)getThumb {
	NSArray *attachments = [self attachmentNames];
	if ([attachments count] > 0) {
		CBLAttachment *attachment = [self attachmentNamed:kTaskImageName];
		UIImage *attachedImage = [UIImage imageWithData:attachment.content];
		return attachedImage;
	} else {
		return nil;
	}
}

//-(nullable NSString*) idForNewDocumentInDatabase: (CBLDatabase*)db {
//	return [NSString stringWithFormat:@"album_%@_%d", [FCUUID uuidForDevice], (int)[NSDate date].timeIntervalSinceReferenceDate];
//}


+(Class)clipsItemClass {
	return [ArticleEntity class];
}

//With image quality decreased
- (NSData *)dataForThumb:(UIImage *)image {
	return UIImageJPEGRepresentation(image, 0.1);
}

@end
