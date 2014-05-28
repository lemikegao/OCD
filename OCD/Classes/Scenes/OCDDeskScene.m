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
@property (nonatomic, strong) OCDDraggableObject *blueCrayon;
@property (nonatomic, strong) OCDDraggableObject *greenCrayon;
@property (nonatomic, strong) OCDDraggableObject *yellowCrayon;

// Helpers
@property (nonatomic) NSInteger zPositionTracker;

@end

@implementation OCDDeskScene

- (id)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if (self)
    {
        self.backgroundColor = RGB(255, 255, 235);
        _zPositionTracker = 1;
        
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
    SKSpriteNode *paperSpriteNode = [SKSpriteNode spriteNodeWithImageNamed:@"desk-paper"];
    CGFloat targetPositionX = _writingOnDesk.position.x - _writingOnDesk.size.width/2 - paperSpriteNode.size.width/2;
    CGFloat targetPositionY = _writingOnDesk.position.y - 0.195*paperSpriteNode.size.height;
    _paper = [[OCDDraggableObject alloc] initWithRenderingNode:paperSpriteNode targetPosition:ccp(targetPositionX, targetPositionY)];
    _paper.delegate = self;
    _paper.position = ccp(self.size.width * 0.22, self.size.height * 0.52);
    [self addChild:_paper];
    
    // Crayons
    for (NSUInteger i=0; i<3; i++)
    {
        OCDDraggableObject *crayon;
        if (i == 0)
        {
            crayon = [[OCDDraggableObject alloc] initWithRenderingNode:[SKSpriteNode spriteNodeWithImageNamed:@"desk-crayon-blue"] targetPosition:CGPointZero];
            self.blueCrayon = crayon;
        }
        else if (i == 1)
        {
            crayon = [[OCDDraggableObject alloc] initWithRenderingNode:[SKSpriteNode spriteNodeWithImageNamed:@"desk-crayon-green"] targetPosition:CGPointZero];
            self.greenCrayon = crayon;
        }
        else
        {
            crayon = [[OCDDraggableObject alloc] initWithRenderingNode:[SKSpriteNode spriteNodeWithImageNamed:@"desk-crayon-yellow"] targetPosition:CGPointZero];
            self.yellowCrayon = crayon;
        }
        
        crayon.delegate = self;
        [self p_randomizeObject:crayon];
        [self addChild:crayon];
    }
}

- (void)p_randomizeObject:(OCDDraggableObject *)object
{
    // Randomize position within the bounds of the screen
    CGRect frame = [object calculateAccumulatedFrame];
    CGFloat randomX = arc4random() % (int)(self.size.width - frame.size.width) + frame.size.width/2;
    CGFloat randomY = arc4random() % (int)(self.size.height - frame.size.height) + frame.size.height/2;
    object.position = ccp(randomX, randomY);
}

#pragma mark - OCDDraggableDelegate methods
- (void)touchStartedOnDraggableObject:(OCDDraggableObject *)object
{
    NSString *shadowFilename;
    BOOL shouldUpdateZPosition = YES;
    if ([object isEqual:self.paper])
    {
        shouldUpdateZPosition = NO;
        shadowFilename = @"desk-paper-shadow";
    }
    else if ([object isEqual:self.blueCrayon])
    {
        shadowFilename = @"desk-crayon-blue-shadow";
    }
    else if ([object isEqual:self.greenCrayon])
    {
        shadowFilename = @"desk-crayon-green-shadow";
    }
    else if ([object isEqual:self.yellowCrayon])
    {
        shadowFilename = @"desk-crayon-yellow-shadow";
    }
    
    UIImage *dragImage = [UIImage imageNamed:shadowFilename];
    SKSpriteNode *renderingNode = (SKSpriteNode*)[object childNodeWithName:OCDDraggableObjectRenderingNodeName];
    renderingNode.texture = [SKTexture textureWithImage:dragImage];
    renderingNode.size = dragImage.size;
    
    if (shouldUpdateZPosition)
    {
        [self p_updateZPositionForObject:object];
    }
}

- (void)touchEndedOnDraggableObject:(OCDDraggableObject *)object
{
    NSString *normalFilename;
    if ([object isEqual:self.paper])
    {
        normalFilename = @"desk-paper";
    }
    else if ([object isEqual:self.blueCrayon])
    {
        normalFilename = @"desk-crayon-blue";
    }
    else if ([object isEqual:self.greenCrayon])
    {
        normalFilename = @"desk-crayon-green";
    }
    else if ([object isEqual:self.yellowCrayon])
    {
        normalFilename = @"desk-crayon-yellow";
    }
    
    UIImage *normalImage = [UIImage imageNamed:normalFilename];
    SKSpriteNode *renderingNode = (SKSpriteNode*)[object childNodeWithName:OCDDraggableObjectRenderingNodeName];
    renderingNode.texture = [SKTexture textureWithImage:normalImage];
    renderingNode.size = normalImage.size;
}

- (void)objectDidLockIntoPosition:(OCDDraggableObject *)object
{
    
}

#pragma mark - Helper methods
- (void)p_updateZPositionForObject:(SKNode *)object
{
    object.zPosition = self.zPositionTracker;
    self.zPositionTracker++;
}

@end
