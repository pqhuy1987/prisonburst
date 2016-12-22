//
//  PBMissle.m
//  Prison Bust
//
//  Created by Mac Admin on 4/24/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import "PBMissle.h"

static SKEmitterNode *fireEmitter = nil;
static NSArray *framesForContact = nil;
static NSArray *missileSpinFrames = nil;

@implementation PBMissle {
    BOOL _blownUp;
}
- (id)init{
    if(self = [super initWithImageNamed:@"rocket.png"]) {
        self.enemyType = enemyTypeMissle;
        self.name = missileIdentifier;
        [self setUpFrames];
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(25, 10)];
        self.physicsBody.categoryBitMask = enemyCategory;
        self.physicsBody.affectedByGravity = NO;
        self.zPosition = 4;
        self.physicsBody.usesPreciseCollisionDetection = NO;
        self.xScale = 1.3;
        self.yScale = 1.3;
        [self fireEmitterSetup];

        [self addChild:[fireEmitter copy]];
        [self spinMissile];
    }
    return self;
}

- (SKAction *)deathAnimation {
    _blownUp = YES;
    SKAction *scaleUp = [SKAction scaleBy:3.0 duration:.2];
    return [SKAction group:@[scaleUp , [SKAction animateWithTextures:framesForContact timePerFrame:0.03 resize:YES restore:YES] , [SKAction fadeOutWithDuration:1.5]]];
}

- (SKAction *)deathAnimationForInvulnerability {
    SKAction *scaleUp = [SKAction scaleBy:2.0 duration:.2];

    return [SKAction group:@[scaleUp , [SKAction animateWithTextures:framesForContact  timePerFrame:0.03 resize:YES restore:YES] , [SKAction fadeOutWithDuration:0.7]]];
}

- (void)setUpFrames {
    dispatch_queue_t background = dispatch_queue_create("secondaryQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_sync(background, ^{
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSMutableArray *frames = [NSMutableArray array];
            SKTextureAtlas *missileAtlas = [SKTextureAtlas atlasNamed:@"missileExplosionV02"];
            for(int i = 1; i < missileAtlas.textureNames.count -1; i++) {
                NSString *tempName;
                if(i <= 9) {
                    tempName = [NSString stringWithFormat:@"explosion.00%i.png" , i];
                } else if(i < 100 && i > 9) {
                    tempName = [NSString stringWithFormat:@"explosion.0%i.png" , i];
                } else {
                    tempName = [NSString stringWithFormat:@"explosion.%i.png" , i];
                }
                
                SKTexture *tempTexture = [missileAtlas textureNamed:tempName];
                
                if(tempTexture) {
                    [frames addObject:tempTexture];
                } else {
                    
                }
            }
            framesForContact = frames;
        });
    });


}

- (void)spinMissile {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *spinningMissile = [NSMutableArray new];
        SKTextureAtlas *missileSpin = [SKTextureAtlas atlasNamed:@"rocketSpinV02"];
        for(int i = 30; i < missileSpin.textureNames.count; i++) {
            NSString *tempName = [NSString stringWithFormat:@"rocket.%d.png" , i];
            SKTexture *tempText = [missileSpin textureNamed:tempName];
            if(tempText) {
                [spinningMissile addObject:tempText];
            }
        }
        missileSpinFrames = spinningMissile;
    });

    SKAction *missileSpinAction = [SKAction animateWithTextures:missileSpinFrames timePerFrame:0.025 resize:NO restore:NO];
    SKAction *spinForever = [SKAction repeatActionForever:missileSpinAction];
    [self runAction:spinForever];
}

- (void)fireEmitterSetup {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SKEmitterNode *fireFlames =  [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource: @"FireEmitterForMissle" ofType:@"sks"]];
        fireFlames.position = CGPointMake(20,0);
        fireFlames.name = @"fireEmitter";
        fireEmitter = fireFlames;
    });
}

- (id)copyWithZone:(NSZone *)zone {
    PBMissle *newMis = [PBMissle new];
    newMis.position = CGPointMake(self.size.width + 200 + 200, 245);
    if(newMis.parent) {
        [newMis removeFromParent];
        NSLog(@"possible threading issues");
    }

    return newMis;
}
@end
