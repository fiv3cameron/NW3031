//
//  NWAudioPlayer.h
//  Nova Wing
//
//  Created by Cameron Frank on 10/17/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(int, songTitle) {
    Null_Audio,
    Menu_Music,
    Level_1,
    Level_2,
    Game_Over,
};

@protocol AudioPlayerDelegate;

@interface NWAudioPlayer : NSObject

@property (nonatomic, assign) songTitle songName;
@property (nonatomic) AVAudioPlayer* bgPlayer;
@property (nonatomic, assign, readonly) BOOL isPlaying;
@property (nonatomic, assign) id <AudioPlayerDelegate> delegate;

-(void)createAllMusicWithAudio: (songTitle)audio;
+(NWAudioPlayer *)sharedAudioPlayer;

@end

@protocol AudioPlayerDelegate <NSObject>
@end