//
//  MyScene.m
//  Nova Wing
//
//  Created by Bryan Todd on 8/11/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import "MainMenu.h"
#import "LevelOne.h"
#import "NWCodex.h"
#import "Tutorial.h"
#import <UIKit/UIKit.h>

static const float BG_VELOCITY = 10.0;

static inline CGPoint CGPointAdd(const CGPoint a, const CGPoint b)
{
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint CGPointMultiplyScalar(const CGPoint a, const CGFloat b)
{
    return CGPointMake(a.x * b, a.y * b);
}

@interface MainMenu()
{
    SKSpriteNode *startButton;
    SKSpriteNode *leaderButton;
    SKSpriteNode *settingsButton;
    SKSpriteNode *codexButton;
    SKSpriteNode *creditButton;
    float rankScoreMoveDist;
    
        //Textures
    SKTexture *audioTexture;
    SKTexture *audioTexture_off;
    SKTexture *audioTexture_highlight;
}

@end


@implementation MainMenu

NSTimeInterval _lastUpdateTime;
NSTimeInterval _dt;

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        [GameState sharedGameData].levelIndex = 0;
        [GameState sharedGameData].lvlIndexMax = 2;

        
        if ([GameState sharedGameData].highScoreL1 < 1) {
            [GameState sharedGameData].audioVolume = 1.0;
        }
        
        [self initializeScrollingBackground];
        [self loadTextures];
        
        [self addChild: [self addTitleNode]];
        [self addChild: [self startButtonNode]];
        [self addChild: [self leaderButtonNode]];
        [self addChild: [self codexButtonNode]];
        [self addChild: [self creditsButtonNode]];
        [self addChild: [self settingsButtonNode]];
        [self updateRank];
        [self createRankInsignia];
        
        [self createAudio];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showAd" object:nil];
        levelTitles = @[@"Event Horizon", @"The Whispers", @"TempLevel3"];
        
        //Check achievements for rank.
        
        
        //[self achievementRetrievement];
        NSLog(@"high score %ld",[GameState sharedGameData].highScoreL1);
        NSLog(@"asteroid deaths %d",[GameState sharedGameData].totalAsteroidDeaths);
        NSLog(@"rank %i",[GameState sharedGameData].rankAchieved);
    }
    return self;
}

-(void)loadTextures {
    audioTexture = [SKTexture textureWithImageNamed:@"Audio"];
    audioTexture_highlight = [SKTexture textureWithImageNamed:@"Audio_press"];
    audioTexture_off = [SKTexture textureWithImageNamed:@"Audio_disengage"];
}

#pragma mark --Create Background

-(void)initializeScrollingBackground
{
    for (int i = 0; i < 2; i ++) {
        SKSpriteNode *starBG = [SKSpriteNode spriteNodeWithImageNamed:@"Stars-Seamless.jpg"];
        starBG.position = CGPointMake(0, i * starBG.size.height);
        starBG.anchorPoint = CGPointZero;
        starBG.name = @"starBG";
        [self addChild:starBG];
    }
}

-(void)moveBG
{
    [self enumerateChildNodesWithName:@"starBG" usingBlock: ^(SKNode *node, BOOL *stop)
     {
         SKSpriteNode * starBG = (SKSpriteNode *) node;
         CGPoint bgVelocity = CGPointMake(0, -BG_VELOCITY);
         CGPoint amtToMove = CGPointMultiplyScalar(bgVelocity,_dt);
         starBG.position = CGPointAdd(starBG.position, amtToMove);
         
         //Checks if bg node is completely scrolled of the screen, if yes then put it at the end of the other node
         if (starBG.position.y <= -starBG.size.height)
         {
             starBG.position = CGPointMake(starBG.position.x,
                                           starBG.position.y + starBG.size.height*2);
         }
     }];
}

-(SKSpriteNode *)addTitleNode
{
    titleImage = [SKSpriteNode spriteNodeWithImageNamed:@"Title.png"];
    titleImage.position = CGPointMake(self.size.width/2, 400);
    titleImage.xScale = 0.5;
    titleImage.yScale = 0.5;
    return titleImage;
}

#pragma mark --Create Buttons

#define BUTTON_HEIGHT 280
#define BUTTON_OFFSET 60

-(SKSpriteNode *)startButtonNode
{
    startButton = [SKSpriteNode spriteNodeWithTexture: [SKTexture textureWithImageNamed:@"buttonStart.png"]];
    startButton.position = CGPointMake(self.size.width/2-300, BUTTON_HEIGHT);
    startButton.xScale = 0.5;
    startButton.yScale = 0.5;
    startButton.name = @"_startButton";
    SKAction *buttonWait = [SKAction waitForDuration:1.0];
    SKAction *buttonShift = [SKAction moveTo:CGPointMake(self.size.width/2, BUTTON_HEIGHT) duration:0.75];
    buttonShift.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *buttonSequence = [SKAction sequence:@[buttonWait,buttonShift]];
    [startButton runAction: buttonSequence];
    return startButton;
}

-(SKSpriteNode *)leaderButtonNode
{
    leaderButton = [SKSpriteNode spriteNodeWithImageNamed:@"buttonLeaderboard.png"];
    leaderButton.position = CGPointMake(self.size.width/2-300, BUTTON_HEIGHT - BUTTON_OFFSET);
    leaderButton.xScale = 0.5;
    leaderButton.yScale = 0.5;
    leaderButton.name = @"_leaderButton";
    SKAction *buttonWait = [SKAction waitForDuration:1.25];
    SKAction *buttonShift = [SKAction moveTo:CGPointMake(self.size.width/2, BUTTON_HEIGHT - BUTTON_OFFSET) duration:0.75];
    buttonShift.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *buttonSequence = [SKAction sequence:@[buttonWait,buttonShift]];
    [leaderButton runAction: buttonSequence];
    return leaderButton;
}

-(SKSpriteNode *)codexButtonNode {
    codexButton = [SKSpriteNode spriteNodeWithImageNamed:@"buttonCodex.png"];
    codexButton.position = CGPointMake(self.size.width/2-300, BUTTON_HEIGHT - (BUTTON_OFFSET * 2));
    codexButton.xScale = 0.5;
    codexButton.yScale = 0.5;
    codexButton.name = @"codexButton";
    SKAction *buttonWait = [SKAction waitForDuration:1.5];
    SKAction *buttonShift = [SKAction moveTo:CGPointMake(self.size.width/2, BUTTON_HEIGHT - (BUTTON_OFFSET * 2)) duration:0.75];
    buttonShift.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *buttonSequence = [SKAction sequence:@[buttonWait,buttonShift]];
    [codexButton runAction: buttonSequence];
    return codexButton;
}

-(SKSpriteNode *)creditsButtonNode {
    creditButton = [SKSpriteNode spriteNodeWithImageNamed:@"buttonCredits.png"];
    creditButton.position = CGPointMake(self.size.width/2-300, BUTTON_HEIGHT - (BUTTON_OFFSET * 3));
    creditButton.xScale = 0.5;
    creditButton.yScale = 0.5;
    creditButton.name = @"creditsButton";
    SKAction *buttonWait = [SKAction waitForDuration:1.75];
    SKAction *buttonShift = [SKAction moveTo:CGPointMake(self.size.width/2, BUTTON_HEIGHT - (BUTTON_OFFSET * 3)) duration:0.75];
    buttonShift.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *buttonSequence = [SKAction sequence:@[buttonWait,buttonShift]];
    [creditButton runAction: buttonSequence];
    return creditButton;
}

-(SKSpriteNode *)settingsButtonNode
{
    settingsButton = [SKSpriteNode spriteNodeWithImageNamed:@"Settings"];
    settingsButton.position = CGPointMake(-settingsButton.size.width, self.size.height);
    settingsButton.xScale = 0.5;
    settingsButton.yScale = 0.5;
    settingsButton.name = @"_settingsButton";
    SKAction *buttonWait = [SKAction waitForDuration:1.5];
    SKAction *buttonShift = [SKAction moveTo:CGPointMake(settingsButton.size.width, self.size.height - 30) duration:0.5];
    buttonShift.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *buttonSequence = [SKAction sequence:@[buttonWait,buttonShift]];
    [settingsButton runAction: buttonSequence];
    return settingsButton;
}


-(SKLabelNode *)highScoreLabel {
    highScore = [[SKLabelNode alloc] initWithFontNamed:@"SF Movie Poster"];
    highScore.position = CGPointMake(self.size.width+175, self.size.height - 40);
    highScore.fontColor = [SKColor whiteColor];
    highScore.fontSize = 30;
    highScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    highScore.zPosition = 101;
    highScore.text = [NSString stringWithFormat:@"HIGH SCORE: %li  ", [GameState sharedGameData].highScoreL1];
    
    SKAction *wait = [SKAction waitForDuration:.75];
    rankScoreMoveDist = highScore.frame.size.width + 175;
    SKAction *move = [SKAction moveByX:-(rankScoreMoveDist + 10) y:0 duration:0.5];
    move.timingMode = SKActionTimingEaseIn;
    SKAction *sequence = [SKAction sequence:@[wait, move]];
    [highScore runAction: sequence];
                                     
    return highScore;
}


-(SKLabelNode *)backToMainButton
{
    SKNode *mainButtonHouse;
    mainButtonHouse.alpha = 0.0;
    
    SKLabelNode *backToMain = [SKLabelNode labelNodeWithFontNamed:@"SF Movie Poster"];
    backToMain.alpha = 0.0;
    backToMain.position = CGPointMake(60.0f, self.size.height - 40);
    backToMain.fontColor = [SKColor whiteColor];
    backToMain.fontSize = 30;
    backToMain.name = @"backToMain";
    backToMain.text = @"BACK to MAIN";
    
    [self fadeInNode:backToMain withWait:1.0 fadeAlphaTo:1.0 fadeAlphaWithDuration:0.3];
    
    return backToMain;
}

#pragma mark --Create Audio

-(void)createAudio
{
    [[NWAudioPlayer sharedAudioPlayer] createAllMusicWithAudio:Menu_Music];
    [NWAudioPlayer sharedAudioPlayer].songName = Menu_Music;
}

-(void)playSoundEffectsWithAction: (SKAction *)action {
    if ([GameState sharedGameData].audioVolume == 1.0) {
        [self runAction:action];
    }
}

-(void)toggleAudio {
    if ([GameState sharedGameData].audioVolume == 1.0) {
        musicToggle.texture = audioTexture_off;
        [GameState sharedGameData].audioVolume = 0.0;
        [[NWAudioPlayer sharedAudioPlayer] bgPlayer].volume = [GameState sharedGameData].audioVolume;
        [[GameState sharedGameData] save];
    } else if ([GameState sharedGameData].audioVolume == 0.0) {
        musicToggle.texture = audioTexture;
        [GameState sharedGameData].audioVolume = 1.0;
        [[NWAudioPlayer sharedAudioPlayer] bgPlayer].volume = [GameState sharedGameData].audioVolume;
        [[GameState sharedGameData] save];
    }
}

-(void)toggleVibration {
    if ([GameState sharedGameData].vibeOn == YES) { //Vibration is on, and user has selected to turn it off.  Do not vibrate.
        vibrationToggleButton.texture = [SKTexture textureWithImageNamed:@"vibrateButton_off"];
        [GameState sharedGameData].vibeOn = NO;
        [[GameState sharedGameData] save];
    } else { //Vibration is off and user has selected to turn it on.  Vibrate.
        vibrationToggleButton.texture = [SKTexture textureWithImageNamed:@"vibrateButton"];
        [GameState sharedGameData].vibeOn = YES;
        [[GameState sharedGameData] save];
        [self vibrate];
    }
}

-(void)vibrate {
    if ([GameState sharedGameData].vibeOn == YES) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

#pragma mark --Level Select

-(SKSpriteNode *)createRightArrowWithWait: (double)waitTime
{
    rightArrow = [SKSpriteNode spriteNodeWithImageNamed:@"arrowR"];
    rightArrow.position = CGPointMake((self.size.width / 8)*7.5, self.size.height / 2);
    rightArrow.name = @"rightArrow";
    rightArrow.alpha = 0;
    rightArrow.xScale = 0.7;
    rightArrow.yScale = 0.7;
    rightArrow.zPosition = 10;

    [self fadeInNode:rightArrow withWait:waitTime fadeAlphaTo:1.0 fadeAlphaWithDuration:0.5];
    
    return rightArrow;
}

-(SKSpriteNode *)createLeftArrowWithWait: (double)waitTime
{
    leftArrow = [SKSpriteNode spriteNodeWithImageNamed:@"arrowL"];
    leftArrow.position = CGPointMake((self.size.width / 8)*0.5, self.size.height /2);
    leftArrow.name = @"leftArrow";
    leftArrow.alpha = 0;
    leftArrow.xScale = 0.7;
    leftArrow.yScale = 0.7;
    leftArrow.zPosition = 10;
    
    [self fadeInNode:leftArrow withWait:waitTime fadeAlphaTo:1.0 fadeAlphaWithDuration:0.5];
    
    return leftArrow;
}

-(SKSpriteNode *)levelThumbWithPositionModifier: (double) PosMod
{
    // Create Level %i Thumbnail
    levelThumb = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"Level-%li.png", [GameState sharedGameData].levelIndex]];
    levelThumb.position = CGPointMake(self.size.width * PosMod, self.size.height/2);
    levelThumb.name = [NSString stringWithFormat:@"_level%li", [GameState sharedGameData].levelIndex];
        
    // Add level name.
    SKLabelNode *levelName = [SKLabelNode labelNodeWithFontNamed:@"SF Movie Poster"];
    levelName.fontSize = 40;
    levelName.text = [levelTitles objectAtIndex:[GameState sharedGameData].levelIndex-1];
    levelName.position = CGPointMake(0, 125);
    [levelThumb addChild:levelName];
    
    //Add high score.
    SKLabelNode *highScore = [[SKLabelNode alloc] initWithFontNamed:@"SF Movie Poster"];
    highScore.position = CGPointMake(0, -150);
    highScore.fontColor = [SKColor whiteColor];
    highScore.fontSize = 35;
    highScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    highScore.zPosition = 101;
    highScore.text = [NSString stringWithFormat:@"High Score: %@", [[GameState sharedGameData] valueForKey:[NSString stringWithFormat:@"highScoreL%li",[GameState sharedGameData].levelIndex]]];
    [levelThumb addChild:highScore];
        
    return levelThumb;
    
    
}

#pragma mark --Settings

-(void)musicVolumeLabel {
    SKLabelNode *musicVolume = [SKLabelNode labelNodeWithFontNamed:@"SF Movie Poster"];
    musicVolume.fontColor = [SKColor whiteColor];
    musicVolume.fontSize = 50;
    musicVolume.position = CGPointMake(self.size.width * 1.5, (self.size.height / 6) * 5);
    musicVolume.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    musicVolume.text = @"Music Volume";
    
    [self addChild:musicVolume];
    [self animateLeft:musicVolume withDelay:1];
}

-(void)musicToggleButton {
    if ([[GameState sharedGameData] audioVolume] == 1.0) {
    musicToggle = [SKSpriteNode spriteNodeWithTexture: audioTexture];
    }
    if ([[GameState sharedGameData] audioVolume] == 0.0) {
        musicToggle = [SKSpriteNode spriteNodeWithTexture: audioTexture_off];
    }
    musicToggle.position = CGPointMake(self.size.width * 1.5, (self.size.height / 8) * 6);
    musicToggle.name = @"musicToggle";
    
    [self addChild:musicToggle];
    [self animateLeft:musicToggle withDelay:1];
}

-(void)vibrationLabel {
    SKLabelNode *vibrationLabel = [SKLabelNode labelNodeWithFontNamed:@"SF Movie Poster"];
    vibrationLabel.fontColor = [SKColor whiteColor];
    vibrationLabel.fontSize = 50;
    vibrationLabel.position = CGPointMake(self.size.width * 1.5, self.size.height * 0.5);
    vibrationLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    vibrationLabel.text = @"Vibration";
    
    [self addChild:vibrationLabel];
    [self animateLeft:vibrationLabel withDelay:1];
}

-(void)vibrationToggleButtonCreate {
    if ([GameState sharedGameData].vibeOn == YES) {
        vibrationToggleButton = [SKSpriteNode spriteNodeWithImageNamed:@"vibrateButton"];
    } else {
        vibrationToggleButton = [SKSpriteNode spriteNodeWithImageNamed:@"vibrateButton_off"];
    }
    vibrationToggleButton.position = CGPointMake(self.size.width * 1.5, self.size.height * 0.5 - self.size.height * 5/6 + self.size.height * 0.75);
    vibrationToggleButton.name = @"vibrationToggleButton";
    
    [self addChild:vibrationToggleButton];
    [self animateLeft:vibrationToggleButton withDelay:1];
}

-(void)resetGameData {
    GDReset = [SKLabelNode labelNodeWithFontNamed:@"SF Movie Poster"];
    GDReset.fontColor = [SKColor whiteColor];
    GDReset.fontSize = 50;
    GDReset.position = CGPointMake(self.size.width * 1.5, (self.size.height / 6) * 1);
    GDReset.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    GDReset.text = @"Reset Scores";
    GDReset.name = @"GameReset";
    
    SKLabelNode *resetDisclaimer = [SKLabelNode labelNodeWithFontNamed:@"SF Movie Poster"];
    resetDisclaimer.fontColor = [SKColor whiteColor];
    resetDisclaimer.text = @"WARNING:: This will reset all high scores";
    resetDisclaimer.fontSize = 25;
    resetDisclaimer.position = CGPointMake(0, -25);
    
    [self addChild:GDReset];
    [GDReset addChild:resetDisclaimer];
    [self animateLeft:GDReset withDelay:1];
}

-(void)resetSuccessPop {
    SKShapeNode *rect = [SKShapeNode node];
    rect.path = [UIBezierPath bezierPathWithRect:CGRectMake(-100, -50, 200, 100)].CGPath;
    rect.position = CGPointMake(self.size.width / 2, self.size.height / 8 * 7);
    rect.fillColor = [SKColor blackColor];
    rect.alpha = 0.6;
    rect.lineWidth = 0;
    
    SKLabelNode *success = [SKLabelNode labelNodeWithFontNamed:@"SF Movie Poster"];
    success.fontColor = [SKColor whiteColor];
    success.fontSize = 70;
    success.position = CGPointMake(self.size.width / 2, self.size.height / 8 * 7);
    success.text = @"Success!";
    
    [self addChild:rect];
    [self addChild:success];
    [self fadeOutNode:rect withWait:2 fadeAlphaTo:0 fadeAlphaWithDuration:.5];
    [self fadeOutNode:success withWait:2 fadeAlphaTo:0 fadeAlphaWithDuration:.5];
    
}

#pragma mark --Game Center

-(void)accessLeaderBoardAndAchievies: (BOOL)showLeaderboard {
//Need to make sure this is correctly accessing leaderboards.  Check if game center is available first.
    NSString *defaultLeaderBoardID = @"L1HS";
    GKGameCenterViewController *leaderboardViewController = [[GKGameCenterViewController alloc] init];
    
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (leaderboardViewController != nil) {
        leaderboardViewController.gameCenterDelegate = rootVC;
        if (showLeaderboard) {
            leaderboardViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
            leaderboardViewController.leaderboardIdentifier = defaultLeaderBoardID;
        } else {
            leaderboardViewController.viewState = GKGameCenterViewControllerStateAchievements;
        }
    }
    
    [rootVC presentViewController:leaderboardViewController animated:YES completion:nil];
}

-(void) gameCenterViewControllerDidFinish: (GKGameCenterViewController *)gameCenterViewController {
    [gameCenterViewController.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    [gameCenterViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)createRankInsignia {
    NSString *insigniaString = [[NSString alloc] init];
    if ([GameState sharedGameData].rankAchieved == 0) {
        return;}
    else {
        switch ([GameState sharedGameData].rankAchieved) {
            case 1: 
                insigniaString = @"FlightSchoolGraduate";
                break;
            case 2:
                insigniaString = @"Cadet";
                break;
            case 3:
                insigniaString = @"Private-1";
                break;
            case 4:
                insigniaString = @"Private-2";
                break;
            case 5:
                insigniaString = @"Sergeant-1";
                break;
            case 6:
                insigniaString = @"Sergeant-2";
                break;
            case 7:
                insigniaString = @"FlightCommander";
                break;
            case 8:
                insigniaString = @"LTCommander";
                break;
            case 9:
                insigniaString = @"Commander";
                break;
            case 10:
                insigniaString = @"FleetGeneral";
                break;
            case 11:
                insigniaString = @"FleetAdmiral";
                break;
            default:
                break;
        }
        
        insigniaNode = [SKSpriteNode spriteNodeWithImageNamed:insigniaString];
        insigniaNode.zPosition = 5;
        insigniaNode.position = CGPointMake(self.size.width + 142, self.size.height-30);
        
        SKAction *wait = [SKAction waitForDuration:.75];
        SKAction *move = [SKAction moveByX:-(rankScoreMoveDist) y:0 duration:0.5];
        move.timingMode = SKActionTimingEaseIn;
        SKAction *sequence = [SKAction sequence:@[wait, move]];
        [insigniaNode runAction: sequence];
        
        [self addChild:insigniaNode];
    }
}

-(void) updateRank {
            long tempScoreForRank = [GameState sharedGameData].totalPoints;
    
            if (tempScoreForRank < 500) {
                [GameState sharedGameData].rankAchieved = 0;
            } else if (tempScoreForRank>=500 && tempScoreForRank < 1000) {
                [GameState sharedGameData].rankAchieved = 1;
            } else if (tempScoreForRank>=1000 && tempScoreForRank < 2500) {
                [GameState sharedGameData].rankAchieved = 2;
            } else if (tempScoreForRank>=2500 && tempScoreForRank < 5000) {
                [GameState sharedGameData].rankAchieved = 3;
            } else if (tempScoreForRank>=5000 && tempScoreForRank < 7500) {
                [GameState sharedGameData].rankAchieved = 4;
            } else if (tempScoreForRank>=7500 && tempScoreForRank < 10000) {
                [GameState sharedGameData].rankAchieved = 5;
            } else if (tempScoreForRank>=10000 && tempScoreForRank < 25000) {
                [GameState sharedGameData].rankAchieved = 6;
            } else if (tempScoreForRank>=25000 && tempScoreForRank < 50000) {
                [GameState sharedGameData].rankAchieved = 7;
            } else if (tempScoreForRank>=50000 && tempScoreForRank < 75000) {
                [GameState sharedGameData].rankAchieved = 8;
            } else if (tempScoreForRank>=75000 && tempScoreForRank < 100000) {
                [GameState sharedGameData].rankAchieved = 9;
            } else if (tempScoreForRank>=100000 && tempScoreForRank < 250000) {
                [GameState sharedGameData].rankAchieved = 10;
            } else if (tempScoreForRank>=250000) {
                [GameState sharedGameData].rankAchieved = 11;
            }
            [[GameState sharedGameData] save];
            [self addChild: [self highScoreLabel]];
}

#pragma mark --Actions

-(void)mainMenuAnimateOut {
    // Button Node Removal.
    SKAction *startButtonRemoved = [SKAction moveTo:CGPointMake(self.size.width/2-300, BUTTON_HEIGHT)  duration:0.75];
    SKAction *leaderButtonRemoved = [SKAction moveTo:CGPointMake(self.size.width/2-300, BUTTON_HEIGHT - BUTTON_OFFSET)  duration:0.75];
    SKAction *codexButtonRemoved = [SKAction moveTo:CGPointMake(self.size.width/2-300, BUTTON_HEIGHT - (BUTTON_OFFSET * 2)) duration:0.75];
    SKAction *creditButtonRemoved = [SKAction moveTo:CGPointMake(self.size.width/2-300, BUTTON_HEIGHT - (BUTTON_OFFSET * 3)) duration:0.75];
    SKAction *settingsButtonRemoved = [SKAction moveTo:CGPointMake(-settingsButton.size.width, self.size.height)  duration:0.5];
    SKAction *highScoreRemoved = [SKAction moveBy:CGVectorMake(self.size.width/2, 0) duration:0.5];
    
    // Title Image Removal.
    SKAction *titleRemoval = [SKAction moveTo:CGPointMake(self.size.width/2, 700) duration:0.75];
    
    // Group & Sequence Removal.
    SKAction *unload = [SKAction removeFromParent];
    
    // Delays.
    SKAction *titleWait = [SKAction waitForDuration:0.5];
    SKAction *startWait = [SKAction waitForDuration:0.75];
    SKAction *leaderWait = [SKAction waitForDuration:0.5];
    SKAction *codexWait = [SKAction waitForDuration:0.25];
    
    // Button Texture Change.
    startButton.texture = [SKTexture textureWithImageNamed:@"buttonStart.png"];
    
    // Action Sequences.
    SKAction *startSequence = [SKAction sequence:@[startWait,startButtonRemoved,unload]];
    SKAction *leaderSequence = [SKAction sequence:@[leaderWait,leaderButtonRemoved,unload]];
    SKAction *settingsSequence = [SKAction sequence:@[settingsButtonRemoved,unload]];
    SKAction *codexSequence = [SKAction sequence:@[codexWait,codexButtonRemoved,unload]];
    SKAction *creditSequence = [SKAction sequence:@[creditButtonRemoved,unload]];
    SKAction *titleSequence = [SKAction sequence:@[titleWait,titleRemoval,unload]];
    SKAction *insigniaSequence = [SKAction sequence:@[highScoreRemoved,unload]];
    SKAction *highScoreSequence = [SKAction sequence:@[highScoreRemoved, unload]];
    
    [startButton runAction: startSequence];
    [leaderButton runAction: leaderSequence];
    [codexButton runAction: codexSequence];
    [creditButton runAction: creditSequence];
    [settingsButton runAction: settingsSequence];
    [titleImage runAction: titleSequence];
    [insigniaNode runAction:insigniaSequence];
    [highScore runAction:highScoreSequence];
}

-(void)animateLeft: (SKNode *)levelNode withDelay: (double)delayTime
{
    SKAction *delay = [SKAction waitForDuration:delayTime];
    SKAction *leftMove = [SKAction moveBy:CGVectorMake(-self.size.width, 0) duration:0.75];
    leftMove.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *moveSequence = [SKAction sequence:@[delay, leftMove]];
    [levelNode runAction: moveSequence];
}

-(void)animateRight: (SKNode *)levelNode withDelay: (double)delayTime
{
    SKAction *delay = [SKAction waitForDuration:delayTime];
    SKAction *rightMove = [SKAction moveBy:CGVectorMake(self.size.width, 0) duration:0.75];
    rightMove.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *moveSequence = [SKAction sequence:@[delay, rightMove]];
    [levelNode runAction: moveSequence];
}

-(void)fadeOutNode: (SKNode *)fadingNode withWait: (double)waitTime fadeAlphaTo: (double)alpha fadeAlphaWithDuration: (double)fadeDuration
{
    SKAction *fadeDelay = [SKAction waitForDuration:waitTime];
    SKAction *fade = [SKAction fadeAlphaTo:alpha duration: fadeDuration];
    SKAction *unload = [SKAction removeFromParent];
    SKAction *fadeSequence = [SKAction sequence:@[fadeDelay, fade, unload]];
    
    [fadingNode runAction: fadeSequence];
}

-(void)fadeInNode: (SKNode *)fadingNode withWait: (double)waitTime fadeAlphaTo: (double)alpha fadeAlphaWithDuration: (double)fadeDuration
{
    SKAction *fadeDelay = [SKAction waitForDuration:waitTime];
    SKAction *fade = [SKAction fadeAlphaTo:alpha duration: fadeDuration];
    SKAction *fadeSequence = [SKAction sequence:@[fadeDelay, fade]];
    
    [fadingNode runAction: fadeSequence];
}

#pragma mark --Touch Events
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //Called when a touch begins
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"_startButton"]) {
        startButton.texture = [SKTexture textureWithImageNamed:@"buttonPressStart.png"];
    }
    
    if ([node.name isEqualToString:@"_leaderButton"]) {
        leaderButton.texture = [SKTexture textureWithImageNamed:@"buttonPressLeaderboard.png"];
    }

    if ([node.name isEqualToString:@"codexButton"]) {
        codexButton.texture = [SKTexture textureWithImageNamed:@"buttonPressCodex.png"];
    }
    
    if ([node.name isEqualToString:@"creditsButton"]) {
        creditButton.texture = [SKTexture textureWithImageNamed:@"buttonPressCredits.png"];
    }
    
    if ([node.name isEqualToString:@"musicToggle"]) {
        musicToggle.texture = audioTexture_highlight;
    }
    
    if ([node.name isEqualToString:@"vibrationToggleButton"]) {
        vibrationToggleButton.texture = [SKTexture textureWithImageNamed:@"vibrateButton_press"];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //Called when a touch ends
    UITouch *touchLift = [touches anyObject];
    CGPoint locationLift = [touchLift locationInNode:self];
    SKNode *nodeLift = [self nodeAtPoint:locationLift];
    
    //Global Transition Properties
    SKColor *fadeColor = [SKColor colorWithRed:0 green:0 blue:0 alpha:1];
    static double levelFadeDuration = 0.5;
    
    //Start Button
    if ([nodeLift.name isEqualToString:@"_startButton"]) {
        
        //Pass Achievements into temp storage area.
        //[[GameKitHelper sharedGameKitHelper] storeDictionaryToAchievementsDictionary:_achievementsDictionary];
        
        SKAction *createSound = [SKAction playSoundFileNamed:@"Button-Press.caf" waitForCompletion:NO];
        SKAction *playSound = [SKAction runBlock:^{
            [self playSoundEffectsWithAction:createSound];
        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAd" object:nil];
        SKAction *menuAnimate = [SKAction runBlock:^{
            [self mainMenuAnimateOut];
        }];
        SKAction *wait = [SKAction waitForDuration:1.25];
        SKAction *Scene = [SKAction runBlock:^{
            if ([GameState sharedGameData].highScoreL1 == 0) {
                //Start Tutorial
                SKView * tutView = (SKView *)self.view;
                tutView.showsFPS = YES;
                tutView.showsNodeCount = YES;
                
                // Create and configure the scene.
                SKScene * tutScene = [[Tutorial alloc] initWithSize:tutView.bounds.size];
                tutScene.scaleMode = SKSceneScaleModeAspectFill;
                SKTransition *tutTrans = [SKTransition fadeWithColor:fadeColor duration:levelFadeDuration];
                
                // Present the scene.
                [tutView presentScene:tutScene transition:tutTrans];
            } else {
                //Load Level 1
                SKView * levelOneView = (SKView *)self.view;
                levelOneView.showsFPS = YES;
                levelOneView.showsNodeCount = YES;
                //levelOneView.showsPhysics = YES;
                
                // Create and configure the scene.
                SKScene * levelOneScene = [[LevelOne alloc] initWithSize:levelOneView.bounds.size];
                levelOneScene.scaleMode = SKSceneScaleModeAspectFill;
                SKTransition *levelOneTrans = [SKTransition fadeWithColor:fadeColor duration:levelFadeDuration];
                
                // Present the scene.
                [levelOneView presentScene:levelOneScene transition:levelOneTrans];
                
                // Load level select area
                /*[GameState sharedGameData].levelIndex = 1;
                 [self addChild:[self levelThumbWithPositionModifier:1.5]];
                 [self animateLeft:levelThumb withDelay:0.5];
                 [self addChild:[self createRightArrowWithWait:0.5]];
                 [self addChild:[self backToMainButton]];*/ }
            }];
        [self runAction:[SKAction sequence:@[playSound,menuAnimate,wait,Scene]]];
    }
    
    //Leaderboard Button
    if ([nodeLift.name isEqualToString:@"_leaderButton"]) {
        //SKTransition
        SKAction *createSound = [SKAction playSoundFileNamed:@"Button-Press.caf" waitForCompletion:NO];
        [self playSoundEffectsWithAction:createSound];
        //Activate leaderboard.
        [self accessLeaderBoardAndAchievies:YES];
    }
    
    if ([nodeLift.name isEqualToString:@"codexButton"]) {
        SKAction *createSound = [SKAction playSoundFileNamed:@"Button-Press.caf" waitForCompletion:NO];
        SKAction *playSound = [SKAction runBlock:^{
            [self playSoundEffectsWithAction:createSound];
        }];
        SKAction *menuAnimate = [SKAction runBlock:^{
            [self mainMenuAnimateOut];
        }];
        SKAction *wait = [SKAction waitForDuration:1.25];
        SKAction *Scene = [SKAction runBlock:^{
            SKView * codexView = (SKView *)self.view;
            codexView.showsFPS = YES;
            codexView.showsNodeCount = YES;
            //levelOneView.showsPhysics = YES;
            
            // Create and configure the scene.
            SKScene * codexScene = [[NWCodex alloc] initWithSize:codexView.bounds.size];
            codexScene.scaleMode = SKSceneScaleModeAspectFill;
            SKTransition *tutTrans = [SKTransition fadeWithColor:fadeColor duration:levelFadeDuration];
            
            // Present the scene.
            [codexView presentScene:codexScene transition:tutTrans];
        }];
        [self runAction:[SKAction sequence:@[playSound,menuAnimate,wait,Scene]]];
    }
    
#pragma mark -- Settings Action Buttons
    if ([nodeLift.name isEqualToString:@"_settingsButton"]) {
        //SKTransition
        SKAction *sound = [SKAction playSoundFileNamed:@"Button-Press.caf" waitForCompletion:NO];
        [self playSoundEffectsWithAction:sound];
        [self mainMenuAnimateOut];
        [self musicVolumeLabel];
        [self musicToggleButton];
        [self vibrationLabel];
        [self vibrationToggleButtonCreate];
        [self resetGameData];
        [self addChild:[self backToMainButton]];
    }
    
    if ([nodeLift.name isEqualToString:@"GameReset"]) {
        [[GameState sharedGameData] resetAll];
        [[GameState sharedGameData] save];
        [self resetSuccessPop];
    }
    
    if ([nodeLift.name isEqualToString:@"backToMain"]) {
        SKAction *createSound = [SKAction playSoundFileNamed:@"Button-Press.caf" waitForCompletion:NO];
        SKAction *playSound = [SKAction runBlock:^{
            [self playSoundEffectsWithAction:createSound];
        }];
        SKAction *scene = [SKAction runBlock:^{
            SKView *mainMenuView = (SKView *)self.view;
            SKScene *mainMenuScene = [[MainMenu alloc] initWithSize:mainMenuView.bounds.size];
            SKTransition *menuTransition = [SKTransition fadeWithDuration:.5];
            [mainMenuView presentScene:mainMenuScene transition:menuTransition];
        }];
        [self runAction:[SKAction sequence:@[playSound,scene]]];
    };
    
    if ([nodeLift.name isEqualToString:@"musicToggle"]) {
        [self toggleAudio];
    }
    
    if ([nodeLift.name isEqualToString:@"vibrationToggleButton"]) {
        [self toggleVibration];
    }
    
    if (![nodeLift.name isEqualToString:@"_startButton"]) {
        startButton.texture = [SKTexture textureWithImageNamed:@"buttonStart.png"];
        leaderButton.texture = [SKTexture textureWithImageNamed:@"buttonLeaderboard.png"];
        codexButton.texture = [SKTexture textureWithImageNamed:@"buttonCodex.png"];
        creditButton.texture = [SKTexture textureWithImageNamed:@"buttonCredits.png"];
    }
    
    if (![nodeLift.name isEqualToString:@"vibrationToggleButton"]) {
        if ([GameState sharedGameData].vibeOn == YES) {
            vibrationToggleButton.texture = [SKTexture textureWithImageNamed:@"vibrateButton"];
        } else {
            vibrationToggleButton.texture = [SKTexture textureWithImageNamed:@"vibrateButton_off"];
        }
    }
    
    if (![nodeLift.name isEqualToString:@"musicToggle"]) {
        if ([GameState sharedGameData].audioVolume == 1.0) {
            musicToggle.texture = audioTexture;
        } else {
            musicToggle.texture = audioTexture_off;
        }
    }
    
#pragma mark --Level Button Actions
    if ([nodeLift.name isEqualToString:@"rightArrow"]) {
        
        //Modular level select implementation.
        switch ([GameState sharedGameData].levelIndex) {
            case 1:
                [self animateLeft:[self childNodeWithName:[NSString stringWithFormat:@"_level%li",[GameState sharedGameData].levelIndex]] withDelay:0.0];
                [GameState sharedGameData].levelIndex = [GameState sharedGameData].levelIndex + 1;
                [self addChild:[self levelThumbWithPositionModifier:1.5]];
                [self animateLeft:[self childNodeWithName:[NSString stringWithFormat:@"_level%li",[GameState sharedGameData].levelIndex]] withDelay:0.0];
                
                break;
            case 2:
                break;
                
            default:
                break;
        }
    }
    
    if ([nodeLift.name isEqualToString:@"leftArrow"]) {

        [self animateRight:[self childNodeWithName:[NSString stringWithFormat:@"_level%li",[GameState sharedGameData].levelIndex]] withDelay:0.0];
        [GameState sharedGameData].levelIndex = [GameState sharedGameData].levelIndex - 1;
        [self addChild:[self levelThumbWithPositionModifier: -0.5]];
        [self animateRight:[self childNodeWithName: [NSString stringWithFormat: @"_level%li",[GameState sharedGameData].levelIndex]] withDelay:0.0];

    }

#pragma mark --Level 1
    if ([nodeLift.name isEqualToString:@"_level1"]) {
        // Transition to Level One Scene
        // Configure the developer view.
        SKView * levelOneView = (SKView *)self.view;
        levelOneView.showsFPS = YES;
        levelOneView.showsNodeCount = YES;
        levelOneView.showsPhysics = YES;
        
        // Create and configure the scene.
        SKScene * levelOneScene = [[LevelOne alloc] initWithSize:levelOneView.bounds.size];
        levelOneScene.scaleMode = SKSceneScaleModeAspectFill;
        SKTransition *levelOneTrans = [SKTransition fadeWithColor:fadeColor duration:levelFadeDuration];
        
        // Present the scene.
        [levelOneView presentScene:levelOneScene transition:levelOneTrans];
    }
    
#pragma mark --Level 2
    if ([nodeLift.name isEqualToString:@"_level2"]) {
        // Transition to Level One Scene
        // Configure the developer view.
        SKView * levelTwoView = (SKView *)self.view;
        levelTwoView.showsFPS = YES;
        levelTwoView.showsNodeCount = YES;
        //levelTwoView.showsPhysics = YES;
        
        // Create and configure the scene.
        /*SKScene * levelTwoScene = [[LevelTwo alloc] initWithSize:levelTwoView.bounds.size andDirection:self.direction];
        levelTwoScene.scaleMode = SKSceneScaleModeAspectFill;
        SKTransition *levelTwoTrans = [SKTransition fadeWithColor:fadeColor duration:levelFadeDuration];*/
        
        // Present the scene.
        //[levelTwoView presentScene:levelTwoScene transition:levelTwoTrans];
    }
}

#pragma mark --Update

-(void)update:(CFTimeInterval)currentTime {
    if (_lastUpdateTime)
    {
        _dt = currentTime - _lastUpdateTime;
    }
    else
    {
        _dt = 0;
    }
    _lastUpdateTime = currentTime;
    

    // Fades right arrow when needed
    if ([GameState sharedGameData].levelIndex == [GameState sharedGameData].lvlIndexMax) {
        [self fadeOutNode:rightArrow withWait:0.6 fadeAlphaTo:0.0 fadeAlphaWithDuration:0.3];
    }
    
    if ([GameState sharedGameData].levelIndex == 1 && [self.children containsObject:leftArrow]) {
        [self fadeOutNode:leftArrow withWait:0.5 fadeAlphaTo:0.0 fadeAlphaWithDuration:0.5];
    }
    
    if ([GameState sharedGameData].levelIndex > 1 && ![self.children containsObject:leftArrow]) {
        [self addChild:[self createLeftArrowWithWait:0.3]];
    }
    
    if (![self.children containsObject:rightArrow] && [GameState sharedGameData].levelIndex < [GameState sharedGameData].lvlIndexMax && [GameState sharedGameData].levelIndex > 0) {
        [self addChild:[self createRightArrowWithWait:0.5]];
    }
    [self moveBG];
}


@end