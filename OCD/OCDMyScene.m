//
//  OCDMyScene.m
//  OCD
//
//  Created by Michael Gao on 4/26/14.
//  Copyright (c) 2014 Chin and Cheeks. All rights reserved.
//

#import "OCDMyScene.h"
#import "CNCOneFingerRotationGestureRecognizer.h"

@interface OCDMyScene() <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSMutableSet *objectSet;
@property (nonatomic, strong) SKSpriteNode *selectedNode;
@property (nonatomic, strong) SKSpriteNode *tappedNode;
@property (nonatomic, strong) SKSpriteNode *rotationSymbol;
@property (nonatomic, strong) SKLabelNode *tappedNodeNameLabel;

// Gesture recognizers
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) CNCOneFingerRotationGestureRecognizer *rotationGestureRecognizer;

@end

static NSUInteger const kNumObjects = 4;
static NSString *const kNodeNameBackground = @"kNodeNameBackground";
static NSString *const kNodeNameResetButton = @"kNodeNameResetButton";
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
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
    
    // Rotation
    self.rotationGestureRecognizer = [[CNCOneFingerRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotateFrom:)];
    self.rotationGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.rotationGestureRecognizer];
}

- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer
{
    CGPoint touchLocation = [recognizer locationInView:recognizer.view];
    touchLocation = [self convertPointFromView:touchLocation];
    
    [self p_selectNodeForTapAtPosition:touchLocation];
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
        self.tappedNode.zRotation -= recognizer.rotation;
        self.rotationSymbol.zRotation += recognizer.rotation;
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
    
    return YES;
}

#pragma mark - Touch detection
- (void)p_selectNodeForTapAtPosition:(CGPoint)touchLocation
{
    SKSpriteNode *touchedNode = (SKSpriteNode *)[self nodeAtPoint:touchLocation];
    NSString *name = touchedNode.name;
    if ([name isEqualToString:kNodeNameBackground] == NO && [name isEqualToString:kNodeNameResetButton] == NO && [touchedNode isKindOfClass:[SKSpriteNode class]])
    {
        // Parent is the border's parent node
        if ([self.tappedNode isEqual:touchedNode.parent] == NO)
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

- (void)p_selectNodeForDragAtPosition:(CGPoint)touchLocation
{
    SKSpriteNode *touchedNode = (SKSpriteNode *)[self nodeAtPoint:touchLocation];
    if ([touchedNode.name isEqual:kNodeNameBackground] == NO && [touchedNode isKindOfClass:[SKLabelNode class]] == NO)
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

#pragma mark - Private methods
- (void)p_resetTappedObject
{
    self.tappedNode.zPosition = kZIndexDefaultObject;
    [self.tappedNode removeAllChildren];
    self.tappedNode = nil;
    // Remove name label
    [self.tappedNodeNameLabel removeFromParent];
}

- (void)update:(CFTimeInterval)currentTime
{

}

@end
