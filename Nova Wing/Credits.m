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
    int creditsRoundCount;
    int positionInRound;
    int localCreditsHits;
    SKSpriteNode *blackHole;
    SKLabelNode *tapPlay;
    NORLabelNode *introduction;
    SKSpriteNode *storyBadge;
    bool storymodeL1;
    bool levelComplete;
    SKSpriteNode *bottom;
    SKEmitterNode *trail;
    
    SKSpriteNode *masterAltimeter;
    
    //Game Over ivars
    SKLabelNode *backToMain;
    SKSpriteNode *playAgain;
    SKSpriteNode *trophyButton;
    
    //Strings for Action Keys (To ensure safety)
    NSString *objectCreateKey;
    NSString *objectRemoveTimerKey;

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
int _totalCreditsHits;
AVAudioPlayer *Explosion;
NSMutableArray *reportArray;

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
        objectRemoveTimerKey = @"objectRemoveTimerKey";
        
        //Set up Arrays
        reportArray = [NSMutableArray array];
    }
    return self;
}

-(void)didMoveToView:(SKView *)view {
    [self setUpScene];
    isSceneLoading = NO;
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
    
    //Create playerParent.
    playerParent = [self createPlayerParent];
    [self createPlayerNode: playerNode];
    
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
    
    [self tapToPlay];
    
    [self addAltimeter];
    creditsRoundCount = 0;
    positionInRound = 0;
    localCreditsHits = 0;
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

-(void)createTitles {
    SKLabelNode *tempNode = [[SKLabelNode alloc] initWithFontNamed:@"SF Movie Poster"];
    tempNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    tempNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    tempNode.position = CGPointMake(self.size.width/2, self.size.height*0.90);
    tempNode.text = @"Developers";
    tempNode.alpha = 0.0;
    
    SKAction *waitIn = [SKAction waitForDuration:0.2];
    SKAction *fadeIn = [SKAction fadeInWithDuration:0.6];
    SKAction *inSeq = [SKAction sequence:@[waitIn, fadeIn]];
    
    SKAction *wait = [SKAction waitForDuration:2.2];
    SKAction *fade = [SKAction fadeOutWithDuration:0.6];
    SKAction *rename = [SKAction runBlock:^{
        tempNode.text = @"Beta Testers";
    }];
    SKAction *waitAgain = [SKAction waitForDuration:0.2];
    SKAction *fadeBackIn = [SKAction fadeInWithDuration:0.6];
    SKAction *waitAgainAgain = [SKAction waitForDuration:4];
    SKAction *fadeOutLast = [SKAction fadeOutWithDuration:0.6];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *seq = [SKAction sequence:@[inSeq,wait,fade,rename,waitAgain,fadeBackIn,waitAgainAgain,fadeOutLast,remove]];
    
    [self addChild:tempNode];
    [tempNode runAction:seq];
}

-(void)rollCredits {
        //Set Up Dictionary
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Credits" ofType:@"plist"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSMutableArray *devsDict = [dict objectForKey:@"Devs"];
    NSMutableArray *betaDict = [dict objectForKey:@"Betas"];
    NSArray *devsSorted = [devsDict sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *betasSorted = [betaDict sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    int matrixSize = (int)[betasSorted count];
    _totalCreditsHits = matrixSize + (int)[devsSorted count];
    
    NSArray *combinedCredits = @[devsSorted,betasSorted];
    
    SKSpriteNode *devNode = [SKSpriteNode node];
    SKLabelNode *name = [[SKLabelNode alloc] initWithFontNamed:@"SF Movie Poster"];
    
    [self addChild:devNode];
    [devNode addChild:name];
    
    name.text = [[combinedCredits objectAtIndex:creditsRoundCount] objectAtIndex:positionInRound];
    name.position = CGPointMake(0, 0);
    
    devNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(name.frame.size.width, name.frame.size.height) center:CGPointMake(0, name.frame.size.height/2)];
    devNode.physicsBody.restitution = 0.5;
    devNode.physicsBody.dynamic = YES;
    devNode.physicsBody.allowsRotation = NO;
    devNode.physicsBody.categoryBitMask = CollisionCategoryObject;
    devNode.physicsBody.contactTestBitMask = CollisionCategoryPlayer | CollisionCategoryBottom;
    devNode.physicsBody.collisionBitMask = CollisionCategoryPlayer | CollisionCategoryBottom;
    devNode.physicsBody.affectedByGravity = NO;
    devNode.physicsBody.linearDamping = 0;
    devNode.name = @"credit";
    
    int tempRand = arc4random()%50;
    double randYPosition = (tempRand+25)/100.0;
    devNode.position = CGPointMake(self.size.width+name.frame.size.width, self.size.height*randYPosition);
    SKAction *waitToLaunch = [SKAction waitForDuration: 0.5];
    SKAction *impulse = [SKAction runBlock:^{
        [devNode.physicsBody applyImpulse:CGVectorMake(-15, 0)];
    }];
    SKAction *wait = [SKAction waitForDuration:2];
    SKAction *diminish = [SKAction fadeOutWithDuration:0.6];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *devNodeSequence = [SKAction sequence:@[waitToLaunch,impulse,wait,diminish,remove]];
    
    [devNode runAction:devNodeSequence withKey:objectRemoveTimerKey];
    
    positionInRound = positionInRound + 1;
    if (creditsRoundCount == 0 && positionInRound == 2) {
        positionInRound = 0;
        creditsRoundCount = creditsRoundCount + 1;
    }
    
    if (creditsRoundCount == 1 && positionInRound == matrixSize) {
        //end credits.
        [self removeAllActions];
        [self checkAchievementsCredits];
        [self buttonsAfterCredits];
    }
}

-(void)checkAchievementsCredits {
    NSMutableArray *reportArray = [NSMutableArray array];
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    if (localCreditsHits == _totalCreditsHits) {
        GKAchievement *achievement1 = [[GKAchievement alloc] initWithIdentifier:@"glory_hog" player:localPlayer];
        achievement1.showsCompletionBanner = YES;
        achievement1.percentComplete = 100.0;
        [reportArray addObject:achievement1];
    }
    GKAchievement *achievement2 = [[GKAchievement alloc] initWithIdentifier:@"stinger" player:localPlayer];
    achievement2.showsCompletionBanner = YES;
    achievement2.percentComplete = 100.0;
    [reportArray addObject:achievement2];
    
    if (localPlayer.isAuthenticated) {
        [GKAchievement reportAchievements:reportArray withCompletionHandler:^(NSError *error) {
            if (error != nil) {
                //[[GameKitHelper sharedGameKitHelper] setLastError:error];
                //NSLog(@"Error in reporting achievements.");
            } else {
                //NSLog(@"Achievements reported.");
                //[reportArray removeAllObjects];
            }
        }];
    }
}

-(void)buttonsAfterCredits {
    SKAction *BTMFadeOut = [SKAction fadeAlphaTo:0.5 duration:0.4];
    SKAction *BTMFadeIn = [SKAction fadeAlphaTo:1.0 duration:0.4];
    SKAction *BTMSeq = [SKAction sequence:@[BTMFadeOut,BTMFadeIn]];
    [backToMain runAction:[SKAction repeatActionForever:BTMSeq]];
}

-(void)bottomCollide {
    bottom = [SKSpriteNode node];
    bottom.position = CGPointMake(0, -4);
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
    tapPlay.text = @"Tap to avoid (or not) the credits!";
    
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
    SKSpriteNode *majorTick = [SKSpriteNode spriteNodeWithColor:[NWColor NWBlue] size:tempMajorSize];
    majorTick.anchorPoint = CGPointMake(0, 0.5);
    majorTick.zPosition = 0;
    
    CGSize tempMinorSize = CGSizeMake(2, 1);
    SKSpriteNode *minorTick = [SKSpriteNode spriteNodeWithColor:[NWColor NWBlue] size:tempMinorSize];
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
    [altimeterIndicator setStrokeColor:[UIColor colorWithWhite:1 alpha:0]];
    [altimeterIndicator setFillColor:[NWColor NWGreen]];
    altimeterIndicator.name = @"indicator";
    
    [masterAltimeter addChild:altimeterIndicator];
}


#pragma mark --Create Audio
-(void)createAudio
{
    [[NWAudioPlayer sharedAudioPlayer] createAllMusicWithAudio:Level_1];
    [NWAudioPlayer sharedAudioPlayer].songName = Level_1;
}

-(void)playSoundEffectsWithAction: (SKAction *)action {
    if ([GameState sharedGameData].audioVolume == 1.0) {
        [self runAction:action];
    }
}

#pragma mark --Animate Obstacles

-(void)initializeObstaclesWithInterval: (float)interval {
    [self createTitles];
    SKAction *wait = [SKAction waitForDuration:interval];
    SKAction *run = [SKAction runBlock:^{
        [self rollCredits];
    }];
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[wait,run]]] withKey:objectCreateKey];
}

#pragma mark --User Interface

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (!isSceneLoading) {
        if (playerParent.physicsBody.dynamic == NO) {
            playerParent.physicsBody.dynamic = YES;
            playerNode.physicsBody.dynamic = YES;
            [tapPlay removeFromParent];
            [self initializeObstaclesWithInterval:1.0];
            [playerParent removeActionForKey:@"bobbingAction"];
            [self addChild:[self backToMenu]];
        }
        
        [playerParent thrustPlayer:playerParent withHeight:self.size.height];
        [playerParent rotateNodeUpwards:playerParent];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //Called when a touch ends
    UITouch *touchLift = [touches anyObject];
    CGPoint locationLift = [touchLift locationInNode:self];
    SKNode *nodeLift = [self nodeAtPoint:locationLift];
    
    if ([nodeLift.name isEqualToString:@"backToMain"]) {
        SKAction *createSound = [SKAction playSoundFileNamed:@"Button-Press.caf" waitForCompletion:NO];
        SKAction *playSound = [SKAction runBlock:^{
            [self playSoundEffectsWithAction:createSound];
        }];
        [self removeAllActions];
        [self removeAllChildren];
        SKView *mainMenuView = (SKView *)self.view;
        SKScene *mainMenuScene = [[MainMenu alloc] initWithSize:mainMenuView.bounds.size];
        SKTransition *menuTransition = [SKTransition fadeWithDuration:.5];
        SKAction *newSceneAction = [SKAction runBlock:^() {
            [mainMenuView presentScene:mainMenuScene transition:menuTransition];
        }];
        [self runAction:[SKAction sequence:@[playSound,newSceneAction]]];
    };
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
    
    if (playerParent.physicsBody.velocity.dy<-750) {
        playerParent.physicsBody.velocity = CGVectorMake(0, -750);
    }
}

#define BTM_RoundRect 8

-(SKSpriteNode *) backToMenu
{
    SKSpriteNode *node = [SKSpriteNode node];
    node.position = CGPointMake(45.0f, self.size.height - 40);
    
    SKShapeNode *blackStripe = [SKShapeNode node];
    [blackStripe setPath:CGPathCreateWithRoundedRect(CGRectMake(-60, -10, 120, 40), BTM_RoundRect, BTM_RoundRect, nil)];
    blackStripe.fillColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    blackStripe.strokeColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    
    backToMain = [SKLabelNode labelNodeWithFontNamed:@"SF Movie Poster"];
    backToMain.alpha = 1.0;
    backToMain.fontColor = [SKColor whiteColor];
    backToMain.fontSize = 30;
    backToMain.name = @"backToMain";
    backToMain.text = @"BACK to MAIN";
    backToMain.position = CGPointMake(10.0f, 0);
    
    [node addChild:blackStripe];
    [node addChild:backToMain];
    
    return node;
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
        if ([secondNode.name isEqualToString:@"credit"]) {
            localCreditsHits = localCreditsHits + 1;
            secondNode.name = @"credit_counted";
        }
    }
    
    if (firstBody.categoryBitMask == CollisionCategoryPlayer && secondBody.categoryBitMask == CollisionCategoryBottom) {
        
        float tempSpeed = playerParent.physicsBody.velocity.dy;
        SKShapeNode *flash = [Multipliers createFlash];
        flash.path = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, self.size.width, self.size.height)].CGPath;
        flash.position = CGPointMake(0, 0);
        flash.fillColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1];
        flash.alpha = 0.0;
        [self addChild:flash];
        [Multipliers popActionWithNode:flash];
        playerParent.physicsBody.dynamic = NO;
        playerNode.physicsBody.dynamic = NO;
        SKAction *movePlayerParentToUpperPosition = [SKAction moveTo:CGPointMake(playerParent.position.x, self.size.height-playerParent.size.height) duration:0.0];
        [playerParent runAction:movePlayerParentToUpperPosition];
        playerParent.physicsBody.dynamic = YES;
        playerNode.physicsBody.dynamic = YES;
        playerParent.physicsBody.velocity = CGVectorMake(0, tempSpeed);
    }
    
    if (firstBody.categoryBitMask == CollisionCategoryObject && secondBody.categoryBitMask == CollisionCategoryBottom) {
        secondNode.physicsBody.velocity = CGVectorMake(secondNode.physicsBody.velocity.dx, -secondNode.physicsBody.velocity.dy);
    }
}

@end