//
//  Ships.h
//  Nova Wing
//
//  Created by Bryan Todd on 8/21/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Ships : SKNode

-(SKSpriteNode *)createAnyShipFromParent: (SKNode *)parentNode withImageNamed: (NSString *) imageName;

@end
