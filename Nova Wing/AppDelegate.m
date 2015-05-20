//
//  AppDelegate.m
//  Nova Wing
//
//  Created by Bryan Todd on 8/11/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize gameCenterEnabled = _gameCenterEnabled; //Added from stack overflow titled "Variable of AppDelegate used as global variable doesn't work".

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self authenticateLocalPlayer];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    _gameCenterEnabled = NO;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self authenticateLocalPlayer];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[GameState sharedGameData] save];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark --Game Center

//authenticateLocalPlayer authenticates the local player <-- this should happen first.
- (void)authenticateLocalPlayer
{
    //Create local player record.
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error) {
        //[GameState sharedGameData].achievementsDictionary = dictionary;
        //[[GameState sharedGameData] save];
        if (viewController != nil) {
            // Use root view controller to present new Game Center Authentication view.
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController: viewController animated: YES completion: ^{
                //LOAD ACHIEVEMENTS USING COMPLETION HANDLER HERE.
                [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler: ^(NSString *leaderboardIdentifier, NSError *error) {
                    
                    if (error != nil) {
                        NSLog(@"%@", [error localizedDescription]);
                    } else {
                        _leaderboardIdentifier = leaderboardIdentifier;
                    }
                }];
                [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
                    if (error != nil) {
                        //[self setLastError: error];
                        NSLog(@"Error in loading achievements.");
                    }
                    if (achievements != nil) {
                        for (GKAchievement *loopAchievie in achievements) {
                            //Set GameState dictionary.
                            [[GameState sharedGameData].achievementsDictionary setValue:loopAchievie forKey:loopAchievie.identifier];
                            //NSLog(loopAchievie.identifier);
                        }
                        [[GameState sharedGameData] save];
                    }
                }];
                if ([GKLocalPlayer localPlayer].isAuthenticated) {
                    _gameCenterEnabled = YES;
                }
            }];
        } else {
            if ([GKLocalPlayer localPlayer].isAuthenticated) {
                _gameCenterEnabled = YES;
                //Get default leaderboard ID after authentication is true.
                [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler: ^(NSString *leaderboardIdentifier, NSError *error) {
                    
                    if (error != nil) {
                        NSLog(@"%@", [error localizedDescription]);
                    } else {
                        _leaderboardIdentifier = leaderboardIdentifier;
                    }
                }];
                
                [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
                    if (error != nil) {
                        //[self setLastError: error];
                        NSLog(@"Error in loading achievements.");
                    }
                    if (achievements != nil) {
                        for (GKAchievement *loopAchievie in achievements) {
                            //Set GameState dictionary.
                            [[GameState sharedGameData].achievementsDictionary setValue:loopAchievie forKey:loopAchievie.identifier];
                            
                            //NSLog(loopAchievie.identifier);
                        }
                        [[GameState sharedGameData] save];
                    }
                }];
                
                //LOAD ACHIEVEMENTS HERE.
            } else {
                //Local player was not already authenticated.
                _gameCenterEnabled = NO;
            }
        }
    };
}

//setLastError creates an NSLog of the error inputted.
- (void)setLastError:(NSError *)error
{
    _lastError = [error copy];
    if (_lastError) {
        NSLog(@"GameKitHelper ERROR: %@",
              [[_lastError userInfo] description]);
    }
}

@end
