//
//  MyScene.h
//  Nova Wing
//

//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LevelTwo.h"

SKSpriteNode *startButton;
SKSpriteNode *leaderButton;
SKSpriteNode *settingsButton;
SKSpriteNode *titleImage;
SKSpriteNode *levelThumb;
SKSpriteNode *levelTwoThumb;
SKSpriteNode *rightArrow;
SKSpriteNode *leftArrow;
SKLabelNode *GDReset;
NSArray *levelTitles;



@interface MainMenu : SKScene
{
}

@property (nonatomic) PBParallaxBackgroundDirection direction;
@property (nonatomic) AVAudioPlayer* bgPlayer;

@end
