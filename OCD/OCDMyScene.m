//
//  OCDMyScene.m
//  OCD
//
//  Created by Michael Gao on 4/26/14.
//  Copyright (c) 2014 Chin and Cheeks. All rights reserved.
//

#import "OCDMyScene.h"

@interface OCDMyScene()

@property (nonatomic, strong) NSMutableSet *objectSet;

@end

static NSUInteger const numObjects = 4;

@implementation OCDMyScene

- (id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];

    if (self)
    {
        // Init
        _objectSet = [[NSMutableSet alloc] initWithCapacity:numObjects];
        
        // Background
        SKSpriteNode *backgroundImage = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
        backgroundImage.anchorPoint = CGPointMake(0, 1);
        backgroundImage.position = CGPointMake(0, size.height);
        [self addChild:backgroundImage];
        
        // Initial objects
        for (NSUInteger i=0; i<numObjects; i++)
        {
            SKSpriteNode *object = [SKSpriteNode spriteNodeWithImageNamed:@"object"];
            [_objectSet addObject:object];
            [self addChild:object];
        }
        
        // Randomize objects
        [self p_randomizeObjects:nil];
        
        // Reset button
        SKButton *resetButton = [SKButton buttonWithImageNamedNormal:@"button-reset" selected:nil];
        resetButton.anchorPoint = CGPointMake(1, 1);
        resetButton.position = CGPointMake(self.size.width * 0.98, self.size.height * 0.98);
        [resetButton setTouchUpInsideTarget:self action:@selector(p_randomizeObjects:)];
        [self addChild:resetButton];
    }
    
    return self;
}

- (void)p_randomizeObjects:(id)sender
{
    // Randomize position within the bounds of the screen & randomize rotation
    [self.objectSet enumerateObjectsUsingBlock:^(SKSpriteNode *obj, BOOL *stop) {
        // Position
        CGFloat randomX = arc4random() % ([@(self.size.width - obj.size.width) intValue]) + obj.size.width/2;
        CGFloat randomY = arc4random() % ([@(self.size.height - obj.size.height) intValue]) + obj.size.height/2;
        obj.position = CGPointMake(randomX, randomY);
        
        // Rotation
        CGFloat randomDegrees = arc4random() % 360;
        obj.zRotation = DegreesToRadians(randomDegrees);
    }];
}

- (void)update:(CFTimeInterval)currentTime
{

}

@end
