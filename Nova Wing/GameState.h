//
//  GameState.h
//  Nova Wing
//
//  Created by Bryan Todd on 8/11/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameState : NSObject <NSCoding>

    @property (assign, nonatomic) int score;
    @property (assign, nonatomic) long highScoreL1;
    @property (assign, nonatomic) long highScoreL2;
    @property (nonatomic) long levelIndex;
    @property (nonatomic) long lvlIndexMax;
    @property (assign, nonatomic) int scoreMultiplier;
    @property (assign, nonatomic) long audioVolume;
    @property (assign, nonatomic) BOOL vibeOn;
    @property (assign, nonatomic) int maxLaserHits;
    @property (assign, nonatomic) int totalLaserHits;
    @property (assign, nonatomic) int totalLasersFired;
    @property (assign, nonatomic) int totalAsteroidsDestroyed;
    @property (assign, nonatomic) int totalDebrisDestroyed;
    @property (assign, nonatomic) int totalChallengePoints;
    @property (assign, nonatomic) long totalPoints;
    @property (assign, nonatomic) int totalGames;
    @property (assign, nonatomic) int totalBlackHoleDeaths;
    @property (assign, nonatomic) int totalAsteroidDeaths;
    @property (assign, nonatomic) int totalDebrisDeaths;
    @property (assign, nonatomic) float allTimeAverageScore;
    @property (assign, nonatomic) float allTimeAverageAccuracy;

+(instancetype)sharedGameData;
-(void)reset;
-(void)resetAll;
-(void)save;

@end