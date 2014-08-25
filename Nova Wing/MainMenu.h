//
//  MyScene.h
//  Nova Wing
//

//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>
#import "LevelTwo.h"

SKSpriteNode *startButton;
SKSpriteNode *leaderButton;
SKSpriteNode *settingsButton;
SKSpriteNode *titleImage;
SKSpriteNode *levelOneThumb;
SKSpriteNode *levelTwoThumb;
SKSpriteNode *rightArrow;
SKSpriteNode *leftArrow;
SKLabelNode *GDReset;

@interface MainMenu : SKScene
{
    AVAudioPlayer *bgPlayer;
}

@property (nonatomic) PBParallaxBackgroundDirection direction;

@end
