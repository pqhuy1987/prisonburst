//
//  PBObjectPool.m
//  Prison Bust
//
//  Created by Mac Admin on 7/1/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import "PBObjectPool.h"

@interface PBObjectPool ()
@property (strong, readwrite, nonatomic) NSArray *objectsInPool;

@end

@implementation PBObjectPool


+ (instancetype)newPoolWithObjects:(NSArray *)objects andName:(NSString *)name {
    PBObjectPool *objPool = [PBObjectPool new];
    objPool.name = name;
    objPool.objectsInPool = objects;
    
    return objPool;
}

- (void)addObjectToPool:(id)object {
    if(object) {
        NSMutableArray *arr = [NSMutableArray arrayWithArray:self.objectsInPool];
        [arr addObject:object];
        self.objectsInPool = [NSArray arrayWithArray:arr];
    }
}

- (id)objectFromPool {
    if(self.objectsInPool.count < 1) {
        NSLog(@"problems maintaining obj pool");
    } else if(self.objectsInPool.count > 5) {
        NSLog(@"still a prob");
    }
    return [[self.objectsInPool objectAtIndex:[self.objectsInPool count] - 1]copy];
   // return [self.objectsInPool lastObject];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"object Pool Name: %@ objects: %@" , self.name , self.objectsInPool];
}

@end
