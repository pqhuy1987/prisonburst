//
//  PBBomb.m
//  Prison Bust
//
//  Created by Mac Admin on 6/22/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import "PBBomb.h"
#import "PBMissle.h"

static SKEmitterNode *smokeForBomb = nil;
static NSArray *movementFrames = nil;

@interface PBBomb ()
@property (nonatomic, strong) NSArray *contactFrames;
@end
@implementation PBBomb {
    BOOL _blownUp;
}

- (instancetype)init {
    if(self = [super init]) {
        [self smokeEmitter];
        self.contactFrames = [self setUpMovementFrames];

    }
    return self;
}

+ (instancetype)bomb {
    PBBomb *bomb = [PBBomb new];
    bomb.zPosition = 4;
    bomb.size = CGSizeMake(100, 100);
    bomb.name = @"bomb";
    bomb.physicsBody = [PBBomb bombPhysicsBody];
    
    [bomb addChild:[smokeForBomb copy]];
    bomb.xScale = 0.7;
    bomb.yScale = 0.7;
    bomb.enemyType = enemyTypeBomb;

    SKAction *animateFrames = [SKAction animateWithTextures:bomb.contactFrames timePerFrame:0.03 resize:YES restore:NO];
    SKAction *forever = [SKAction repeatActionForever:animateFrames];
    [bomb runAction:forever];
    return bomb;
}

- (void)executeDeathAnimation {
    PBMissle *missile = [PBMissle new];
    SKAction *blowUp = [missile deathAnimationForInvulnerability];
    [self enumerateChildNodesWithName:@"Smoke" usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
    }];
    [self runAction:blowUp completion:^{
        [self removeFromParent];
        _blownUp = YES;
        
    }];
}


- (NSArray *)setUpMovementFrames {
    dispatch_queue_t background = dispatch_queue_create("secondaryQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_sync(background, ^{
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSMutableArray *temp = [NSMutableArray array];
            SKTextureAtlas *bombAtlas = [SKTextureAtlas atlasNamed:@"bombFramesSmall"];
            for(int i = 25; i < bombAtlas.textureNames.count; i++) {
                NSString *tempName;
                if(i < 10) {
                    tempName = [NSString stringWithFormat:@"bomb.00%d.png" , i];
                } else if(i >= 10) {
                    tempName = [NSString stringWithFormat:@"bomb.0%d.png" , i];
                }
                SKTexture *texture = [bombAtlas textureNamed:tempName];
                if(texture) {
                    [temp addObject:texture];
                }
            }
            movementFrames = temp;
        });
    });
    return movementFrames;
}
- (SKEmitterNode *)particleEmitterWithName:(NSString *)name {
    NSString *path = [[NSBundle mainBundle]pathForResource:name ofType:@"sks"];
    NSData *sceneData = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
    NSKeyedUnarchiver *archiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:sceneData];
    [archiver setClass:[SKEmitterNode class] forClassName:@"SKEditorScene"];
    id node = [archiver decodeObjectForKey:(NSKeyedArchiveRootObjectKey)];
    [archiver finishDecoding];
    return node;
}




- (void) smokeEmitter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SKEmitterNode *emitter = [self particleEmitterWithName:@"Smoke"];
        emitter.particleSize = CGSizeMake(1, 1);
        emitter.particleBirthRate = 10;
        emitter.particleColor = [UIColor blackColor];
        emitter.particleLifetime = 10;
        emitter.xScale = 0.5;
        emitter.yScale = 0.5;
        emitter.physicsBody.categoryBitMask = 0x1 << 5;;
        
        CGPathRef circle = CGPathCreateWithEllipseInRect(CGRectMake(-50,-50,80,80), NULL);
        SKAction *followTrack = [SKAction followPath:circle asOffset:NO orientToPath:YES duration:2.0];
        SKAction *forever = [SKAction repeatActionForever:followTrack];
        emitter.particleAction = forever;
        emitter.name = @"smokeEmitter";
        emitter.position = CGPointMake(0, 0);
        smokeForBomb = emitter;
    
    });
}

+ (SKPhysicsBody *)bombPhysicsBody {
    SKPhysicsBody *bombPhysicsBody = [SKPhysicsBody bodyWithCircleOfRadius:20];
    bombPhysicsBody.categoryBitMask = enemyCategory;
    bombPhysicsBody.contactTestBitMask = playerCategory;
    bombPhysicsBody.collisionBitMask = groundBitMask;
    bombPhysicsBody.affectedByGravity = YES;
    bombPhysicsBody.allowsRotation = NO;
    bombPhysicsBody.dynamic = YES;
    bombPhysicsBody.mass = 1;
    return bombPhysicsBody;
}

- (id)copyWithZone:(NSZone *)zone {
    PBBomb *bomb = [PBBomb bomb];
    bomb.position = CGPointMake(1120, 220);
    return bomb;
}
@end
