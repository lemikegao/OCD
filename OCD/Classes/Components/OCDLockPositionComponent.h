//
//  OCDLockPositionComponent.h
//  OCD
//
//  Created by Michael Gao on 5/11/14.
//  Copyright (c) 2014 Chin and Cheeks. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OCDLockPositionComponentDelegate <NSObject>

- (void)objectDidLockIntoPosition;

@end

@interface OCDLockPositionComponent : NSObject <SKComponent>

@property (nonatomic) CGPoint targetPosition;
@property (nonatomic, weak) id<OCDLockPositionComponentDelegate> delegate;

@end
