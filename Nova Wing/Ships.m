//
//  Ships.m
//  Nova Wing
//
//  Created by Bryan Todd on 8/21/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import "Ships.h"

@implementation Ships

-(Ships *)initWithImageNamed: (NSString *)imageName
{
    self = [super initWithImageNamed:imageName];

    // Adds more accurate physics body for ship collisions
    CGFloat offsetX = (self.frame.size.width * 1.2) * self.anchorPoint.x;
    CGFloat offsetY = (self.frame.size.height * 1.2) * self.anchorPoint.y;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, 8 - offsetX, 30 - offsetY);
    CGPathAddLineToPoint(path, NULL, 7 - offsetX, 22 - offsetY);
    CGPathAddLineToPoint(path, NULL, 50 - offsetX, 2 - offsetY);
    CGPathAddLineToPoint(path, NULL, 65 - offsetX, 7 - offsetY);
    CGPathAddLineToPoint(path, NULL, 70 - offsetX, 8 - offsetY);
    CGPathAddLineToPoint(path, NULL, 27 - offsetX, 31 - offsetY);
    
    CGPathCloseSubpath(path);
    
    self.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
    
    CGPathRelease(path);
    
    self.physicsBody.dynamic = NO;
    self.physicsBody.restitution = 0.0f;
    self.physicsBody.friction = 0.0f;
    self.physicsBody.linearDamping = 1.0f;
    self.physicsBody.allowsRotation = NO;
    self.physicsBody.usesPreciseCollisionDetection = YES;
    
    // Keeps player ship on top of all other objects(unless other objects are assigned greater z position
    self.zPosition = 100.0f;

    return self;
}

-(void)rotateNodeUpwards: (SKNode *)nodeRotate {
    SKAction *rotateUp = [SKAction rotateToAngle:0.4 duration:.2 shortestUnitArc:YES];
    rotateUp.timingMode = SKActionTimingEaseInEaseOut;
    [nodeRotate runAction:rotateUp];
}

-(void)rotateNodeDownwards: (SKNode *)nodeRotate {
    SKAction *rotateDown = [SKAction rotateToAngle:-M_PI_4 duration:.15 shortestUnitArc:YES];
    rotateDown.timingMode = SKActionTimingEaseInEaseOut;
    [nodeRotate runAction:rotateDown];
}

-(void)shipBobbing: (SKNode *)bobShip {
    SKAction *bobUp = [SKAction moveToY:bobShip.position.y + 5 duration:.8];
    bobUp.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *bobDown = [SKAction moveToY:bobShip.position.y - 5 duration:.8];
    bobDown.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *bobSequence = [SKAction sequence:@[bobUp, bobDown]];
    SKAction *repeatAction = [SKAction repeatActionForever:bobSequence];
    
    [bobShip runAction:repeatAction withKey:@"bobbingAction"];
    
}

-(void)thrustPlayer:(SKNode *)player withHeight:(float)levelHeight {
    if (player.position.y > levelHeight - 50)
    {
        player.physicsBody.velocity = CGVectorMake(0.0f, 0.0f);
    }
    else player.physicsBody.velocity = CGVectorMake(0.0f, player.position.y*1.3);
    
}

@end
