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

-(void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeDouble:self.highScoreL1 forKey:SSGameDataHighScoreL1Key];
    [encoder encodeDouble:self.highScoreL2 forKey:SSGameDataHighScoreL2Key];
}

-(instancetype)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if (self) {
        _highScoreL1 = [decoder decodeDoubleForKey:SSGameDataHighScoreL1Key];
        _highScoreL2 = [decoder decodeDoubleForKey:SSGameDataHighScoreL2Key];
    }
    
    return self;
}

+(NSString*)filePath {
    static NSString* filePath = nil;
    if (!filePath) {
        filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]stringByAppendingString:@"gamedata"];
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
    //self.highScoreL1 = 0;
    //self.highScoreL2 = 0;
}

@end
