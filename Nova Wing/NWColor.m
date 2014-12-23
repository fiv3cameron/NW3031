//
//  NWColor.m
//  Nova Wing
//
//  Created by Cameron Frank on 11/22/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import "NWColor.h"

@implementation NWColor

+(SKColor *)NWBlue {
    return [SKColor colorWithRed:0.5 green:0.8 blue:1 alpha:1];
}

+(SKColor *)NWGreen {
    return [SKColor colorWithRed:0.1 green:1 blue:0.7 alpha:1];
}

+(SKColor *)NWPurple {
    return [SKColor colorWithRed:1 green:0 blue:0.7 alpha:1];
}

+(SKColor *)NWYellow {
    return [SKColor colorWithRed:1 green:1 blue:0 alpha:1];
}

+(SKColor *)NWRed {
    return [SKColor colorWithRed:1 green:0.1 blue:0.2 alpha:1];
}

+(SKColor *)NWSilver {
    return [SKColor colorWithRed:0.75 green:0.75 blue:0.85 alpha:1];
}

+(SKColor *)NWTransparent {
    return[SKColor colorWithRed:1 green:1 blue:1 alpha:0];
}

+(SKColor *)NWLaserHit {
    return [SKColor colorWithRed:0.33 green:0.33 blue:0.34 alpha:1.0];
}

+(SKColor *)NWShieldHit {
    return [SKColor colorWithRed:0.8 green:0.9 blue:1 alpha:1];
}


@end
