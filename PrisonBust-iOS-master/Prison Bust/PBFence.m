//
//  PBFence.m
//  Prison Bust
//
//  Created by Mac Admin on 4/24/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//


#import "PBFence.h"


static NSArray *fenceAFrames = nil;
static NSArray *fenceBFrames = nil;
static NSArray *framesForContact = nil;
static SKEmitterNode *sparksDoe = nil;

@interface PBFence()
@property (strong, nonatomic) SKEmitterNode *sparksEmitter;
@end
@implementation PBFence
- (id)init {
    if(self = [super initWithImageNamed:@"electricFence.png"]) {
        [self loadEmitter];
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(140, 150)];
        self.physicsBody.categoryBitMask = enemyCategory;
        self.xScale = 2.0;
        self.physicsBody.dynamic = NO;
        self.enemyType = enemyTypeFence;
        self.name = fenceIdentifier;
        [self addChild:[sparksDoe copy]];
        
        [self loadDeathAnimationImages];
        [self loadFenceBreakFrames];
        [self addFenceBreakChildren];

        
        
    }
    return self;
}

- (void)loadEmitter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SKEmitterNode *sparks = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle]pathForResource:@"Spark" ofType:@"sks"]];
        sparks.position = CGPointMake(0, 90);
        sparks.name = @"sparksEmitter";
        [sparks runAction:[SKAction rotateToAngle:-0.25 duration:0]];
        sparks.physicsBody.collisionBitMask = 32;
        sparksDoe = sparks;
        
    });
}


- (void)loadDeathAnimationImages {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *arr = [NSMutableArray array];
        SKTextureAtlas *deathAtlas = [SKTextureAtlas atlasNamed:@"FenceDeathAnimation"];
        for(int i = 0; i < deathAtlas.textureNames.count; i++) {
            NSString *tempName = [NSString stringWithFormat:@"Electro_%d" , i + 1];
            SKTexture *tempTexture = [deathAtlas textureNamed:tempName];
            if(tempTexture) {
                [arr addObject:tempTexture];
            }
        }
        framesForContact = arr;
    });
}




- (SKAction *)deathAnimation {
    SKAction *playSound = [SKAction playSoundFileNamed:@"StaticTrimmedAudio.mp3" waitForCompletion:NO];
    SKAction *deathFrames = [SKAction repeatAction:[SKAction animateWithTextures:framesForContact timePerFrame:0.05] count:20];
    return [SKAction group:@[playSound, deathFrames]];
}

- (id)copyWithZone:(NSZone *)zone {
    PBFence *newFence = [[PBFence alloc]init];
    newFence.position = CGPointMake(self.size.width + 700, 218);
    newFence.xScale = .2;
    newFence.yScale = .25;
    newFence.hidden = NO;
    newFence.zPosition = 3.5;
    newFence.physicsBody.affectedByGravity = YES;
    return newFence;
}


- (void) breakFence {
    self.texture = nil;
    [self enumerateChildNodesWithName:@"sparksEmitter" usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
    }];
    [self animateFenceBreak];
    
}




- (void)loadFenceBreakFrames {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *framesA = [NSMutableArray array];
        SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"fenceANew"];
        for (int i = 0; i < atlas.textureNames.count; i++) {
            NSString *tempString = [NSString stringWithFormat:@"fence_break_%dA" , i+1];
            SKTexture *tempTexture = [atlas textureNamed:tempString];
            if(tempTexture) {
                [framesA addObject:tempTexture];
            }
        }
        fenceAFrames = framesA;
        
        NSMutableArray *framesB = [NSMutableArray array];
        SKTextureAtlas *atlasB = [SKTextureAtlas atlasNamed:@"fenceB"];
        for (int i = 0; i < atlasB.textureNames.count; i++) {
            NSString *tempString = [NSString stringWithFormat:@"fence_break_%dB" , i+1];
            SKTexture *tempTexture = [atlasB textureNamed:tempString];
            if(tempTexture) {
                [framesB addObject:tempTexture];
            }
        }
        fenceBFrames = framesB;
    });
}

- (void)addFenceBreakChildren {
    SKSpriteNode *fencePartA = [SKSpriteNode spriteNodeWithImageNamed:@"fence_break_1A"];
    fencePartA.name = @"FenceA";
    fencePartA.position = CGPointMake(0, 45);
    fencePartA.hidden = YES;
    fencePartA.xScale = 0.9;
    fencePartA.yScale = 0.9;
    fencePartA.zPosition = 3.9;
    [self addChild:fencePartA];

    SKSpriteNode *fencePartB = [SKSpriteNode spriteNodeWithImageNamed:@"fence_break_1B"];
    fencePartB.name = @"FenceB";
    fencePartB.xScale = 0.9;
    fencePartB.yScale = 0.9;
    fencePartB.position = CGPointMake(fencePartB.size.width/2 + 20, -30);
    fencePartB.hidden = YES;
    fencePartB.zPosition = 4.1;
    
    [self addChild:fencePartB];
    
    NSLog(@"breaking fence created");
}

- (void)animateFenceBreak {
    [self animateFencePartA];
    [self animateFencePartB];
}

- (void) animateFencePartA {
    [self enumerateChildNodesWithName:@"FenceA" usingBlock:^(SKNode *node, BOOL *stop) {
        node.hidden = NO;
        [node runAction: [SKAction animateWithTextures:fenceAFrames timePerFrame:0.015 resize:NO restore:NO]];
    }];
    NSLog(@"part a destroyed");
}

- (void )animateFencePartB {
    [self enumerateChildNodesWithName:@"FenceB" usingBlock:^(SKNode *node, BOOL *stop) {
        node.hidden = NO;
        [node runAction:[SKAction animateWithTextures:fenceBFrames timePerFrame:0.02 resize:NO restore:NO]];
    }];
    NSLog(@"part b destroyed");
}


@end



