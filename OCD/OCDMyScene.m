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
@property (nonatomic, strong) SKSpriteNode *selectedNode;
@property (nonatomic, strong) SKSpriteNode *previousSelectedNode;

@end

static NSUInteger const kNumObjects = 4;
static NSString *const kNodeNameBackground = @"kNodeNameBackground";
static NSString *const kNodeNameBorder = @"kNodeNameBorder";
static NSInteger const kZIndexDefaultObject = 1;
static NSInteger const kZIndexSelectedObject = 10;
static NSInteger const kZIndexFront = 1000;

@implementation OCDMyScene

- (id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];

    if (self)
    {
        // Init
        _objectSet = [[NSMutableSet alloc] initWithCapacity:kNumObjects];
        _selectedNode = nil;
        _previousSelectedNode = nil;
        
        // Background
        SKSpriteNode *backgroundImage = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
        backgroundImage.name = kNodeNameBackground;
        backgroundImage.anchorPoint = CGPointMake(0, 1);
        backgroundImage.position = CGPointMake(0, size.height);
        [self addChild:backgroundImage];
        
        // Initial objects
        for (NSUInteger i=0; i<kNumObjects; i++)
        {
            SKSpriteNode *object = [SKSpriteNode spriteNodeWithImageNamed:@"object"];
            object.zPosition = kZIndexDefaultObject;
            [_objectSet addObject:object];
            [self addChild:object];
        }
        
        // Randomize objects
        [self p_randomizeObjects:nil];
        
        // Reset button
        SKButton *resetButton = [SKButton buttonWithImageNamedNormal:@"button-reset" selected:nil];
        resetButton.zPosition = kZIndexFront;
        resetButton.anchorPoint = CGPointMake(1, 1);
        resetButton.position = CGPointMake(self.size.width * 0.98, self.size.height * 0.98);
        [resetButton setTouchUpInsideTarget:self action:@selector(p_randomizeObjects:)];
        [self addChild:resetButton];
    }
    
    return self;
}

- (void)didMoveToView:(SKView *)view
{
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
}

- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint touchLocation = [recognizer locationInView:recognizer.view];
        touchLocation = [self convertPointFromView:touchLocation];
        
        [self p_selectNodeForTouch:touchLocation];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [recognizer translationInView:recognizer.view];
        translation = CGPointMake(translation.x, -translation.y);
        [self p_panForTranslation:translation];
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        // Remove border
        [self.selectedNode removeAllChildren];
        
//        CGFloat scrollDuration = 0.5f;
//        CGFloat damping = 0.2f;
//        CGPoint velocity = [recognizer velocityInView:recognizer.view];
//        CGPoint pos = self.selectedNode.position;
//        CGPoint p = CGPointMake(velocity.x * scrollDuration * damping, velocity.y * scrollDuration * damping);
//        
//        CGPoint newPos = [self p_positionWithinBoundsForPosition:CGPointMake(pos.x + p.x, pos.y - p.y)];
//        [self.selectedNode removeAllActions];
//        
//        SKAction *moveTo = [SKAction moveTo:newPos duration:scrollDuration];
//        [moveTo setTimingMode:SKActionTimingEaseOut];
//        [self.selectedNode runAction:moveTo];
        
        self.previousSelectedNode = self.selectedNode;
        self.selectedNode = nil;
    }
}

#pragma mark - Touch detection
- (void)p_selectNodeForTouch:(CGPoint)touchLocation
{
    SKSpriteNode *touchedNode = (SKSpriteNode *)[self nodeAtPoint:touchLocation];
    if ([touchedNode.name isEqual:kNodeNameBackground] == NO)
    {
        if ([self.selectedNode isEqual:touchedNode] == NO)
        {
            // Move previous selected node back and new selected node forward
            self.previousSelectedNode.zPosition = kZIndexDefaultObject;
            touchedNode.zPosition = kZIndexSelectedObject;
            self.selectedNode = touchedNode;
            
            // Add border to selectedNode
            SKShapeNode *border = [SKShapeNode new];
            border.name = kNodeNameBorder;
            border.path = CGPathCreateWithRect(CGRectMake(-touchedNode.size.width/2, -touchedNode.size.height/2, touchedNode.size.width, touchedNode.size.height), NULL);
            border.strokeColor = [UIColor yellowColor];
            [touchedNode addChild:border];
        }
    }
}

- (void)p_panForTranslation:(CGPoint)translation
{
    CGPoint position = self.selectedNode.position;
    self.selectedNode.position = [self p_positionWithinBoundsForPosition:CGPointMake(position.x + translation.x, position.y + translation.y)];
}

- (CGPoint)p_positionWithinBoundsForPosition:(CGPoint)newPos
{
    CGPoint retVal = newPos;
    CGFloat nodeWidth = self.selectedNode.size.width;
    CGFloat nodeHeight = self.selectedNode.size.height;
    
    if (newPos.x < nodeWidth/2)
    {
        retVal.x = nodeWidth/2;
    }
    else if (newPos.x > self.size.width - nodeWidth/2)
    {
        retVal.x = self.size.width - nodeWidth/2;
    }
    
    if (newPos.y < nodeHeight/2)
    {
        retVal.y = nodeHeight/2;
    }
    else if (newPos.y > self.size.height - nodeHeight/2)
    {
        retVal.y = self.size.height - nodeHeight/2;
    }
    
    return retVal;
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
