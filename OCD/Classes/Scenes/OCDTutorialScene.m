//
//  OCDTutorialScene.m
//  OCD
//
//  Created by Michael Gao on 5/10/14.
//  Copyright (c) 2014 Chin and Cheeks. All rights reserved.
//

#import "OCDTutorialScene.h"
#import "OCDDraggableObject.h"

@interface OCDTutorialScene() <OCDDraggableObjectDelegate>

@property (nonatomic) CGFloat scaleFactor;

@property (nonatomic, strong) SKSpriteNode *dashedO;
@property (nonatomic, strong) SKSpriteNode *dashedC;
@property (nonatomic, strong) SKSpriteNode *dashedD;

@property (nonatomic, strong) OCDDraggableObject *coloredO;
@property (nonatomic, strong) OCDDraggableObject *coloredC;
@property (nonatomic, strong) OCDDraggableObject *coloredD;

@property (nonatomic) NSInteger zPositionTracker;
@property (nonatomic) NSInteger lockedObjectCounter;

@end

@implementation OCDTutorialScene

- (id)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if (self)
    {
        // Init
        _zPositionTracker = 0;
        _lockedObjectCounter = 0;
        if (IS_IPAD)
        {
            _scaleFactor = 2;
        }
        else if (IS_IPHONE_5)
        {
            _scaleFactor = 1.2;
        }
        else
        {
            _scaleFactor = 1;
        }
        
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
    _dashedO.position = ccp(self.size.width * 0.2, self.size.height * 0.55);
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
    _coloredO = [[OCDDraggableObject alloc] initWithRenderingNode:[SKSpriteNode spriteNodeWithImageNamed:@"ocd-letter-o"] targetPosition:_dashedO.position];
    _coloredO.delegate = self;
    [self p_updateZPositionForObject:_coloredO];
    [self addChild:_coloredO];
    
    // Letter 'C'
    _coloredC = [[OCDDraggableObject alloc] initWithRenderingNode:[SKSpriteNode spriteNodeWithImageNamed:@"ocd-letter-c"] targetPosition:_dashedC.position];
    _coloredC.delegate = self;
    [self p_updateZPositionForObject:_coloredC];
    [self addChild:_coloredC];
    
    // Letter 'D'
    _coloredD = [[OCDDraggableObject alloc] initWithRenderingNode:[SKSpriteNode spriteNodeWithImageNamed:@"ocd-letter-d"] targetPosition:_dashedD.position];
    _coloredD.delegate = self;
    [self p_updateZPositionForObject:_coloredD];
    [self addChild:_coloredD];
}

- (void)p_randomizeObjects
{
    // Randomize position within the bounds of the screen
    CGRect frame = [_coloredO calculateAccumulatedFrame];
    CGFloat randomX = arc4random() % (int)frame.size.width + (_dashedO.position.x - frame.size.width/3);
    CGFloat randomY = arc4random() % (int)(self.size.height - frame.size.height) + frame.size.height/2;
    _coloredO.position = CGPointMake(randomX, randomY);
    
    frame = [_coloredC calculateAccumulatedFrame];
    randomX = arc4random() % (int)frame.size.width + (_dashedC.position.x - frame.size.width/2);
    randomY = arc4random() % (int)(self.size.height - frame.size.height) + frame.size.height/2;
    _coloredC.position = CGPointMake(randomX, randomY);
    
    frame = [_coloredD calculateAccumulatedFrame];
    randomX = arc4random() % (int)frame.size.width + (_dashedD.position.x - frame.size.width/2);
    randomY = arc4random() % (int)(self.size.height - frame.size.height) + frame.size.height/2;
    _coloredD.position = CGPointMake(randomX, randomY);
}

- (void)p_displayIntroductionSequence
{
    // Begin button
    CNCButton *beginButton = [CNCButton buttonWithImageNamedNormal:@"ocd-button-begin" selected:@"ocd-button-begin-highlight"];
    beginButton.position = ccp(self.size.width * 0.5, self.size.height * 0.2);
    beginButton.alpha = 0;
    [beginButton setTouchDownTarget:self action:@selector(p_pressedBeginButton:)];
    [beginButton setTouchUpInsideTarget:self action:@selector(p_releasedBeginButton:)];
    [self addChild:beginButton];
    
    SKAction *wait = [SKAction waitForDuration:2];
    SKAction *fadeIn = [SKAction fadeInWithDuration:1];
    [beginButton runAction:[SKAction sequence:@[wait, fadeIn]]];
}

#pragma mark - Button actions
- (void)p_pressedBeginButton:(id)sender
{
    [[OCDGameManager sharedGameManager] playSoundEffect:@"sfx-button-press.caf"];
}

- (void)p_releasedBeginButton:(id)sender
{
    
}

#pragma mark - OCDDraggableDelegate methods
- (void)touchStartedOnDraggableObject:(OCDDraggableObject *)object
{
    NSString *letter;
    if ([object isEqual:self.coloredO])
    {
        letter = @"o";
    }
    else if ([object isEqual:self.coloredC])
    {
        letter = @"c";
    }
    else if ([object isEqual:self.coloredD])
    {
        letter = @"d";
    }
    UIImage *dragImage = [UIImage imageNamed:[NSString stringWithFormat:@"ocd-letter-shadow-%@", letter]];
    SKSpriteNode *renderingNode = (SKSpriteNode*)[object childNodeWithName:OCDDraggableObjectRenderingNodeName];
    renderingNode.texture = [SKTexture textureWithImage:dragImage];
    renderingNode.size = dragImage.size;
    
    [self p_updateZPositionForObject:object];
}

- (void)touchEndedOnDraggableObject:(OCDDraggableObject *)object
{
    NSString *letter;
    if ([object isEqual:self.coloredO])
    {
        letter = @"o";
    }
    else if ([object isEqual:self.coloredC])
    {
        letter = @"c";
    }
    else if ([object isEqual:self.coloredD])
    {
        letter = @"d";
    }
    UIImage *normalImage = [UIImage imageNamed:[NSString stringWithFormat:@"ocd-letter-%@", letter]];
    SKSpriteNode *renderingNode = (SKSpriteNode*)[object childNodeWithName:OCDDraggableObjectRenderingNodeName];
    renderingNode.texture = [SKTexture textureWithImage:normalImage];
    renderingNode.size = normalImage.size;
}

- (void)objectDidLockIntoPosition:(OCDDraggableObject *)object
{
    NSString *letter;
    SKNode *dashedNode;
    if ([object isEqual:self.coloredO])
    {
        letter = @"o";
        dashedNode = self.dashedO;
    }
    else if ([object isEqual:self.coloredC])
    {
        letter = @"c";
        dashedNode = self.dashedC;
    }
    else if ([object isEqual:self.coloredD])
    {
        letter = @"d";
        dashedNode = self.dashedD;
    }
    
    SKSpriteNode *lockedInSprite = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"ocd-letter-3d-%@", letter]];
    lockedInSprite.position = object.position;
    lockedInSprite.alpha = 0;
    [self p_updateZPositionForObject:lockedInSprite];
    [self addChild:lockedInSprite];

    [lockedInSprite runAction:[SKAction fadeInWithDuration:1.5]];
    [dashedNode runAction:[SKAction fadeOutWithDuration:1.5]];
    
    self.lockedObjectCounter++;
    
    if (self.lockedObjectCounter == 3)
    {
        // Display introduction sequence
        [self p_displayIntroductionSequence];
    }
}

#pragma mark - Helper methods
- (void)p_updateZPositionForObject:(SKNode *)object
{
    object.zPosition = self.zPositionTracker;
    self.zPositionTracker++;
}

@end
