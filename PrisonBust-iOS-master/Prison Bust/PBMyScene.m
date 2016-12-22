////
////  PBMyScene.m
////  Prison Bust
////
////  Created by Mac Admin on 4/23/14.
////  Copyright (c) 2014 Ben Gabay. All rights reserved.
////
//
#import "PBEnemy.h"
#import "PBMyScene.h"
#import "PBBackground.h"
#import "PBPlayer.h"
#import "PBFence.h"
#import "PBMissle.h"
#import "PBBomb.h"
#import "PBPowerUp.h"
#import "PBSpikePit.h"
#import "PBGameOverLayer.h"
#import "PBObjectPool.h"
#import "PBHighScoresScene.h"
#import "PBMyScene+PBMyScene_Additions.h"
@import AVFoundation;

//DEBUG VARIABLES
static BOOL shouldIncludePowerup = YES;


//move speeds

static NSInteger midgroundMoveSpeed = 0;
static NSInteger backgroundMoveSpeed = 0;
static NSInteger foregroundMoveSpeed = 0;

static NSInteger foregroundMoveSpeedInvulnerable = 6;
static NSInteger midgroundMoveSpeedInvulnerable = 4;
static NSInteger backgroundMoveSpeedInvulnerable = 2;

static NSInteger globalGravity = -4.8;

static NSArray *enemyPools = nil;

static NSArray *midgroundNodes = nil;




@interface PBMyScene() <SKPhysicsContactDelegate>

//background vars
@property (nonatomic, strong) PBBackground *currentBackground;
@property (nonatomic, strong) PBBackground *currentMidground;
@property (nonatomic, strong) PBBackground *currentForeGround;


//object Pools
@property (nonatomic, strong) PBObjectPool *missilePool;
@property (nonatomic, strong) PBObjectPool *fencePool;
@property (nonatomic, strong) PBObjectPool *spikePitPool;

//player
@property (nonatomic, strong) PBPlayer *player;

//current enemies holders
@property (nonatomic, strong) PBMissle *currentMissile;
@property (nonatomic, strong) PBFence *currentFence;
@property (nonatomic, strong) PBSpikePit *currentSpikePit;
@property (nonatomic, strong) PBBomb *currentBomb;

//powerUp holder
@property (nonatomic, strong) PBPowerUp *currentPowerUp;

//score label
@property (nonatomic, strong) SKLabelNode *scoreLabel;

//gesture recognizers
@property (nonatomic, strong) UISwipeGestureRecognizer *downwardSwipeRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *upwardSwipeRecognizer;

//delta time
@property (nonatomic) CFTimeInterval lastUpdateTimeInterval;

//music niggie
@property (nonatomic, strong) AVAudioPlayer *musicPlayer;

@property (nonatomic, strong) NSArray *enemyTypes;

@end
@implementation PBMyScene {
    int _score;
    BOOL _stopMovingBackgrounds;
    BOOL _poweredUp;
    BOOL _stopBombDrop;
    
    BOOL _dispatchBombBackground;
    
    BOOL _isSliding;
    BOOL _isJumping;
    BOOL _missileHit;
    
    
    CGPoint _playerFreezePoint;
    NSTimer *_powerDown;
    NSTimer *_enemyDispatchTimer;
    NSTimer *_powerUpDispatchTimer;
    NSTimer *_blinkRedTimer;
    SKPhysicsBody *_basePhysicsBody;
    
    
    //Only for beta testing
    SKSpriteNode *_powerUpButton;
    
}

/*
 NEW BUILD ==================================> 1.4
 - spinning missile -> CHECK
 - addition of bombs
 - player shadow    -> CHECK
 - updated run cycle -> CHECK NIGGe
 NEW BUILD ==================================> 1.5
  - addition of bombs  -> CHECK
  - reduce memory load -> CHECK
  - fix player jumping deformity -> CHECK
  - updated assets     -> CHECK
 
 NEW BUILD ==================================> 1.6
  CHECK -> updated menu assets
  CHECK -> sliding while powering up issue (scaling)
  CHECK -> spike pit death -> detect if we have reached half of the length, if so fall downward only
  CHECK -> highScore button added to gameOverScene
 
 
 NEW BUILD ==================================> 1.7
  CHECK -> missile artillery
  CHECK -> bomb artillery
  - when player explodes, the explosion is not suspended (affectedByGravity)
  - spike pit invulnerability animation?
  - music
  - social media API integration

 
 <<<<<===== NOTES =====>>>>>
 -missile artillery 1 : 7 || 6 midgrounds
 
 -bomb artillery need to be orchestrated with drop bomb
   >jump avoid vs slide avoid
   >possible gravity issues
   > midgroundBombShooter production + bomb drop = one action?
 
 -other 2 elements can be produced as normal from the obj pool
 
 -find way to cache actions/ missiles + bombs
 
 - find way to space enemies so they dont spawn close to each other
 
 - take powerUp in to account of spacing
 
 - cycle through midground nodes at (3 || 4) normal, 1 missile, 2 bombs/ (6 || 7)
   >different patterns, same ratio? 
   >implement cycle counter or grab them in order from static array?
   >grab from static array doe.
 
 
 - > problems with 1.7
   > suspend player in air, if jumping after explosion
   > midground node regeneration after death.     CHECK
   > spacing cannon and other enemies correctly.  CHECK
   > enemy timing system optimizations            CHECK
        -flag to generate random enemy when we choose bomb?
        -dispatch bomb from generateRandomEnemy?
        -set in enumerateOverMidground or genRanEnemy?
 
 
 - problems with 1.8
  > stop bomb from rotating in air after death              CHECK
  > initial lag with bomb drop, slight lag with missiles    CHECK
     > no significant mem usage
     > lower draw number?
  > physics body with body parts issue (parts sitting on top of hidden player)  FUCKING CHECK
  > fix sound timing with fence                             CHECK
  > add powerUps                                            CHECK
  > fix 'one after another' enemy deaths
    -deal by fixing enemy spawns
 
  >Fix bomb death when invulnerable                         CHECK
  >Fix emitter issues for bomb                          SpriteKit editor malfunctions
 
 1.9
   >fix 'falling' explosion effect.                     CHECKKKKKKKKK
        poss approaches:
            - set player.physicsBody = nil. player.position = contact.contactPoint
            - .affectedByGravity = NO;   => bad solution
                cannot 
   >music
   >slight lag when beginning                       due to large texture atlas. BombArtillery at 2, rocketLauncher at 4
   >Bomb stop its path when player dies                 CHECK
 
 //TODO
  -bomb artillery bad quality
  -no overlapping between bomb and enemy
  -invulnerability til we can jump
  -missile artillery timing
  -MUSIC
 */


-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        [self setUpMidgroundNodesArray];
        
        //set background
        self.currentBackground = [PBBackground backgroundNode];
        [self addChild:self.currentBackground];
        
        //set midground - normal
        self.currentMidground = [PBBackground midgroundNode];
        [self addChild:self.currentMidground];
        
        //set foreground
        self.currentForeGround = [PBBackground foregroundNode];
        [self addChild:self.currentForeGround];
        
        //set edge colliders
        [self addChild:[self bottomCollider]];

        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gameOver) name:@"playerDiedNotification" object:nil];
        
        
        self.player = [self playerInstance];
        [self addChild:self.player];
        [self shadowForPlayer];
        
        [self enemyDispatchTimer];
        [self powerUpDispatchTimer];
        
        
        
        _missileHit = NO;
        _score = 0;
        [self initializeScoreLabelNode];
        
        //set gravity
        self.physicsWorld.gravity = CGVectorMake(0, globalGravity);
        self.physicsWorld.contactDelegate = self;
        
        [self loadPlayerExplosionSprites];
        
        PBHighScoresScene *scene = [PBHighScoresScene highScoresScene];
        
        
      //  [self setUpPowerUpButton];
        
        _dispatchBombBackground = NO;
    }
    return self;
}


#pragma mark - handling contact

- (void)contactWithEnemy:(PBEnemy *)enemy andPosition:(CGPoint)position {
    if([enemy isKindOfClass:[PBFence class]]) {
        [self didContactFence];
    } else if([enemy isKindOfClass:[PBSpikePit class]]) {
        [self didContactSpikePit];
    } else if([enemy isKindOfClass:[PBMissle class]]) {
        [self didContactMissileWithPosition:position missile:(PBMissle *)enemy];
    } else if([enemy isKindOfClass:[PBBomb class]]) {
        [self didContactBombWithPosition:position bomb:(PBBomb *)enemy];
    } else {
        NSException *e = [NSException exceptionWithName:@"Bad parameters" reason:@"passed in PBEnemy that is unrecoginized" userInfo:0];
        @throw e;
    }
    [self endingSequence];
}

- (void)didContactMissileWithPosition:(CGPoint)position missile:(PBMissle *)missile{
    if(_missileHit) {
        return;
    }
    _missileHit = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _missileHit = NO;
    });
    //PBMissle *missile = (PBMissle *)contact.bodyB.node;
    [missile removeFromParent];
    self.player.deathDispatched = YES;
    
    self.player.physicsBody = nil;
    self.player.position = position;
    [self.player executeDeathAnimationWithEnemy:enemyTypeMissle];
    
    [self removeShadow];
    [self explosionReactionAtPoint:position];

}

- (void)didContactFence {
    self.player.deathDispatched = YES;
    [self.player executeDeathAnimationWithEnemy:enemyTypeFence];
}

- (void)didContactSpikePit {
    if(self.player.isInvulnerable) {
        //do something different if we're invulnerable
    } else {
        self.player.deathDispatched = YES;
        if (self.player.position.y > 230) {
            self.player.isJumping = YES;
        }
        [self removeShadow];
        [self.player executeDeathAnimationWithEnemy:enemyTypeSpikePit];

    }
}

- (void)didContactBombWithPosition:(CGPoint)position bomb:(PBBomb *)bomb {
    if(_missileHit) {
        return;
    }
    _missileHit = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _missileHit = NO;
    });
    
    self.player.deathDispatched = YES;
    
    self.player.physicsBody = nil;
    self.player.position = position;
    [self.player executeDeathAnimationWithEnemy:enemyTypeMissle];
    [self removeShadow];
    
    [self explosionReactionAtPoint:position];
    [bomb removeFromParent];

}

- (void)endingSequence {
    _stopMovingBackgrounds = YES;
    [self pauseBombs];
    [self runAction:[SKAction sequence:@[[SKAction waitForDuration:2.0] , [SKAction runBlock:^{
        [self gameOver];
    }]]]];
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    if(contact.bodyA.categoryBitMask == playerCategory && contact.bodyB.categoryBitMask == enemyCategory) {
        //FENCE====================================================================================================================
        if([contact.bodyB.node isKindOfClass:[PBFence class]]) {
            if(self.player.isInvulnerable) {
                PBFence *fence = (PBFence *)contact.bodyB.node;
                [fence breakFence];
                
            } else {
                [self contactWithEnemy:(PBEnemy *)contact.bodyB.node andPosition:contact.contactPoint];
            }
        //SPIKE PIT====================================================================================================================
        } else if ([contact.bodyB.node isKindOfClass:[PBSpikePit class]]) {
            if(self.player.isInvulnerable) {
                return;
            } else {
                [self contactWithEnemy:(PBEnemy *)contact.bodyB.node andPosition:contact.contactPoint];

            }
            
        //MISSILE===================================================================================================================
        } else if([contact.bodyB.node isKindOfClass:[PBMissle class]]) {
            NSLog(@"missile hit player");
            if(self.player.isInvulnerable) {
                PBMissle *missile = (PBMissle *)contact.bodyB.node;
                missile.physicsBody.collisionBitMask = groundBitMask;
                
                [missile runAction:[missile deathAnimationForInvulnerability]completion:^{
                    [missile removeFromParent];
                    return;
                }];
            } else {
                [self contactWithEnemy:(PBEnemy *)contact.bodyB.node andPosition:contact.contactPoint];
            }
        }
        //BOMB====================================================================================================================
        else if([contact.bodyB.node isKindOfClass:[PBBomb class]]) {
            if(self.player.isInvulnerable) {
                PBBomb *bomb = (PBBomb *)contact.bodyB.node;
                [bomb executeDeathAnimation];
            } else {
                [self contactWithEnemy:(PBEnemy *)contact.bodyB.node andPosition:contact.contactPoint];
            }
        }

    //POWERUP====================================================================================================================
 
    } else if(contact.bodyB.categoryBitMask == playerCategory && contact.bodyA.categoryBitMask == enemyCategory) {
        NSLog(@"spritekit swtiched up the bodies on us");
        @throw [NSException exceptionWithName:@"physicsBodyException" reason:@"" userInfo:nil];
    }
    
    //detect for player and powerup
    if(contact.bodyB.categoryBitMask == playerCategory && contact.bodyA.categoryBitMask == powerUpCategory) {
        [self powerUpPickedUpWithBody:contact.bodyA];
        
    } else if(contact.bodyB.categoryBitMask == powerUpCategory && contact.bodyA.categoryBitMask == playerCategory) {
        [self powerUpPickedUpWithBody:contact.bodyB];
    }
    
    else if(contact.bodyB.categoryBitMask == enemyCategory && contact.bodyA.categoryBitMask == groundBitMask) {
        if([contact.bodyB.node isKindOfClass:[PBBomb class]]) {
            PBBomb *bomb = (PBBomb *)contact.bodyB.node;
            [bomb executeDeathAnimation];
        }
    }
}

- (void)powerUpPickedUpWithBody:(SKPhysicsBody *)body {
    [body.node removeFromParent];
    if(_poweredUp) {        //we are already invulnerable, dont do anything
        return;
    } else {
        _poweredUp = YES;
        [self.player powerUpPickedUp];
        [self beginInvulnerableCounter];
        [self changeShadowSize];
    }
}


- (void)update:(CFTimeInterval)currentTime {
    if(_stopMovingBackgrounds) {
        return;
    }
    
    if(self.player.isInvulnerable) {
        backgroundMoveSpeed = backgroundMoveSpeedInvulnerable;
        midgroundMoveSpeed = midgroundMoveSpeedInvulnerable;
        foregroundMoveSpeed = foregroundMoveSpeedInvulnerable;
    } else {
        backgroundMoveSpeed = 1.3;
        midgroundMoveSpeed = 2.5;
        foregroundMoveSpeed = 3.5;
        
    }
    
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }

    [self enumerateOverPlayer:timeSinceLast];
    
    [self enumerateOverForeground:timeSinceLast];
    
    [self enumerateOverBackground:timeSinceLast];

    [self enumerateOverMidground:timeSinceLast];

    [self enumerateOverFences:timeSinceLast];

    [self enumerateOverMissiles:timeSinceLast];
    
    [self enumerateSpikePit:timeSinceLast];
    
    [self enumerateOverPowerUps:timeSinceLast];
    
    [self enumerateOverBombs:timeSinceLast];
    
    //update score
    [self updateScore];
}

- (void)executeSlide {
    if(self.player.isInvulnerable) {
        NSLog(@"SWIPE DOWN invulnerable");

        return;
    }
    NSLog(@"SWIPE DOWN");
    dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
        if(self.player.isInvulnerable) {
            return;
        } else {
            if((!self.player.deathDispatched || !self.player.playerState == dying) && !_isJumping &&!_isSliding) {
                if(self.player.position.y < 230 && self.player.position.y > 225) {
                    self.physicsWorld.gravity = CGVectorMake(0, globalGravity);
                    
                    _isSliding = YES;
                    [self enumerateOverShadow];
                    [self.player slideAnimation];
                }
            }
        }
    });
}

- (void)jumpAction {
    if(self.player.isInvulnerable) {
        NSLog(@"SWIPE UP invulnerable");

        return;
    }
    NSLog(@"SWIPE UP");

    dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
        if((!self.player.playerState == dying || !self.player.deathDispatched) && !_isSliding) {
            if(self.player.position.y < 230 && self.player.position.y > 225) {
                _isJumping = YES;
                self.physicsWorld.gravity = CGVectorMake(0, globalGravity);
                self.player.isSliding = NO;
                [self enumerateOverShadow];
                [self.player startJumpingAnimations];
                [self.player runAction:[SKAction runBlock:^{
                    self.player.physicsBody.mass = 50;
                    [self.player.physicsBody applyImpulse:CGVectorMake(0, 250 * self.player.physicsBody.mass)];
                }]];
            }
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _isJumping = NO;
        });
    });
}



- (void)didMoveToView:(SKView *)view {
    //set sliding gesture recognizer here
    self.downwardSwipeRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(executeSlide)];
    self.downwardSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [view addGestureRecognizer:self.downwardSwipeRecognizer];
    self.upwardSwipeRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(jumpAction)];
    self.upwardSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [view addGestureRecognizer:self.upwardSwipeRecognizer];
}


- (void)willMoveFromView:(SKView *)view {
    [view removeGestureRecognizer:self.downwardSwipeRecognizer];
    [view removeGestureRecognizer:self.upwardSwipeRecognizer];
    [_powerUpDispatchTimer invalidate];
    [_enemyDispatchTimer invalidate];
    [self removeAllChildren];
}

- (void)gameOver {
    _stopBombDrop = YES;
    _stopMovingBackgrounds = YES;
    [self presentGameOverScene];
}

#pragma mark - score label setup

- (void) initializeScoreLabelNode {
    SKLabelNode *scoreNode = [SKLabelNode labelNodeWithFontNamed:@"Verdana"];
    scoreNode.position = CGPointMake(self.size.width/6 , self.size.height/2 + 60);
    scoreNode.zPosition = self.player.zPosition + 1;
    scoreNode.name = @"score label";
    scoreNode.text = [NSString stringWithFormat:@"Score : %d", _score];
    scoreNode.fontColor = [SKColor blackColor];
    scoreNode.fontSize = 11;
    [self addChild:scoreNode];
    self.scoreLabel = scoreNode;
}

#pragma mark - enumeration over nodes

- (void)enumerateOverForeground:(CFTimeInterval)timeSinceLast {
    [self enumerateChildNodesWithName:foregroundName usingBlock:^(SKNode *node, BOOL *stop) {
        node.position = CGPointMake(node.position.x - foregroundMoveSpeed + timeSinceLast , node.position.y);
    }];
    if(self.currentForeGround.position.x < -self.size.width + 100) {
        PBBackground *newForeground = [PBBackground foregroundNode];
        newForeground.position = CGPointMake(self.currentForeGround.position.x + self.currentForeGround.frame.size.width, self.currentForeGround.position.y);
        [self addChild:newForeground];
        self.currentForeGround = newForeground;
    }
}

- (void)enumerateOverBackground: (CFTimeInterval) timeSinceLast{
    [self enumerateChildNodesWithName:backgroundName usingBlock:^(SKNode *node, BOOL *stop) {
        node.position = CGPointMake(node.position.x - backgroundMoveSpeed + timeSinceLast, node.position.y);
        
    }];
    if (self.currentBackground.position.x < -self.size.width + 100) {
        PBBackground *newBackground = [PBBackground backgroundNode];
        newBackground.position = CGPointMake(self.currentBackground.position.x + self.currentBackground.frame.size.width, self.currentBackground.position.y);
        [self addChild:newBackground];
        self.currentBackground = newBackground;
    }
}

- (void)enumerateOverPlayer:(CFTimeInterval)timeSinceLast {
    [self enumerateChildNodesWithName:playerName usingBlock:^(SKNode *node, BOOL *stop) {
        if(self.player.deathDispatched) {
            self.player.position = _playerFreezePoint;
        }
    }];
}

- (void)enumerateOverMidgroundWithName:(NSString *)name timeInterval:(CFTimeInterval)timeSinceLast {
    [self enumerateChildNodesWithName:name usingBlock:^(SKNode *node, BOOL *stop) {
        node.position = CGPointMake(node.position.x - midgroundMoveSpeed + timeSinceLast, node.position.y);
        if(node.position.x < -self.size.width - 200) {
            [node removeFromParent];
        }
    }];
}

- (void)fireWithArtilleryName:(NSString *)name {
    SKNode *child = [self.currentMidground childNodeWithName:name];
    [child runAction:[self.currentMidground fireArtillery]];
}

- (void)enumerateOverMidground:(CFTimeInterval)timeSinceLast {
    
    static BOOL firingEnabled = YES;
    
    [self enumerateOverMidgroundWithName:midgroundShooterNameBomb timeInterval:timeSinceLast];
    [self enumerateOverMidgroundWithName:midgroundShooterNameMissile timeInterval:timeSinceLast];
    [self enumerateOverMidgroundWithName:midgroundName timeInterval:timeSinceLast];
    
    if([self.currentMidground.name isEqualToString:midgroundShooterNameBomb]) {
        if(firingEnabled) {
            [self fireWithArtilleryName:@"bombArtillery"];
            firingEnabled = NO;
        }
    } else if([self.currentMidground.name isEqualToString:midgroundShooterNameMissile]) {
        NSUInteger sizeThreshold = (self.player.isInvulnerable) ? self.size.width/1.35 : self.size.width/5;    //used to determine how fast the missiles should fire after creation. (faster for invulnerability)
        //the larger the divisor, the longer the waiting time before firing
        
        if(firingEnabled && self.currentMidground.position.x < sizeThreshold) {
            [self fireWithArtilleryName:@"missileArtillery"];
          //r  [self tripleMissile];
            firingEnabled = NO;
        }
    }
    
    
    if(self.currentMidground.position.x < -self.size.width + 200) {
        PBBackground *newMidground;

        if(_dispatchBombBackground) {
            newMidground = [midgroundNodes objectAtIndex:1];
            if(newMidground.parent) {
                newMidground = [PBBackground midgroundNodeWithBombShooter];
            }
            [self orchestrateBombDrop];
            firingEnabled = YES;
            _dispatchBombBackground = NO;
        } else {
            
            //Implement 1 : 3 ratio here
            int randomIndex = arc4random() % 3;
            if(randomIndex == 0) {
                newMidground = [midgroundNodes objectAtIndex:2];
                if(newMidground.parent) {
                    newMidground = [PBBackground midgroundNodeWithMissileShooter];
                }
            } else {
                newMidground = [midgroundNodes objectAtIndex:0];
                if(newMidground.parent) {
                    newMidground = [PBBackground midgroundNode];
                }
            }
        }

        newMidground.position = CGPointMake(self.currentMidground.position.x + self.currentMidground.size.width,self.currentMidground.position.y);
        if(!newMidground) {
            NSLog(@"midground is nil");
        } else {
            [self addChild:newMidground];
            self.currentMidground = newMidground;
            firingEnabled = YES;
        }
    }
}

- (void)enumerateOverMissiles:(CFTimeInterval)timeSinceLast {
    [self enumerateChildNodesWithName:missileIdentifier usingBlock:^(SKNode *node, BOOL *stop) {
        node.position = CGPointMake(node.position.x - foregroundMoveSpeed - 2 + timeSinceLast, node.position.y);
        if(node.position.x < - self.size.width) {
            [node removeFromParent];
        }
    }];
    
}

- (void)enumerateOverBombs:(CFTimeInterval)timeSinceLast {
    if(_stopBombDrop) {
        return;
    }
    
    [self enumerateChildNodesWithName:@"bomb" usingBlock:^(SKNode *node, BOOL *stop) {
        if(node.position.y < 228) {
            [node removeActionForKey:@"bombDrop"];
            node.position = CGPointMake(node.position.x - foregroundMoveSpeed - 2 + timeSinceLast, node.position.y);
            if(node.position.x < - self.size.width) {
                [node removeFromParent];
            }
        }

    }];
}

- (void)pauseBombs {
    [self enumerateChildNodesWithName:@"bomb" usingBlock:^(SKNode *node, BOOL *stop) {
        node.paused = YES;
    }];
}

- (void)enumerateOverFences:(CFTimeInterval)timeSinceLast {
    [self enumerateChildNodesWithName:fenceIdentifier usingBlock:^(SKNode *node, BOOL *stop) {
        node.position = CGPointMake(node.position.x - foregroundMoveSpeed + timeSinceLast, node.position.y);

   
        if(node.position.x < - self.size.width) {
            [node removeFromParent];
        }
    }];
}

- (void)enumerateOverPowerUps:(CFTimeInterval)timeSinceLast {
    [self enumerateChildNodesWithName:@"powerUp" usingBlock:^(SKNode *node, BOOL *stop) {
        node.position = CGPointMake(node.position.x - foregroundMoveSpeed + timeSinceLast, node.position.y);
        if(node.position.x < - self.size.width) {
            [node removeFromParent];
        }
    }];
}

- (void)enumerateSpikePit:(CFTimeInterval)timeSinceLast {
    [self enumerateChildNodesWithName:spikePitIdentifier usingBlock:^(SKNode *node, BOOL *stop) {
        node.position = CGPointMake(node.position.x - foregroundMoveSpeed + timeSinceLast, node.position.y);
        if(node.position.x < - self.size.width) {
            [node removeFromParent];
        }
    }];
    
}


- (void)updateScore {
    _score += midgroundMoveSpeed/2;
    self.scoreLabel.text = [NSString stringWithFormat:@"Score : %d", _score];
}

- (void)presentGameOverScene {
    PBHighScoreObject *playerScore = [[PBHighScoreObject alloc]scoreWithDate:[PBMyScene dateToString:[NSDate date]] andScore:_score];

    PBGameOverLayer *gameOverLayer = [PBGameOverLayer gameOverLayerWithScore:playerScore];
    gameOverLayer.scaleMode = SKSceneScaleModeAspectFill;
    SKTransition *transition = [SKTransition crossFadeWithDuration:2.0];
    [self.view presentScene:gameOverLayer transition:transition];
    
}


- (void)explosionReactionAtPoint:(CGPoint)point {
    [self runAction:[self explosionSpritesAtLocation:point]];
}

#pragma mark - handling shadows

- (void)removeShadow {
    [self enumerateChildNodesWithName:@"shadow" usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
    }];
}

- (void)changeShadowSize {
    [self enumerateChildNodesWithName: @"shadow" usingBlock:^(SKNode *node, BOOL *stop) {
        
        if(_poweredUp) {
            [node runAction:[SKAction scaleXBy:2 y:1.0 duration:0.5]];
            
        } else if(!self.player.isInvulnerable || !_poweredUp){
            [node runAction:[SKAction scaleXBy:0.5 y:1.0 duration:0.5]];
        }
    }];
}

- (void)shadowForPlayer {
    SKSpriteNode *shadow = [SKSpriteNode spriteNodeWithImageNamed:@"Shadow_standard"];
    shadow.position = CGPointMake(self.player.position.x - 5, self.player.position.y + 6);
    shadow.name = @"shadow";
    shadow.xScale = 0.3;
    shadow.yScale = 0.4;
    shadow.zPosition = 4;
    [self addChild:shadow];
}

#pragma mark - invulnerability convienience methods

- (void)powerDown {
    _poweredUp = NO;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self changeShadowSize];
        self.player.isInvulnerable = NO;
        self.player.playerState = running;
    });
}

- (void)beginInvulnerableCounter {
    if(_poweredUp) {
        [_powerDown invalidate];
        [_blinkRedTimer invalidate];
        _powerDown = [NSTimer scheduledTimerWithTimeInterval:7.5 target:self selector:@selector(powerDown) userInfo:nil repeats:NO];
        _blinkRedTimer = [NSTimer scheduledTimerWithTimeInterval:7.0 target:self selector:@selector(powerDownAnimation) userInfo:nil repeats:NO];
    } else {
        NSLog(@"calling beginInvulnerableCounter without invulnerability");
    }
}

- (void)powerDownAnimation {
    [self.player InvulnerableToRegular];
}

- (void)enemyDispatchTimer {

    _enemyDispatchTimer = [NSTimer scheduledTimerWithTimeInterval:3.5 target:self selector:@selector(generateRandomEnemy) userInfo:nil repeats:YES];
    [_enemyDispatchTimer fire];
}

- (void)powerUpDispatchTimer {

    int randomSeconds = 10;
    //(arc4random() % 15) + 3;
    _powerUpDispatchTimer = [NSTimer scheduledTimerWithTimeInterval:randomSeconds target:self selector:@selector(generatePowerUp) userInfo:nil repeats:YES];
}


- (void)generatePowerUp {
    if(shouldIncludePowerup && !_poweredUp) {
        [self addChild:[self powerUpInstance]];
    }
}

- (void)generateRandomEnemy {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.currentMissile = [self missileInstance];
        self.currentFence = [self fenceInstance];
        self.currentSpikePit = [self spikePitInstance];
        enemyPools = [self setUpObjectPools];
    });

    int randomIndex = arc4random() % 4;
    if(randomIndex == 3) {
        _dispatchBombBackground = YES;
        return;
    }
    NSLog(@"randomIndex = %d" , randomIndex);
    SKSpriteNode *enemySprite = (SKSpriteNode *)[self enemyWithIndex:randomIndex];
    
    if(!enemySprite) {
        NSLog(@"enemy is nil, randomIndex = %d" , randomIndex);
        return;
    } else if(enemySprite.parent) {
        enemySprite = [enemySprite copy];
        NSLog(@"attempting to add node which is already attached to our scene: %@" , enemySprite);
    }
    [self addChild:enemySprite atPosition:enemySprite.position];
}

- (NSArray *)setUpObjectPools {
    for(int i = 1; i <= self.enemyTypes.count; i++) {
        switch (i) {
            case 1:
                self.spikePitPool = [PBObjectPool newPoolWithObjects:@[self.currentSpikePit] andName:@"spikePit Pool"];
                break;
            case 2:
                self.missilePool = [PBObjectPool newPoolWithObjects:@[self.currentMissile] andName:@"missile Pool"];

                break;
            case 3:
                self.fencePool = [PBObjectPool newPoolWithObjects:@[self.currentFence] andName:@"fence Pool"];
                break;
            default:
                break;
        }
    }
    return @[self.spikePitPool, self.missilePool, self.fencePool];
}



- (id)enemyWithIndex:(NSInteger)index {
    id enemy;
    switch (index) {
        case 0:
            enemy = [enemyPools[0] objectFromPool];
            break;
        case 1:
            enemy = [enemyPools[1] objectFromPool];
            break;
        case 2:
            enemy = [enemyPools[2] objectFromPool];
            break;

        default:
            break;
    }
    if(enemy) {
        return enemy;
    }
    NSLog(@"bad index passed in to selector: enemyWithIndex:(NSInteger)index");
    return nil;
}


- (NSArray *)enemyTypes {
    if(!_enemyTypes) {
        _enemyTypes = @[[NSNumber numberWithInt:enemyTypeFence] ,[NSNumber numberWithInt:enemyTypeMissle] ,[NSNumber numberWithInt:enemyTypeSpikePit]];
    }
    return _enemyTypes;
}

- (void)stopInvulnerabilityTimers {
    [_powerUpDispatchTimer invalidate];
    [_blinkRedTimer invalidate];
}


#pragma mark - power up and power down button Setup

- (void)setUpPowerUpButton {

    _powerUpButton = [SKSpriteNode spriteNodeWithImageNamed:@"powerUpPicPNG"];
    _powerUpButton.position = CGPointMake(self.size.width - 30, self.size.height/1.7 );
    _powerUpButton.xScale = 0.15;
    _powerUpButton.yScale = 0.15;
    _powerUpButton.zPosition = self.player.zPosition;
    _powerUpButton.hidden = NO;
    [self addChild:_powerUpButton];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
#warning dont forget to remove power up button
    if([_powerUpButton containsPoint:touchLocation]) {
        if(_poweredUp == NO) {
            //power up
            [_powerUpButton runAction:[SKAction colorizeWithColor:[UIColor greenColor] colorBlendFactor:0.9 duration:1]];
            _poweredUp = YES;
            [self.player powerUpPickedUp];
            [self beginInvulnerableCounter];
            _poweredUp = YES;
            
            [self changeShadowSize];
        } else {
            //power down
            if(_poweredUp) {
                _poweredUp = NO;
                [_powerUpButton runAction:[SKAction colorizeWithColor:[UIColor redColor] colorBlendFactor:0.9 duration:1]];
                [self powerDown];
                [self stopInvulnerabilityTimers];
                
            }
        }
    }
}

- (void)enumerateOverShadow {
    [self enumerateChildNodesWithName:@"shadow" usingBlock:^(SKNode *node, BOOL *stop) {
        if(_isJumping) {
            [node runAction:[SKAction sequence:@[[SKAction fadeOutWithDuration:0.4],
                                                 [SKAction fadeInWithDuration:0.3]
                                                 ]]];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _isJumping = NO;
            });
            
        } else if(_isSliding) {
            static BOOL isScaled = NO;
            if(!isScaled) {
                [node runAction:[SKAction scaleXBy:2.0 y:1.0 duration:0.2]];
                isScaled = YES;

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.55 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [node runAction:[SKAction scaleXBy:0.5 y:1.0 duration:0.2]];
                    _isSliding = NO;
                    isScaled = NO;
                });
            }
        }
    }];
}



- (void)addChild:(SKNode *)node atPosition:(CGPoint)position {
    if(!node.physicsBody) {
        NSLog(@"sprite holding nil state for physics body. node: %@" , node);
        PBEnemy *enemy = (PBEnemy *)node;
        if (position.x < self.size.width) {
            position.x = position.x + (self.size.width * 2);
        }
        
        if(enemy.enemyType == enemyTypeMissle) {
            enemy = [self.currentMissile copy];
        }

        enemy.position = CGPointMake(position.x + 150, position.y);
        [self addChild:enemy];
        return;
    }
    
    if (position.x < self.size.width) {
        position.x = position.x + (self.size.width * 2);
        node.position = position;
        [self addChild:node];
    } else {
        node.position = position;
        [self addChild:node];
    }
    NSLog(@"child added: %@ at position %@" , node.name, NSStringFromCGPoint(position));

}

- (void)orchestrateBombDrop {
    PBBomb *bomb = [PBBomb bomb];
    bomb.physicsBody.affectedByGravity = NO;
    bomb.position = CGPointMake(self.size.width * 1.5, self.size.height);
    [self addChild:bomb];
    
    CGMutablePathRef path;
    int randomDodge = arc4random() % 2;
    
    if (randomDodge == 1) {
        //jump dodge
        path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, bomb.position.x, bomb.position.y);
        CGPathAddArc(path, NULL, self.size.width/1.5, self.size.height/3, 70, 90, 110, NO);
        CGPathCloseSubpath(path);
        
    } else {
        //slide dodge
        path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, bomb.position.x, bomb.position.y);
        CGPathAddArc(path, NULL, self.size.width/2, self.size.height/5, 160, 90, 110, NO);
        CGPathCloseSubpath(path);
    }

    SKAction *followArc = [SKAction followPath:path asOffset:NO orientToPath:YES duration:12.0];
    [bomb runAction:followArc withKey:@"bombDrop"];
}

- (void)tripleMissile {
    PBMissle *missileInstance = [self missileInstance];
    PBMissle *missileInstance2 = [self missileInstance];
    PBMissle *missileInstance3 = [self missileInstance];
    [self addChild:missileInstance];
    [self runAction:[SKAction waitForDuration:0.5]];
    [self addChild:missileInstance2 atPosition:CGPointMake(missileInstance.position.x * 1.2, missileInstance.position.y)];
    [self runAction:[SKAction waitForDuration:0.5]];
    [self addChild:missileInstance3 atPosition:CGPointMake(missileInstance2.position.x * 1.2, missileInstance2.position.y)];
    
}

- (void)setUpMidgroundNodesArray {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PBBackground *regularMidground = [PBBackground midgroundNode];
        PBBackground *bombArtilleryMidground = [PBBackground midgroundNodeWithBombShooter];
        PBBackground *missileArtilleryMidground = [PBBackground midgroundNodeWithMissileShooter];
        midgroundNodes = @[regularMidground , bombArtilleryMidground , missileArtilleryMidground];
    });
}


@end
