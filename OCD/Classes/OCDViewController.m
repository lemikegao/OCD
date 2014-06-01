//
//  OCDViewController.m
//  OCD
//
//  Created by Michael Gao on 4/26/14.
//  Copyright (c) 2014 Chin and Cheeks. All rights reserved.
//

#import "OCDViewController.h"
#import "OCDPrototypeScene.h"
#import "OCDTutorialScene.h"
#import "OCDDeskScene.h"

@implementation OCDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // Configure the view in viewWillLayoutSubviews so bounds.size accomodates landscape orientation
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Add version (build) label
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, skView.bounds.size.height - 12, 100, 12)];
    versionLabel.font = [UIFont fontWithName:@"Helvetica" size:10];
    versionLabel.backgroundColor = [UIColor clearColor];
    versionLabel.textColor = [UIColor blackColor];
    versionLabel.text = [NSString stringWithFormat:@"v%@ (%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    [skView addSubview:versionLabel];
    
    // Create and configure the scene.
//    SKScene *scene = [OCDPrototypeScene sceneWithSize:skView.bounds.size];
    SKScene *scene = [OCDTutorialScene sceneWithSize:skView.bounds.size];
//    SKScene *scene = [OCDDeskScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeLeft;
}

@end
