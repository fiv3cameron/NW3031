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
    CGFloat offsetX = (ship.frame.size.width * 1.5) * ship.anchorPoint.x;
    CGFloat offsetY = (ship.frame.size.height * 1.5) * ship.anchorPoint.y;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, 0 - offsetX, 48 - offsetY);
    CGPathAddLineToPoint(path, NULL, 0 - offsetX, 30 - offsetY);
    CGPathAddLineToPoint(path, NULL, 76 - offsetX, 0 - offsetY);
    CGPathAddLineToPoint(path, NULL, 99 - offsetX, 0 - offsetY);
    CGPathAddLineToPoint(path, NULL, 99 - offsetX, 8 - offsetY);
    CGPathAddLineToPoint(path, NULL, 27 - offsetX, 47 - offsetY);
    
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
    SKAction *rotateUp = [SKAction rotateToAngle:M_PI_4 duration:.2 shortestUnitArc:YES];
    rotateUp.timingMode = SKActionTimingEaseOut;
    [nodeRotate runAction:rotateUp];
}

-(void)rotateNodeDownwards: (SKNode *)nodeRotate {
    SKAction *rotateDown = [SKAction rotateToAngle:-M_PI_4 duration:.15 shortestUnitArc:YES];
    rotateDown.timingMode = SKActionTimingEaseIn;
    [nodeRotate runAction:rotateDown];
}
@end
