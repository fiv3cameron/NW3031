//
//  Ships.m
//  Nova Wing
//
//  Created by Bryan Todd on 8/21/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import "Ships.h"

@implementation Ships

-(SKNode *)createAnyShipFromParent: (SKNode *)parentNode withImageNamed: (NSString *) imageName
{
    SKSpriteNode *ship = [SKSpriteNode spriteNodeWithImageNamed:imageName];

    
    // Adds more accurate physics body for ship collisions
    CGFloat offsetX = (ship.frame.size.width * 1.2) * ship.anchorPoint.x;
    CGFloat offsetY = (ship.frame.size.height * 1.2) * ship.anchorPoint.y;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, 8 - offsetX, 30 - offsetY);
    CGPathAddLineToPoint(path, NULL, 7 - offsetX, 22 - offsetY);
    CGPathAddLineToPoint(path, NULL, 50 - offsetX, 2 - offsetY);
    CGPathAddLineToPoint(path, NULL, 65 - offsetX, 7 - offsetY);
    CGPathAddLineToPoint(path, NULL, 70 - offsetX, 8 - offsetY);
    CGPathAddLineToPoint(path, NULL, 27 - offsetX, 31 - offsetY);
    
    CGPathCloseSubpath(path);
    

    [parentNode addChild:ship];
    
    parentNode.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
    parentNode.physicsBody.dynamic = NO;
    parentNode.physicsBody.restitution = 0.0f;
    parentNode.physicsBody.friction = 0.0f;
    parentNode.physicsBody.linearDamping = 1.0f;
    parentNode.physicsBody.allowsRotation = NO;
    parentNode.physicsBody.usesPreciseCollisionDetection = YES;
    

    
    return parentNode;
}

-(void)rotateNodeUpwards: (SKNode *)nodeRotate {
    SKAction *rotateUp = [SKAction rotateToAngle:0.4 duration:.2 shortestUnitArc:YES];
    rotateUp.timingMode = SKActionTimingEaseInEaseOut;
    [nodeRotate runAction:rotateUp];
}

-(void)rotateNodeDownwards: (SKNode *)nodeRotate {
    SKAction *rotateDown = [SKAction rotateToAngle:-M_PI_4 duration:.2 shortestUnitArc:YES];
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

@end
