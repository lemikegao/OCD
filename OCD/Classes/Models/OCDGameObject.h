//
//  OCDGameObject.h
//  OCD
//
//  Created by Michael Gao on 5/4/14.
//  Copyright (c) 2014 Chin and Cheeks. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface OCDGameObject : SKSpriteNode

/**
 * Double tap to lock object
 */
@property (nonatomic, assign, getter = isLocked) BOOL locked;

@end
