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

-(SKShapeNode *)createFlash {
    SKColor *blueFlash = [SKColor colorWithRed:0.5 green:0.8 blue:1 alpha:1];
    SKColor *greenFlash = [SKColor colorWithRed:0.1 green:1 blue:0.7 alpha:1];
    SKColor *purpleFlash = [SKColor colorWithRed:1 green:0 blue:0.7 alpha:1];
    SKColor *yellowFlash = [SKColor colorWithRed:1 green:1 blue:0 alpha:1];
    
    SKShapeNode *flash = [SKShapeNode node];
    flash.alpha = 0;
    flash.zPosition = 103;
    
    switch ([GameState sharedGameData].scoreMultiplier) {
        case 1:
            flash.fillColor = blueFlash;
            break;
        case 2:
            flash.fillColor = greenFlash;
            break;
        case 3:
            flash.fillColor = purpleFlash;
            break;
        case 4:
            flash.fillColor = yellowFlash;
            break;            
        default:
            break;
    }

    return flash;
}

-(void)popActionWithNode: (SKNode *)node {
    SKAction *fadeIn = [SKAction fadeAlphaTo:1 duration:.05];
    SKAction *fadeOut = [SKAction fadeAlphaTo:0 duration:.15];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *seq = [SKAction sequence:@[fadeIn,fadeOut, remove]];
    
    [node runAction:seq];
}

@end
