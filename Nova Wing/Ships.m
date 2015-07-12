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

-(void)rotateNodeUpwards: (Ships *)nodeRotate {
    SKAction *rotateUp = [SKAction rotateToAngle:0.42 duration:.2 shortestUnitArc:YES];
    rotateUp.timingMode = SKActionTimingEaseInEaseOut;
    [nodeRotate runAction:rotateUp];
}

-(void)rotateNodeDownwards: (Ships *)nodeRotate {
    SKAction *rotateDown = [SKAction rotateToAngle:-M_PI_4 duration:.15 shortestUnitArc:YES];
    rotateDown.timingMode = SKActionTimingEaseInEaseOut;
    [nodeRotate runAction:rotateDown];
}

-(void)shipBobbing: (Ships *)bobShip {
    SKAction *bobUp = [SKAction moveToY:bobShip.position.y + 5 duration:.8];
    bobUp.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *bobDown = [SKAction moveToY:bobShip.position.y - 5 duration:.8];
    bobDown.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *bobSequence = [SKAction sequence:@[bobUp, bobDown]];
    SKAction *repeatAction = [SKAction repeatActionForever:bobSequence];
    
    [bobShip runAction:repeatAction withKey:@"bobbingAction"];
}

#define THRUST_CONSTANT 550.0

-(void)thrustPlayer:(Ships *)player withHeight:(float)levelHeight tinyActive:(BOOL)tinyActive {
    float tinyBoost = 1.0;
    if (tinyActive) {
        tinyBoost = 1.25;
    }
    
    if (player.position.y > levelHeight - 50)
    {
        player.physicsBody.velocity = CGVectorMake(0.0f, 0.0f);
    }
    else player.physicsBody.velocity = CGVectorMake(0.0f, MIN(player.position.y * 1.5 * tinyBoost, THRUST_CONSTANT*tinyBoost));
}

-(void)logicTinyNova {
    SKAction *shrink = [SKAction scaleTo:0.3 duration:0.25];
    SKAction *pop = [SKAction scaleTo:0.5 duration:.1];
    SKAction *hold = [SKAction waitForDuration:7.75];
    SKAction *big1 = [SKAction scaleTo:0.8 duration:.1];
    SKAction *waitB1 = [SKAction waitForDuration:0.25];
    SKAction *small1 = [SKAction scaleTo:0.6 duration:.1];
    SKAction *waitS1 = [SKAction waitForDuration:0.5];
    SKAction *big2 = [SKAction scaleTo:0.9 duration:.1];
    SKAction *waitB2 = [SKAction waitForDuration:0.25];
    SKAction *small2 = [SKAction scaleTo:0.7 duration:0.1];
    SKAction *waitS2 = [SKAction waitForDuration:0.25];
    SKAction *bigFinal = [SKAction scaleTo:1.0 duration:0.25];
    
    SKAction *tiny = [SKAction sequence:@[shrink, pop, hold, big1, waitB1, small1, waitS1, big2, waitB2, small2, waitS2, bigFinal]];
    [self runAction:tiny];
    self.physicsBody.linearDamping = 0.0;
}

-(void)closeTinyNova {
    self.physicsBody.linearDamping = 1.0;
}

@end
