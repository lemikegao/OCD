//
//  OCDConstants.h
//  OCD
//
//  Created by Michael Gao on 4/27/14.
//  Copyright (c) 2014 Chin and Cheeks. All rights reserved.
//

#ifndef OCD_OCDConstants_h
#define OCD_OCDConstants_h

#define DegreesToRadians(d) (M_PI * (d) / 180.0f)
#define RadiansToDegrees(r) ((r) * 180.0f / M_PI)

#define RGBA(r,g,b,a)				[SKColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b)					RGBA(r, g, b, 1.0f)

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_IPHONE_4 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 480.0f)

#endif
