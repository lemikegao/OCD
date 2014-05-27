//
//  OCDDeskScene.m
//  OCD
//
//  Created by Michael Gao on 5/26/14.
//  Copyright (c) 2014 Chin and Cheeks. All rights reserved.
//

#import "OCDDeskScene.h"
#import "OCDDraggableObject.h"

@interface OCDDeskScene() <OCDDraggableObjectDelegate>

// Static objects
@property (nonatomic, strong) SKSpriteNode *coffeeStain;
@property (nonatomic, strong) SKSpriteNode *writingOnDesk;

// Draggable objects
@property (nonatomic, strong) OCDDraggableObject *paper;

@end

@implementation OCDDeskScene

- (id)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if (self)
    {
        self.backgroundColor = RGB(255, 255, 235);
        
        [self p_setupObjects];
    }
    
    return self;
}

- (void)p_setupObjects
{
    // Coffee stain
    _coffeeStain = [SKSpriteNode spriteNodeWithImageNamed:@"desk-stain"];
    _coffeeStain.position = ccp(self.size.width * 0.2, self.size.height * 0.7);
    [self addChild:_coffeeStain];
    
    // Writing on desk
    _writingOnDesk = [SKSpriteNode spriteNodeWithImageNamed:@"desk-text"];
    _writingOnDesk.position = ccp(self.size.width * 0.9, self.size.height * 0.38);
    [self addChild:_writingOnDesk];
    
    // Paper
#warning - TODO: Update target position
    _paper = [[OCDDraggableObject alloc] initWithRenderingNode:[SKSpriteNode spriteNodeWithImageNamed:@"desk-paper"] targetPosition:CGPointZero];
    _paper.delegate = self;
    _paper.position = ccp(self.size.width * 0.22, self.size.height * 0.52);
    [self addChild:_paper];
}

#pragma mark - OCDDraggableDelegate methods
- (void)touchStartedOnDraggableObject:(OCDDraggableObject *)object
{
    NSString *shadowFilename;
    if ([object isEqual:self.paper])
    {
        shadowFilename = @"desk-paper-shadow";
    }
    UIImage *dragImage = [UIImage imageNamed:shadowFilename];
    SKSpriteNode *renderingNode = (SKSpriteNode*)[object childNodeWithName:OCDDraggableObjectRenderingNodeName];
    renderingNode.texture = [SKTexture textureWithImage:dragImage];
    renderingNode.size = dragImage.size;
}

- (void)touchEndedOnDraggableObject:(OCDDraggableObject *)object
{
    NSString *normalFilename;
    if ([object isEqual:self.paper])
    {
        normalFilename = @"desk-paper";
    }
    UIImage *normalImage = [UIImage imageNamed:normalFilename];
    SKSpriteNode *renderingNode = (SKSpriteNode*)[object childNodeWithName:OCDDraggableObjectRenderingNodeName];
    renderingNode.texture = [SKTexture textureWithImage:normalImage];
    renderingNode.size = normalImage.size;
}

- (void)objectDidLockIntoPosition:(OCDDraggableObject *)object
{
    
}

@end
