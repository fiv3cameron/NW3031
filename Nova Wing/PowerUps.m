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
    [self initColors];
    
    SKShapeNode *flash = [SKShapeNode node];
    flash.alpha = 0;
    flash.zPosition = 103;
    
    switch ([GameState sharedGameData].scoreMultiplier) {
        case 1:
            flash.fillColor = NWBlue;
            break;
        case 2:
            flash.fillColor = NWGreen;
            break;
        case 3:
            flash.fillColor = NWPurple;
            break;
        case 4:
            flash.fillColor = NWYellow;
            break;            
        default:
            break;
    }

    return flash;
}

-(void)initColors {
    NWBlue = [SKColor colorWithRed:0.5 green:0.8 blue:1 alpha:1];
    NWGreen = [SKColor colorWithRed:0.1 green:1 blue:0.7 alpha:1];
    NWPurple = [SKColor colorWithRed:1 green:0 blue:0.7 alpha:1];
    NWYellow = [SKColor colorWithRed:1 green:1 blue:0 alpha:1];
}

-(SKEmitterNode *)createShipTrail {
    [self initColors];
    
    SKEmitterNode *shipTrail = [[SKEmitterNode alloc] init];
    [shipTrail setParticleTexture: [SKTexture textureWithImageNamed:@"spark.png"]];
    [shipTrail setNumParticlesToEmit:0];
    [shipTrail setParticleBirthRate:80];
    [shipTrail setParticleLifetime:2.5];
    [shipTrail setParticlePositionRange:CGVectorMake(0.0, 8.0)];
    [shipTrail setEmissionAngle:185];
    [shipTrail setEmissionAngleRange:0];
    [shipTrail setParticleSpeed:100];
    [shipTrail setParticleSpeedRange:50];
    [shipTrail setXAcceleration:-500];
    [shipTrail setYAcceleration:0];
    [shipTrail setParticleAlpha:0.8];
    [shipTrail setParticleAlphaRange:0.2];
    [shipTrail setParticleAlphaSpeed:-0.5];
    [shipTrail setParticleScale:0.3];
    [shipTrail setParticleScaleRange:0.4];
    [shipTrail setParticleScaleSpeed:-0.2];
    [shipTrail setParticleRotation:0];
    [shipTrail setParticleRotationRange:0];
    [shipTrail setParticleRotationSpeed:0];
    
    switch ([GameState sharedGameData].scoreMultiplier) {
        case 1:
            [shipTrail setParticleColor: NWBlue];
            break;
        case 2:
            [shipTrail setParticleColor: NWGreen];
            break;
        case 3:
            [shipTrail setParticleColor: NWPurple];
            break;
        case 4:
            [shipTrail setParticleColor: NWYellow];
            break;
        default:
            break;
    }
    
    [shipTrail setParticleColorBlendFactor:1];
    [shipTrail setParticleColorBlendFactorRange:0];
    [shipTrail setParticleColorBlendFactorSpeed:0];
    [shipTrail setParticleBlendMode:SKBlendModeAdd];
    
    return shipTrail;
}

-(void)popActionWithNode: (SKNode *)node {
    SKAction *fadeIn = [SKAction fadeAlphaTo:1 duration:.05];
    SKAction *fadeOut = [SKAction fadeAlphaTo:0 duration:.15];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *seq = [SKAction sequence:@[fadeIn,fadeOut, remove]];
    
    [node runAction:seq];
}

@end
