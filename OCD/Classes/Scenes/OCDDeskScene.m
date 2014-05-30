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
@property (nonatomic, strong) SKSpriteNode *blueCrayonOutline;
@property (nonatomic, strong) SKSpriteNode *greenCrayonOutline;
@property (nonatomic, strong) SKSpriteNode *yellowCrayonOutline;

// Draggable objects
@property (nonatomic, strong) OCDDraggableObject *paper;
@property (nonatomic, strong) OCDDraggableObject *blueCrayon;
@property (nonatomic, strong) OCDDraggableObject *greenCrayon;
@property (nonatomic, strong) OCDDraggableObject *yellowCrayon;
@property (nonatomic, strong) OCDDraggableObject *mug;

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
    _paper.position = ccp(self.size.width * 0.24, self.size.height * 0.59);
    [self addChild:_paper];
    
    // Crayon outlines
    _blueCrayonOutline = [SKSpriteNode spriteNodeWithImageNamed:@"desk-crayon-blue-outline"];
    _blueCrayonOutline.position = ccp(-self.size.width * 0.02, -self.size.height * 0.043);
    [_paper addChild:_blueCrayonOutline];
    
    _greenCrayonOutline = [SKSpriteNode spriteNodeWithImageNamed:@"desk-crayon-green-outline"];
    _greenCrayonOutline.position = ccp(self.size.width * 0.03, _blueCrayonOutline.position.y);
    [_paper addChild:_greenCrayonOutline];
    
    _yellowCrayonOutline = [SKSpriteNode spriteNodeWithImageNamed:@"desk-crayon-yellow-outline"];
    _yellowCrayonOutline.position = ccp(self.size.width * 0.08, _blueCrayonOutline.position.y);
    [_paper addChild:_yellowCrayonOutline];
    
    // Crayons
    for (NSUInteger i=0; i<3; i++)
    {
        OCDDraggableObject *crayon;
        if (i == 0)
        {
            crayon = [[OCDDraggableObject alloc] initWithRenderingNode:[SKSpriteNode spriteNodeWithImageNamed:@"desk-crayon-blue"] targetPosition:CGPointMake(self.paper.position.x + self.blueCrayonOutline.position.x, self.paper.position.y + self.blueCrayonOutline.position.y)];
            self.blueCrayon = crayon;
            crayon.position = ccp(self.size.width * 0.62, self.size.height * 0.22);
        }
        else if (i == 1)
        {
            crayon = [[OCDDraggableObject alloc] initWithRenderingNode:[SKSpriteNode spriteNodeWithImageNamed:@"desk-crayon-green"] targetPosition:CGPointMake(self.paper.position.x + self.greenCrayonOutline.position.x, self.paper.position.y + self.greenCrayonOutline.position.y)];
            self.greenCrayon = crayon;
            crayon.position = ccp(self.size.width * 0.69, self.size.height * 0.16);
        }
        else
        {
            crayon = [[OCDDraggableObject alloc] initWithRenderingNode:[SKSpriteNode spriteNodeWithImageNamed:@"desk-crayon-yellow"] targetPosition:CGPointMake(self.paper.position.x + self.yellowCrayonOutline.position.x, self.paper.position.y + self.yellowCrayonOutline.position.y)];
            self.yellowCrayon = crayon;
            crayon.position = ccp(self.size.width * 0.55, self.size.height * 0.18);
        }
        
        crayon.delegate = self;
        [self addChild:crayon];
    }
    
    // Mug
    _mug = [[OCDDraggableObject alloc] initWithRenderingNode:[SKSpriteNode spriteNodeWithImageNamed:@"desk-mug"] targetPosition:_coffeeStain.position];
    _mug.position = ccp(self.size.width * 0.78, self.size.height * 0.73);
    _mug.delegate = self;
    [self addChild:_mug];
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
    else if ([object isEqual:self.mug])
    {
        shadowFilename = @"desk-mug-shadow";
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
        [self p_updateCrayonTargetPositions];
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
    else if ([object isEqual:self.mug])
    {
        normalFilename = @"desk-mug";
    }
    
    UIImage *normalImage = [UIImage imageNamed:normalFilename];
    SKSpriteNode *renderingNode = (SKSpriteNode*)[object childNodeWithName:OCDDraggableObjectRenderingNodeName];
    renderingNode.texture = [SKTexture textureWithImage:normalImage];
    renderingNode.size = normalImage.size;
}

- (void)objectDidLockIntoPosition:(OCDDraggableObject *)object
{
    if ([object isEqual:self.blueCrayon])
    {
        SKSpriteNode *blueCrayonSprite = [SKSpriteNode spriteNodeWithImageNamed:@"desk-crayon-blue"];
        blueCrayonSprite.position = self.blueCrayonOutline.position;
        [self.paper addChild:blueCrayonSprite];
        
        [self.blueCrayonOutline removeFromParent];
        [self.blueCrayon removeFromParent];
        self.blueCrayon = nil;
    }
    else if ([object isEqual:self.greenCrayon])
    {
        SKSpriteNode *greenCrayonSprite = [SKSpriteNode spriteNodeWithImageNamed:@"desk-crayon-green"];
        greenCrayonSprite.position = self.greenCrayonOutline.position;
        [self.paper addChild:greenCrayonSprite];
        
        [self.greenCrayonOutline removeFromParent];
        [self.greenCrayon removeFromParent];
        self.greenCrayon = nil;
    }
    else if ([object isEqual:self.yellowCrayon])
    {
        SKSpriteNode *yellowCrayonSprite = [SKSpriteNode spriteNodeWithImageNamed:@"desk-crayon-yellow"];
        yellowCrayonSprite.position = self.yellowCrayonOutline.position;
        [self.paper addChild:yellowCrayonSprite];
        
        [self.yellowCrayonOutline removeFromParent];
        [self.yellowCrayon removeFromParent];
        self.yellowCrayon = nil;
    }
}

#pragma mark - Helper methods
- (void)p_updateZPositionForObject:(SKNode *)object
{
    object.zPosition = self.zPositionTracker;
    self.zPositionTracker++;
}

- (void)p_updateCrayonTargetPositions
{
    CGPoint paperPosition = self.paper.position;
    self.blueCrayon.lockPositionComponent.targetPosition = CGPointMake(paperPosition.x + self.blueCrayonOutline.position.x, paperPosition.y + self.blueCrayonOutline.position.y);
    self.greenCrayon.lockPositionComponent.targetPosition = CGPointMake(paperPosition.x + self.greenCrayonOutline.position.x, paperPosition.y + self.greenCrayonOutline.position.y);
    self.yellowCrayon.lockPositionComponent.targetPosition = CGPointMake(paperPosition.x + self.yellowCrayonOutline.position.x, paperPosition.y + self.yellowCrayonOutline.position.y);
}

@end
