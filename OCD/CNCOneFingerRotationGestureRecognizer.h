//
//  CNCOneFingerRotationGestureRecognizer.h
//  OCD
//
//  Created by Michael Gao on 5/3/14.
//  Copyright (c) 2014 Chin and Cheeks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNCOneFingerRotationGestureRecognizer : UIGestureRecognizer

@property (nonatomic, assign) CGPoint rotationCenter;
@property (nonatomic, assign) CGFloat rotation;

@end
