//
//  Album.h
//  Cliplay
//
//  Created by 邢磊 on 2016/11/3.
//
//

#import <Foundation/Foundation.h>
#import <CouchbaseLite/CouchbaseLite.h>
#import "ArticleEntity.h"

#define kTaskImageName @"image"
#define ImageDataContentType @"image/jpg"

@interface Album : CBLModel

@property NSString *title;

@property NSArray *clips;

-(void)setImage: (UIImage*)image;
-(UIImage *)getImage;
@end
