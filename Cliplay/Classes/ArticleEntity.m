//
//  ArticleEntity.m
//  Cliplay
//
//  Created by 邢磊 on 16/4/1.
//
//

#import "ArticleEntity.h"

@implementation ArticleEntity

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = super.init;
	if (self) {
		_desc = dictionary[@"desc"];
		_image = dictionary[@"url"];
	}
	return self;
}

@end



