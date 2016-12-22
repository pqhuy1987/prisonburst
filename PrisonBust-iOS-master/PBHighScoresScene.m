
//
//  PBHighScoresScene.m
//  Prison Bust
//
//  Created by Mac Admin on 5/19/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import "PBHighScoresScene.h"
#import "PBGameStartScene.h"
#import "PBHighScoreObject.h"

static NSString *highScoresButtonName = @"prison_break_highscores";
static NSString *mainMenuButtonName = @"main_menu_v02";
static NSString *highScoresBackgroundNodeName = @"prison_break_GAME_Highscores";

@interface PBHighScoresScene ()

@property (strong, nonatomic, readwrite) NSMutableArray *highScores;
@property (strong, nonatomic) SKSpriteNode *mainMenu;

@end

@implementation PBHighScoresScene {
    SKSpriteNode *_mainMenuButton;
    CGFloat _width;
}

#pragma mark - lifeCycle

- (id)init {
    if(self = [super init]) {
        [self listenForNewScore];
        [self addChild:self.mainMenu];
        [self addHighScoreLabel];
        self.highScores = [self loadScores];
        self.highScores = [PBHighScoreObject compareHighScores:self.highScores];
        _width = 0.5;
        [self presentScores:self.highScores];
    }
    return self;
}

//designated initializer
+ (instancetype)highScoresScene {
    PBHighScoresScene *highScoresScene = [PBHighScoresScene new];
    SKSpriteNode *backgroundImageNode = [PBHighScoresScene backgroundImageNode];
    backgroundImageNode.position = CGPointMake(0.5, 0.5);
    [highScoresScene addChild:backgroundImageNode];
    
    return highScoresScene;
}

#pragma mark - convenience

- (SKSpriteNode *)highScoresLabel {
    SKSpriteNode *highScoresNode = [SKSpriteNode spriteNodeWithImageNamed:highScoresButtonName];
    highScoresNode.position = CGPointMake(0.5, 0.75);
    highScoresNode.xScale = 0.001;
    highScoresNode.yScale = 0.0009;
    highScoresNode.zPosition = 11;
    highScoresNode.name = @"highScoreNode";
    return highScoresNode;
}

+ (SKSpriteNode *)backgroundImageNode {
    SKSpriteNode *backgroundImageNode = [SKSpriteNode spriteNodeWithImageNamed:highScoresBackgroundNodeName];
    backgroundImageNode.xScale = 0.001;
    backgroundImageNode.yScale = 0.001;
    return backgroundImageNode;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event    {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    
    if([_mainMenu containsPoint:touchLocation]) {
        NSLog(@"main menu pressed");
        [self presentMainMenu];
    }
}

- (void)presentMainMenu {
    PBGameStartScene *gameStartScene = [PBGameStartScene gameStartScene];
    gameStartScene.scaleMode = SKSceneScaleModeAspectFill;
    [self.view presentScene:gameStartScene];
}

- (void)addHighScoreLabel{
    SKSpriteNode *highScoreLabel = [SKSpriteNode spriteNodeWithImageNamed:@"highscores banner"];
    highScoreLabel.position = CGPointMake(self.size.width/2, self.size.height/1.78);
    highScoreLabel.xScale = 0.001;
    highScoreLabel.yScale = 0.001;
    highScoreLabel.zPosition = 10;
    [self addChild:highScoreLabel];
}

#pragma mark - loading, unloading, and presenting scores

- (void)addHighScore:(PBHighScoreObject *)highScoreObj {
    [self.highScores addObject:highScoreObj];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *highScoreData = [NSKeyedArchiver archivedDataWithRootObject:self.highScores];
    [defaults setObject:highScoreData forKey:@"highScores"];
    [defaults synchronize];
}

- (NSMutableArray *)loadScores {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *scoreData = [defaults objectForKey:@"highScores"];
    NSMutableArray *scoreArr = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:scoreData]];
    return scoreArr;
}

- (SKLabelNode *) makeDropShadowString:(NSString *) myString
{
    int offSetX = 3;
    int offSetY = 3;
    
    SKLabelNode *completedString = [SKLabelNode labelNodeWithFontNamed:@"Verdana-Bold"];
    completedString.fontSize = 30.0f;
    completedString.fontColor = [SKColor whiteColor];
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

- (void)presentScores:(NSMutableArray *)scoresArray {

    if(scoresArray.count < 6) {
        [scoresArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Verdana-Bold"];
            scoreLabel = [self makeDropShadowString:[NSString stringWithFormat:@"%@" , obj]];
            scoreLabel.text = [NSString stringWithFormat:@"%@" , obj];
#warning issue with high score display. find way to make position right aligned!
            scoreLabel.position = CGPointMake(_width , self.size.height/1.6 - (idx * .07));
            scoreLabel.xScale = 0.001;
            scoreLabel.yScale = 0.001;
            scoreLabel.zPosition = 11;
            [self addChild:scoreLabel];
        }];
    } else {
        scoresArray = [PBHighScoreObject compareHighScores:scoresArray];
        [self presentScores:scoresArray];
    }
}

#pragma mark - listener

- (void)listenForNewScore {
    NSNotificationCenter *notifyCenter = [NSNotificationCenter defaultCenter];
    [notifyCenter addObserverForName:@"newHighScoreAdded" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self addHighScore:note.object];
    }];
}

#pragma mark - lazy loading

- (SKSpriteNode *)mainMenu {
    if(!_mainMenu) {
        SKSpriteNode *mainMenuButton = [SKSpriteNode spriteNodeWithImageNamed:mainMenuButtonName];
        mainMenuButton.position = CGPointMake(0.5, 0.28);
        mainMenuButton.xScale = 0.0008;
        mainMenuButton.yScale = 0.0008;
        mainMenuButton.zPosition = 10;
        mainMenuButton.alpha = 0.8;
        _mainMenu = mainMenuButton;
    }
    return _mainMenu;
}

- (NSMutableArray *)highScores  {
    if (!_highScores) {
        _highScores = [NSMutableArray array];
    }
    return _highScores;
}

@end
