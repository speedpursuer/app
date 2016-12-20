//
//  Album.m
//  Cliplay
//
//  Created by 邢磊 on 2016/11/3.
//
//

#import "Album.h"

@implementation Album

@dynamic clips;

+ (Album*) getAlbumInDatabase:(CBLDatabase*) database withTitle:(NSString *)title withUUID:(NSString *)uuid {
	
	NSString *docID = [NSString stringWithFormat:@"album_%@_%d", uuid, (int)[NSDate date].timeIntervalSinceReferenceDate];
	Album* album = [Album modelForDocument: database[docID]];
	
	album.type = AlbumModelType;
	album.uuid = uuid;
	album.title = title;
	
	return album;
}

-(void)setImage: (UIImage*)image {
	[self setAttachmentNamed:kTaskImageName withContentType:ImageDataContentType content:[self dataForImage:image]];
}

-(UIImage *)getImage {
	NSArray *attachments = [self attachmentNames];
	if ([attachments count] > 0) {
		CBLAttachment *attachment = [self attachmentNamed:[attachments objectAtIndex:0]];
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
- (NSData *)dataForImage:(UIImage *)image {
	return UIImageJPEGRepresentation(image, 0.1);
}

@end
