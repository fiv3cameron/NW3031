//
//  MyScene.h
//  Nova Wing
//

//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
//#import "PBParallaxScrolling.h"

SKSpriteNode *musicToggle;
SKSpriteNode *sfxToggle;
SKSpriteNode *vibrationToggleButton;
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

//@property (nonatomic) PBParallaxBackgroundDirection direction;
@property (nonatomic) AVAudioPlayer* bgPlayer;

@end
