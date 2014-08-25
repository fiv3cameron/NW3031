//
//  PillarNode.h
//  Nova Wing
//
//  Created by Bryan Todd on 8/11/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import "GameObjects.h"

@interface ObstaclesL2 : GameObjects

@property (nonatomic) CGSize size;

- (SKSpriteNode *) createAnyPillar;
- (SKSpriteNode *) rockPillarCreate;
- (SKSpriteNode *) thinRockPillarCreate;
- (SKSpriteNode *) radioTowerCreate;
- (SKSpriteNode *) lavaPillarCreate;
- (SKSpriteNode *) createAnyACO;
- (SKSpriteNode *) L2ACO1;
- (SKSpriteNode *) L2ACO2;
- (SKSpriteNode *) L2ACO3;

@end
