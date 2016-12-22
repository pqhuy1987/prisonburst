//
//  PBMyScene+PBMyScene_Additions.m
//  Prison Bust
//
//  Created by Mac Admin on 5/15/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import "PBMyScene+PBMyScene_Additions.h"
#import "PBFence.h"
#import "PBMissle.h"
#import "PBPlayer.h"
#import "PBSpikePit.h"
#import "PBBomb.h"
#import "PBPowerUp.h"
#import "PBPlayer.h"    


@implementation PBMyScene (PBMyScene_Additions)
#pragma mark - enemy instances for enumeration

- (PBBomb *)bombInstance {
    PBBomb *bomb = [PBBomb bomb];
    bomb.position = CGPointMake(self.size.width + 100+ 700, 220);
    return bomb;
}

- (PBFence *)fenceInstance {
    PBFence *newFence = [[PBFence alloc]init];
    newFence.position = CGPointMake(self.size.width + 700, 218);
    newFence.xScale = .2;
    newFence.yScale = .25;
    newFence.hidden = NO;
    newFence.zPosition = 3.5;
    newFence.physicsBody.affectedByGravity = YES;
    return newFence;
}

- (PBMissle *)missileInstance {
    PBMissle *newMissile = [[PBMissle alloc]init];
    newMissile.position = CGPointMake(self.size.width + 200, 245);
    return newMissile;
}

- (PBSpikePit *)spikePitInstance {
    PBSpikePit *spikePit = [PBSpikePit new];
    spikePit.position = CGPointMake(self.size.width + 200+ 700, 210);
    return spikePit;
}

- (PBPowerUp *)powerUpInstance {
    PBPowerUp *powerUp = [PBPowerUp powerUp];
    [powerUp floatPowerUp];
    powerUp.position = CGPointMake(self.size.width + 200+ 700, 220);
    powerUp.zPosition = 4;
    return powerUp;
}

- (PBPlayer *)playerInstance {
    PBPlayer *player = [[PBPlayer alloc]init];
    player.position = CGPointMake(self.size.width/3.5, 230);
    return player;
}

#pragma mark - colliders on the edges

- (SKNode *)bottomCollider {
    SKNode *bottomCollider = [SKNode node];
    bottomCollider.position = CGPointMake(0, 0);
    bottomCollider.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(0, 210) toPoint:CGPointMake(self.size.width, 210)];
    bottomCollider.physicsBody.dynamic = YES;
    bottomCollider.name = @"bottom collider";
    bottomCollider.physicsBody.categoryBitMask = groundBitMask;
    return bottomCollider;
}

#pragma mark - death state convienience methods

- (SKAction *)explosionSpritesAtLocation:(CGPoint)location {
    
    SKAction *action = [SKAction runBlock:^{
        [self enumerateChildNodesWithName:@"bodyPart" usingBlock:^(SKNode *node, BOOL *stop) {
            node.position = location;
            node.hidden = NO;
            node.physicsBody.affectedByGravity = YES;
            node.physicsBody.allowsRotation = NO;
            node.physicsBody.mass = 1;
            [node runAction:[SKAction colorizeWithColor:[UIColor blackColor] colorBlendFactor:0.5 duration:6.0]];
            int randX = (arc4random() % 150) - 50;
            int randY = (arc4random() % 450);
            node.zPosition = 4;
            [node.physicsBody applyImpulse:CGVectorMake(randX, randY)];
        }];
    }];
    return action;
}

#pragma mark - smoke emitters for death states (rocket)

- (SKEmitterNode *)smokeEmitter {
    SKEmitterNode *smokeEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"Smoke" ofType:@"sks"]];
    
    return smokeEmitter;
}

- (SKEmitterNode *)smokeForBodyParts {
    SKEmitterNode *smokeEmitter = [self particleEmitterWithName:@"TEMP"];
    return smokeEmitter;
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

- (void)loadPlayerExplosionSprites {
    for(int i = 1; i < 7; i++) {
        SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"blown_up_%d" , i]];
        node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(5, 5)];
        node.physicsBody.categoryBitMask = nilBitMask;
        node.physicsBody.collisionBitMask = groundBitMask;
        node.xScale = 0.2;
        node.yScale = 0.2;
        node.hidden = YES;
        node.zPosition = 3;
        node.physicsBody.mass = 10;
        node.physicsBody.affectedByGravity = NO;
        node.physicsBody.dynamic = YES;
        node.position = CGPointMake(self.size.width/2, self.size.height/2);
        node.name = @"bodyPart";
        
        [node addChild:[self smokeForBodyParts]];
        [self addChild:node];
    }
}

+ (NSString *)dateToString:(NSDate *)date {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.timeStyle = NSDateFormatterShortStyle;
    dateFormat.dateStyle = NSDateFormatterShortStyle;
    NSString *dateString = [dateFormat stringFromDate:date];
    return dateString;
}

#pragma mark - background music
//#pragma mark - handling in-game music - change resource name
//- (void)setUpMusicAndPlay {
//    NSString *musicPath = [[NSBundle mainBundle]pathForResource:@"musicFile" ofType:@"mp3"];
//    self.musicPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:musicPath] error:NULL];
//    self.musicPlayer.numberOfLoops = -1;
//    self.musicPlayer.volume = 1.0;
//    [self.musicPlayer prepareToPlay];
//    [self.musicPlayer play];
//}
//
//


@end
