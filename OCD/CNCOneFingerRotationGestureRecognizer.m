//
//  CNCOneFingerRotationGestureRecognizer.m
//  OCD
//
//  Created by Michael Gao on 5/3/14.
//  Copyright (c) 2014 Chin and Cheeks. All rights reserved.
//

#import "CNCOneFingerRotationGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation CNCOneFingerRotationGestureRecognizer

- (id)init
{
    self = [super init];
    if (self)
    {
        _rotation = 0;
        _rotationCenter = self.view.center;
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    // Fail when more than 1 finger is detected
    if (touches.count > 1)
    {
        self.state = UIGestureRecognizerStateFailed;
    }
    
    self.rotation = 0;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    if (touches.count > 1)
    {
        self.state = UIGestureRecognizerStateCancelled;
    }
    
    if (self.state == UIGestureRecognizerStatePossible)
    {
        self.state = UIGestureRecognizerStateBegan;
    }
    else
    {
        self.state = UIGestureRecognizerStateChanged;
    }
    
    // To rotate with one finger, we simulate a second finger.
    // The second figure is on the opposite side of the virtual
    // circle that represents the rotation gesture.
    
    UITouch *touch = [touches anyObject];       // There is only 1 touch
    UIView *view = self.view;
    CGPoint currentTouchPoint = [touch locationInView:view];
    CGPoint previousTouchPoint = [touch previousLocationInView:view];
    
    CGFloat angleInRadians = atan2f(currentTouchPoint.y - self.rotationCenter.y, currentTouchPoint.x - self.rotationCenter.x) - atan2f(previousTouchPoint.y - self.rotationCenter.y, previousTouchPoint.x - self.rotationCenter.x);
    self.rotation = angleInRadians;
    NSLog(@"angleInRadians: %f", angleInRadians);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    // Perform final check to make sure a tap was not misinterpreted.
    if (self.state == UIGestureRecognizerStateChanged)
    {
        self.state = UIGestureRecognizerStateEnded;
    }
    else
    {
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
    self.state = UIGestureRecognizerStateFailed;
}

@end
