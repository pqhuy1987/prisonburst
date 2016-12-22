//
//  PBObjectPool.h
//  Prison Bust
//
//  Created by Mac Admin on 7/1/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBObjectPool : NSObject


+ (instancetype) newPoolWithObjects:(NSArray *)objects andName:(NSString *)name;
- (void)addObjectToPool:(id)object;
- (id)objectFromPool;



@property (strong, readonly, nonatomic) NSArray *objectsInPool;
@property (strong, nonatomic) NSString *name;
@end
