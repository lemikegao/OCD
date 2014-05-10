//
//  SKButton.m
//  DoTheDancing-SpriteKit
//
//  Created by Michael Gao on 12/15/13.
//  Copyright (c) 2013 Chin and Cheeks LLC. All rights reserved.
//

#import "CNCButton.h"
#import <objc/message.h>

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

@implementation CNCButton

#pragma mark Convenience Methods
+ (instancetype)buttonWithImageNamedNormal:(NSString *)normal selected:(NSString *)selected
{
    return [[self alloc] initWithImageNamedNormal:normal selected:selected];
}

#pragma mark Texture Initializer

/**
 * Override the super-classes designated initializer, to get a properly set SKButton in every case
 */
- (id)initWithTexture:(SKTexture *)texture color:(UIColor *)color size:(CGSize)size {
    return [self initWithTextureNormal:texture selected:nil disabled:nil color:color size:size];
}

- (id)initWithTextureNormal:(SKTexture *)normal selected:(SKTexture *)selected {
    return [self initWithTextureNormal:normal selected:selected disabled:nil];
}

/**
 * This is the designated Initializer
 */
- (id)initWithTextureNormal:(SKTexture *)normal selected:(SKTexture *)selected disabled:(SKTexture *)disabled {
    return [self initWithTextureNormal:normal selected:selected disabled:disabled color:[SKColor whiteColor] size:normal.size];
}

- (id)initWithTextureNormal:(SKTexture *)normal selected:(SKTexture *)selected disabled:(SKTexture *)disabled color:(SKColor *)color size:(CGSize)size
{
    self = [super initWithTexture:normal color:color size:size];
    if (self) {
        [self setNormalTexture:normal];
        [self setSelectedTexture:selected];
        [self setDisabledTexture:disabled];
        [self setIsEnabled:YES];
        [self setIsSelected:NO];
        
        _title = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
        [_title setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
        [_title setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
        
        [self addChild:_title];
        [self setUserInteractionEnabled:YES];
    }
    return self;
}

#pragma mark Image Initializer

- (id)initWithImageNamedNormal:(NSString *)normal selected:(NSString *)selected {
    return [self initWithImageNamedNormal:normal selected:selected disabled:nil];
}

- (id)initWithImageNamedNormal:(NSString *)normal selected:(NSString *)selected disabled:(NSString *)disabled {
    SKTexture *textureNormal = nil;
    if (normal) {
        textureNormal = [SKTexture textureWithImageNamed:normal];
    }
    
    SKTexture *textureSelected = nil;
    if (selected) {
        textureSelected = [SKTexture textureWithImageNamed:selected];
    }
    
    SKTexture *textureDisabled = nil;
    if (disabled) {
        textureDisabled = [SKTexture textureWithImageNamed:disabled];
    }
    
    return [self initWithTextureNormal:textureNormal selected:textureSelected disabled:textureDisabled];
}




#pragma -
#pragma mark Setting Target-Action pairs

- (void)setTouchUpInsideTarget:(id)target action:(SEL)action {
    _targetTouchUpInside = target;
    _actionTouchUpInside = action;
}

- (void)setTouchDownTarget:(id)target action:(SEL)action {
    _targetTouchDown = target;
    _actionTouchDown = action;
}

- (void)setTouchUpTarget:(id)target action:(SEL)action {
    _targetTouchUp = target;
    _actionTouchUp = action;
}

#pragma -
#pragma mark Setter overrides

- (void)setIsEnabled:(BOOL)isEnabled {
    _isEnabled = isEnabled;
    if ([self disabledTexture]) {
        if (!_isEnabled) {
            [self setTexture:_disabledTexture];
        } else {
            [self setTexture:_normalTexture];
        }
    }
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    if ([self selectedTexture] && [self isEnabled]) {
        if (_isSelected) {
            [self setTexture:_selectedTexture];
        } else {
            [self setTexture:_normalTexture];
        }
    }
}

- (void)setNormalTexture:(SKTexture *)normalTexture
{
    _normalTexture = normalTexture;
    [self setTexture:_normalTexture];
}

#pragma -
#pragma mark Touch Handling

/**
 * This method only occurs, if the touch was inside this node. Furthermore if
 * the Button is enabled, the texture should change to "selectedTexture".
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self isEnabled]) {
        if ([self.targetTouchDown respondsToSelector:self.actionTouchDown])
        {
            SuppressPerformSelectorLeakWarning(
                [self.targetTouchDown performSelector:self.actionTouchDown withObject:self];
                                               );
        }
        [self setIsSelected:YES];
    }
}

/**
 * If the Button is enabled: This method looks, where the touch was moved to.
 * If the touch moves outside of the button, the isSelected property is restored
 * to NO and the texture changes to "normalTexture".
 */
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self isEnabled]) {
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInNode:self.parent];
        
        if (CGRectContainsPoint(self.frame, touchPoint)) {
            [self setIsSelected:YES];
        } else {
            [self setIsSelected:NO];
        }
    }
}

/**
 * If the Button is enabled AND the touch ended in the buttons frame, the
 * selector of the target is run.
 */
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInNode:self.parent];
    
    if ([self isEnabled] && CGRectContainsPoint(self.frame, touchPoint)) {
        if ([self.targetTouchUpInside respondsToSelector:self.actionTouchUpInside])
        {
            SuppressPerformSelectorLeakWarning(
                [self.targetTouchUpInside performSelector:self.actionTouchUpInside withObject:self];
                                               );
        }
    }
    [self setIsSelected:NO];
    if ([self.targetTouchUp respondsToSelector:self.actionTouchUp])
    {
        SuppressPerformSelectorLeakWarning(
            [self.targetTouchUp performSelector:self.actionTouchUp withObject:self];
                                           );
    }
}

#pragma -
#pragma mark Enable/disable button
- (void)disableButton
{
    self.isEnabled = NO;
    self.alpha = 0.4;
}

- (void)enableButton
{
    self.isEnabled = YES;
    self.alpha = 1.0;
}

@end