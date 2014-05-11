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

@property (nonatomic, strong) NSMutableSet *objectSet;

@end

@implementation OCDTutorialScene

- (id)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if (self)
    {
        // Init
        _objectSet = [[NSMutableSet alloc] initWithCapacity:3];
        
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
    SKSpriteNode *dashedO = [SKSpriteNode spriteNodeWithImageNamed:@"ocd-letter-dotted-o"];
    dashedO.position = ccp(self.size.width * 0.2, self.size.height * 0.5);
    [self addChild:dashedO];
    
    // Letter 'C'
    SKSpriteNode *dashedC = [SKSpriteNode spriteNodeWithImageNamed:@"ocd-letter-dotted-c"];
    dashedC.position = ccp(self.size.width * 0.5, dashedO.position.y);
    [self addChild:dashedC];
    
    // Letter 'D'
    SKSpriteNode *dashedD = [SKSpriteNode spriteNodeWithImageNamed:@"ocd-letter-dotted-d"];
    dashedD.position = ccp(self.size.width * 0.8, dashedO.position.y);
    [self addChild:dashedD];
}

- (void)p_setupColoredLetters
{
    // Letter 'O'
    OCDDraggableObject *coloredO = [[OCDDraggableObject alloc] initWithRenderingNode:[SKSpriteNode spriteNodeWithImageNamed:@"ocd-letter-o"]];
    [self addChild:coloredO];
    
    // Letter 'C'
    OCDDraggableObject *coloredC = [[OCDDraggableObject alloc] initWithRenderingNode:[SKSpriteNode spriteNodeWithImageNamed:@"ocd-letter-c"]];
    [self addChild:coloredC];
    
    // Letter 'D'
    OCDDraggableObject *coloredD = [[OCDDraggableObject alloc] initWithRenderingNode:[SKSpriteNode spriteNodeWithImageNamed:@"ocd-letter-d"]];
    [self addChild:coloredD];
    
    [self.objectSet addObjectsFromArray:@[coloredO, coloredC, coloredD]];
}

- (void)p_randomizeObjects
{
    // Randomize position within the bounds of the screen & randomize rotation
    [self.objectSet enumerateObjectsUsingBlock:^(OCDDraggableObject *obj, BOOL *stop) {
        // Position
        CGFloat randomX = arc4random() % ([@(self.size.width - obj.renderingNode.size.width) intValue]) + obj.renderingNode.size.width/2;
        CGFloat randomY = arc4random() % ([@(self.size.height - obj.renderingNode.size.height) intValue]) + obj.renderingNode.size.height/2;
        obj.position = CGPointMake(randomX, randomY);
    }];
}

@end
