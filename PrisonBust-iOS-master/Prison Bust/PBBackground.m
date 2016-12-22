//
//  PBBackground.m
//  Prison Bust
//
//  Created by Mac Admin on 4/23/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import "PBBackground.h"
static NSArray *bombArtilleryFrames = nil;
static NSArray *missileArtilleryFrames = nil;
static NSInteger backgroundZPosition = 1;
static NSInteger midgroundZPosition = 2;
static NSInteger foregroundZPosition = 3;
static NSString *midgroundImageName = @"prison_break_middleground_V02";
static NSString *backgroundImageName = @"prison_break_background_v02";
static NSString *foregroundImageName = @"prison_break_foreground_V02";
static NSString *midgroundNameShooter = @"midgroundWithShooter";

static SKAction *bombShooter = nil;
static SKAction *missileShooter = nil;
@interface PBBackground()
@property (strong, nonatomic) NSMutableArray *backgroundWithShooterFrames;

@end

@implementation PBBackground


- (void)setUp {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [PBBackground setUpBackgroundShooterAtlasBomb];
        [PBBackground setUpBackgroundShooterAtlasMissile];
        bombShooter = [PBBackground runBackgroundShooterAnimationBomb];
        missileShooter = [PBBackground runBackgroundShooterAnimationMissile];
    });
}

- (instancetype)init {
    if(self = [super init]) {
        [self setUp];
    }
    return self;
}

+ (instancetype)backgroundNode {
    
    PBBackground *backgroundNode = [[PBBackground alloc] initWithImageNamed:backgroundImageName];
    backgroundNode.blendMode = SKBlendModeReplace;
    //deal with this after getting images=====================================================================
    backgroundNode.yScale = 0.3;
    backgroundNode.xScale = 0.4;
    backgroundNode.anchorPoint = CGPointMake(0, 0);
    backgroundNode.position = CGPointMake(0, 190);
    //========================================================================================================
    
    backgroundNode.name = backgroundName;
    backgroundNode.zPosition = backgroundZPosition;
    
 
    return backgroundNode;
}

+ (instancetype)midgroundNode {
    PBBackground *midgroundNode = [[PBBackground alloc]initWithImageNamed:midgroundImageName];
    
    //========================================================================================================
    midgroundNode.xScale = 0.45;
    midgroundNode.yScale = 0.35;
    midgroundNode.position = CGPointMake(0, 204);
    midgroundNode.anchorPoint = CGPointMake(0, 0);
    //========================================================================================================
    
    midgroundNode.name = midgroundName;
    midgroundNode.zPosition = midgroundZPosition;
    midgroundNode.backgroundType = PBMidgroundTypeNormal;
    return midgroundNode;
    
}

+ (instancetype)midgroundNodeWithBombShooter {
    
    
    PBBackground *midgroundNodeShooter = [[PBBackground alloc]initWithImageNamed:midgroundImageName];
    //=================================================================
    midgroundNodeShooter.xScale = 0.45;
    midgroundNodeShooter.yScale = 0.35;
    midgroundNodeShooter.position = CGPointMake(0, 204);
    midgroundNodeShooter.anchorPoint = CGPointMake(0, 0);
    //=================================================================
    
        
    SKSpriteNode *bombArtillery = [SKSpriteNode spriteNodeWithImageNamed:@"cannon.001.png"];
    bombArtillery.position = CGPointMake(100,145);
    bombArtillery.name = @"bombArtillery";
    bombArtillery.zPosition = midgroundZPosition - 2.1;
    bombArtillery.xScale = 3;
    bombArtillery.yScale = 3;
    [midgroundNodeShooter addChild:bombArtillery];
  //  [midgroundNodeShooter setUpBackgroundShooterAtlasBomb];
    midgroundNodeShooter.zPosition = midgroundZPosition;
    midgroundNodeShooter.name = midgroundShooterNameBomb;
    midgroundNodeShooter.backgroundType = PBMidgroundTypeBomb;
    return midgroundNodeShooter;
}

+ (instancetype)midgroundNodeWithMissileShooter {
    PBBackground *midgroundNodeShooter = [[PBBackground alloc]initWithImageNamed:midgroundImageName];
    //=================================================================
    midgroundNodeShooter.xScale = 0.45;
    midgroundNodeShooter.yScale = 0.35;
    midgroundNodeShooter.position = CGPointMake(0, 205);
    midgroundNodeShooter.anchorPoint = CGPointMake(0, 0);
    //=================================================================
    
    
    SKSpriteNode *missileArtillery = [SKSpriteNode spriteNodeWithImageNamed:@"cannon.001.png"];
    missileArtillery.position = CGPointMake(midgroundNodeShooter.size.width * 1.65,180);
    missileArtillery.name = @"missileArtillery";
    missileArtillery.zPosition = midgroundZPosition - 2.1;
    missileArtillery.xScale = 2.3;
    missileArtillery.yScale = 2.3;
    [midgroundNodeShooter addChild:missileArtillery];
    midgroundNodeShooter.zPosition = midgroundZPosition;
    midgroundNodeShooter.name = midgroundShooterNameMissile;
    midgroundNodeShooter.backgroundType = PBMidgroundTypeMissile;
    return midgroundNodeShooter;
}

+ (instancetype)foregroundNode {
    PBBackground *foreground = [[PBBackground alloc]initWithImageNamed:foregroundImageName];
    foreground.zPosition = foregroundZPosition;
    foreground.yScale = .27;
    foreground.xScale = 0.5;
    foreground.name = foregroundName;
    foreground.position = CGPointMake(0, 192);
    foreground.anchorPoint = CGPointMake(0, 0);
    return foreground;
}

- (SKAction *)fireArtillery {
    switch (self.backgroundType) {
        case PBMidgroundTypeMissile:
            return missileShooter;
            break;
        case PBMidgroundTypeBomb:
            return bombShooter;
            break;
        default:
            break;
    }
    return nil;
}

+ (SKAction *)runBackgroundShooterAnimationMissile {
    SKAction *playSound = [SKAction playSoundFileNamed:@"firework_rocket_launch.mp3" waitForCompletion:NO];
    SKAction *waitAction = [SKAction waitForDuration:0.3];
    SKAction *repeatAction = [SKAction repeatAction:[SKAction sequence:@[playSound,waitAction]] count:3];
    SKAction *animateFrames = [SKAction animateWithTextures:missileArtilleryFrames timePerFrame:0.016 resize:YES restore:NO];
    return [SKAction group:@[repeatAction, animateFrames]];
}

+ (SKAction *)runBackgroundShooterAnimationBomb {
    return [SKAction animateWithTextures:bombArtilleryFrames timePerFrame:0.014 resize:YES restore:NO];
}

+ (void)setUpBackgroundShooterAtlasBomb {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *arr = [NSMutableArray new];
        SKTextureAtlas *backgroundwithShooterAtlas = [SKTextureAtlas atlasNamed:@"bombArtilleryV05"];
        for(int i = 1; i < backgroundwithShooterAtlas.textureNames.count; i++) {
            NSString *tempName;
            if(i < 10) {
                tempName = [NSString stringWithFormat:@"cannon.00%d.png" , i];
            } else if(i > 9 && i < 100) {
                tempName = [NSString stringWithFormat:@"cannon.0%d.png" , i];
            } else {
                tempName = [NSString stringWithFormat:@"cannon.%d.png" , i];
            }
            
            SKTexture *tempTexture = [backgroundwithShooterAtlas textureNamed:tempName];
            if(tempTexture) {
                [arr addObject:tempTexture];
            }
        }
        bombArtilleryFrames = arr;
    });

}

+ (void)setUpBackgroundShooterAtlasMissile {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *arr = [NSMutableArray new];
        SKTextureAtlas *backgoundShooterMissile = [SKTextureAtlas atlasNamed:@"rocket_launcherV04"];
        for(int i = 1; i < backgoundShooterMissile.textureNames.count; i++) {
            NSString *tempName;
            if(i < 10) {
                tempName = [NSString stringWithFormat:@"rocket_launcher.00%d.png" , i];
            } else if(i > 9 && i < 100) {
                tempName = [NSString stringWithFormat:@"rocket_launcher.0%d.png" , i];
            } else {
                tempName = [NSString stringWithFormat:@"rocket_launcher.%d.png" , i];
            }
            SKTexture *tempText = [backgoundShooterMissile textureNamed:tempName];
            if(tempText) {
                [arr addObject:tempText];
            }
        }
        missileArtilleryFrames = arr;
    });
}

@end
