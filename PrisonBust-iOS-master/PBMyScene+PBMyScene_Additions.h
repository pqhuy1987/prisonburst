//
//  PBMyScene+PBMyScene_Additions.h
//  Prison Bust
//
//  Created by Mac Admin on 5/15/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import "PBMyScene.h"

@class PBFence, PBMissle, PBSpikePit, PBPowerUp, PBPlayer, PBBomb;
@interface PBMyScene (PBMyScene_Additions)

- (PBMissle *)missileInstance;
- (PBFence *)fenceInstance;
- (PBSpikePit *)spikePitInstance;
- (PBBomb *)bombInstance;

- (PBPowerUp *)powerUpInstance;

- (PBPlayer *)playerInstance;

//on screen edge colliders
- (SKNode *)bottomCollider;

//exploding body parts
- (void)loadPlayerExplosionSprites;
- (SKAction *)explosionSpritesAtLocation:(CGPoint)location;

//convenience
+ (NSString *)dateToString:(NSDate *)date;

@end
