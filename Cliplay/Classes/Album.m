//
//  Album.m
//  Cliplay
//
//  Created by 邢磊 on 2016/11/3.
//
//

#import "Album.h"
//#import "CBLService.h"

@implementation Album

@dynamic title, clips;

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

-(nullable NSString*) idForNewDocumentInDatabase: (CBLDatabase*)db {
	return [NSString stringWithFormat:@"album_%@", [NSDate date].description];
}

+(Class)clipsItemClass {
	return [ArticleEntity class];
}

- (NSData *)dataForImage:(UIImage *)image {
	return UIImageJPEGRepresentation(image, 0.5);
}

@end
