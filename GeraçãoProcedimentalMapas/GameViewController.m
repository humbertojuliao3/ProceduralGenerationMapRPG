//
//  GameViewController.m
//  GeraçãoProcedimentalMapas
//
//  Created by Humberto  Julião on 10/10/17.
//  Copyright © 2017 Humberto Julião. All rights reserved.
//

#import "GameViewController.h"
#import "MyScene.h"

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    skView.showsDrawCount = YES;
    
    SKScene * scene = [MyScene sceneWithSize: CGSizeMake(skView.bounds.size.width*2, skView.bounds.size.height*2)];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    
    [skView presentScene:scene];
    
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
