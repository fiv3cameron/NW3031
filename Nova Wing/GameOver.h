//
//  GameOver.h
//  Nova Wing
//
//  Created by Bryan Todd on 8/11/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LevelTwo.h"

SKLabelNode *backToMain;
SKSpriteNode *playAgain;

@interface GameOver : SKScene

@property (nonatomic) PBParallaxBackgroundDirection direction;

@end
