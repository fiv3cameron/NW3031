//
//  LevelOne.h
//  Nova Wing
//
//  Created by Cameron Frank on 8/19/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Ships.h"
#import "NORLabelNode.h"

@interface Tutorial : SKScene
{
    AVAudioPlayer *bgPlayer;
}

-(void)scoreAdd;

@end