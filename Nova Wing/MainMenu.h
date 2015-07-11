//
//  MyScene.h
//  Nova Wing
//

//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface MainMenu : SKScene
{
}

@property (nonatomic) AVAudioPlayer* bgPlayer;
@property (nonatomic, assign) GKGameCenterViewController *gcManager;
@property (nonatomic, retain) NSMutableDictionary *achievementsDictionary;
@property (nonatomic, retain) GKAchievement *activeRank;
@property (nonatomic, assign) int maxRank;

@end
