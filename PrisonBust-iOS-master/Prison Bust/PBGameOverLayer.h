//
//  PBGameOverLayer.h
//  Prison Bust
//
//  Created by Mac Admin on 4/25/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//
@import SpriteKit;
#import "PBHighScoreObject.h"

@interface PBGameOverLayer : SKScene

@property (strong, nonatomic) PBHighScoreObject *playerScore;

+ (instancetype)gameOverLayerWithScore:(PBHighScoreObject *)playerScore;
@end
