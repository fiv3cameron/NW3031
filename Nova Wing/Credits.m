//
//  Credits.m
//  Nova Wing
//
//  Created by Bryan Todd on 6/16/15.
//  Copyright (c) 2015 FIV3 Interactive, LLC. All rights reserved.
//

#import "Credits.h"
#import <AudioToolbox/AudioToolbox.h>
#import "MainMenu.h"

@interface Credits() <SKPhysicsContactDelegate>
{
    Ships *playerNode;
    Ships *playerParent;
    SKSpriteNode *shield;
    BOOL isSceneLoading;
    SKLabelNode *loading;
    
    //Game Over ivars
    SKLabelNode *backToMain;
    SKSpriteNode *playAgain;
    SKSpriteNode *trophyButton;
    
    //Strings for Action Keys (To ensure safety)
    NSString *objectCreateKey;

}
//Preloading Sound Actions -> Properties Here
@property (strong, nonatomic) SKAction* Explosion;
@property (strong, nonatomic) SKAction* ScoreCollect;
@property (strong, nonatomic) SKAction* ShieldPowerUp;
@property (strong, nonatomic) SKAction* ShipExplode;

@end

@implementation Credits

NSTimeInterval _lastUpdateTime;
NSTimeInterval _dt;
SKLabelNode* _score;

#define AUTOCANNON_INTERVAL 0.3
#define AUTOCANNON_SHOTS_FIRED 25

#pragma mark --CreateBackground

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor colorWithRed:0 green:0 blue:0 alpha:1];
        
        loading = [SKLabelNode labelNodeWithFontNamed:@"SF Movie Poster"];
        loading.position = CGPointMake(self.size.width / 2, self.size.height / 2);
        loading.fontColor = [SKColor whiteColor];
        loading.fontSize = 40;
        loading.name = @"loading";
        loading.text = @"LOADING...";
        [self addChild:loading];
        
        isSceneLoading = YES;
        
        objectCreateKey = @"objectCreateKey";
        
        //Preload Sound Actions
        [self preloadSoundActions];
        
        //Set up Arrays
        reportArray = [NSMutableArray array];
    }
    return self;
}

-(void)didMoveToView:(SKView *)view {
    //[SKTextureAtlas preloadTextureAtlases:textureAtlases withCompletionHandler:^{
        [self setUpScene];
        isSceneLoading = NO;
    //}];
}

-(void)setUpScene {
    self.backgroundColor = [SKColor colorWithRed:0 green:0 blue:0 alpha:1];
    [loading removeFromParent];
    
    self.physicsWorld.gravity = CGVectorMake(0.0f, -8.0f);
    self.physicsWorld.contactDelegate = self;
    self.scaleMode = SKSceneScaleModeAspectFit;
    
    NSString *starsPath = [[NSBundle mainBundle] pathForResource:@"Stars-L1" ofType:@"sks"];
    SKEmitterNode *stars = [NSKeyedUnarchiver unarchiveObjectWithFile:starsPath];
    stars.position = CGPointMake(self.size.width, self.size.height / 2);
    
    //Pre emits particles so layer is populated when scene begins
    [stars advanceSimulationTime:1.5];
    
    //Create playerParent & wingmanParent.
    playerParent = [self createPlayerParent];
    [self createPlayerNode: playerNode];
    
    //Create scoring node.
    SKSpriteNode *scoreColumn = [SKSpriteNode node];
    scoreColumn.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, 10, self.size.height)];
    scoreColumn.physicsBody.categoryBitMask = CollisionCategoryScore;
    scoreColumn.physicsBody.contactTestBitMask = CollisionCategoryObject;
    scoreColumn.physicsBody.collisionBitMask = 0;
    scoreColumn.physicsBody.usesPreciseCollisionDetection = YES;
    scoreColumn.physicsBody.dynamic = NO;
    scoreColumn.position = CGPointMake(0, 0);
    [self addChild:scoreColumn];
    
    [self createAudio];
    
    [self addChild:stars];
    [self createBlackHole];
    [self bottomCollide];
    [self addChild:playerParent];
    [playerParent addChild:playerNode];
    
    //Physics Joint
    SKPhysicsJointFixed *test = [SKPhysicsJointFixed jointWithBodyA:playerParent.physicsBody bodyB:playerNode.physicsBody anchor:CGPointMake(playerParent.position.x+50, playerParent.position.y+50)];
    [self.physicsWorld addJoint:test];
    
    //shipBobbing is factory method within playerNode.
    [playerParent shipBobbing:playerParent];
    
    [self createScoreTextBox];
    
    [self tapToPlay];
    _score.text = @"Score: 0";
    
    [self addAltimeter];
}

-(void)preloadSoundActions {
    _Explosion = [SKAction playSoundFileNamed:@"Explosion.caf" waitForCompletion:NO];
    _ScoreCollect = [SKAction playSoundFileNamed:@"Score-Collect.caf" waitForCompletion:NO];
    _ShipExplode = [SKAction playSoundFileNamed:@"Ship-Explode.caf" waitForCompletion:NO];
}

-(Ships *)createPlayerParent {
    playerParent = [Ships node];
    playerParent.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:50];
    playerParent.position = CGPointMake(self.frame.size.width/5, self.frame.size.height/2);
    playerParent.physicsBody.dynamic = NO;
    playerParent.physicsBody.allowsRotation = YES;
    playerParent.physicsBody.categoryBitMask = 0;
    playerParent.physicsBody.contactTestBitMask = 0;
    playerParent.physicsBody.collisionBitMask = 0;
    
    return playerParent;
}

-(void)createBlackHole {
    blackHole = [SKSpriteNode spriteNodeWithImageNamed:@"Black-Hole-1"];
    blackHole.position = CGPointMake(self.size.width/2, -100);
    
    [self addChild:blackHole];
}

#pragma mark --Create Elements

-(Ships *) createPlayerNode: (Ships *)tempPlayer
{
    playerNode = [[Ships alloc] initWithImageNamed:@"Nova-L1"];
    playerNode.position = CGPointMake(0, 0);
    playerNode.physicsBody.categoryBitMask = CollisionCategoryPlayer;
    playerNode.physicsBody.collisionBitMask = 0;
    playerNode.physicsBody.contactTestBitMask = CollisionCategoryBottom | CollisionCategoryObject | CollisionCategoryMulti | CollisionCategoryPup;
    
    return tempPlayer;
}

-(void)createObstacles {
    
    int tempObjectSelector = arc4random()%11;
    switch (tempObjectSelector)
    {
        case 1:
        case 2:
            break;
        case 3:
        case 4:
            //[self asteroid1];
            break;
        case 5:
            //[self shipChunk];
            break;
        case 6:
            break;
        case 7:
            //[self asteroid2];
            break;
        case 8:
            break;
        case 9:
            //[self asteroid3];
            break;
        case 10:
            //[self asteroid4];
            break;
        default:
            break;
    }
}

-(void)bottomCollide {
    bottom = [SKSpriteNode node];
    bottom.position = CGPointMake(0, -12);
    bottom.size = CGSizeMake(self.size.width, 1);
    bottom.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, self.size.width, 10)];
    bottom.physicsBody.dynamic = NO;
    bottom.physicsBody.categoryBitMask = CollisionCategoryBottom;
    bottom.physicsBody.collisionBitMask = 0;
    
    [self addChild:bottom];
}

-(void)tapToPlay {
    tapPlay = [SKLabelNode labelNodeWithFontNamed:@"SF Movie Poster"];
    tapPlay.fontSize = 35;
    tapPlay.fontColor = [SKColor whiteColor];
    tapPlay.position = CGPointMake(self.size.width/2, self.size.height / 5);
    tapPlay.text = @"Tap the screen to play!";
    
    [self addChild:tapPlay];
}

-(void)addAltimeter {
    //Create main parent altimeter node.
    masterAltimeter = [SKSpriteNode node];
    masterAltimeter.anchorPoint = CGPointZero;
    masterAltimeter.position = CGPointMake(0, self.size.height*3/8);
    masterAltimeter.zPosition = 15;
    CGSize tempMasterSize = CGSizeMake(self.size.width/20, self.size.height/4);
    masterAltimeter.size = tempMasterSize;
    [self addChild:masterAltimeter];
    
    //Create tick marks.
    CGSize tempMajorSize = CGSizeMake(6, 2);
    SKSpriteNode *majorTick = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithWhite:1 alpha:1] size:tempMajorSize];
    majorTick.anchorPoint = CGPointMake(0, 0.5);
    majorTick.zPosition = 0;
    
    CGSize tempMinorSize = CGSizeMake(2, 1);
    SKSpriteNode *minorTick = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithWhite:1 alpha:1] size:tempMinorSize];
    minorTick.anchorPoint = CGPointMake(0, 0.5);
    majorTick.zPosition = 0;
    
    for (int tempTickCount=0; tempTickCount<=20; tempTickCount++) {
        if (tempTickCount == 4 || tempTickCount == 5 || tempTickCount == 6) {
            minorTick.color = [NWColor NWYellow];
        } else if (tempTickCount == 1 || tempTickCount == 2 || tempTickCount == 3) {
            minorTick.color = [NWColor NWRed];
        } else {
            minorTick.color = [UIColor colorWithWhite:1 alpha:1];
        }
        
        if (tempTickCount == 0 || tempTickCount == 10 || tempTickCount == 20) {
            majorTick.position = CGPointMake(0, masterAltimeter.size.height*tempTickCount/20);
            [masterAltimeter addChild:[majorTick copy]];
        } else {
            minorTick.position = CGPointMake(0, masterAltimeter.size.height*tempTickCount/20);
            [masterAltimeter addChild:[minorTick copy]];
        }
    }
    
    //Create indicator.
    SKShapeNode *altimeterIndicator = [SKShapeNode node];
    altimeterIndicator.zPosition = 1;
    CGMutablePathRef tempIndicatorPath = CGPathCreateMutable();
    CGPathMoveToPoint(tempIndicatorPath, NULL, 3, 0);
    CGPathAddLineToPoint(tempIndicatorPath, NULL, 3, 0);
    CGPathAddLineToPoint(tempIndicatorPath, NULL, 5, -2);
    CGPathAddLineToPoint(tempIndicatorPath, NULL, 12, -2);
    CGPathAddLineToPoint(tempIndicatorPath, NULL, 12, 2);
    CGPathAddLineToPoint(tempIndicatorPath, NULL, 5, 2);
    CGPathCloseSubpath(tempIndicatorPath);
    [altimeterIndicator setPath:tempIndicatorPath];
    CGPathRelease(tempIndicatorPath);
    [altimeterIndicator setStrokeColor:[UIColor colorWithWhite:1 alpha:1]];
    [altimeterIndicator setFillColor:[NWColor NWRed]];
    altimeterIndicator.name = @"indicator";
    
    [masterAltimeter addChild:altimeterIndicator];
}

#pragma mark --Create Audio
-(void)createAudio
{
    [[NWAudioPlayer sharedAudioPlayer] createAllMusicWithAudio:Level_1];
    [NWAudioPlayer sharedAudioPlayer].songName = Level_1;
}

-(void)vibrate {
    if ([GameState sharedGameData].vibeOn == YES) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

-(void)playSoundEffectsWithAction: (SKAction *)action {
    if ([GameState sharedGameData].audioVolume == 1.0) {
        [self runAction:action];
    }
}

#pragma mark --Score

-(void)createScoreTextBox {
    _score = [[SKLabelNode alloc] initWithFontNamed:@"SF Movie Poster"];
    _score.position = CGPointMake(self.size.width - 100, self.size.height - 30);
    _score.fontColor = [SKColor whiteColor];
    _score.fontSize = 30;
    _score.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    _score.zPosition = 101;
}

-(void)scoreAddWithMultiplier: (int)tempMultiplier {
    [self playSoundEffectsWithAction:_ScoreCollect];
    [GameState sharedGameData].score = [GameState sharedGameData].score + [GameState sharedGameData].scoreMultiplier*tempMultiplier;
    _score.text = [NSString stringWithFormat:@"Score: %i", [GameState sharedGameData].score];
}

-(void)scorePlusWithMultiplier: (int)tempMultiplier fromNode: (SKSpriteNode *)tempNode {
    SKLabelNode *plusOne = [SKLabelNode labelNodeWithFontNamed:@"SF Movie Poster"];
    plusOne.position = CGPointMake(25, tempNode.position.y);
    plusOne.fontColor = [SKColor whiteColor];
    plusOne.fontSize = 30;
    plusOne.zPosition = 101;
    int tempScore = [GameState sharedGameData].scoreMultiplier*tempMultiplier;
    plusOne.text = [NSString stringWithFormat:@"+%i", tempScore];
    
    [self addChild:plusOne];
    
    SKAction *scale = [SKAction scaleBy:2 duration:1];
    SKAction *moveUp = [SKAction moveBy:CGVectorMake(0,50) duration:1];
    SKAction *fade = [SKAction fadeAlphaTo:0 duration:1];
    
    SKAction *group = [SKAction group:@[scale,moveUp,fade]];
    [plusOne runAction:group];
}

#pragma mark --Animate Obstacles

-(void)initializeObstaclesWithInterval: (float)interval {
    SKAction *wait = [SKAction waitForDuration:interval];
    SKAction *run = [SKAction runBlock:^{
        [self createObstacles];
    }];
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[wait,run]]] withKey:objectCreateKey];
}

-(void) moveAerialNode: (SKSpriteNode *)incomingNode allowsRotation: (BOOL)allowsRotate
{
    //Calculations.
    float startHeight = incomingNode.position.y;
    float blackHoleRad = blackHole.size.width/2;
    float distToCent = sqrt(blackHoleRad * blackHoleRad - self.size.width/2 * self.size.width/2)*0.9;
    float sumHeight = startHeight + distToCent;
    float triangleWidth = self.size.width/2;
    double square = (sumHeight * sumHeight + triangleWidth * triangleWidth);
    float arcCenterHeight = sqrt(square);
    float deltaHeight = arcCenterHeight - sumHeight;
    double aerialSpeed = 0.95 - ([GameState sharedGameData].scoreMultiplier/10); //Base duration of 0.95 seconds.
    
    //Random +/-0.05s duration adjustment.
    int tempRand = arc4random()%100;
    double randDuration = (tempRand-50)/1000.0;
    double totalDuration = aerialSpeed + randDuration;
    
    totalDuration = MAX(totalDuration, 0.5);
    
    //Random rotation function.
    int tempRand2 = arc4random()%75 + 50;
    double tempRandSigned = tempRand2-50.0;
    double randAngleRad = (tempRandSigned)*180/100.0;
    double randAngleDeg = randAngleRad*3.141592654/180;
    
    //Time dilation calculations.  If position <=40% & >30% of screen height, reduce base aerial speed by 10% (corresponds to duration increase of 10/9).  Else if position <=30% & >20%, reduce base aerial speed by 20% (corresponds to duration increase of 25%).  If position <=20%, reduce base aerial speed by 30% (corresponds to duration increase of 10/7).
    if (startHeight <= self.size.height*0.40 && startHeight > self.size.height*0.30) {
        totalDuration = totalDuration * 10/9;
    } else if (startHeight <= self.size.height*0.30 && startHeight > self.size.height*0.20) {
        totalDuration = totalDuration * 5/4;
    } else if (startHeight <= self.size.height*0.20) {
        totalDuration = totalDuration * 10/7;
    }
    
    //Score differential calculations.  Max score-based speed differential is an increase in speed of 50% (corresponds to a duration decrease of 2/3).
    float scoreDifferential = MIN([GameState sharedGameData].score/1500, 1);  // <---ratio from 0 to 1 of score normalized against score of 1500.
    float durationReduction = 1/3*scoreDifferential;  // <---reduce duration by 33% max corresponds to increase in speed of 50%.
    totalDuration = totalDuration*(1-durationReduction);
    
    //Action Definitions.
    SKAction *horzMove = [SKAction moveToX: -incomingNode.size.width duration:totalDuration*2];
    SKAction *vertMoveUp = [SKAction moveByX:0 y:deltaHeight duration:totalDuration];
    SKAction *vertMoveDwn = [SKAction moveByX:0 y:-deltaHeight duration:totalDuration];
    SKAction *rotate = [SKAction rotateByAngle:randAngleDeg duration:totalDuration*2];
    vertMoveUp.timingMode = SKActionTimingEaseOut;
    vertMoveDwn.timingMode = SKActionTimingEaseIn;
    
    //Groups & Sequences
    if (allowsRotate == YES) {
        SKAction *vertMove = [SKAction sequence:@[vertMoveUp, vertMoveDwn]];
        SKAction *remove = [SKAction removeFromParent];
        SKAction *aerialGroup = [SKAction group:@[vertMove,horzMove,rotate]];
        SKAction *aerialSqnce = [SKAction sequence:@[aerialGroup, remove]];
        //Run sequence
        [incomingNode runAction:aerialSqnce];
    } else {
        SKAction *vertMove = [SKAction sequence:@[vertMoveUp, vertMoveDwn]];
        SKAction *remove = [SKAction removeFromParent];
        SKAction *aerialGroup = [SKAction group:@[vertMove,horzMove]];
        SKAction *aerialSqnce = [SKAction sequence:@[aerialGroup, remove]];
        //Run sequence
        [incomingNode runAction:aerialSqnce];
    }
}

#pragma mark --User Interface

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (!isSceneLoading) {
        if (playerParent.physicsBody.dynamic == NO) {
            playerParent.physicsBody.dynamic = YES;
            playerNode.physicsBody.dynamic = YES;
            //playerParent.physicsBody.allowsRotation = YES;
            [self addChild:_score];
            [self createObstacles];
            [tapPlay removeFromParent];
            [self initializeObstaclesWithInterval:0.5];
            [playerParent removeActionForKey:@"bobbingAction"];
        }
        
        [playerParent thrustPlayer:playerParent withHeight:self.size.height];
        [playerParent rotateNodeUpwards:playerParent];
    }
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"playButton"]) {
        playAgain.texture = [SKTexture textureWithImageNamed:@"buttonPressPlay"];
    }
    
    if ([node.name isEqualToString:@"trophyButton"]) {
        trophyButton.texture = [SKTexture textureWithImageNamed:@"Trophy_Button_press"];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //Called when a touch ends
    UITouch *touchLift = [touches anyObject];
    CGPoint locationLift = [touchLift locationInNode:self];
    SKNode *nodeLift = [self nodeAtPoint:locationLift];
    
    if ([nodeLift.name isEqualToString:@"backToMain"]) {
        
        [[GameState sharedGameData] reset];
        
        SKView *mainMenuView = (SKView *)self.view;
        SKScene *mainMenuScene = [[MainMenu alloc] initWithSize:mainMenuView.bounds.size];
        SKTransition *menuTransition = [SKTransition fadeWithDuration:.5];
        [mainMenuView presentScene:mainMenuScene transition:menuTransition];
    };
    
    if ([nodeLift.name isEqualToString:@"playButton"]) {
        
        [[GameState sharedGameData] reset];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAd" object:nil];
        
        playAgain.texture = [SKTexture textureWithImageNamed:@"buttonPlay"];
        SKColor *fadeColor = [SKColor colorWithRed:0 green:0 blue:0 alpha:1];
        
        SKView * levelOneView = (SKView *)self.view;
        levelOneView.showsFPS = YES;
        levelOneView.showsNodeCount = YES;
        
        // Create and configure the scene.
        SKScene * levelOneScene = [[Credits alloc] initWithSize:levelOneView.bounds.size];
        levelOneScene.scaleMode = SKSceneScaleModeAspectFill;
        SKTransition *levelOneTrans = [SKTransition fadeWithColor:fadeColor duration:0.5];
        
        // Present the scene.
        [levelOneView presentScene:levelOneScene transition:levelOneTrans];
    }
    
    if (![nodeLift.name isEqualToString:@"playButton"]) {
        playAgain.texture = [SKTexture textureWithImageNamed:@"buttonPlay"];
    }
    
    if ([nodeLift.name isEqualToString:@"trophyButton"]) {
        trophyButton.texture = [SKTexture textureWithImageNamed:@"Trophy_Button"];
        NSString *defaultLeaderBoardID = @"L1HS";
        GKGameCenterViewController *leaderboardViewController = [[GKGameCenterViewController alloc] init];
        
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (leaderboardViewController != nil) {
            leaderboardViewController.gameCenterDelegate = rootVC;
            leaderboardViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
            leaderboardViewController.leaderboardIdentifier = defaultLeaderBoardID;
        }
        
        [rootVC presentViewController:leaderboardViewController animated:YES completion:nil];
    }
    
    if (![nodeLift.name isEqualToString:@"trophyButton"]) {
        trophyButton.texture = [SKTexture textureWithImageNamed:@"Trophy_Button"];
    }
    
}

-(void)update:(NSTimeInterval)currentTime {
    if (_lastUpdateTime)
    {
        _dt = currentTime - _lastUpdateTime;
    }
    else
    {
        _dt = 0;
    }
    _lastUpdateTime = currentTime;
    
    blackHole.zRotation = blackHole.zRotation + .01;
    
    if (playerParent.physicsBody.velocity.dy < 0) {
        [playerParent rotateNodeDownwards:playerParent];
    }
    
    //Altimeter updates.
    [masterAltimeter childNodeWithName:@"indicator"].position = CGPointMake(0, masterAltimeter.size.height/2 + (playerParent.position.y-self.size.height/2)*(masterAltimeter.size.height / self.size.height));
}

#pragma mark --Game Over

-(void)gameOver {
    //Update leaderboard if necessary.
    GKLocalPlayer *tempLocalPlayer = [GKLocalPlayer localPlayer];
    if (tempLocalPlayer.isAuthenticated) {
        [[GameKitHelper sharedGameKitHelper] submitScore:[GameState sharedGameData].score toLeader:@"L1HS"];
    }
    
    //Update GameState data & stats tracking.
    [GameState sharedGameData].highScoreL1 = MAX([GameState sharedGameData].score, [GameState sharedGameData].highScoreL1);
    [GameState sharedGameData].totalGames = [GameState sharedGameData].totalGames + 1;
    [GameState sharedGameData].totalPoints = [GameState sharedGameData].totalPoints + [GameState sharedGameData].score;
    [GameState sharedGameData].allTimeAverageAccuracy = [GameState sharedGameData].totalLaserHits / [GameState sharedGameData].totalLasersFired;
    [GameState sharedGameData].allTimeAverageScore = [GameState sharedGameData].totalPoints / [GameState sharedGameData].totalGames;
    
    //Remove all actions & children from the scene.
    [self removeAllActions];
    [self removeAllChildren];
    
    [[GameState sharedGameData] save];
    [self playSoundEffectsWithAction:_ShipExplode];
    [self createBackgroundWithIndex:0];
    //Pop color.
    SKShapeNode *flash = [SKShapeNode node];
    flash.fillColor = [SKColor whiteColor]; //Deep red.
    flash.alpha = 0;
    flash.zPosition = 103;
    flash.path = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, self.size.width, self.size.height)].CGPath;
    flash.position = CGPointMake(0, 0);
    [self addChild:flash];
    [Multipliers popActionWithNode:flash];
    
    SKAction *wait = [SKAction waitForDuration:0.5];
    SKAction *gameOver = [SKAction runBlock:^{[self gameOverComplete];}];
    [self runAction:[SKAction sequence:@[wait,gameOver]]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAd" object:nil];
    
    if (tempLocalPlayer.isAuthenticated) {
        [GKAchievement reportAchievements:reportArray withCompletionHandler:^(NSError *error) {
            if (error != nil) {
                //[[GameKitHelper sharedGameKitHelper] setLastError:error];
                NSLog(@"Error in reporting achievements.");
            } else {
                NSLog(@"Achievements reported.");
                //[reportArray removeAllObjects];
            }
        }];
        long tempTotalScore = [GameState sharedGameData].totalPoints;
        NSData *tempData = [NSData dataWithBytes: &tempTotalScore length:sizeof(tempTotalScore)];
        [tempLocalPlayer saveGameData:tempData withName:@"totalScore" completionHandler:nil];
    }
}

-(void)gameOverComplete {
    
    [self addChild:[self backToMenu]];
    [self createCurrentScore];
    [self createHighScore];
    [self playAgainButton];
    [self leaderboardTrophy];
}

-(void)createBackgroundWithIndex: (CGFloat)index {
    SKSpriteNode *bgImg = [SKSpriteNode spriteNodeWithImageNamed:@"GameOver-L1"];
    bgImg.anchorPoint = CGPointMake(0.5f, 0.0f);
    bgImg.position = CGPointMake(160.0f, 0.0f);
    bgImg.zPosition = index;
    [self addChild:bgImg];
}

-(void)createCurrentScore {
    SKLabelNode *curScore = [[SKLabelNode alloc] initWithFontNamed:@"SF Movie Poster"];
    curScore.position = CGPointMake(self.size.width / 2, (self.size.height / 6) * 3.7);
    curScore.fontColor = [SKColor whiteColor];
    curScore.fontSize = 60;
    curScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    curScore.zPosition = 101;
    curScore.text = [NSString stringWithFormat:@"SCORE: %i", [GameState sharedGameData].score];
    [self addChild:curScore];
}

-(void)createHighScore {
    SKLabelNode *highScore = [[SKLabelNode alloc] initWithFontNamed:@"SF Movie Poster"];
    highScore.position = CGPointMake(self.size.width / 2, (self.size.height / 6) * 3.4);
    highScore.fontColor = [SKColor whiteColor];
    highScore.fontSize = 30;
    highScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    highScore.zPosition = 101;
    highScore.text = [NSString stringWithFormat:@"HIGH SCORE: %li", [GameState sharedGameData].highScoreL1];
    [self addChild:highScore];
}

-(void)playAgainButton {
    playAgain = [SKSpriteNode spriteNodeWithTexture: [SKTexture textureWithImageNamed:@"buttonPlay"]];
    playAgain.position = CGPointMake(self.size.width / 2, self.size.height/5);
    playAgain.name = @"playButton";
    playAgain.alpha = 0.0;
    [self addChild:playAgain];
    
    SKAction *wait = [SKAction waitForDuration:0.1];
    SKAction *move = [SKAction fadeAlphaTo:1.0 duration:0.5];
    [playAgain runAction:[SKAction sequence:@[wait,move]]];
}

-(SKLabelNode *) backToMenu
{
    backToMain = [SKLabelNode labelNodeWithFontNamed:@"SF Movie Poster"];
    backToMain.position = CGPointMake(60.0f, self.size.height - 40);
    backToMain.fontColor = [SKColor whiteColor];
    backToMain.fontSize = 30;
    backToMain.name = @"backToMain";
    backToMain.text = @"BACK to MAIN";
    
    return backToMain;
}

-(void)leaderboardTrophy {
    trophyButton = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"Trophy_Button"]];
    trophyButton.position = CGPointMake(playAgain.position.x-playAgain.size.width/2+trophyButton.size.width/2, playAgain.position.y + playAgain.size.height + 25);
    trophyButton.name = @"trophyButton";
    trophyButton.alpha = 0.0;
    
    SKAction *wait = [SKAction waitForDuration:0.1];
    SKAction *move = [SKAction fadeAlphaTo:1.0 duration:0.5];
    [trophyButton runAction:[SKAction sequence:@[wait,move]]];
    
    [self addChild:trophyButton];
}

-(void)didBeginContact:(SKPhysicsContact *)contact {
    
    SKPhysicsBody *firstBody;
    SKPhysicsBody *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    //SKSpriteNode *firstNode = (SKSpriteNode *)firstBody.node;
    SKSpriteNode *secondNode = (SKSpriteNode *)secondBody.node;
    
    if (firstBody.categoryBitMask == CollisionCategoryPlayer && secondBody.categoryBitMask == CollisionCategoryObject) {
        [self vibrate];
        [self playSoundEffectsWithAction:_ShipExplode];
        
        if ([secondNode.name isEqualToString:@"asteroid"] || [secondNode.name isEqualToString:@"red_asteroid"]) {
            [GameState sharedGameData].totalAsteroidDeaths = [GameState sharedGameData].totalAsteroidDeaths + 1;
        } else if ([secondNode.name isEqualToString:@"debris"]) {
            [GameState sharedGameData].totalDebrisDeaths = [GameState sharedGameData].totalDebrisDeaths + 1;
        }
        
    }
    
    if (firstBody.categoryBitMask == CollisionCategoryPlayer && secondBody.categoryBitMask == CollisionCategoryBottom) {
        [self vibrate];
        [self playSoundEffectsWithAction:_ShipExplode];

        [GameState sharedGameData].totalBlackHoleDeaths = [GameState sharedGameData].totalBlackHoleDeaths + 1;
    }
    
    if (firstBody.categoryBitMask == CollisionCategoryScore && secondBody.categoryBitMask == CollisionCategoryObject) {
        //Object has passed scoring threshold.  Run score function.
        [self scoreAddWithMultiplier:1];
        [self scorePlusWithMultiplier:1 fromNode:secondNode];
        
        secondNode.physicsBody.categoryBitMask = 0;
    }
}

@end
