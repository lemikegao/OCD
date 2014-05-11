//
//  OCDTutorialScene.m
//  OCD
//
//  Created by Michael Gao on 5/10/14.
//  Copyright (c) 2014 Chin and Cheeks. All rights reserved.
//

#import "OCDTutorialScene.h"
#import "OCDDraggableObject.h"

@interface OCDTutorialScene()

@property (nonatomic, strong) SKSpriteNode *dashedO;
@property (nonatomic, strong) SKSpriteNode *dashedC;
@property (nonatomic, strong) SKSpriteNode *dashedD;

@property (nonatomic, strong) OCDDraggableObject *coloredO;
@property (nonatomic, strong) OCDDraggableObject *coloredC;
@property (nonatomic, strong) OCDDraggableObject *coloredD;

@end

@implementation OCDTutorialScene

- (id)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if (self)
    {
        // Set up background
        self.backgroundColor = RGB(255, 255, 235);
        
        // Set up level
        [self p_setupDashedPlaceholders];
        [self p_setupColoredLetters];
        [self p_randomizeObjects];
        
        // Play music
        [[OCDGameManager sharedGameManager] playBackgroundMusic:@"tutorial-music.mp3"];
    }
    
    return self;
}

- (void)p_setupDashedPlaceholders
{
    // Letter 'O'
    _dashedO = [SKSpriteNode spriteNodeWithImageNamed:@"ocd-letter-dotted-o"];
    _dashedO.position = ccp(self.size.width * 0.2, self.size.height * 0.5);
    [self addChild:_dashedO];
    
    // Letter 'C'
    _dashedC = [SKSpriteNode spriteNodeWithImageNamed:@"ocd-letter-dotted-c"];
    _dashedC.position = ccp(self.size.width * 0.5, _dashedO.position.y);
    [self addChild:_dashedC];
    
    // Letter 'D'
    _dashedD = [SKSpriteNode spriteNodeWithImageNamed:@"ocd-letter-dotted-d"];
    _dashedD.position = ccp(self.size.width * 0.8, _dashedO.position.y);
    [self addChild:_dashedD];
}

- (void)p_setupColoredLetters
{
    // Letter 'O'
    _coloredO = [[OCDDraggableObject alloc] initWithRenderingNode:[SKSpriteNode spriteNodeWithImageNamed:@"ocd-letter-o"]];
    [self addChild:_coloredO];
    
    // Letter 'C'
    _coloredC = [[OCDDraggableObject alloc] initWithRenderingNode:[SKSpriteNode spriteNodeWithImageNamed:@"ocd-letter-c"]];
    [self addChild:_coloredC];
    
    // Letter 'D'
    _coloredD = [[OCDDraggableObject alloc] initWithRenderingNode:[SKSpriteNode spriteNodeWithImageNamed:@"ocd-letter-d"]];
    [self addChild:_coloredD];
}

- (void)p_randomizeObjects
{
    // Randomize position within the bounds of the screen
    CGFloat randomX = arc4random() % (int)_coloredO.renderingNode.size.width + (_dashedO.position.x - _coloredO.renderingNode.size.width/3);
    CGFloat randomY = arc4random() % (int)(self.size.height - _coloredO.renderingNode.size.height) + _coloredO.renderingNode.size.height/2;
    _coloredO.position = CGPointMake(randomX, randomY);
    
    randomX = arc4random() % (int)_coloredC.renderingNode.size.width + (_dashedC.position.x - _coloredC.renderingNode.size.width/2);
    randomY = arc4random() % (int)(self.size.height - _coloredC.renderingNode.size.height) + _coloredC.renderingNode.size.height/2;
    _coloredC.position = CGPointMake(randomX, randomY);
    
    randomX = arc4random() % (int)_coloredD.renderingNode.size.width + (_dashedD.position.x - _coloredD.renderingNode.size.width/2);
    randomY = arc4random() % (int)(self.size.height - _coloredD.renderingNode.size.height) + _coloredD.renderingNode.size.height/2;
    _coloredD.position = CGPointMake(randomX, randomY);
}

@end
