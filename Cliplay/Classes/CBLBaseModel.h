//
//  CBLBaseModel.h
//  Cliplay
//
//  Created by 邢磊 on 2016/12/13.
//
//

#import <CouchbaseLite/CouchbaseLite.h>

@interface CBLBaseModel : CBLModel
@property NSString *owner;
@property NSString *title;
@property NSString *uuid;
//@property NSString *idPrefix;
@end
