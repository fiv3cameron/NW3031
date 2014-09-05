//
//  LevelOne.h
//  Nova Wing
//
//  Created by Bryan Todd on 8/11/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>
#import "PBParallaxScrolling.h"
#import "GameObjects.h"
#import "Ships.h"

@interface LevelTwo : SKScene
{
    AVAudioPlayer *bgPlayer;
}

@property (nonatomic) PBParallaxBackgroundDirection direction;

-(id)initWithSize:(CGSize)size andDirection: (PBParallaxBackgroundDirection) direction;
-(void)scoreAdd;

@end
