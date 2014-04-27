//
//  OCDMyScene.m
//  OCD
//
//  Created by Michael Gao on 4/26/14.
//  Copyright (c) 2014 Chin and Cheeks. All rights reserved.
//

#import "OCDMyScene.h"

@implementation OCDMyScene

-(id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];

    if (self)
    {
        // Background
        SKSpriteNode *backgroundImage = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
        backgroundImage.anchorPoint = CGPointMake(0, 1);
        backgroundImage.position = CGPointMake(0, size.height);
        [self addChild:backgroundImage];
        
        // Temp object
        SKSpriteNode *object = [SKSpriteNode spriteNodeWithImageNamed:@"object"];
        object.position = CGPointMake(self.size.width * 0.5, self.size.height * 0.5);
        [self addChild:object];
    }
    
    return self;
}

-(void)update:(CFTimeInterval)currentTime
{

}

@end
