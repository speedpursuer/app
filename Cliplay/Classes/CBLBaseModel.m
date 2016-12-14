//
//  CBLBaseModel.m
//  Cliplay
//
//  Created by 邢磊 on 2016/12/13.
//
//

#import "CBLBaseModel.h"

@implementation CBLBaseModel
@dynamic owner, title;
@synthesize uuid;

- (void) willSave: (nullable NSSet*)changedPropertyNames {
	if(self.isNew) {
		self.owner = [NSString stringWithFormat:@"user_%@", uuid];
	}
}

@end
