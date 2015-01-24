//
//  Obstacles.h
//  Nova Wing
//
//  Created by Bryan Todd on 8/25/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import "GameObjects.h"

@interface Obstacles : GameObjects

- (SKSpriteNode *) createObstacleWithNode: (SKSpriteNode *) incomingNode withName: (NSString*) obstacleType withImage: (NSString *)imageName;

@end
