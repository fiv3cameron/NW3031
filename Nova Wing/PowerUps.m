//
//  PowerUps.m
//  Nova Wing
//
//  Created by Cameron Frank on 10/25/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import "PowerUps.h"

@implementation PowerUps

-(SKSpriteNode *)createPups {
    SKSpriteNode  *pupTemp = [SKSpriteNode node];
    
    int randPup = 1;
    
    switch (randPup) {
        case Wing_man:
            pupTemp = [SKSpriteNode spriteNodeWithImageNamed:@"Wingman"];
            pupType = Wing_man;
            break;
            
        default:
            break;
    }
    
    
    return pupTemp;
    
}


@end
