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

@synthesize enableGameCenter;

//Singleton...apparently?
+ (instancetype)sharedGameKitHelper
{
    static GameKitHelper *sharedGameKitHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGameKitHelper = [[GameKitHelper alloc] init];
    });
    return sharedGameKitHelper;
}

- (instancetype)init
{
    if (self = [super init]) {
        if ([[AppDelegate alloc] gameCenterEnabled]) {
            enableGameCenter = YES;
        } else {
            enableGameCenter = NO;
        }
    }
    return self;
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
        //[self setLastError:error];
        BOOL success = (error == nil);
        
        if ([_delegate respondsToSelector:@selector(onScoresSubmitted:)]) {
            [_delegate onScoresSubmitted:success];
            //UIResponder *temp = (UIResponder *)[[UIApplication sharedApplication] delegate];
            
        }
    }];
}

/*-(void)retrieveAchievementsToDictionary: (NSMutableDictionary *)achievementsDictionary {
    managed under main menu "achievementRetrievement" function.
}

-(void)achievementLoad {
    if (enableGameCenter) {
        [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
            if (error != nil) {
                NSLog(@"Error in loading achievements.");
            }
            if (achievements != nil) {
                //Process achievements.
                for (GKAchievement *temp in achievements) {
                    //temp
                    //[[GameKitHelper sharedGameKitHelper].achievementsDictionary setObject:temp forKey:temp.identifier];
                    //[_achievementsDictionary setObject:temp forKey:temp.identifier];
                }
                NSLog(@"Achievements Retrievemented");
            }
        }];
    } else {
        NSLog(@"Achievements not loaded");
    }
}*/

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
    if (achievement) {
        achievement.percentComplete = percent;
        [GKAchievement reportAchievements:@[achievement] withCompletionHandler:^(NSError *error){
            if (error != nil) {
                //[self setLastError:error];
            }
        }];
    }
}

-(void)sendUpdateArrayToGameCenter: (NSArray *)incomingArray {
    [GKAchievement reportAchievements:incomingArray withCompletionHandler:^(NSError *error){
        if (error != nil) {
            //[self setLastError:error];
        }
    }];
}

-(void) gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    //nothing.
}

@end
