//
//  Credits.h
//  Nova Wing
//
//  Created by Bryan Todd on 6/16/15.
//  Copyright (c) 2015 FIV3 Interactive, LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Ships.h"
#import "NORLabelNode.h"
#import "Multipliers.h"

@interface Credits : SKScene

@property (nonatomic, retain) NSMutableDictionary *achievementsDictionary;

@end

SKSpriteNode *blackHole;
SKLabelNode *tapPlay;
NORLabelNode *introduction;
SKSpriteNode *storyBadge;
bool storymodeL1;
bool levelComplete;
SKSpriteNode *bottom;
AVAudioPlayer *Explosion;
SKEmitterNode *trail;
NSMutableArray *reportArray;
SKSpriteNode *masterAltimeter;
