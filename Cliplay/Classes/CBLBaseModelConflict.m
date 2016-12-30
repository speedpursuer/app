//
//  CBLBaseModelConflict.m
//  Cliplay
//
//  Created by 邢磊 on 2016/12/30.
//
//

#import "CBLBaseModelConflict.h"

@implementation CBLBaseModelConflict
@dynamic isFromLocal;
- (void)awakeFromInitializer{
	[super awakeFromInitializer];
	self.isFromLocal = YES;
}
@end
