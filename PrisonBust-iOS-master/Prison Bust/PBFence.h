//
//  PBFence.h
//  Prison Bust
//
//  Created by Mac Admin on 4/24/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import "PBEnemy.h"

@interface PBFence : PBEnemy
- (SKAction *)deathAnimation;
- (void)breakFence;
@end
