//
//  OCDDraggableObject.m
//  OCD
//
//  Created by Michael Gao on 5/11/14.
//  Copyright (c) 2014 Chin and Cheeks. All rights reserved.
//

#import "OCDDraggableObject.h"

@interface OCDDraggableObject() <OCDDraggableComponentDelegate, OCDLockPositionComponentDelegate>

@property (nonatomic, weak) OCDDraggableComponent *draggableComponent;
@property (nonatomic, weak) OCDLockPositionComponent *lockPositionComponent;

@end

NSString *const OCDDraggableObjectRenderingNodeName = @"OCDDraggableObjectRenderingNodeName";

@implementation OCDDraggableObject

- (id)init
{
    self = [super init];
    if (self)
    {
        self.dragThreshold = 1;
        
        OCDDraggableComponent *draggableComponent = [OCDDraggableComponent new];
        draggableComponent.delegate = self;
        OCDLockPositionComponent *lockPositionComponent = [OCDLockPositionComponent new];
        lockPositionComponent.delegate = self;
        
        [self addComponent:draggableComponent];
        [self addComponent:lockPositionComponent];
        
        _draggableComponent = draggableComponent;
        _lockPositionComponent = lockPositionComponent;
    }
    
    return self;
}

- (instancetype)initWithRenderingNode:(SKSpriteNode *)node targetPosition:(CGPoint)position
{
    self = [self init];
    if (self)
    {
        _lockPositionComponent.targetPosition = position;
        SKSpriteNode *renderingNode = node;
        renderingNode.name = OCDDraggableObjectRenderingNodeName;
        [self addChild:node];
    }
    
    return self;
}

#pragma mark - OCDDraggableComponentDelegate methods
- (void)objectDidGetTouched
{
    [self.delegate touchStartedOnDraggableObject:self];
}

- (void)objectDidEndTouch
{
    [self.delegate touchEndedOnDraggableObject:self];
}

#pragma mark - OCDLockPositionComponentDelegate methods
- (void)objectDidLockIntoPosition
{
    [self.delegate objectDidLockIntoPosition:self];
}

@end
