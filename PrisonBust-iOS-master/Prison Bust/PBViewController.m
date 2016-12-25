//
//  PBViewController.m
//  Prison Bust
//
//  Created by Mac Admin on 4/23/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import "PBViewController.h"
#import "PBMyScene.h"
#import "PBGameOverLayer.h"
#import "PBGameStartScene.h"

#import "PBFence.h"
#import "PBMissle.h"

@implementation PBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    
    // Show debug information.
    skView.showsFPS = NO;
    skView.showsDrawCount = NO;
    skView.showsNodeCount = NO;
  //  skView.showsPhysics = YES;

    // Create and configure the scene.
    SKScene * scene = [PBGameStartScene gameStartScene];
    
    scene.scaleMode = SKSceneScaleModeAspectFill;
    [skView presentScene:scene];
    
}

- (BOOL)shouldAutorotate
{
    return YES;
}


- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}





@end
