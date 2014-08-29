//
//  PillarNode.m
//  Nova Wing
//
//  Created by Bryan Todd on 8/11/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import "ObstaclesL2.h"

@implementation ObstaclesL2

- (BOOL) collisionOccured:(SKNode *)player
{
    return YES;
}

#pragma mark --Create Obstacles
- (SKSpriteNode *)createAnyPillar
{
    SKSpriteNode *pillar1;                               // Initialize pointer to pillar.
    int randPillarInt = arc4random_uniform(3) + 1;       // Generate random integer between 1 and 4 to select pillar type.
    switch (randPillarInt) {                             // Switch-case to select pillar type.
        case 1:
            pillar1 = [self rockPillarCreate];
            break;
        case 2:
            pillar1 = [self thinRockPillarCreate];
            break;
        case 4:
            pillar1 = [self radioTowerCreate];
            break;
        case 3:
            pillar1 = [self lavaPillarCreate];
            break;
        default:
            break;
    }
    return pillar1; // Return pointer.
}

- (SKSpriteNode *)createAnyACO
{
    SKSpriteNode * ACO;
    /*int ACOInt = arc4random_uniform(2) + 1;
    switch (ACOInt) {
        case 1:
            ACO = [self L2ACO1];
            break;
        case 2:
            ACO = [self L2ACO2];
            break;
        case 3:
            ACO = [self L2ACO3];
            break;
        default:
            break;
     }*/
    ACO = [self L2ACO1];
    return ACO;
}

#pragma mark --Pillar Types
- (SKSpriteNode *)rockPillarCreate
{
    SKSpriteNode *deliverPillar = [SKSpriteNode spriteNodeWithImageNamed: @"Pillar-1"];
    deliverPillar.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, deliverPillar.size.width / 2, deliverPillar.size.height / 2)];
    deliverPillar.physicsBody.dynamic = NO;
    deliverPillar.name = @"pillar";
    return deliverPillar;
    
};

- (SKSpriteNode *)thinRockPillarCreate
{
    SKSpriteNode *deliverPillar = [SKSpriteNode spriteNodeWithImageNamed:@"Pillar-2"];
    
    //Create Path for pillar PhysicsBody
    CGFloat offsetX = (deliverPillar.frame.size.width * 1.2) * deliverPillar.anchorPoint.x;
    CGFloat offsetY = (deliverPillar.frame.size.height * 1.2) * deliverPillar.anchorPoint.y;
    
    CGMutablePathRef thinPillarPath = CGPathCreateMutable();
    
    CGPathMoveToPoint(thinPillarPath, NULL, 13 - offsetX, 561 - offsetY);
    CGPathAddLineToPoint(thinPillarPath, NULL, 1 - offsetX, 0 - offsetY);
    CGPathAddLineToPoint(thinPillarPath, NULL, 73 - offsetX, 1 - offsetY);
    CGPathAddLineToPoint(thinPillarPath, NULL, 65 - offsetX, 341 - offsetY);
    
    CGPathCloseSubpath(thinPillarPath);
    
    deliverPillar.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:thinPillarPath];
    deliverPillar.physicsBody.dynamic = NO;
    deliverPillar.name = @"pillar";
    return deliverPillar;
}

- (SKSpriteNode *) radioTowerCreate
{
    SKSpriteNode *deliverPillar = [SKSpriteNode spriteNodeWithImageNamed:@"Pillar-4"];
    deliverPillar.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, deliverPillar.size.width / 2, deliverPillar.size.height / 2)];
    deliverPillar.physicsBody.dynamic = NO;
    deliverPillar.name = @"pillar";
    return deliverPillar;
}

- (SKSpriteNode *) lavaPillarCreate
{
    SKSpriteNode *deliverPillar = [SKSpriteNode spriteNodeWithImageNamed:@"Pillar-3"];
    deliverPillar.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, deliverPillar.size.width / 2.1, deliverPillar.size.height / 2.1)];
    deliverPillar.physicsBody.dynamic = NO;
    deliverPillar.name = @"pillar";
    return deliverPillar;
}

#pragma mark --ACO Types
- (SKSpriteNode *)L2ACO1
{
    SKSpriteNode *aerialObject = [SKSpriteNode spriteNodeWithImageNamed:@"AOb-1"];
    aerialObject.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:aerialObject.size.height/2];
    aerialObject.physicsBody.dynamic = NO;
    aerialObject.name = @"aerial";
    return aerialObject;
}

- (SKSpriteNode *)L2ACO2
{
    SKSpriteNode *aerialObject = [SKSpriteNode spriteNodeWithImageNamed:@"AOb-2"];
    aerialObject.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:aerialObject.size.width/2];
    aerialObject.physicsBody.dynamic = NO;
    aerialObject.name = @"aerial";
    return aerialObject;
}

- (SKSpriteNode *)L2ACO3
{
    SKSpriteNode *aerialObject = [SKSpriteNode spriteNodeWithImageNamed:@"AOb-3"];
    aerialObject.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:aerialObject.size.width/2];
    aerialObject.physicsBody.dynamic = NO;
    aerialObject.name = @"aerial";
    return aerialObject;
}

@end
