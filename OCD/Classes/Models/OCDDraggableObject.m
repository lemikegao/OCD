//
//  OCDDraggableObject.m
//  OCD
//
//  Created by Michael Gao on 5/11/14.
//  Copyright (c) 2014 Chin and Cheeks. All rights reserved.
//

#import "OCDDraggableObject.h"
#import "OCDDraggableComponent.h"
#import "OCDLockPositionComponent.h"

@interface OCDDraggableObject()

@property (nonatomic, weak) OCDDraggableComponent *draggableComponent;
@property (nonatomic, weak) OCDLockPositionComponent *lockPositionComponent;

@end

@implementation OCDDraggableObject

- (id)init
{
    self = [super init];
    if (self)
    {
        OCDDraggableComponent *draggableComponent = [OCDDraggableComponent new];
        OCDLockPositionComponent *lockPositionComponent = [OCDLockPositionComponent new];
        
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
        [self addChild:node];
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    [self.delegate startedDraggingDraggableObject:self];
}

@end
