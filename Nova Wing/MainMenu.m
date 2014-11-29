//
//  MyScene.m
//  Nova Wing
//
//  Created by Bryan Todd on 8/11/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import "MainMenu.h"
#import "LevelOne.h"
#import "LevelTwo.h"

static const float BG_VELOCITY = 10.0;

static inline CGPoint CGPointAdd(const CGPoint a, const CGPoint b)
{
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint CGPointMultiplyScalar(const CGPoint a, const CGFloat b)
{
    return CGPointMake(a.x * b, a.y * b);
}


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
        
        [self addChild: [self addTitleNode]];
        [self addChild: [self startButtonNode]];
        [self addChild: [self leaderButtonNode]];
        [self addChild: [self settingsButtonNode]];
        [self addChild: [self highScoreLabel]];
        [self createAudio];
        levelTitles = @[@"Event Horizon", @"The Whispers", @"TempLevel3"];
    }
    return self;
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
-(SKSpriteNode *)startButtonNode
{
    startButton = [SKSpriteNode spriteNodeWithTexture: [SKTexture textureWithImageNamed:@"buttonStart.png"]];
    startButton.position = CGPointMake(self.size.width/2-300, 250);
    startButton.xScale = 0.5;
    startButton.yScale = 0.5;
    startButton.name = @"_startButton";
    SKAction *buttonWait = [SKAction waitForDuration:1.0];
    SKAction *buttonShift = [SKAction moveTo:CGPointMake(self.size.width/2, 250) duration:0.75];
    buttonShift.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *buttonSequence = [SKAction sequence:@[buttonWait,buttonShift]];
    [startButton runAction: buttonSequence];
    return startButton;
}

-(SKSpriteNode *)leaderButtonNode
{
    leaderButton = [SKSpriteNode spriteNodeWithImageNamed:@"buttonLeaderboard.png"];
    leaderButton.position = CGPointMake(self.size.width/2-300, 190);
    leaderButton.xScale = 0.5;
    leaderButton.yScale = 0.5;
    leaderButton.name = @"_leaderButton";
    SKAction *buttonWait = [SKAction waitForDuration:1.25];
    SKAction *buttonShift = [SKAction moveTo:CGPointMake(self.size.width/2, 190) duration:0.75];
    buttonShift.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *buttonSequence = [SKAction sequence:@[buttonWait,buttonShift]];
    [leaderButton runAction: buttonSequence];
    return leaderButton;
}

-(SKSpriteNode *)settingsButtonNode
{
    settingsButton = [SKSpriteNode spriteNodeWithImageNamed:@"buttonSettings.png"];
    settingsButton.position = CGPointMake(self.size.width/2-300, 130);
    settingsButton.xScale = 0.5;
    settingsButton.yScale = 0.5;
    settingsButton.name = @"_settingsButton";
    SKAction *buttonWait = [SKAction waitForDuration:1.5];
    SKAction *buttonShift = [SKAction moveTo:CGPointMake(self.size.width/2, 130) duration:0.75];
    buttonShift.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *buttonSequence = [SKAction sequence:@[buttonWait,buttonShift]];
    [settingsButton runAction: buttonSequence];
    return settingsButton;
}

-(SKLabelNode *)highScoreLabel {
    SKLabelNode *highScore = [[SKLabelNode alloc] initWithFontNamed:@"SF Movie Poster"];
    highScore.position = CGPointMake(self.size.width, self.size.height - 30);
    highScore.fontColor = [SKColor whiteColor];
    highScore.fontSize = 30;
    highScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    highScore.zPosition = 101;
    highScore.text = [NSString stringWithFormat:@"HIGH SCORE: %li  ", [GameState sharedGameData].highScoreL1];
    
    SKAction *wait = [SKAction waitForDuration:.75];
    SKAction *move = [SKAction moveByX:-(highScore.frame.size.width + 10) y:0 duration:0.5];
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

-(void)toggleAudio {
    if ([GameState sharedGameData].audioVolume == 1.0) {
        musicToggle.texture = [SKTexture textureWithImageNamed:@"Audio_off"];
        [GameState sharedGameData].audioVolume = 0.0;
        [[NWAudioPlayer sharedAudioPlayer] bgPlayer].volume = [GameState sharedGameData].audioVolume;
        [[GameState sharedGameData] save];
    } else if ([GameState sharedGameData].audioVolume == 0.0) {
        musicToggle.texture = [SKTexture textureWithImageNamed:@"Audio"];
        [GameState sharedGameData].audioVolume = 1.0;
        [[NWAudioPlayer sharedAudioPlayer] bgPlayer].volume = [GameState sharedGameData].audioVolume;
        [[GameState sharedGameData] save];
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
    musicVolume.position = CGPointMake(self.size.width * 1.5, (self.size.height / 8) * 6);
    musicVolume.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    musicVolume.text = @"Music Volume";
    
    [self addChild:musicVolume];
    [self animateLeft:musicVolume withDelay:1];
}

-(void)musicToggleButton {
    if ([[GameState sharedGameData] audioVolume] == 1.0) {
    musicToggle = [SKSpriteNode spriteNodeWithTexture: [SKTexture textureWithImageNamed:@"Audio"]];
    }
    if ([[GameState sharedGameData] audioVolume] == 0.0) {
        musicToggle = [SKSpriteNode spriteNodeWithTexture: [SKTexture textureWithImageNamed:@"Audio_off"]];
    }
    musicToggle.position = CGPointMake(self.size.width * 1.5, (self.size.height / 8) * 5);
    musicToggle.xScale = 0.3;
    musicToggle.yScale = 0.3;
    musicToggle.name = @"musicToggle";
    
    [self addChild:musicToggle];
    [self animateLeft:musicToggle withDelay:1];
}

-(void)resetGameData {
    GDReset = [SKLabelNode labelNodeWithFontNamed:@"SF Movie Poster"];
    GDReset.fontColor = [SKColor whiteColor];
    GDReset.fontSize = 50;
    GDReset.position = CGPointMake(self.size.width * 1.5, (self.size.height / 8) * 2);
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

#pragma mark --Actions

-(void)mainMenuAnimateOut {
    // Button Node Removal.
    SKAction *startButtonRemoved = [SKAction moveTo:CGPointMake(self.size.width/2-300, 250)  duration:0.75];
    SKAction *leaderButtonRemoved = [SKAction moveTo:CGPointMake(self.size.width/2-300, 190)  duration:0.75];
    SKAction *settingsButtonRemoved = [SKAction moveTo:CGPointMake(self.size.width/2-300, 130)  duration:0.75];
    
    // Title Image Removal.
    SKAction *titleRemoval = [SKAction moveTo:CGPointMake(self.size.width/2, 700) duration:0.75];
    
    // Group & Sequence Removal.
    SKAction *unload = [SKAction removeFromParent];
    
    // Delays.
    SKAction *titleWait = [SKAction waitForDuration:0.5];
    SKAction *startWait = [SKAction waitForDuration:0.5];
    SKAction *leaderWait = [SKAction waitForDuration:0.25];
    
    // Button Texture Change.
    startButton.texture = [SKTexture textureWithImageNamed:@"buttonStart.png"];
    
    // Action Sequences.
    SKAction *startSequence = [SKAction sequence:@[startWait,startButtonRemoved,unload]];
    SKAction *leaderSequence = [SKAction sequence:@[leaderWait,leaderButtonRemoved,unload]];
    SKAction *settingsSequence = [SKAction sequence:@[settingsButtonRemoved,unload]];
    SKAction *titleSequence = [SKAction sequence:@[titleWait,titleRemoval,unload]];
    
    [startButton runAction: startSequence];
    [leaderButton runAction: leaderSequence];
    [settingsButton runAction: settingsSequence];
    [titleImage runAction: titleSequence];
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

    if ([node.name isEqualToString:@"_settingsButton"]) {
        settingsButton.texture = [SKTexture textureWithImageNamed:@"buttonPressSettings.png"];
    }
    
    if ([node.name isEqualToString:@"musicToggle"]) {
        musicToggle.texture = [SKTexture textureWithImageNamed:@"Audio_press"];
    }
    
    if ([node.name isEqualToString:@"sfxToggle"]) {
        sfxToggle.texture = [SKTexture textureWithImageNamed:@"Audio_press"];
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
        
        [self mainMenuAnimateOut];
        
        // Transition to Level One Scene
        // Configure the developer view.
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
        [self addChild:[self backToMainButton]];*/
        
    }
    if (![nodeLift.name isEqualToString:@"_startButton"] && ![nodeLift.name isEqualToString:@"_leaderButton"] && ![nodeLift.name isEqualToString:@"_settingsButton"]) {
        startButton.texture = [SKTexture textureWithImageNamed:@"buttonStart.png"];
        leaderButton.texture = [SKTexture textureWithImageNamed:@"buttonLeaderboard.png"];
        settingsButton.texture = [SKTexture textureWithImageNamed:@"buttonSettings.png"];
    }
    
    //Leaderboard Button
    if ([nodeLift.name isEqualToString:@"_leaderButton"]) {
        //SKTransition
    }
    
#pragma mark -- Settings Action Buttons
    if ([nodeLift.name isEqualToString:@"_settingsButton"]) {
        //SKTransition
        [self mainMenuAnimateOut];
        [self musicVolumeLabel];
        [self musicToggleButton];
        [self resetGameData];
        [self addChild:[self backToMainButton]];
    }
    
    if ([nodeLift.name isEqualToString:@"GameReset"]) {
        [[GameState sharedGameData] resetAll];
        [[GameState sharedGameData] save];
        [self resetSuccessPop];
    }
    
    if ([nodeLift.name isEqualToString:@"backToMain"]) {        
        SKView *mainMenuView = (SKView *)self.view;
        SKScene *mainMenuScene = [[MainMenu alloc] initWithSize:mainMenuView.bounds.size];
        SKTransition *menuTransition = [SKTransition fadeWithDuration:.5];
        [mainMenuView presentScene:mainMenuScene transition:menuTransition];
    };
    
    if ([nodeLift.name isEqualToString:@"musicToggle"]) {
        [self toggleAudio];
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
        SKScene * levelTwoScene = [[LevelTwo alloc] initWithSize:levelTwoView.bounds.size andDirection:self.direction];
        levelTwoScene.scaleMode = SKSceneScaleModeAspectFill;
        SKTransition *levelTwoTrans = [SKTransition fadeWithColor:fadeColor duration:levelFadeDuration];
        
        // Present the scene.
        [levelTwoView presentScene:levelTwoScene transition:levelTwoTrans];
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