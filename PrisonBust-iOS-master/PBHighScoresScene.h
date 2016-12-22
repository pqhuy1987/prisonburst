//
//  PBHighScoresScene.h
//  Prison Bust
//
//  Created by Mac Admin on 5/19/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@class PBHighScoreObject;

@interface PBHighScoresScene : SKScene
@property (strong, readonly, nonatomic) NSMutableArray *highScores;
+ (instancetype)highScoresScene;
- (void)addHighScore:(PBHighScoreObject*)highScoreObj;

@end
