//
//  Obstacles.m
//  Nova Wing
//
//  Created by Bryan Todd on 8/25/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import "Obstacles.h"

@implementation Obstacles

- (SKSpriteNode *)createObstacleWithNode:(SKSpriteNode *)incomingNode withName:(NSString*)obstacleType withImage: (NSString *)imageName
{
    incomingNode = [SKSpriteNode spriteNodeWithImageNamed:imageName];
    incomingNode.name = [NSString stringWithString:obstacleType];
    return incomingNode;
}

-(SKSpriteNode *)createPillarPhysicsBody:(SKSpriteNode *)incomingNode withIdentifier:(int)pillarSelect
{
    switch (pillarSelect) {
        case 1:
            incomingNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: incomingNode.size];
            incomingNode.physicsBody.dynamic = NO;
            break;
        case 2:
        {
            CGFloat offsetX = incomingNode.frame.size.width * incomingNode.anchorPoint.x;
            CGFloat offsetY = incomingNode.frame.size.height * incomingNode.anchorPoint.y;
            
            CGMutablePathRef thinPillarPath = CGPathCreateMutable();
            
            CGPathMoveToPoint(thinPillarPath, NULL, 13 - offsetX, 561 - offsetY);
            CGPathAddLineToPoint(thinPillarPath, NULL, 1 - offsetX, 0 - offsetY);
            CGPathAddLineToPoint(thinPillarPath, NULL, 73 - offsetX, 1 - offsetY);
            CGPathAddLineToPoint(thinPillarPath, NULL, 65 - offsetX, 341 - offsetY);
            
            CGPathCloseSubpath(thinPillarPath);
            
            incomingNode.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:thinPillarPath];
            incomingNode.physicsBody.dynamic = NO;
            incomingNode.name = @"pillar";
            return incomingNode;
        }
            break;
        case 3:
            incomingNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: incomingNode.size];
            incomingNode.physicsBody.dynamic = NO;
            break;
        case 4:
            incomingNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: incomingNode.size];
            incomingNode.physicsBody.dynamic = NO;
            break;
        default:
            break;
    }
    return incomingNode;
}

@end
