//
//  ArticleEntity.h
//  Cliplay
//
//  Created by 邢磊 on 16/4/1.
//
//

#import <Foundation/Foundation.h>
@interface ArticleEntity : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithURL:(NSString *)url;
- (instancetype)initWithData:(NSString *)url desc:(NSString *)desc;

@property (nonatomic, copy, readonly) NSString *desc;
@property (nonatomic, copy, readonly) NSString *image;

@end