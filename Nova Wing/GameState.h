//
//  GameState.h
//  Nova Wing
//
//  Created by Bryan Todd on 8/11/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameState : NSObject <NSCoding>

    @property (assign, nonatomic) long score;
    @property (assign, nonatomic) long highScoreL1;
    @property (assign, nonatomic) long highScoreL2;
    @property (nonatomic) long levelIndex;
    @property (nonatomic) long lvlIndexMax;
    @property (nonatomic) int scoreMultiplier;
    @property (nonatomic, assign) long audioVolume;

+(instancetype)sharedGameData;
-(void)reset;
-(void)resetAll;
-(void)save;

@end