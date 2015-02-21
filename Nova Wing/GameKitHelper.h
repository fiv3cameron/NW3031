//
//  GameKitHelper.h
//  Nova Wing
//
//  Created by Bryan Todd on 2/9/15.
//  Copyright (c) 2015 FIV3 Interactive, LLC. All rights reserved.
//

@import GameKit;

//   Protocol to notify external
//   objects when Game Center events occur or
//   when Game Center async tasks are completed

@protocol GCHelperProtocol <NSObject>

-(void) onScoresSubmitted:(bool)success;

@end

extern NSString *const PresentAuthenticationViewController;

@interface GameKitHelper : NSObject

@property (nonatomic, assign)id<GCHelperProtocol> delegate;

@property (nonatomic, readonly) UIViewController *authenticationViewController;
@property (nonatomic, readonly) NSError *lastError;
@property (assign, nonatomic) BOOL enableGameCenter;

+(instancetype)sharedGameKitHelper;
-(void)authenticateLocalPlayer;
-(void) submitScore:(int64_t)score toLeader: (NSString*)leaderboard;
-(UIViewController*) getRootViewController;

@end
