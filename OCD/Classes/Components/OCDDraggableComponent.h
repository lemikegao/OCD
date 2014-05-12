//
//  OCDDraggableComponent.h
//  OCD
//
//  Created by Michael Gao on 5/11/14.
//  Copyright (c) 2014 Chin and Cheeks. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OCDDraggableComponentDelegate <NSObject>

- (void)objectDidStartDragging;

@end

@interface OCDDraggableComponent : NSObject <SKComponent>

@property (nonatomic, weak) id<OCDDraggableComponentDelegate> delegate;

@end
