//
//  PowerUps.m
//  Nova Wing
//
//  Created by Cameron Frank on 10/25/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import "PowerUps.h"

@implementation PowerUps



-(SKSpriteNode *)createPupsWithType: (pupType)type {
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
        default:
            break;
    }
    
    
    return pupTemp;
    
}

-(pupType)powerUpTypes {
    int randPup = (arc4random()% 3) + 1;

    switch (randPup) {
        case Wing_man:
            _powerUp = Wing_man;
            break;
        case Over_shield:
            _powerUp = Over_shield;
            break;
        case Auto_Cannon:
            _powerUp = Auto_Cannon;
        default:
            break;
    }
    
    return _powerUp;
}

@end
