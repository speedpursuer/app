//
//  Album.h
//  Cliplay
//
//  Created by 邢磊 on 2016/11/3.
//
//

#import <Foundation/Foundation.h>
#import "CBLBaseModel.h"
#import "ArticleEntity.h"

#define kTaskImageName @"image"
#define AlbumModelType @"album"
#define ImageDataContentType @"image/jpg"

@interface Album : CBLBaseModel

@property NSArray *clips;
+ (Album*) getAlbumInDatabase:(CBLDatabase*) database withTitle:(NSString *)title withUUID:(NSString *)uuid;
-(void)setImage: (UIImage*)image;
-(UIImage *)getImage;
@end
