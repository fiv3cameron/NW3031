//
//  GameKitHelper.m
//  Nova Wing
//
//  Created by Bryan Todd on 2/9/15.
//  Copyright (c) 2015 FIV3 Interactive, LLC. All rights reserved.
//

#import "GameKitHelper.h"

NSString *const PresentAuthenticationViewController = @"present_authentication_view_controller";

@implementation GameKitHelper

//Singleton...apparently?
+ (instancetype)sharedGameKitHelper
{
    static GameKitHelper *sharedGameKitHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGameKitHelper = [[GameKitHelper alloc] init];
    });
    return sharedGameKitHelper;
}

- (id)init
{
    self = [super init];
    if (self) {
        _enableGameCenter = YES;
    }
    return self;
}

- (void)authenticateLocalPlayer
{
    //1
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    //2
    //localPlayer.authenticateHandler =
    
    //https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/GameKit_Guide/Users/Users.html
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error) {
        //3
        [self setLastError:error];
        
        if(viewController != nil) {
            //4
            [self setAuthenticationViewController:viewController];
        } else if([GKLocalPlayer localPlayer].isAuthenticated) {
            //5
            _enableGameCenter = YES;
            NSLog(@"Successful");
        } else {
            //6
            _enableGameCenter = NO;
            NSLog(@"Failure");
        }
    };
}

-(UIViewController*) getRootViewController {
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

- (void)setAuthenticationViewController:(UIViewController *)authenticationViewController
{
    if (authenticationViewController != nil) {
        _authenticationViewController = authenticationViewController;
        [[NSNotificationCenter defaultCenter]
         postNotificationName:PresentAuthenticationViewController
         object:self];
    }
}

- (void)setLastError:(NSError *)error
{
    _lastError = [error copy];
    if (_lastError) {
        NSLog(@"GameKitHelper ERROR: %@",
              [[_lastError userInfo] description]);
    }
}

-(void)submitScore: (int64_t)score toLeader: (NSString *)leaderboard {
    //If game center authentication failed, do nothing.  This must remain at top of this function!
    if (![GameKitHelper sharedGameKitHelper].enableGameCenter) {
        return;
    }
    
    //Create game center score object.
    GKScore* gkScore = [[GKScore alloc] initWithLeaderboardIdentifier:leaderboard player:[GKLocalPlayer localPlayer]];
    gkScore.value = score;
    gkScore.leaderboardIdentifier = leaderboard;
    
    //Send the score to Game Center
    [GKScore reportScores:@[gkScore] withCompletionHandler:^(NSError *error) {
        [self setLastError:error];
        BOOL success = (error == nil);
        
        if ([_delegate respondsToSelector:@selector(onScoresSubmitted:)]) {
            [_delegate onScoresSubmitted:success];
        }
    }];
}

/*-(void)retrieveAchievementsToDictionary: (NSMutableDictionary *)achievementsDictionary {
    //GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) { //error occurs here!
        if (error != nil)
        {
            NSLog(@"Error in loading achievements: %@", error);
        }
        if (achievements != nil)
        {
            // Process the array of achievements.
            //https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/GameKit_Guide/Achievements/Achievements.html#//apple_ref/doc/uid/TP40008304-CH7-SW11
            
            for (GKAchievement *achievement in achievements) {
                [achievementsDictionary setObject:achievement forKey:achievement.identifier];
            }
        }
    }];
}

-(GKAchievement *)getAchievementForIdentifier: (NSString *)identifier fromDictionary: (NSMutableDictionary *)achievementsDictionary {
    GKAchievement *achievement = [achievementsDictionary objectForKey:identifier];
    if (achievement == nil) {
        achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
        [achievementsDictionary setObject:achievement forKey:identifier];
    }
    return achievement;
}

-(void)reportAchievementWithIdentifier: (NSString *)identifier percentComplete: (float) percent fromDictionary: (NSMutableDictionary *)dictionary
{
    GKAchievement *achievement = [self getAchievementForIdentifier:identifier fromDictionary:dictionary];
    for (GKAchievement *tempAchievement in _achievementsDictionary) {
        if ([tempAchievement.identifier isEqualToString:identifier]) {
            tempAchievement.percentComplete = 100.0;
        }
    }
    if (achievement) {
        achievement.percentComplete = percent;
        [GKAchievement reportAchievements:@[achievement] withCompletionHandler:^(NSError *error){
            if (error != nil) {
                [self setLastError:error];
            }
        }];
    }
}*/

-(void) gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    //nothing.
}

/*-(void) storeDictionaryToAchievementsDictionary: (NSMutableDictionary *)dictionary {
    _achievementsDictionary = dictionary;
}

-(NSMutableDictionary *) fillDictionaryFromAchievementsDictionary {
    return _achievementsDictionary;
}*/

@end
