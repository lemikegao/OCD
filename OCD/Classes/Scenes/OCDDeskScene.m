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
    
    // Crayon outlines
    _blueCrayonOutline = [SKSpriteNode spriteNodeWithImageNamed:@"desk-crayon-blue-outline"];
    _blueCrayonOutline.position = ccp(self.size.width * 0.14, self.size.height * 0.25);
    [self addChild:_blueCrayonOutline];
    
    _greenCrayonOutline = [SKSpriteNode spriteNodeWithImageNamed:@"desk-crayon-green-outline"];
    _greenCrayonOutline.position = ccp(self.size.width * 0.20, _blueCrayonOutline.position.y);
    [self addChild:_greenCrayonOutline];
    
    _yellowCrayonOutline = [SKSpriteNode spriteNodeWithImageNamed:@"desk-crayon-yellow-outline"];
    _yellowCrayonOutline.position = ccp(self.size.width * 0.26, _blueCrayonOutline.position.y);
    [self addChild:_yellowCrayonOutline];
    
    // Paper
    SKSpriteNode *paperSpriteNode = [SKSpriteNode spriteNodeWithImageNamed:@"desk-paper"];
    CGFloat targetPositionX = _writingOnDesk.position.x - _writingOnDesk.size.width/2 - paperSpriteNode.size.width/2;
    CGFloat targetPositionY = _writingOnDesk.position.y - 0.0515*paperSpriteNode.size.height;
    _paper = [[OCDDraggableObject alloc] initWithRenderingNode:paperSpriteNode targetPosition:ccp(targetPositionX, targetPositionY)];
    _paper.delegate = self;
    _paper.position = ccp(self.size.width * 0.24, self.size.height * 0.59);
    [self addChild:_paper];
    
    // Crayons
    for (NSUInteger i=0; i<3; i++)
    {
        OCDDraggableObject *crayon;
        if (i == 0)
        {
            crayon = [[OCDDraggableObject alloc] initWithRenderingNode:[SKSpriteNode spriteNodeWithImageNamed:@"desk-crayon-blue"] targetPosition:self.blueCrayonOutline.position];
            self.blueCrayon = crayon;
            crayon.position = ccp(self.size.width * 0.62, self.size.height * 0.22);
        }
        else if (i == 1)
        {
            crayon = [[OCDDraggableObject alloc] initWithRenderingNode:[SKSpriteNode spriteNodeWithImageNamed:@"desk-crayon-green"] targetPosition:self.greenCrayonOutline.position];
            self.greenCrayon = crayon;
            crayon.position = ccp(self.size.width * 0.69, self.size.height * 0.16);
        }
        else
        {
            crayon = [[OCDDraggableObject alloc] initWithRenderingNode:[SKSpriteNode spriteNodeWithImageNamed:@"desk-crayon-yellow"] targetPosition:self.yellowCrayonOutline.position];
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
        [self.blueCrayonOutline removeFromParent];
    }
    else if ([object isEqual:self.greenCrayon])
    {
        [self.greenCrayonOutline removeFromParent];
    }
    else if ([object isEqual:self.yellowCrayon])
    {
        [self.yellowCrayonOutline removeFromParent];
    }
}

#pragma mark - Helper methods
- (void)p_updateZPositionForObject:(SKNode *)object
{
    object.zPosition = self.zPositionTracker;
    self.zPositionTracker++;
}

@end
