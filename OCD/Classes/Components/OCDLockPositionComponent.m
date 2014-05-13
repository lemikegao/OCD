//
//  OCDLockPositionComponent.m
//  OCD
//
//  Created by Michael Gao on 5/11/14.
//  Copyright (c) 2014 Chin and Cheeks. All rights reserved.
//

#import "OCDLockPositionComponent.h"

static CGFloat const kMaxLockDistance = 5;

@implementation OCDLockPositionComponent
@synthesize node, enabled;

- (void)dragDropped:(SKCTouchState*)touchState
{
    // Check if renderingNode is close enough to lock into place
    CGFloat xDistance = fabsf(self.targetPosition.x - self.node.position.x);
    CGFloat xDistance2 = fabsf(self.node.position.x - self.targetPosition.x);
    CGFloat yDistance = fabsf(self.targetPosition.y - self.node.position.y);
    CGFloat yDistance2 = fabsf(self.node.position.y - self.targetPosition.y);
    
    CGFloat xMinDistance = (xDistance < xDistance2) ? xDistance : xDistance2;
    CGFloat yMinDistance = (yDistance < yDistance2) ? yDistance : yDistance2;
    
    if (xMinDistance <= kMaxLockDistance && yMinDistance <= kMaxLockDistance)
    {
        // Snap into place
        self.node.position = self.targetPosition;
        
        // Disable user interaction
        self.node.userInteractionEnabled = NO;
        
        // Add temporary border to indicate that object is locked into place
        CGRect frame = [self.node calculateAccumulatedFrame];
        SKShapeNode *border = [SKShapeNode new];
        border.path = CGPathCreateWithRect(CGRectMake(-frame.size.width/2, -frame.size.height/2, frame.size.width, frame.size.height), NULL);
        border.strokeColor = [UIColor brownColor];
        [self.node addChild:border];
        
        [self.delegate objectDidLockIntoPosition];
    }
}

@end
