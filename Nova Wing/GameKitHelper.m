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
    localPlayer.authenticateHandler =
    ^(UIViewController *viewController, NSError *error) {
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

-(void) gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    //[gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
