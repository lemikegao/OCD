//
//  OCDGameObject.m
//  OCD
//
//  Created by Michael Gao on 5/4/14.
//  Copyright (c) 2014 Chin and Cheeks. All rights reserved.
//

#import "OCDGameObject.h"

@implementation OCDGameObject

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initialize];
    }
    
    return self;
}

- (id)initWithImageNamed:(NSString *)name
{
    self = [super initWithImageNamed:name];
    if (self)
    {
        [self initialize];
    }
    
    return self;
}

- (void)initialize
{
    _locked = NO;
}

@end
