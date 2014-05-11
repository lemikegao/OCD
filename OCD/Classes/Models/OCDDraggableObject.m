//
//  OCDDraggableObject.m
//  OCD
//
//  Created by Michael Gao on 5/11/14.
//  Copyright (c) 2014 Chin and Cheeks. All rights reserved.
//

#import "OCDDraggableObject.h"
#import "OCDDraggableComponent.h"

@interface OCDDraggableObject()

@property (nonatomic, weak) SKSpriteNode *renderingNode;

@end

@implementation OCDDraggableObject

- (id)init
{
    self = [super init];
    if (self)
    {
        [self addComponent:[OCDDraggableComponent new]];
    }
    
    return self;
}

- (instancetype)initWithRenderingNode:(SKSpriteNode *)node
{
    self = [self init];
    if (self)
    {
        OCDDraggableComponent *component = [self getComponent:[OCDDraggableComponent class]];
        _renderingNode = node;
        component.renderingNode = node;
        [self addChild:node];
    }
    
    return self;
}

- (SKSpriteNode *)renderingNode
{
    return _renderingNode;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    [self.delegate startedDraggingDraggableObject:self];
}

@end
