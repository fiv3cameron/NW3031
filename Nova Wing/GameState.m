//
//  GameState.m
//  Nova Wing
//
//  Created by Bryan Todd on 8/11/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import "GameState.h"
#import "KeychainWrapper.h"

@implementation GameState

static NSString* const SSGameDataChecksumKey = @"SSGameDataChecksumKey";
static NSString* const SSGameDataHighScoreL1Key = @"highScoreL1";
static NSString* const SSGameDataHighScoreL2Key = @"highScoreL2";
static NSString* const SSGameDataAudioVolume = @"audioVolume";
static NSString* const SSGameDataVibeState = @"vibrationState";
static NSString* const SSGameDataAchievementsKey = @"achievementsKey";
static NSString* const SSGameDataStats = @"statsKey";
static NSString* const SSGameDataRankKey = @"rankKey";
static NSString* const SSGameDataTotalLaserHitsKey = @"totalLaserHitsKey";
static NSString* const SSGameDataTotalLasersFiredKey = @"totalLasersFiredKey";
static NSString* const SSGameDataTotalAsteroidsDestroyedKey = @"totalAsteroidsDestroyed";
static NSString* const SSGameDataTotalDebrisDestroyed = @"totalDebrisDestroyed";
static NSString* const SSGameDataTotalChallengePoints = @"totalChallengePoints";
static NSString* const SSGameDataTotalPoints = @"totalPoints";
static NSString* const SSGameDataTotalGames = @"totalGames";
static NSString* const SSGameDataTotalBlackHoleDeaths = @"totalBlackHoleDeaths";
static NSString* const SSGameDataTotalAsteroidDeaths = @"totalAsteroidDeaths";
static NSString* const SSGameDataTotalDebrisDeaths = @"totalDebrisDeaths";
static NSString* const SSGameDataAllTimeAverageScore = @"allTimeAverageScore";
static NSString* const SSGameDataAllTimeAverageAccuracy = @"allTimeAverageAccuracy";

-(void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeDouble:self.highScoreL1 forKey:SSGameDataHighScoreL1Key];
    [encoder encodeDouble:self.highScoreL2 forKey:SSGameDataHighScoreL2Key];
    [encoder encodeDouble:self.audioVolume forKey:SSGameDataAudioVolume];
    [encoder encodeInt:self.vibeOn forKey:SSGameDataVibeState];
    [encoder encodeObject:self.achievementsDictionary forKey:SSGameDataAchievementsKey];
    [encoder encodeInt:self.rankAchieved forKey:SSGameDataRankKey];
    [encoder encodeInt:self.totalLaserHits forKey:SSGameDataTotalLaserHitsKey];
    [encoder encodeInt:self.totalLasersFired forKey:SSGameDataTotalLasersFiredKey];
    [encoder encodeInt:self.totalAsteroidsDestroyed forKey:SSGameDataTotalAsteroidsDestroyedKey];
    [encoder encodeInt:self.totalDebrisDestroyed forKey:SSGameDataTotalDebrisDestroyed];
    [encoder encodeInt:self.totalChallengePoints forKey:SSGameDataTotalChallengePoints];
    [encoder encodeDouble:self.totalPoints forKey:SSGameDataTotalPoints];
    [encoder encodeInt:self.totalGames forKey:SSGameDataTotalGames];
    [encoder encodeInt:self.totalBlackHoleDeaths forKey:SSGameDataTotalBlackHoleDeaths];
    [encoder encodeInt:self.totalAsteroidDeaths forKey:SSGameDataTotalAsteroidDeaths];
    [encoder encodeInt:self.totalDebrisDeaths forKey:SSGameDataTotalDebrisDeaths];
    [encoder encodeFloat:self.allTimeAverageScore forKey:SSGameDataAllTimeAverageScore];
    [encoder encodeFloat:self.allTimeAverageAccuracy forKey:SSGameDataAllTimeAverageAccuracy];
}

-(instancetype)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if (self) {
        _highScoreL1 = [decoder decodeDoubleForKey:SSGameDataHighScoreL1Key];
        _highScoreL2 = [decoder decodeDoubleForKey:SSGameDataHighScoreL2Key];
        _audioVolume = [decoder decodeDoubleForKey:SSGameDataAudioVolume];
        _vibeOn = [decoder decodeIntForKey:SSGameDataVibeState];
        _achievementsDictionary = [decoder decodeObjectForKey:SSGameDataAchievementsKey];
        _rankAchieved = [decoder decodeIntForKey:SSGameDataRankKey];
        _totalLaserHits = [decoder decodeIntForKey:SSGameDataTotalLaserHitsKey];
        _totalLasersFired = [decoder decodeIntForKey:SSGameDataTotalLasersFiredKey];
        _totalAsteroidsDestroyed = [decoder decodeIntForKey:SSGameDataTotalAsteroidsDestroyedKey];
        _totalDebrisDestroyed = [decoder decodeIntForKey:SSGameDataTotalDebrisDestroyed];
        _totalChallengePoints = [decoder decodeIntForKey:SSGameDataTotalChallengePoints];
        _totalPoints = [decoder decodeDoubleForKey:SSGameDataTotalPoints];
        _totalGames = [decoder decodeIntForKey:SSGameDataTotalGames];
        _totalBlackHoleDeaths = [decoder decodeIntForKey:SSGameDataTotalBlackHoleDeaths];
        _totalAsteroidDeaths = [decoder decodeIntForKey:SSGameDataTotalAsteroidDeaths];
        _totalDebrisDeaths = [decoder decodeIntForKey:SSGameDataTotalDebrisDeaths];
        _allTimeAverageScore = [decoder decodeFloatForKey:SSGameDataAllTimeAverageScore];
        _allTimeAverageAccuracy = [decoder decodeFloatForKey:SSGameDataAllTimeAverageAccuracy];
    }
    
    return self;

}

+(instancetype)sharedGameData {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self loadInstance];
    });
    
    return sharedInstance;
}

-(void)reset {
    self.score = 0;
}

-(void)resetAll {
    self.score = 0;
    self.highScoreL1 = 0;
    self.highScoreL2 = 0;
}

+(NSString*)filePath {
    static NSString* filePath = nil;
    if (!filePath) {
        filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]stringByAppendingPathComponent:@"gamedata"];
    }
    
    return filePath;
}

+(instancetype)loadInstance {
    NSData* decodedData = [NSData dataWithContentsOfFile: [GameState filePath]];
    if (decodedData) {
        NSString* checksumOfSavedFile = [KeychainWrapper computeSHA256DigestForData:decodedData];
        NSString* checksumInKeychain = [KeychainWrapper keychainStringFromMatchingIdentifier:SSGameDataChecksumKey];
        
        if ([checksumOfSavedFile isEqualToString: checksumInKeychain]){
            GameState* gameData = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
            return gameData;
        }
    }
    
    return [[GameState alloc]init];
}

-(void)save {
    NSData* encodedData = [NSKeyedArchiver archivedDataWithRootObject: self];
    [encodedData writeToFile:[GameState filePath] atomically:YES];
    NSString* checksum = [KeychainWrapper computeSHA256DigestForData: encodedData];
    if ([KeychainWrapper keychainStringFromMatchingIdentifier:SSGameDataChecksumKey]) {
        [KeychainWrapper updateKeychainValue:checksum forIdentifier:SSGameDataChecksumKey];
    } else {
        [KeychainWrapper createKeychainValue:checksum forIdentifier:SSGameDataChecksumKey];
    }
}





@end
