//
//  AppDelegate.h
//  Nova Wing
//
//  Created by Bryan Todd on 8/11/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

-(void)authenticateLocalPlayer;

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) NSMutableDictionary *achievementsDictionary;
@property (nonatomic, retain) NSString* leaderboardIdentifier;
@property (nonatomic, retain) NSError* lastError;

@end
