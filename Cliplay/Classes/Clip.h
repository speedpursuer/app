//
//  Clip.h
//  Cliplay
//
//  Created by 邢磊 on 2016/11/28.
//
//

#import <CouchbaseLite/CouchbaseLite.h>

@interface Clip : CBLModel

@property (readwrite) NSString* desc;

@property (readwrite) NSString* url;

@end
