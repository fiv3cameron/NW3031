//
//  PowerUps.h
//  Nova Wing
//
//  Created by Cameron Frank on 10/8/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface PowerUps : NSObject

-(SKSpriteNode *)createMultiplier;
-(SKShapeNode *)createFlash;
-(SKSpriteNode *)createPup;
-(void)popActionWithNode: (SKNode *)node;

@end
