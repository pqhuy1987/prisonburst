//
//  PBGameStartScene.m
//  Prison Bust
//
//  Created by Mac Admin on 5/1/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import "PBGameStartScene.h"
#import "PBMyScene.h"
#import "PBHighScoresScene.h"

static NSString *backgroundImageName = @"prison_break_GAME_MAIN_v03";
static NSString *gameStartButtonImageName = @"prison_break_start_button_v02";
static NSString *highScoreButtonImageName = @"prison_break_highscores_v02";
static NSString *prisonBustLabelName = @"prisonbust";

@interface PBGameStartScene ()

@property (strong, nonatomic) SKSpriteNode *startGameButton;
@property (strong, nonatomic) SKSpriteNode *highScoresButton;

@end

@implementation PBGameStartScene

#pragma mark - lifeCycle

//designated initializer
+ (instancetype)gameStartScene{
    PBGameStartScene *gameStartScene = [PBGameStartScene new];
    SKSpriteNode *backgroundImageNode = [PBGameStartScene backgroundImage];
    backgroundImageNode.position = CGPointMake(backgroundImageNode.size.width/2, backgroundImageNode.size.height/2 + 0.22);
    [gameStartScene addChild:backgroundImageNode];
    return gameStartScene;
}

- (id)init{
    if(self = [super init]) {
        [self addChild:self.highScoresButton];
        [self addChild:self.startGameButton];
    }
    return self;
}

#pragma mark - handling contact

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    
    if ([self.highScoresButton containsPoint:touchLocation]) {
        NSLog(@"high score touched");
        [self presentHighScoresScene];
    } else if([self.startGameButton containsPoint:touchLocation]) {
        NSLog(@"start game button touched");
        [self presentGamePlayScene];
    }
}

#pragma mark - lazy loading

- (SKSpriteNode *)highScoresButton {
    if(!_highScoresButton) {
        SKSpriteNode *button = [SKSpriteNode spriteNodeWithImageNamed:highScoreButtonImageName];
        button.position = CGPointMake(0.84, 0.34);
        button.zPosition = 1;
        button.xScale = 0.001;
        button.yScale = 0.001;
        _highScoresButton = button;
    }
    return _highScoresButton;
}

- (SKSpriteNode *)startGameButton {
    if(!_startGameButton) {
        SKSpriteNode *button = [SKSpriteNode spriteNodeWithImageNamed:gameStartButtonImageName];
        button.position = CGPointMake(0.84, 0.42);
        button.xScale = 0.001;
        button.yScale = 0.001;
        button.zPosition = 1;
        _startGameButton = button;
    }
    return _startGameButton;
}

#pragma mark - convenience

+ (SKSpriteNode *)backgroundImage {
    SKSpriteNode *backgroundSpriteNode = [SKSpriteNode spriteNodeWithImageNamed:backgroundImageName];
    backgroundSpriteNode.xScale = 0.00123;
    backgroundSpriteNode.yScale = 0.00125;
    return backgroundSpriteNode;
}

#pragma mark - presenting scenes

- (void)presentGamePlayScene {
    PBMyScene *newGamePlay = [PBMyScene sceneWithSize:CGSizeMake(320, 568)];
    newGamePlay.scaleMode = SKSceneScaleModeAspectFill;
    [self.view presentScene:newGamePlay];
}

- (void)presentHighScoresScene {
    PBHighScoresScene *highScoresScene = [PBHighScoresScene highScoresScene];
    highScoresScene.scaleMode = SKSceneScaleModeAspectFill;
    [self.view presentScene:highScoresScene];
}

@end
