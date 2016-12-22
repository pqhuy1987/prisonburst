//
//  PBGameOverLayer.m
//  Prison Bust
//
//  Created by Mac Admin on 4/25/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import "PBGameOverLayer.h"
#import "PBMyScene.h"
#import "PBGameStartScene.h"
#import "PBHighScoresScene.h"
#import "PBHighScoreObject.h"

static NSString *sceneBackgroundImageName = @"prison_break_GAME_END_clean";
static NSString *startGameButtonName = @"play_again_v02";
static NSString *mainMenuButtonName = @"main_menu_v02";
static NSString *yourHighScoreLabelName = @"yourscore";
static NSString *highestScoreLabelName = @"highscore";
static NSString *highScoresButtonName = @"prison_break_highscores_v02";

@interface PBGameOverLayer ()

@property (strong, nonatomic) SKSpriteNode *playAgainButton;
@property (strong, nonatomic) SKSpriteNode *mainMenuButton;
@property (strong, nonatomic) SKSpriteNode *highScoresButton;

@end

@implementation PBGameOverLayer

#pragma mark - lifeCycle

//designated initializer
+ (instancetype)gameOverLayerWithScore:(PBHighScoreObject *)playerScore {
    PBGameOverLayer *gameOverLayer = [[PBGameOverLayer alloc]initWithScore:playerScore];
    SKSpriteNode *backgroundImageNode = [PBGameOverLayer backgroundImage];
    backgroundImageNode.position = CGPointMake(gameOverLayer.size.width/2, gameOverLayer.size.height/2);
    [gameOverLayer addChild:backgroundImageNode];
    return gameOverLayer;
}

- (id)initWithScore:(PBHighScoreObject *)playerScore {
    if(self = [super init]) {
        //adding buttons ---- need to be properties because we ref them in touchesBegan:
        [self addChild:self.highScoresButton];
        [self addChild:self.playAgainButton];
        [self addChild:self.mainMenuButton];
        
        //adding labels
        [self addHighScoreLabels];
        
        if(playerScore) {
            self.playerScore = playerScore;
            [self postNewHighScore];
            [self addPlayerScoreNode];
            [self displayHighestScore];
        } else {
            @throw [NSException exceptionWithName:@"no score exception" reason:@"player score not input from game ending" userInfo:0];
        }
    }
    return self;
}

- (void)willMoveFromView:(SKView *)view {
    [self removeAllChildren];
}

#pragma mark - adding buttons and labels

- (void)addHighScoreLabels {
    //highScoreLabel
    SKSpriteNode *highScore = [SKSpriteNode spriteNodeWithImageNamed:yourHighScoreLabelName];
    highScore.position = CGPointMake(0.23, 0.72);
    highScore.xScale = 0.0009;
    highScore.yScale = 0.0009;
    highScore.zPosition = 5;
    [self addChild:highScore];
    
    //player high Score
    SKSpriteNode *playerHighScore = [SKSpriteNode spriteNodeWithImageNamed:highestScoreLabelName];
    playerHighScore.position = CGPointMake(0.23, 0.65);
    playerHighScore.xScale = 0.0009;
    playerHighScore.yScale = 0.0009;
    playerHighScore.zPosition = 5;
    [self addChild:playerHighScore];
}

- (SKLabelNode *) makeDropShadowString:(NSString *) myString
{
    int offSetX = 3;
    int offSetY = 3;
    
    SKLabelNode *completedString = [SKLabelNode labelNodeWithFontNamed:@"Verdana-Bold"];
    completedString.fontSize = 30.0f;
    completedString.fontColor = [SKColor yellowColor];
    completedString.text = myString;
    
    
    SKLabelNode *dropShadow = [SKLabelNode labelNodeWithFontNamed:@"Verdana-Bold"];
    dropShadow.fontSize = 30.0f;
    dropShadow.fontColor = [SKColor blackColor];
    dropShadow.text = myString;
    dropShadow.zPosition = completedString.zPosition - 1;
    dropShadow.position = CGPointMake(dropShadow.position.x - offSetX, dropShadow.position.y - offSetY);
    
    [completedString addChild:dropShadow];
    
    return completedString;
}

- (void)addPlayerScoreNode {
    int score = self.playerScore.score;

    SKLabelNode *playerScoreLabelNode = [[SKLabelNode alloc]initWithFontNamed:@"Verdana-Bold"];
    playerScoreLabelNode = [self makeDropShadowString:[NSString stringWithFormat:@" %d" , score]];
    playerScoreLabelNode.position = CGPointMake(self.size.width/1.9, self.size.height/1.43);
    playerScoreLabelNode.zPosition = 50;
    playerScoreLabelNode.text = [NSString stringWithFormat:@"   %d", score];
    playerScoreLabelNode.fontColor = [SKColor colorWithRed:1 green:0.15 blue:0.3 alpha:1.0];
    playerScoreLabelNode.fontSize = 30;
    playerScoreLabelNode.hidden = NO;
    playerScoreLabelNode.xScale = 0.002;
    playerScoreLabelNode.yScale = 0.002;
    playerScoreLabelNode.name = @"playerScoreNode";
    [self addChild:playerScoreLabelNode];
    NSLog(@"player score label added");
    NSLog(@"score label location: %@" , NSStringFromCGPoint(playerScoreLabelNode.position));
}

- (void)displayHighestScore {
    PBHighScoresScene *highScoreRef = [PBHighScoresScene highScoresScene];
    PBHighScoreObject *obj = [highScoreRef.highScores firstObject];
    NSInteger highestScore = obj.score;
    SKLabelNode *highestScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Verdana-Bold"];
    highestScoreLabel = [self makeDropShadowString:[NSString stringWithFormat:@" %li" , (long)highestScore]];
    highestScoreLabel.position = CGPointMake(self.size.width/1.9, self.size.height/1.6);
    highestScoreLabel.zPosition = 50;
    highestScoreLabel.text = [NSString stringWithFormat:@" %li" , (long)highestScore];
    highestScoreLabel.fontColor = [SKColor colorWithRed:1 green:0.15 blue:0.3 alpha:1.0];
    highestScoreLabel.fontSize = 30;
    highestScoreLabel.hidden = NO;
    highestScoreLabel.xScale = 0.002;
    highestScoreLabel.yScale = 0.002;
    highestScoreLabel.name = @"highestScoreLabel";
    [self addChild:highestScoreLabel];
}

#pragma mark - lazy loading

- (SKSpriteNode *)highScoresButton {
    if(!_highScoresButton) {
        SKSpriteNode *highScores = [SKSpriteNode spriteNodeWithImageNamed:highScoresButtonName];
        highScores.position = CGPointMake(0.5, 0.3);
        highScores.xScale = 0.0009;
        highScores.yScale = 0.0009;
        highScores.zPosition = 5;
        _highScoresButton = highScores;
    }
    return _highScoresButton;
}

- (SKSpriteNode *)mainMenuButton {
    if(!_mainMenuButton) {
        SKSpriteNode *mainMenu = [SKSpriteNode spriteNodeWithImageNamed:mainMenuButtonName];
        mainMenu.position = CGPointMake(0.84, 0.3);
        mainMenu.xScale = 0.0009;
        mainMenu.yScale = 0.0009;
        mainMenu.zPosition = 5;
        _mainMenuButton = mainMenu;
    }
    return _mainMenuButton;
}

- (SKSpriteNode *)playAgainButton {
    if(!_playAgainButton) {
        SKSpriteNode *playAgain = [SKSpriteNode spriteNodeWithImageNamed:startGameButtonName];
        playAgain.xScale = 0.0009;
        playAgain.yScale = 0.0009;
        playAgain.position = CGPointMake(0.15, 0.3);
        playAgain.zPosition = 5;
        _playAgainButton = playAgain;
    }
    return _playAgainButton;
}

#pragma mark - convenience

- (void)postNewHighScore {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"newHighScoreAdded" object:self.playerScore];
}

+ (SKSpriteNode *)backgroundImage {
    SKSpriteNode *backgroundImageNode = [[SKSpriteNode alloc]initWithImageNamed:sceneBackgroundImageName];
    backgroundImageNode.xScale = 0.001;
    backgroundImageNode.yScale = 0.0009;
    backgroundImageNode.name = @"backgroundImage";
    return backgroundImageNode;
}

#pragma mark - handing contact

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //we will present a button to the user, sense if the button has been touched. if yes...
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    
    if ([self.playAgainButton containsPoint:touchLocation]) {
        NSLog(@"play again touched");
        [self presentGamePlayScene];
    } else if([self.mainMenuButton containsPoint:touchLocation]) {
        NSLog(@"main menu touched");
        [self presentMainMenu];
    } else if([self.highScoresButton containsPoint:touchLocation]) {
        NSLog(@"high scores button touched");
        [self presentHighScoresScene];
    }
}

#pragma mark - presenting scenes

- (void)presentGamePlayScene {
    PBMyScene *newGamePlay = [[PBMyScene alloc]initWithSize:CGSizeMake(320, 568)];
    newGamePlay.scaleMode = SKSceneScaleModeAspectFill;
    [self.view presentScene:newGamePlay];
}

- (void)presentHighScoresScene {
    PBHighScoresScene *highScoresScene = [PBHighScoresScene highScoresScene];
    highScoresScene.scaleMode = SKSceneScaleModeAspectFill;
    [self.view presentScene:highScoresScene];
}

- (void)presentMainMenu {
    PBGameStartScene *gameStartScene = [PBGameStartScene gameStartScene];
    gameStartScene.scaleMode = SKSceneScaleModeAspectFill;
    [self.view presentScene:gameStartScene];
}


@end
