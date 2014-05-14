//
//  OCDDraggableComponent.m
//  OCD
//
//  Created by Michael Gao on 5/11/14.
//  Copyright (c) 2014 Chin and Cheeks. All rights reserved.
//

#import "OCDDraggableComponent.h"

@interface OCDDraggableComponent()

@property (nonatomic) CGPoint startPosition;
@property (nonatomic) CGSize sceneSize;

@end

@implementation OCDDraggableComponent
@synthesize node, enabled;

- (void)awake
{
    self.node.userInteractionEnabled = YES;
}

- (void)onEnter
{
    self.sceneSize = self.node.scene.size;
}

- (void)dragStart:(SKCTouchState *)touchState
{
    self.startPosition = self.node.position;
}

- (void)dragMoved:(SKCTouchState *)touchState
{
    self.node.position = [self p_positionInBoundsForPosition:skpAdd(self.node.position, touchState.touchDelta)];
}

- (void)dragDropped:(SKCTouchState*)touchState
{
    
}

- (void)dragCancelled:(SKCTouchState *)touchState
{
    self.node.position = self.startPosition;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[OCDGameManager sharedGameManager] playSoundEffect:@"sfx-click.wav"];
    [self.delegate objectDidGetTouched];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[OCDGameManager sharedGameManager] playSoundEffect:@"sfx-click.wav"];
    [self.delegate objectDidEndTouch];
}

#pragma mark - Private methods
- (CGPoint)p_positionInBoundsForPosition:(CGPoint)newPos
{
    CGPoint retVal = newPos;
    CGFloat renderingNodeWidth = self.node.frame.size.width;
    CGFloat renderingNodeHeight = self.node.frame.size.height;
    if (newPos.x < renderingNodeWidth/2)
    {
        retVal.x = renderingNodeWidth/2;
    }
    else if (newPos.x > self.sceneSize.width - renderingNodeWidth/2)
    {
        retVal.x = self.sceneSize.width - renderingNodeWidth/2;
    }
    
    if (newPos.y < renderingNodeHeight/2)
    {
        retVal.y = renderingNodeHeight/2;
    }
    else if (newPos.y > self.sceneSize.height - renderingNodeHeight/2)
    {
        retVal.y = self.sceneSize.height - renderingNodeHeight/2;
    }
    
    return retVal;
}

@end
