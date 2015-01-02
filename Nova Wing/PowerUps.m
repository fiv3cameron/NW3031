//
//  PowerUps.m
//  Nova Wing
//
//  Created by Cameron Frank on 10/25/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import "PowerUps.h"

@implementation PowerUps

+(SKSpriteNode *)createPupsWithType: (pupType)type {
    SKSpriteNode  *pupTemp = [SKSpriteNode node];
    
    switch (type) {
        case Wing_man:
            pupTemp = [SKSpriteNode spriteNodeWithImageNamed:@"Wingman"];
            break;
        case Over_shield:
            pupTemp = [SKSpriteNode spriteNodeWithImageNamed:@"Overshield"];
            break;
        case Auto_Cannon:
            pupTemp = [SKSpriteNode spriteNodeWithImageNamed:@"Autocannon"];
            break;
        case Tiny_Nova:
            pupTemp = [SKSpriteNode spriteNodeWithImageNamed:@"TinyNova"];
        default:
            break;
    }
    
    return pupTemp;
    
}

-(pupType)powerUpTypes {
    
    int randPup = (arc4random()% 4) + 1;

    switch (randPup) {
        case Wing_man:
            _powerUp = Wing_man;
            break;
        case Over_shield:
            _powerUp = Over_shield;
            break;
        case Auto_Cannon:
            _powerUp = Auto_Cannon;
            break;
        case Tiny_Nova:
            _powerUp = Tiny_Nova;
            break;
        default:
            break;
    }
    
    return _powerUp;
}

+(void)wingmanInvincibilityFlicker: (SKSpriteNode *)player {
    SKAction *alphaFadeOut = [SKAction fadeAlphaTo:0.5 duration:0.1];
    SKAction *wait = [SKAction waitForDuration:0.3];
    SKAction *alphaFadeUp = [SKAction fadeAlphaTo:1 duration:0.1];
    SKAction *alphaFadeSqnce = [SKAction sequence:@[alphaFadeOut, wait, alphaFadeUp]];
    SKAction *alphaFade4x = [SKAction sequence:@[alphaFadeSqnce,alphaFadeSqnce,alphaFadeSqnce,alphaFadeSqnce]];
    [player runAction:alphaFade4x];
}

-(void)closeTinyNova: (SKSpriteNode *)player {
    player.physicsBody.linearDamping = 1.0;
}

+(SKSpriteNode *)autoCannonFire: (SKSpriteNode *)player withColor: (SKColor *)tempColor {
    SKSpriteNode *laser = [SKSpriteNode spriteNodeWithImageNamed:@"Laser"];
    laser.color = tempColor;
    laser.colorBlendFactor = 1.0;
    laser.xScale = 0.25;
    laser.yScale = 0.8;
    laser.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(laser.size.width, laser.size.height)];
    laser.physicsBody.dynamic = YES;
    laser.physicsBody.affectedByGravity = NO;
    
    return laser;
}

+(void)animateLaser: (SKSpriteNode *)laserToMove withWidth: (float)incomingWidth {
    //Calcs
    float xvector = incomingWidth + laserToMove.size.width-laserToMove.position.x;
    float yvector = xvector*tan(laserToMove.zRotation);
    float hypotenuse = sqrtf(xvector*xvector+yvector*yvector);
    float arbitraryVelocity = 400.0;
    float tempDuration = hypotenuse/arbitraryVelocity;

    //Movements
    SKAction *laserMovement = [SKAction moveBy:CGVectorMake(xvector, yvector) duration:tempDuration];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *laserSqnce = [SKAction sequence:@[laserMovement,remove]];
    [laserToMove runAction:laserSqnce];
}

@end