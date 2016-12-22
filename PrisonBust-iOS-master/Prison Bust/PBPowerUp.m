//
//  PBPowerUp.m
//  Prison Bust
//
//  Created by Mac Admin on 4/24/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import "PBPowerUp.h"

@implementation PBPowerUp
+ (instancetype)powerUp {
    PBPowerUp *powerUpNode = [[PBPowerUp alloc]initWithImageNamed:@"powerup_float_1"];
    powerUpNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(1, 1)];
    powerUpNode.physicsBody.categoryBitMask  = powerUpCategory;
    powerUpNode.physicsBody.contactTestBitMask = playerCategory;
    powerUpNode.physicsBody.affectedByGravity = NO;
    powerUpNode.name = @"powerUp";
    powerUpNode.xScale = 0.35;
    powerUpNode.yScale = 0.4;
    return powerUpNode;
}

- (NSArray *)frames {
    NSMutableArray *frames = [NSMutableArray array];
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"powerUp"];
    for(int i = 0; i < atlas.textureNames.count; i++) {
        NSString *tempString = [NSString stringWithFormat:@"powerup_float_%d" , i + 1];
        SKTexture *tempTexture = [atlas textureNamed:tempString];
        if(tempTexture) {
            [frames addObject:tempTexture];
        }
    }
    return [NSArray arrayWithArray:frames];
}

- (void)floatPowerUp {
    [self runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:[self frames] timePerFrame:0.06]]];
    
}
@end
