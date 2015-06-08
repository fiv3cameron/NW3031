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

@interface LevelOne : SKScene
{
    AVAudioPlayer *bgPlayer;
}

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
SKEmitterNode *wingmanTrail;
int localLaserHits;
int localTotalLaserHits;
int localTotalLasersFired;
int localTotalAsteroidHits;
int localTotalDebrisHits;
int localChallengePoints;
NSMutableArray *reportArray;
SKSpriteNode *masterAltimeter;