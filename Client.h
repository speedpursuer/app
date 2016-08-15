//
//  Client.h
//  Cliplay
//
//  Created by 邢磊 on 16/8/4.
//
//

#import <Foundation/Foundation.h>
#import "LoopBack.h"

@interface Client : LBModel
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *avatar;
@end

@interface ClientModelRepository : LBModelRepository
+ (instancetype)repository;
@end

