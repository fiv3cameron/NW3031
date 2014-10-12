//
//  PowerUps.m
//  Nova Wing
//
//  Created by Cameron Frank on 10/8/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import "PowerUps.h"

@implementation PowerUps

-(SKSpriteNode *)createMultiplier {
    SKSpriteNode *multitemp = [SKSpriteNode node];
    
    switch ([GameState sharedGameData].scoreMultiplier) {
        case 1:
            multitemp = [SKSpriteNode spriteNodeWithImageNamed:@"2xMulti"];
            break;
        case 2:
            multitemp = [SKSpriteNode spriteNodeWithImageNamed:@"3xMulti"];
            break;
        case 3:
            multitemp = [SKSpriteNode spriteNodeWithImageNamed:@"4xMulti"];
            break;
        case 4:
            multitemp = [SKSpriteNode spriteNodeWithImageNamed:@"5xMulti"];
            break;
        default:
            break;
    }
    
    return multitemp;
}


-(SKSpriteNode *)createPup {
    SKSpriteNode *temp = [SKSpriteNode node];
    return temp;
}

-(void)createFlash {
    
}

@end
