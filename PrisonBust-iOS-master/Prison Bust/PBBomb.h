//
//  PBBomb.h
//  Prison Bust
//
//  Created by Mac Admin on 6/22/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import "PBEnemy.h"

@interface PBBomb : PBEnemy

+ (instancetype)bomb;
- (void)executeDeathAnimation;

@end
