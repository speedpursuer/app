//
//  Client.m
//  Cliplay
//
//  Created by 邢磊 on 16/8/4.
//
//

#import "Client.h"

@implementation Client

@end

@implementation ClientModelRepository

+ (instancetype)repository {
	ClientModelRepository *repository = [self repositoryWithClassName:@"clients"];
	repository.modelClass = [Client class];
	return repository;
}

@end