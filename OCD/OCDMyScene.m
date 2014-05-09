//
//  OCDMyScene.m
//  OCD
//
//  Created by Michael Gao on 4/26/14.
//  Copyright (c) 2014 Chin and Cheeks. All rights reserved.
//

#import "OCDMyScene.h"
#import "CNCOneFingerRotationGestureRecognizer.h"
#import "OCDGameObject.h"

@interface OCDMyScene() <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSMutableSet *objectSet;
@property (nonatomic, strong) OCDGameObject *selectedNode;
@property (nonatomic, strong) OCDGameObject *tappedNode;
@property (nonatomic, strong) SKSpriteNode *rotationSymbol;
@property (nonatomic, strong) SKLabelNode *tappedNodeNameLabel;
@property (nonatomic, assign) CGFloat tappedNodeRotationRemainder;

// Gesture recognizers
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGestureRecognizer;
@property (nonatomic, strong) CNCOneFingerRotationGestureRecognizer *rotationGestureRecognizer;

@end

static NSUInteger const kNumObjects = 4;
static NSString *const kNodeNameBackground = @"kNodeNameBackground";
static NSString *const kNodeNameLock = @"kNodeNameLock";
static NSString *const kNodeNameRotationIcon = @"kNodeNameRotationIcon";
static NSString *const kNodeNameResetButton = @"kNodeNameResetButton";
static NSString *const kNodeNameBorder = @"kNodeNameBorder";
static NSString *const kNodeNameGameObject = @"kNodeNameGameObject";
static NSInteger const kZIndexDefaultObject = 1;
static NSInteger const kZIndexSelectedObject = 10;
static NSInteger const kZIndexFront = 1000;
static NSUInteger const kDegreeInterval = 15;

@implementation OCDMyScene

- (id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];

    if (self)
    {
        // Init
        _objectSet = [[NSMutableSet alloc] initWithCapacity:kNumObjects];
        _selectedNode = nil;
        
        // Background
        SKSpriteNode *backgroundImage = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
        backgroundImage.name = kNodeNameBackground;
        backgroundImage.anchorPoint = CGPointMake(0, 1);
        backgroundImage.position = CGPointMake(0, size.height);
        [self addChild:backgroundImage];
        
        // Initial objects
        for (NSUInteger i=0; i<kNumObjects; i++)
        {
            OCDGameObject *object = [[OCDGameObject alloc] initWithImageNamed:@"object"];
            object.name = kNodeNameGameObject;
            object.zPosition = kZIndexDefaultObject;
            [_objectSet addObject:object];
            [self addChild:object];
        }
        
        // Randomize objects
        [self p_randomizeObjects:nil];
        
        // Reset button
        CNCButton *resetButton = [CNCButton buttonWithImageNamedNormal:@"button-reset" selected:nil];
        resetButton.name = kNodeNameResetButton;
        resetButton.zPosition = kZIndexFront;
        resetButton.position = CGPointMake(self.size.width * 0.98 - resetButton.size.width/2, self.size.height * 0.02 + resetButton.size.height/2);
        [resetButton setTouchUpInsideTarget:self action:@selector(p_randomizeObjects:)];
        [self addChild:resetButton];
        
        // Initialize tapped node name label
        _tappedNodeNameLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-Bold"];
        _tappedNodeNameLabel.fontSize = 14;
        _tappedNodeNameLabel.text = @"Box";
        _tappedNodeNameLabel.fontColor = [UIColor whiteColor];
        _tappedNodeNameLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        _tappedNodeNameLabel.zPosition = kZIndexFront;
        
        // Add version label
        SKLabelNode *versionLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        versionLabel.fontSize = 12;
        versionLabel.text = [NSString stringWithFormat:@"%@ (%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
        versionLabel.fontColor = [UIColor whiteColor];
        versionLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        [self addChild:versionLabel];
        
        _rotationSymbol = [[SKSpriteNode alloc] initWithImageNamed:@"object-rotation"];
        _rotationSymbol.position = CGPointZero;
        _rotationSymbol.name = kNodeNameRotationIcon;
    }
    
    return self;
}

- (void)didMoveToView:(SKView *)view
{
    // Drag
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    self.panGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.panGestureRecognizer];
    
    // Tap
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    self.tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
    
    // Double tap
    self.doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapFrom:)];
    self.doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:self.doubleTapGestureRecognizer];
    
    // Rotation
    self.rotationGestureRecognizer = [[CNCOneFingerRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotateFrom:)];
    self.rotationGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.rotationGestureRecognizer];
    
    [self.rotationGestureRecognizer requireGestureRecognizerToFail:self.panGestureRecognizer];
}

- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer
{
    CGPoint touchLocation = [recognizer locationInView:recognizer.view];
    touchLocation = [self convertPointFromView:touchLocation];
    
    [self p_selectNodeForTapAtPosition:touchLocation];
}

- (void)handleDoubleTapFrom:(UITapGestureRecognizer *)recognizer
{
    CGPoint touchLocation = [recognizer locationInView:recognizer.view];
    touchLocation = [self convertPointFromView:touchLocation];
    
    [self p_lockNodeForDoubleTapAtPosition:touchLocation];
    [self p_resetTappedObject];
}

- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint touchLocation = [recognizer locationInView:recognizer.view];
        touchLocation = [self convertPointFromView:touchLocation];
        
        // Remove any border from any tapped objects
        [self p_resetTappedObject];
        
        [self p_selectNodeForDragAtPosition:touchLocation];
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
        self.selectedNode.zPosition = kZIndexDefaultObject;
        [self.selectedNode removeAllChildren];
        self.selectedNode = nil;
    }
}

- (void)handleRotateFrom:(CNCOneFingerRotationGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        recognizer.rotationCenter = [self convertPointToView:self.tappedNode.position];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        [self p_rotateForRotation:recognizer.rotation];
    }
}

#pragma mark - UIGestureRecognizerDelegate methods
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    // Only allow rotation when there is a tapped node
    if ([gestureRecognizer isEqual:self.rotationGestureRecognizer] && self.tappedNode == nil)
    {
        return NO;
    }
    if ([gestureRecognizer isEqual:self.panGestureRecognizer])
    {
        CGPoint touchLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
        touchLocation = [self convertPointFromView:touchLocation];
        SKSpriteNode *touchedNode = (SKSpriteNode *)[self nodeAtPoint:touchLocation];
        if ([touchedNode.name isEqualToString:kNodeNameLock])
        {
            touchedNode = (SKSpriteNode*)touchedNode.parent;
        }
        
        return [touchedNode.name isEqualToString:kNodeNameGameObject];
    }
    
    return YES;
}

#pragma mark - Touch detection
- (void)p_selectNodeForTapAtPosition:(CGPoint)touchLocation
{
    OCDGameObject *touchedNode = (OCDGameObject *)[self nodeAtPoint:touchLocation];
    NSString *name = touchedNode.name;
    if ([name isEqualToString:kNodeNameLock])
    {
        // Send touch to parent object (the box)
        touchedNode = (OCDGameObject *)touchedNode.parent;
    }
    if ([name isEqualToString:kNodeNameBackground] == NO && [name isEqualToString:kNodeNameResetButton] == NO && [touchedNode isKindOfClass:[CNCButton class]] == NO && [touchedNode isKindOfClass:[SKLabelNode class]] == NO)
    {
        // Parent is the border's parent node
        if ([touchedNode.name isEqualToString:kNodeNameBorder] || [touchedNode.name isEqualToString:kNodeNameRotationIcon])
        {
            touchedNode = (OCDGameObject *)touchedNode.parent;
        }
        
        if ([self.tappedNode isEqual:touchedNode] == NO)
        {
            // Move previous selected node back and new tapped node forward
            [self p_resetTappedObject];
            touchedNode.zPosition = kZIndexSelectedObject;
            self.tappedNode = touchedNode;
            
            // Add border to selectedNode
            SKShapeNode *border = [SKShapeNode new];
            border.name = kNodeNameBorder;
            border.path = CGPathCreateWithRect(CGRectMake(-touchedNode.size.width/2, -touchedNode.size.height/2, touchedNode.size.width, touchedNode.size.height), NULL);
            border.strokeColor = [UIColor greenColor];
            [touchedNode addChild:border];
            
            // Add label
            // Check if there is room above the object
            CGPoint labelPos;
            if (self.tappedNode.position.y + self.tappedNode.size.height/2 + 30 < self.size.height)
            {
                labelPos = CGPointMake(self.tappedNode.position.x, self.tappedNode.position.y + self.tappedNode.size.height/2 + 16);
            }
            else
            {
                labelPos = CGPointMake(self.tappedNode.position.x, self.tappedNode.position.y - self.tappedNode.size.height/2 - 16);
            }
            
            self.tappedNodeNameLabel.position = labelPos;
            [self addChild:self.tappedNodeNameLabel];
            
            // Add rotation symbol
            self.rotationSymbol.zRotation = self.tappedNode.zRotation * -1;
            [self.tappedNode addChild:self.rotationSymbol];
            
            self.tappedNodeRotationRemainder = 0;
        }
        else
        {
            // Deselect already tapped node
            [self p_resetTappedObject];
        }
    }
    else
    {
        [self p_resetTappedObject];
        
        if ([name isEqualToString:kNodeNameResetButton])
        {
            [self p_randomizeObjects:nil];
        }
    }
}

- (void)p_lockNodeForDoubleTapAtPosition:(CGPoint)touchLocation
{
    OCDGameObject *touchedNode = (OCDGameObject *)[self nodeAtPoint:touchLocation];
    NSString *name = touchedNode.name;
    if ([name isEqualToString:kNodeNameLock] || [name isEqualToString:kNodeNameRotationIcon])
    {
        // Send touch to parent object (the box)
        touchedNode = (OCDGameObject *)touchedNode.parent;
    }
    if ([touchedNode isKindOfClass:[OCDGameObject class]])
    {
        BOOL locked = touchedNode.isLocked;
        if (locked)
        {
            // Unlock
            // Remove lock icon
            [touchedNode.children enumerateObjectsUsingBlock:^(SKSpriteNode *obj, NSUInteger idx, BOOL *stop) {
                if ([obj.name isEqualToString:kNodeNameLock])
                {
                    [obj removeFromParent];
                }
            }];
        }
        else
        {
            // Lock
            // Add lock icon
            SKSpriteNode *lockIcon = [SKSpriteNode spriteNodeWithImageNamed:@"lock"];
            lockIcon.name = kNodeNameLock;
            lockIcon.zRotation = touchedNode.zRotation * -1;
            [touchedNode addChild:lockIcon];
        }
        
        touchedNode.locked = !locked;
    }
}

- (void)p_selectNodeForDragAtPosition:(CGPoint)touchLocation
{
    OCDGameObject *touchedNode = (OCDGameObject *)[self nodeAtPoint:touchLocation];
    if ([touchedNode.name isEqual:kNodeNameBackground] == NO && [touchedNode.name isEqualToString:kNodeNameLock] == NO && [touchedNode isKindOfClass:[SKLabelNode class]] == NO && touchedNode.isLocked == NO)
    {
        if ([self.selectedNode isEqual:touchedNode] == NO)
        {
            // Move previous selected node back and new selected node forward
            self.selectedNode.zPosition = kZIndexDefaultObject;
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

- (void)p_rotateForRotation:(CGFloat)rotation
{
    // Rotate every degree
//    self.tappedNode.zRotation -= rotation;
//    self.rotationSymbol.zRotation += rotation;
    
    self.tappedNodeRotationRemainder += rotation;
    
    CGFloat degreeIntervalInRadians = DegreesToRadians(kDegreeInterval);
    CGFloat numIntervalsToRotate = (fabsf(self.tappedNodeRotationRemainder) > degreeIntervalInRadians) ? 1 : 0;
    CGFloat multiplier = (self.tappedNodeRotationRemainder > 0) ? 1 : -1;
    CGFloat amountToRotateInRadians = multiplier * numIntervalsToRotate * degreeIntervalInRadians;
    self.tappedNode.zRotation -= amountToRotateInRadians;
    self.rotationSymbol.zRotation += amountToRotateInRadians;
    
    self.tappedNodeRotationRemainder -= amountToRotateInRadians;
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
        NSUInteger randomNumDegreeInterval = arc4random() % 360/kDegreeInterval;        // 360 degrees / 15 degree intervals
        obj.zRotation = DegreesToRadians(randomNumDegreeInterval * kDegreeInterval);
    }];
}

#pragma mark - Private methods
- (void)p_resetTappedObject
{
    self.tappedNode.zPosition = kZIndexDefaultObject;
    // Remove border and rotate symbol
    [self.tappedNode.children enumerateObjectsUsingBlock:^(SKSpriteNode *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.name isEqualToString:kNodeNameBorder] || [obj.name isEqualToString:kNodeNameRotationIcon])
        {
            [obj removeFromParent];
        }
    }];
    self.tappedNode = nil;
    // Remove name label
    [self.tappedNodeNameLabel removeFromParent];
}

- (void)update:(CFTimeInterval)currentTime
{

}

@end
