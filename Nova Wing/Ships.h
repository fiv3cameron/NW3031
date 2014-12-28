//
//  Ships.h
//  Nova Wing
//
//  Created by Bryan Todd on 8/21/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Ships : SKSpriteNode

-(Ships *)initWithImageNamed: (NSString *)imageName;
-(void)rotateNodeUpwards: (SKNode *)nodeRotate;
-(void)rotateNodeDownwards: (SKNode *)nodeRotate;
-(void)shipBobbing: (SKNode *)bobShip;
-(void)thrustPlayer:(SKNode *)player withHeight:(float)levelHeight;
-(void)logicTinyNova;
-(void)closeTinyNova;

@end
