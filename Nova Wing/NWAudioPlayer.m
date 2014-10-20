//
//  NWAudioPlayer.m
//  Nova Wing
//
//  Created by Cameron Frank on 10/17/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import "NWAudioPlayer.h"

@implementation NWAudioPlayer
{
    AVPlayer *player;
}

@synthesize isPlaying, delegate;

+(NWAudioPlayer *)sharedAudioPlayer {
    static dispatch_once_t pred;
    static NWAudioPlayer *sharedAudioPlayer = nil;
    dispatch_once(&pred, ^
                  {
                      sharedAudioPlayer = [[self alloc] init];
                  });
    return sharedAudioPlayer;
}

-(void)createAllMusicWithAudio: (songTitle)audio {
    
    switch (audio) {
        case Menu_Music:
            [self playMusicWithString:@"menuMusic" ofTitle:audio];
            break;
        case Level_1:
            [self playMusicWithString:@"Level-1-Music" ofTitle:audio];
            break;
        case Level_2:
            [self playMusicWithString:@"Level-2-Music" ofTitle:audio];
            break;
        case Game_Over:
            break;
        default:
            break;
    }
}

-(void)playMusicWithString: (NSString *)file ofTitle: (songTitle)audio {
    if (audio != _songName) {
        NSString *soundFile = [[NSBundle mainBundle] pathForResource:file ofType:@"m4a"];
        NSURL *soundFileUrl = [NSURL fileURLWithPath:soundFile];
        NSError *Error = nil;
        _bgPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileUrl error:&Error];
        _bgPlayer.numberOfLoops = -1;
        _bgPlayer.volume = [GameState sharedGameData].audioVolume;
    
        [_bgPlayer prepareToPlay];
        [_bgPlayer play];
    }
}

@end
