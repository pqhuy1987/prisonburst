//
//  PBSpikePit.m
//  Prison Bust
//
//  Created by Mac Admin on 5/29/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import "PBSpikePit.h"


static NSArray *framesForContact = nil;
static NSString *spikeImageName = @"spike_pit";
@interface PBSpikePit ()
@property (nonatomic, strong) NSMutableArray *spikePitDeathFrames;
@end
@implementation PBSpikePit {
    BOOL _deathDispatched;
}
- (id)init {
    if(self = [super initWithImageNamed:spikeImageName]) {
        self.enemyType = enemyTypeSpikePit;
        self.name = spikePitIdentifier;
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(170, 50)];
        self.physicsBody.categoryBitMask = enemyCategory;
        self.physicsBody.affectedByGravity = NO;
        self.physicsBody.dynamic = NO;
        self.zPosition = 3.5;
        self.xScale = 0.35;
        self.yScale = 0.3;
        
        SKSpriteNode *bottomHalfNode = [[SKSpriteNode alloc]initWithImageNamed:@"spikepit_front"];
        bottomHalfNode.zPosition = 4.5;
        bottomHalfNode.position = CGPointMake(4, -15);
        [self addChild:bottomHalfNode];
        _deathDispatched = NO;
        [self setUpContactFrames];
    }
    return self;
}


- (SKAction *)deathAnimation {
    if(!_deathDispatched) {
        SKAction *playSound = [SKAction playSoundFileNamed:@"blood_splat.mp3" waitForCompletion:NO];
        SKAction *spikePitDeathFrames = [SKAction animateWithTextures:framesForContact timePerFrame:0.1 resize:YES restore:NO];
        SKAction *deathAnimation = [SKAction sequence:@[spikePitDeathFrames , [SKAction setTexture:[framesForContact lastObject]]]];
        _deathDispatched = YES;
        return [SKAction group:@[deathAnimation , playSound]];
    }
    return nil;
}

- (void)setUpContactFrames {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *frames = [NSMutableArray array];
        SKTextureAtlas *spikePitAtlas = [SKTextureAtlas atlasNamed:@"pitDeathFrames"];
        for(int i = 0; i < spikePitAtlas.textureNames.count; i++) {
            NSString *tempName = [NSString stringWithFormat:@"pit_death_%d" , i + 1];
            SKTexture *tempTexture = [spikePitAtlas textureNamed:tempName];
            if(tempTexture) {
                [frames addObject:tempTexture];
            }
        }
        framesForContact = frames;
    });
}

- (id)copyWithZone:(NSZone *)zone {
    PBSpikePit *newPit = [[PBSpikePit alloc]init];
    newPit.position = CGPointMake(self.size.width + 200 + 200, 210);
    if(newPit.parent) {
        [newPit removeFromParent];
        NSLog(@"possible threading issues: spikePit");
    }
    return newPit;
}
@end
