//
//  PBPlayer.m
//  Prison Bust
//
//  Created by Mac Admin on 4/23/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import "PBPlayer.h"
#import "PBFence.h"
#import "PBMissle.h"
#import "PBBomb.h"
#import "PBSpikePit.h"

static NSInteger playerMass = 50;
static NSInteger playerZPosition = 4;
static NSString *characterImageName = @"prison_break_character_RUN_PLACEHOLDER";

static NSArray *runningFrames = nil;
static NSArray *jumpingFrames = nil;
static NSArray *slidingFrames = nil;
static NSArray *invulnerableRunFrames = nil;


@interface PBPlayer()


//invulnerable transformations
@property (strong, nonatomic) NSMutableArray *regToInvulnerable;
@property (strong, nonatomic) NSMutableArray *invulnerableToReg;

//for death animations
@property (strong, nonatomic) PBBomb *bomb;
@property (strong, nonatomic) PBFence *fence;
@property (strong, nonatomic) PBSpikePit *spikePit;
@property (strong, nonatomic) PBMissle *missile;


@end

@implementation PBPlayer 
#pragma mark - lifeCycle

- (instancetype)init {
    self = [super initWithImageNamed:characterImageName];
    self.name = playerName;
    self.zPosition = playerZPosition;
    self.physicsBody = [PBPlayer originalPhysicsBody];

    [self addObserver:self forKeyPath:@"invulnerabilityKeyPath" options:0 context:NULL];
    self.xScale = 0.5;
    self.yScale = 0.5;
    self.isInvulnerable = NO;
    [self setUpAnimations];
    self.playerState = running;
    _deathDispatched = NO;
    
    [self loadEnemies];
    
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"invulnerabilityKeyPath"];
}


#pragma mark - player death and powerUp

- (void)playerDied {
    if(self.isInvulnerable) {
        return;
    }
    self.hidden = YES;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"playerDiedNotification" object:nil];
}

- (void)powerUpPickedUp {
    if(!self.isInvulnerable) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeAllActions];
            self.isInvulnerable = YES;
            self.playerState = running;
        });

    }
}

#pragma mark - setup Animations


- (void)setUpRunFrames {
    //load running frames
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SKTextureAtlas *runningAtlas = [SKTextureAtlas atlasNamed:@"runCycleV2"];
        NSMutableArray *running = [[NSMutableArray alloc] init];
        for(int i = 1; i < runningAtlas.textureNames.count; i++) {
            NSString *tempString;
            if (i < 10) {
                tempString = [NSString stringWithFormat:@"Run_Cycle_0%d.png" , i];
            } else {
                tempString = [NSString stringWithFormat:@"Run_Cycle_%d.png" , i];
            }
            SKTexture *runningTemp = [runningAtlas textureNamed:tempString];
            if(runningTemp) {
                [running addObject:runningTemp];
            }
        }
        runningFrames = running;
    });
}

- (void)setUpJumpFrames {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *jumping = [NSMutableArray new];
        SKTextureAtlas *jumpAtlas = [SKTextureAtlas atlasNamed:@"jumpingAtlasV3"];
        
        for(int i = 0; i < jumpAtlas.textureNames.count; i++) {
            NSString *tempName = [NSString stringWithFormat:@"jump_%d" , i + 1];
            SKTexture *jumpTemp = [jumpAtlas textureNamed:tempName];
            if(jumpTemp) {
                [jumping addObject:jumpTemp];
            }
        }
        jumpingFrames = jumping;
    });
}

- (void)setUpSlidingFrames {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *slidingDoe = [NSMutableArray array];
        SKTextureAtlas *slideAtlas = [SKTextureAtlas atlasNamed:@"slidingV2"];
        for(int i = 1; i < [slideAtlas.textureNames count] + 1;i++) {
            NSString *tempName = [NSString stringWithFormat:@"slide_%ld", (long)i];
            SKTexture *tempTexture = [slideAtlas textureNamed:tempName];
            if(tempTexture) {
                [slidingDoe addObject:tempTexture];
            }
        }
        for(NSInteger i = [slideAtlas.textureNames count] -1; i > 0 ; i--) {
            NSString *tempName = [NSString stringWithFormat:@"slide_%ld" , (long)i];
            SKTexture *tempText = [slideAtlas textureNamed:tempName];
            if(tempText) {
                [slidingDoe addObject:tempText];
            }
        }
        slidingFrames = slidingDoe;
    });
}

- (void)setUpRunningInvulnerableAnimation {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *running = [[NSMutableArray alloc]init];
        SKTextureAtlas *invulnerableRunAtlas = [SKTextureAtlas atlasNamed:@"runningInvulnerableV2"];
        for(int i = 1; i < invulnerableRunAtlas.textureNames.count -1; i++) {
            NSString *tempName;
            if(i < 10) {
                tempName = [NSString stringWithFormat:@"powerup_run_0%d" , i];
            } else {
                tempName = [NSString stringWithFormat:@"powerup_run_%d" , i];
            }
            SKTexture *tempTexture = [invulnerableRunAtlas textureNamed:tempName];
            if(tempTexture) {
                [running addObject:tempTexture];
            }
        }
        invulnerableRunFrames = running;
    });
}

- (void)setUpAnimations {
    [self setUpRunFrames];
    [self setUpJumpFrames];
    [self setUpSlidingFrames];
    [self setUpRunningInvulnerableAnimation];
}

#pragma mark - basic and invulnerable animations

- (void)startRunningAnimation {
    if(![self actionForKey:@"running"]) {
        [self runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:runningFrames timePerFrame:0.08 resize:NO restore:NO]]withKey:@"running"];
    }
}

- (void)stopRunningAnimation {
    [self removeActionForKey:@"running"];
}

- (void)startJumpingAnimations {
    if(![self actionForKey:@"jumping"]) {
        [self runAction:[SKAction animateWithTextures:jumpingFrames timePerFrame:0.19 resize:YES restore:YES] withKey:@"jumping"];
        
    }
}

- (void)slideAnimation {
    _isSliding = YES;
    self.physicsBody = [PBPlayer slidingPhysicsBody];
    [self slide];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.75 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self runAction:[SKAction runBlock:^{
            if(self.isInvulnerable) {
                return;
            }
            if(!_deathDispatched) {
                if(!_isSliding) {
                    self.physicsBody = [PBPlayer physicsBodyAfterSlide];
                    return;
                }
                self.physicsBody = [PBPlayer physicsBodyAfterSlide];
                _isSliding = NO;
                if(self.playerState != running) {
                     self.playerState = running;
                }
               
            }
        }]withKey:@"physicsBodyChange"];
    });
    
}

- (void)slide {
    [self runAction:[SKAction animateWithTextures:slidingFrames timePerFrame:0.2 resize:YES restore:YES] withKey:@"sliding"];
}

- (void)stopSlidingAnimation {
    [self removeActionForKey:@"sliding"];
}

- (void)startRunningInvulnerableAnimation {
    if(![self actionForKey:@"running_invulnerable"]) {
        if(_isSliding) {
            [self stopSlidingAnimation];
            //[self removeActionForKey:@"physicsBodyChange"];
        }
        self.physicsBody = [PBPlayer physicsBodyInvulnerable];
        [self runAction:
            [SKAction group:@[
                        [SKAction scaleBy:2.0 duration:0.3] ,
                        [SKAction repeatActionForever:[SKAction animateWithTextures:invulnerableRunFrames timePerFrame:.08 resize:NO restore:YES]]
                        ]]];
    }
}

- (void)InvulnerableToRegular {
    if(self.isInvulnerable) {
        self.physicsBody.allowsRotation = NO;
        SKAction *invulnerableToReg = [SKAction sequence:@[
                                                           [SKAction repeatAction:[self colorizeSpriteNodeWithColor:[SKColor redColor]] count:3],
                                                           [SKAction scaleBy:0.5 duration:0.5] ,
                                                           [SKAction repeatActionForever:[SKAction animateWithTextures:runningFrames timePerFrame:0.08 resize:NO restore:YES]]
                                                           ]];
        [self runAction:invulnerableToReg];
        self.physicsBody = [PBPlayer originalPhysicsBody];
    }
}

- (void) stopRunningInvulnerableAnimation {
    [self removeActionForKey:@"running_invulnerable"];
}

#pragma mark - player state

- (void)setPlayerState:(PBPlayerAnimationState)playerState {

    if(self.isInvulnerable) {
        switch (playerState) {
            case running:
                [self startRunningInvulnerableAnimation];
                break;
            default:
                break;
        }
    } else {
        switch (playerState) {
            case running:
                [self startRunningAnimation];
                
                break;
            case jumping:
                if(_playerState == running) {
                    [self stopRunningAnimation];
                    [self startJumpingAnimations];
                    self.playerState = running;
                } else if(_playerState == sliding) {
                    _isSliding = NO;
                    [self stopSlidingAnimation];
                    [self startJumpingAnimations];
                }
                break;
            case sliding:
                if(_playerState == running) {
                    [self slideAnimation];
                    [self stopSlidingAnimation];
                    self.playerState = running;
                }
                break;
            case dying:
                [self removeAllActions];
            default:
                break;
        }
    }
    
    _playerState = playerState;
}

#pragma mark - reactions and other

-(SKAction*)colorizeSpriteNodeWithColor:(SKColor*)color
{
    SKAction *changeColorAction = [SKAction colorizeWithColor:color colorBlendFactor:0.65 duration:0.2];
    SKAction *waitAction = [SKAction waitForDuration:0.2];
    SKAction *startingColorAction = [SKAction colorizeWithColorBlendFactor:0.0 duration:0.3];
    SKAction *selectAction = [SKAction sequence:@[changeColorAction, waitAction, startingColorAction]];
    return selectAction;
}

- (void)executeDeathAnimationWithEnemy:(enemyType)enemyType {
    NSLog(@"calling player execution");
    SKAction *dyingAction;

    if(!_deathDispatched) {
        return;
    } else {
        _deathDispatched = YES;
//FENCE==================================================
        if(enemyType == enemyTypeFence) {
            dyingAction = [self.fence deathAnimation];
            [self runAction:dyingAction completion:^{
                self.hidden = YES;
            }];
//MISSILE==================================================
        } else if(enemyType == enemyTypeMissle) {
            self.playerState = dying;
            dyingAction = [self.missile deathAnimation];
            [self runAction:dyingAction];
//SPIKEPIT==================================================
        } else if(enemyType == enemyTypeSpikePit) {
            dyingAction = [self.spikePit deathAnimation];
            self.physicsBody = nil;
            self.xScale = 0.3;
            self.yScale = 0.3;
            if(_isSliding) {
                self.playerState = dying;
                [self runAction:[SKAction group:@[dyingAction , [self dropInSpikePitAtLocation:CGPointMake(self.position.x + 10, self.position.y + 10) WithDuration:0.3]]]completion:^{
                    [self addBloodEmitter];
                }];
            } else if(_isJumping) {
                self.playerState = dying;
                [self runAction:[SKAction group:@[dyingAction , [self dropInSpikePitAtLocation:CGPointMake(self.position.x - 17, self.position.y) WithDuration:0.15]]]completion:^{
                    [self addBloodEmitter];
                }];
            } else {
                self.playerState = dying;
                [self runAction:[SKAction group:@[dyingAction , [self dropInSpikePitAtLocation:self.position WithDuration:0.3]]] completion:^{
                    [self addBloodEmitter];
                }];
            }
        }
    }
}

- (SKAction *)dropInSpikePitAtLocation:(CGPoint)location WithDuration:(NSTimeInterval)duration {
    SKAction *drop = [SKAction group:@[[SKAction moveToX:location.x + 22
                                            duration:duration] , [SKAction moveToY:location.y - 22 duration:duration]]];

    return drop;
}

- (void)addBloodEmitter {
    SKEmitterNode *bloodEmitter = [self particleEmitterWithName:@"blood"];
    bloodEmitter.position = CGPointMake(10, 10);
    bloodEmitter.zPosition = self.zPosition + 1;
    bloodEmitter.name = @"bloodEmitter";
    bloodEmitter.xScale = 0.6;
    bloodEmitter.yScale = 0.6;
    [self addChild:bloodEmitter];
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

#pragma mark - different physics bodies for player state

+ (SKPhysicsBody *)originalPhysicsBody {
    SKPhysicsBody *orginalBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(30, 60)];
    orginalBody.dynamic = YES;
    orginalBody.mass = playerMass;
    orginalBody.contactTestBitMask = enemyCategory | powerUpCategory;
    orginalBody.categoryBitMask = playerCategory;
    orginalBody.collisionBitMask = groundBitMask;
    orginalBody.allowsRotation = NO;
    
    return orginalBody;
}

+ (SKPhysicsBody *)physicsBodyAfterSlide {
    SKPhysicsBody *orginalBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(15, 30)];
    orginalBody.dynamic = YES;
    orginalBody.mass = playerMass;
    orginalBody.contactTestBitMask = enemyCategory | powerUpCategory;
    orginalBody.categoryBitMask = playerCategory;
    orginalBody.collisionBitMask = groundBitMask;
    orginalBody.allowsRotation = NO;
    
    return orginalBody;
}

+ (SKPhysicsBody *)slidingPhysicsBody {
    SKPhysicsBody *slidingBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(35, 15)];
    slidingBody.dynamic = YES;
    slidingBody.mass = playerMass;
    slidingBody.contactTestBitMask = enemyCategory | powerUpCategory;
    slidingBody.categoryBitMask = playerCategory;
    slidingBody.collisionBitMask = groundBitMask;
    slidingBody.allowsRotation = NO;
    return slidingBody;
}

+ (SKPhysicsBody *)physicsBodyInvulnerable {
    SKPhysicsBody *orginalBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(15, 35)];
    orginalBody.dynamic = YES;
    orginalBody.mass = playerMass;
    orginalBody.contactTestBitMask = enemyCategory | powerUpCategory;
    orginalBody.categoryBitMask = playerCategory;
    orginalBody.collisionBitMask = groundBitMask;
    orginalBody.allowsRotation = NO;
    
    return orginalBody;
}

- (void)loadEnemies {
    self.missile = [PBMissle new];
    self.fence = [PBFence new];
    self.spikePit = [PBSpikePit new];
    self.bomb = [PBBomb bomb];
}

@end
