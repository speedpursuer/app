//
//  AppSettings+Cliplay.h
//  Cliplay
//
//  Created by 邢磊 on 2016/9/23.
//
//

#import <AppSettings/AppSettings.h>

@interface AppSettings (Cliplay)
@property (nonatomic, strong) NSString *postID;
+ (id)loadWithDefault;
@end
