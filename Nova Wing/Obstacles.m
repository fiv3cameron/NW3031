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

@end
