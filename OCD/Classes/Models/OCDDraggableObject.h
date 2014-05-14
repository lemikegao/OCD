//
//  OCDDraggableObject.h
//  OCD
//
//  Created by Michael Gao on 5/11/14.
//  Copyright (c) 2014 Chin and Cheeks. All rights reserved.
//

@class OCDDraggableObject;

@protocol OCDDraggableObjectDelegate <NSObject>

- (void)touchStartedOnDraggableObject:(OCDDraggableObject *)object;
- (void)touchEndedOnDraggableObject:(OCDDraggableObject *)object;
- (void)objectDidLockIntoPosition:(OCDDraggableObject *)object;

@end

extern NSString *const OCDDraggableObjectRenderingNodeName;

@interface OCDDraggableObject : SKComponentNode

@property (nonatomic, weak) SKScene<OCDDraggableObjectDelegate> *delegate;

- (instancetype)initWithRenderingNode:(SKSpriteNode *)node targetPosition:(CGPoint)position;

@end
