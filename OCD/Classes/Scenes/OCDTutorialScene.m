//
//  OCDTutorialScene.m
//  OCD
//
//  Created by Michael Gao on 5/10/14.
//  Copyright (c) 2014 Chin and Cheeks. All rights reserved.
//

#import "OCDTutorialScene.h"

@implementation OCDTutorialScene

- (id)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if (self)
    {
        // Set up background
        self.backgroundColor = RGB(255, 255, 235);
        
        [self p_setupDashedPlaceholders];
        
        // Play music
        [[OCDGameManager sharedGameManager] playBackgroundMusic:@"tutorial-music.mp3"];
    }
    
    return self;
}

- (void)p_setupDashedPlaceholders
{
    SKSpriteNode *dashedO = [SKSpriteNode spriteNodeWithImageNamed:@"ocd-letter-dotted-o"];
    dashedO.position = ccp(self.size.width * 0.33, self.size.height * 0.5);
    [self addChild:dashedO];
}

@end
