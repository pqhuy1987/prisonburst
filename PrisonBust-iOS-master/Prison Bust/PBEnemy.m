//
//  PBEnemy.m
//  Prison Bust
//
//  Created by Mac Admin on 4/24/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import "PBEnemy.h"

static NSInteger enemyZPosition = 4;

@implementation PBEnemy
- (instancetype)init {
    if(self = [super init]) {
        self.name = @"EnemyNode";
       // self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.frame.size];
        self.physicsBody.categoryBitMask = enemyCategory;
       // self.physicsBody.contactTestBitMask = playerCategory;
        self.enemyType = enemyTypeDefault;
        self.zPosition = enemyZPosition;
        self.physicsBody.allowsRotation = NO;
        self.physicsBody.dynamic = YES;
    }
    return self;
}

+ (instancetype)enemyWithType:(enemyType)enemyType {
    PBEnemy *enemy = [PBEnemy new];
    enemy.enemyType = enemyType;
    return enemy;
}

- (void)executeDeathAnimation {
    NSLog(@"this is an abstract method");
}

@end
