//
//  LevelOne.m
//  Nova Wing
//
//  Created by Cameron Frank on 8/19/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import "LevelOne.h"
#import "GameOverL1.h"
#import "Obstacles.h"
#import "Multipliers.h"
#import "PowerUps.h"

typedef NS_OPTIONS(uint32_t, CollisionCategory) {
    CollisionCategoryPlayer     = 0x1 << 0,
    CollisionCategoryLaser      = 0x1 << 2,
    CollisionCategoryObject     = 0x1 << 4,
    CollisionCategoryBottom     = 0x1 << 5,
    CollisionCategoryScore      = 0x1 << 6,
    CollisionCategoryPup        = 0x1 << 7,
};

@interface LevelOne() <SKPhysicsContactDelegate>
{
    Ships *_player;
    Ships *playerNode;
    Ships *playerParent;
    pupType powerUp;
    BOOL activePup;
    
}
@end

@implementation LevelOne

NSTimeInterval _lastUpdateTime;
NSTimeInterval _dt;
SKLabelNode* _score;
NSTimer *objectCreateTimer;
NSTimer *multiTimer;
NSTimer *pupTimer;
NSTimer *tenSeconds;
NSTimer *halfSecond;


#pragma mark --CreateBackground

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        levelComplete = NO;
        storymodeL1 = NO;
        [GameState sharedGameData].scoreMultiplier = 1;
        [GameState sharedGameData].maxLaserHits = 0;
        activePup = NO;
        
        self.backgroundColor = [SKColor colorWithRed:0 green:0 blue:0 alpha:1];
        
        self.physicsWorld.gravity = CGVectorMake(0.0f, -8.0f);
        self.physicsWorld.contactDelegate = self;
        self.scaleMode = SKSceneScaleModeAspectFit;
        
        NSString *starsPath = [[NSBundle mainBundle] pathForResource:@"Stars-L1" ofType:@"sks"];
        SKEmitterNode *stars = [NSKeyedUnarchiver unarchiveObjectWithFile:starsPath];
        stars.position = CGPointMake(self.size.width, self.size.height / 2);
        
        //Pre emits particles so layer is populated when scene begins
        [stars advanceSimulationTime:1.5];
        
        //Create playerParent
        playerParent = [Ships node];
        playerParent.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:50];
        playerParent.position = CGPointMake(self.frame.size.width/5, self.frame.size.height/2);
        playerParent.physicsBody.dynamic = NO;
        playerParent.physicsBody.allowsRotation = YES;
        playerParent.physicsBody.contactTestBitMask = 0;
        playerParent.physicsBody.collisionBitMask = 0;
        [self createPlayerNode: playerNode];
        
        [self createAudio];
        [self createShipAudio];
        
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
        [self createScoreNode];
        //[self scoreTrack];
        if (storymodeL1 == YES) {
            [self intro];
            [self tapToPlay];
        } else if (storymodeL1 == NO)
            [self tapToPlay];
        _score.text = @"Score: 0";
        
    }
    
    return self;
}

-(void)createBlackHole {
    blackHole = [SKSpriteNode spriteNodeWithImageNamed:@"BlackHole"];
    blackHole.position = CGPointMake(self.size.width/2, -160);
    blackHole.xScale = 1.4;
    blackHole.yScale = 1.4;
    
    [self addChild:blackHole];
}

#pragma mark --Create Elements

-(Ships *) createPlayerNode: (Ships *)tempPlayer
{
    playerNode = [[Ships alloc] initWithImageNamed:@"Nova-L1"];
    playerNode.position = CGPointMake(0, 0);
    playerNode.physicsBody.categoryBitMask = CollisionCategoryPlayer;
    playerNode.physicsBody.collisionBitMask = 0;
    playerNode.physicsBody.contactTestBitMask = CollisionCategoryBottom | CollisionCategoryObject | CollisionCategoryScore | CollisionCategoryPup;
    
    
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
            [self rocket];
            break;
        case 4:
            [self asteroid1];
            break;
        case 5:
            [self shipChunk];
            break;
        case 6:
            break;
        case 7:
            [self asteroid2];
            break;
        case 8:
            break;
        case 9:
            [self asteroid3];
            break;
        case 10:
            [self asteroid4];
            break;

        default:
            break;
    }
    

}

-(void)asteroid1 {
    
    SKSpriteNode *tempNode = [SKSpriteNode node];
    SKSpriteNode *obstacle1 = [[Obstacles alloc] createObstacleWithNode:tempNode withName:@"aerial" withImage:@"L1-AOb-1"];
    
    int tempRand = arc4random()%80;
    double randYPosition = (tempRand+10)/100.0;
    obstacle1.position = CGPointMake(self.size.width+obstacle1.size.width, self.size.height*randYPosition);
    //obstacle1.name = @"aerial";
    obstacle1.zPosition = 10;
    
    int tempRand2 = arc4random()%200;
    double randScale = (tempRand2-100)/1000.0;
    obstacle1.xScale = 0.5 + randScale;
    obstacle1.yScale = 0.5 + randScale;
    
    obstacle1.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:obstacle1.size.height/2];
    obstacle1.physicsBody.categoryBitMask = CollisionCategoryObject;
    obstacle1.physicsBody.dynamic = NO;
    obstacle1.physicsBody.collisionBitMask = 0;
    obstacle1.physicsBody.contactTestBitMask = CollisionCategoryLaser || CollisionCategoryPlayer;
    
    [self addChild: obstacle1];
    [self moveAerialNode:obstacle1 allowsRotation:YES];
}

-(void)asteroid2 {
    
    SKSpriteNode *tempNode = [SKSpriteNode node];
    SKSpriteNode *obstacle2 = [[Obstacles alloc] createObstacleWithNode:tempNode withName:@"aerial" withImage:@"L1-AOb-2"];
    
    int tempRand = arc4random()%80;
    double randYPosition = (tempRand+10)/100.0;
    obstacle2.position = CGPointMake(self.size.width+obstacle2.size.width, self.size.height*randYPosition);
    obstacle2.anchorPoint = CGPointZero;
    obstacle2.zPosition = 10;
    obstacle2.xScale = 0.4;
    obstacle2.yScale = 0.4;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, 5, 5);
    CGPathAddLineToPoint(path, NULL, 50, 5);
    CGPathAddLineToPoint(path, NULL, 55, 15);
    CGPathAddLineToPoint(path, NULL, 50, 25);
    CGPathAddLineToPoint(path, NULL, 10, 25);
    
    CGPathCloseSubpath(path);
    
    obstacle2.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
    obstacle2.physicsBody.categoryBitMask = CollisionCategoryObject;
    obstacle2.physicsBody.dynamic = NO;
    obstacle2.physicsBody.collisionBitMask = 0;
    obstacle2.physicsBody.contactTestBitMask = CollisionCategoryLaser || CollisionCategoryPlayer;
    
    [self addChild: obstacle2];
    [self moveAerialNode:obstacle2 allowsRotation:YES];
    
}

-(void)asteroid3 {
    
    SKSpriteNode *tempNode = [SKSpriteNode node];
    SKSpriteNode *obstacle2 = [[Obstacles alloc] createObstacleWithNode:tempNode withName:@"aerial" withImage:@"L1-AOb-3"];
    
    int tempRand = arc4random()%80;
    double randYPosition = (tempRand+10)/100.0;
    obstacle2.position = CGPointMake(self.size.width+obstacle2.size.width, self.size.height*randYPosition);
    //obstacle1.name = @"aerial";
    obstacle2.zPosition = 10;
    
    int tempRand2 = arc4random()%100;
    double randScale = (tempRand2)/1000.0;
    obstacle2.xScale = 0.4 + randScale;
    obstacle2.yScale = 0.4 + randScale;
    
    obstacle2.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:obstacle2.size.height/2];
    obstacle2.physicsBody.categoryBitMask = CollisionCategoryObject;
    obstacle2.physicsBody.dynamic = NO;
    obstacle2.physicsBody.collisionBitMask = 0;
    obstacle2.physicsBody.contactTestBitMask = CollisionCategoryLaser || CollisionCategoryPlayer;
    
    [self addChild: obstacle2];
    [self moveAerialNode:obstacle2 allowsRotation:YES];
}

-(void)asteroid4 {
    
    SKSpriteNode *tempNode = [SKSpriteNode node];
    SKSpriteNode *obstacle2 = [[Obstacles alloc] createObstacleWithNode:tempNode withName:@"aerial" withImage:@"L1-AOb-4"];
    
    int tempRand = arc4random()%80;
    double randYPosition = (tempRand+10)/100.0;
    obstacle2.position = CGPointMake(self.size.width+obstacle2.size.width, self.size.height*randYPosition);
    //obstacle1.name = @"aerial";
    obstacle2.zPosition = 10;
    
    int tempRand2 = arc4random()%100;
    double randScale = (tempRand2)/1000.0;
    obstacle2.xScale = 0.4 + randScale;
    obstacle2.yScale = 0.4 + randScale;
    
    obstacle2.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:obstacle2.size.height/2];
    obstacle2.physicsBody.categoryBitMask = CollisionCategoryObject;
    obstacle2.physicsBody.dynamic = NO;
    obstacle2.physicsBody.collisionBitMask = 0;
    obstacle2.physicsBody.contactTestBitMask = CollisionCategoryLaser || CollisionCategoryPlayer;
    
    [self addChild: obstacle2];
    [self moveAerialNode:obstacle2 allowsRotation:YES];
    
}

-(void)rocket {
    SKSpriteNode *tempNode = [SKSpriteNode node];
    SKSpriteNode *obstacle2 = [[Obstacles alloc] createObstacleWithNode:tempNode withName:@"aerial" withImage:@"Rocket-1"];
    
    int tempRand = arc4random()%80;
    double randYPosition = (tempRand+10)/100.0;
    obstacle2.position = CGPointMake(self.size.width+obstacle2.size.width, self.size.height*randYPosition);
    obstacle2.anchorPoint = CGPointZero;
    //obstacle1.name = @"aerial";
    obstacle2.zPosition = 10;

    obstacle2.xScale = 0.4;
    obstacle2.yScale = 0.4;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, 50, 0);
    CGPathAddLineToPoint(path, NULL, 80, 10);
    CGPathAddLineToPoint(path, NULL, 50, 20);
    CGPathAddLineToPoint(path, NULL, 0, 20);
    
    CGPathCloseSubpath(path);
    
    obstacle2.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
    obstacle2.physicsBody.categoryBitMask = CollisionCategoryObject;
    obstacle2.physicsBody.dynamic = NO;
    obstacle2.physicsBody.collisionBitMask = 0;
    obstacle2.physicsBody.contactTestBitMask = CollisionCategoryLaser || CollisionCategoryPlayer;
    
    [self addChild: obstacle2];
    [self moveAerialNode:obstacle2 allowsRotation:YES];
}

-(void)shipChunk {
    SKSpriteNode *tempNode = [SKSpriteNode node];
    SKSpriteNode *obstacle2 = [[Obstacles alloc] createObstacleWithNode:tempNode withName:@"aerial" withImage:@"Ship-Chunk-1"];
    
    int tempRand = arc4random()%80;
    double randYPosition = (tempRand+10)/100.0;
    obstacle2.position = CGPointMake(self.size.width+obstacle2.size.width, self.size.height*randYPosition);
    obstacle2.anchorPoint = CGPointZero;
    obstacle2.zPosition = 10;
    obstacle2.xScale = 0.5;
    obstacle2.yScale = 0.5;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, 10, 0);
    CGPathAddLineToPoint(path, NULL, 50, 20);
    CGPathAddLineToPoint(path, NULL, 60, 60);
    CGPathAddLineToPoint(path, NULL, 50, 60);
    CGPathAddLineToPoint(path, NULL, 10, 20);
    
    CGPathCloseSubpath(path);
    
    obstacle2.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
    obstacle2.physicsBody.categoryBitMask = CollisionCategoryObject;
    obstacle2.physicsBody.dynamic = NO;
    obstacle2.physicsBody.collisionBitMask = 0;
    obstacle2.physicsBody.contactTestBitMask = CollisionCategoryLaser || CollisionCategoryPlayer;
    
    [self addChild: obstacle2];
    [self moveAerialNode:obstacle2 allowsRotation: YES];
}

-(void)bottomCollide {
    bottom = [SKSpriteNode node];
    bottom.position = CGPointMake(0, -4);
    bottom.size = CGSizeMake(self.size.width, 1);
    bottom.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, self.size.width, 1)];
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

-(void)intro {

    storyBadge = [SKSpriteNode spriteNodeWithImageNamed:@"CMDR-FletcherPop"];
    storyBadge.position = CGPointMake(self.size.width / 2, self.size.height / 2);
    storyBadge.zPosition = 101;
    
    introduction  = [NORLabelNode labelNodeWithFontNamed:@"SF Movie Poster"];
    introduction.fontColor = [SKColor whiteColor];
    introduction.fontSize = 30;
    introduction.lineSpacing = 1;
    introduction.position = CGPointMake(self.size.width / 2, self.size.height / 2 - 50);
    introduction.zPosition = 102;
    introduction.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    introduction.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    introduction.text = @"A Black Hole just came out of nowhere!\n Could it be? Theres... agh...\n the Whispers... I can't...";
    
    [self addChild:storyBadge];
    [self addChild:introduction];
}

/*-(void)createShipTrail {
    NSString *trailPath = [[NSBundle mainBundle] pathForResource:@"ShipTrail" ofType:@"sks"];
    
    SKEmitterNode *trail = [NSKeyedUnarchiver unarchiveObjectWithFile:trailPath];
    trail.position = _player.position;
    
    [self addChild:trail];
}*/

#pragma mark --Create Audio
-(void)createAudio
{
    [[NWAudioPlayer sharedAudioPlayer] createAllMusicWithAudio:Level_1];
    [NWAudioPlayer sharedAudioPlayer].songName = Level_1;
}

-(void)createShipAudio {
    NSString *soundFile = [[NSBundle mainBundle] pathForResource:@"Engine-Audio" ofType:@"wav"];
    NSURL *soundFileUrl = [NSURL fileURLWithPath:soundFile];
    NSError *Error = nil;
    Engine = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileUrl error:&Error];
    Engine.numberOfLoops = -1;
    Engine.volume = 0.8 * [[GameState sharedGameData] audioVolume];
    [Engine prepareToPlay];
    [Engine play];
}

-(void)explosionAudio {
    NSString *soundFile = [[NSBundle mainBundle] pathForResource:@"Explosion" ofType:@"wav"];
    NSURL *soundFileUrl = [NSURL fileURLWithPath:soundFile];
    NSError *Error = nil;
    Explosion = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileUrl error:&Error];
    Explosion.numberOfLoops = 1;
    Explosion.volume = [[GameState sharedGameData] audioVolume];
    [Explosion prepareToPlay];
    [Explosion play];
}

#pragma mark --Score

-(void)createScoreNode {
    _score = [[SKLabelNode alloc] initWithFontNamed:@"SF Movie Poster"];
    _score.position = CGPointMake(self.size.width - 100, self.size.height - 30);
    _score.fontColor = [SKColor whiteColor];
    _score.fontSize = 30;
    _score.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    _score.zPosition = 101;
}

-(void)scoreAdd {
    [GameState sharedGameData].score = [GameState sharedGameData].score + [GameState sharedGameData].scoreMultiplier;
    _score.text = [NSString stringWithFormat:@"Score: %li", [GameState sharedGameData].score];
}

-(void)scorePlus {
    SKLabelNode *plusOne = [SKLabelNode labelNodeWithFontNamed:@"SF Movie Poster"];
    plusOne.position = CGPointMake(25, [self childNodeWithName:@"aerial"].position.y);
    plusOne.fontColor = [SKColor whiteColor];
    plusOne.fontSize = 30;
    plusOne.zPosition = 101;
    plusOne.text = [NSString stringWithFormat:@"+%i", [GameState sharedGameData].scoreMultiplier];
    
    [self addChild:plusOne];
    
    SKAction *scale = [SKAction scaleBy:2 duration:1];
    SKAction *moveUp = [SKAction moveBy:CGVectorMake(0,50) duration:1];
    SKAction *fade = [SKAction fadeAlphaTo:0 duration:1];
    
    SKAction *group = [SKAction group:@[scale,moveUp,fade]];
    [plusOne runAction:group];

}

-(void)scoreMulti {
    [trail removeFromParent];
    
    SKShapeNode *flash = [[Multipliers alloc] createFlash];
    flash.path = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, self.size.width, self.size.height)].CGPath;
    flash.position = CGPointMake(0, 0);
    [self addChild:flash];
    [[Multipliers alloc] popActionWithNode:flash];
    
    trail = [[Multipliers alloc] createShipTrail];
    trail.position = CGPointMake(-30, 8);
    trail.zPosition = 1;
    trail.targetNode = self.scene;
    trail.name = @"particleTrail";
    [playerNode addChild:trail];
    
    switch ([GameState sharedGameData].scoreMultiplier) {
        case 1:
            [[self childNodeWithName:@"multiplier"] removeFromParent];
            [GameState sharedGameData].scoreMultiplier ++;
            [objectCreateTimer invalidate];
            objectCreateTimer = [NSTimer scheduledTimerWithTimeInterval:0.35 target:self selector:@selector(createObstacles) userInfo:nil repeats:YES];
            break;
        case 2:
            [[self childNodeWithName:@"multiplier"] removeFromParent];
            [GameState sharedGameData].scoreMultiplier ++;
            [objectCreateTimer invalidate];
            objectCreateTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(createObstacles) userInfo:nil repeats:YES];
            break;
        case 3:
            [[self childNodeWithName:@"multiplier"] removeFromParent];
            [GameState sharedGameData].scoreMultiplier ++;
            [objectCreateTimer invalidate];
            objectCreateTimer = [NSTimer scheduledTimerWithTimeInterval:0.28 target:self selector:@selector(createObstacles) userInfo:nil repeats:YES];
            break;
        case 4:
            [[self childNodeWithName:@"multiplier"] removeFromParent];
            [GameState sharedGameData].scoreMultiplier ++;
            [objectCreateTimer invalidate];
            objectCreateTimer = [NSTimer scheduledTimerWithTimeInterval:0.27 target:self selector:@selector(createObstacles) userInfo:nil repeats:YES];
            [multiTimer invalidate];
            break;
        default:
            break;
    }
}

#pragma mark --Animate Obstacles

-(void) moveAerialNode: (SKSpriteNode *)incomingNode allowsRotation: (BOOL)allowsRotate
{
    //Calculations.
    float startHeight = incomingNode.position.y;
    float blackHoleRad = blackHole.size.width/2;
    float distToCent = sqrt(blackHoleRad * blackHoleRad - self.size.width/2 * self.size.width/2);
    float sumHeight = startHeight + distToCent;
    float triangleWidth = self.size.width/2;
    double square = (sumHeight * sumHeight + triangleWidth * triangleWidth);
    float arcCenterHeight = sqrt(square);
    float deltaHeight = arcCenterHeight - sumHeight;
    double aerialSpeed = .8 - ([GameState sharedGameData].scoreMultiplier/10);
    
    int tempRand = arc4random()%150;
    double randDuration = (tempRand-100)/1000.0;
    double totalDuration = aerialSpeed + randDuration;
    
    int tempRand2 = arc4random()%75 + 50;
    double tempRandSigned = tempRand2-50.0;
    double randAngleRad = (tempRandSigned)*180/100.0;
    double randAngleDeg = randAngleRad*3.141592654/180;
    
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

#pragma mark --Power Ups

-(void)createMultiplier {
    int tempRand = arc4random()%80;
    double randYPosition = (tempRand+10)/100.0;
    
    SKSpriteNode *multiplier = [[Multipliers alloc] createMultiplier];
    multiplier.position = CGPointMake(self.size.width + multiplier.size.width, self.size.height * randYPosition);
    multiplier.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: multiplier.size];
    multiplier.physicsBody.categoryBitMask = CollisionCategoryScore;
    multiplier.physicsBody.dynamic = NO;
    multiplier.physicsBody.collisionBitMask = 0;
    multiplier.name = @"multiplier";
    multiplier.xScale = 0.6;
    multiplier.yScale = 0.6;
    multiplier.zPosition = 11;
    
    int randomInt = arc4random()%2;
    if (randomInt == 1) {
        [self addChild:multiplier];
        [self moveAerialNode:multiplier allowsRotation: NO];
    }
}

-(void)createPowerUp {
    
    if (!activePup) {
        int tempRand = arc4random()%80;
        double randYPos = (tempRand + 10) / 100.0;
        
        powerUp = [[PowerUps alloc] powerUpTypes];
        SKSpriteNode *Pup = [[PowerUps alloc] createPupsWithType:powerUp];
        Pup.position = CGPointMake(self.size.width + Pup.size.width, self.size.height * randYPos);
        Pup.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius: Pup.size.width * .3];
        Pup.physicsBody.categoryBitMask = CollisionCategoryPup;
        Pup.physicsBody.dynamic = NO;
        Pup.physicsBody.collisionBitMask = 0;
        Pup.name = @"PowerUp";
        Pup.zPosition = 11;
        
        [self addChild:Pup];
        [self moveAerialNode:Pup allowsRotation:NO];
    }
}

-(void)checkPup {
    
    switch (powerUp) {
        case Wing_man:
            [self createPupTitleWithText:@"Wingman!"];
            [self autoCannonRun];
            break;
        case Over_shield:
            [self createPupTitleWithText:@"Overshield!"];
            [self autoCannonRun];
            break;
        case Auto_Cannon:
            [self createPupTitleWithText:@"Auto Cannon!"];
            [self autoCannonRun];
            break;
        case Tiny_Nova:
            [self createPupTitleWithText:@"Tiny Nova!"];
            [self tinyNova];
            break;
        default:
            break;
    }
    [[self childNodeWithName:@"PowerUp"] removeFromParent];
}

-(void)createPupTitleWithText: (NSString *)title {
    SKLabelNode *pupText = [SKLabelNode labelNodeWithFontNamed:@"SF Movie Poster"];
    pupText.position = CGPointMake(self.size.width / 2, self.size.height * 0.75);
    pupText.fontColor = [SKColor whiteColor];
    pupText.fontSize = 45;
    pupText.zPosition = 101;
    pupText.text = title;
    
    [self addChild:pupText];
    
    SKAction *scale = [SKAction scaleBy:2 duration:1];
    SKAction *moveUp = [SKAction moveBy:CGVectorMake(0,50) duration:1];
    SKAction *fade = [SKAction fadeAlphaTo:0 duration:1];
    
    SKAction *group = [SKAction group:@[scale,moveUp,fade]];
    [pupText runAction:group];
}

-(void)tinyNova {
    [[PowerUps alloc] logicTinyNova:_player];
    tenSeconds = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(tinyNovaClose) userInfo:nil repeats:NO];
    activePup = YES;
}

-(void)tinyNovaClose {
    [[PowerUps alloc] closeTinyNova:_player];
    activePup = NO;
    [tenSeconds invalidate];
}

-(void)autoCannonRun {
    //tenSeconds = [NSTimer scheduledTimerWithTimeInterval:10.1 target:self selector:@selector(autoCannonFinish) userInfo:nil repeats:NO];
    lasersFired = 0;
    localLaserHits = 0;
    halfSecond = [NSTimer scheduledTimerWithTimeInterval:0.45 target:self selector:@selector(autoCannonFire) userInfo:nil repeats:YES];
    activePup = YES;
}

-(void)autoCannonFire {
    
    if (lasersFired == 20) {
        [self autoCannonFinish];
    } else {
        SKSpriteNode *laser = [[PowerUps alloc] autoCannonFire:playerNode];
        laser.position = CGPointMake(playerParent.position.x, playerParent.position.y);
        laser.zRotation = playerParent.zRotation;
        laser.physicsBody.categoryBitMask = CollisionCategoryLaser;
        laser.physicsBody.collisionBitMask = 0;
        laser.physicsBody.contactTestBitMask = CollisionCategoryObject;
        laser.name = @"laser";
        [self addChild:laser];
        lasersFired = lasersFired + 1;
        [[PowerUps alloc] animateLaser:laser withWidth: self.size.width];
    }
}

-(void)laserContactRemove: (SKSpriteNode *)firstNodeToRemove andRemove: (SKSpriteNode *)secondNodeToRemove {
    SKShapeNode *flash = [SKShapeNode node];
    flash.fillColor = [SKColor colorWithRed:0.33 green:0.33 blue:0.34 alpha:1];
    flash.alpha = 0;
    flash.zPosition = 103;
    flash.path = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, self.size.width, self.size.height)].CGPath;
    flash.position = CGPointMake(0, 0);
    [self addChild:flash];
    SKAction *fadeIn = [SKAction fadeAlphaTo:1 duration:.05];
    SKAction *fadeOut = [SKAction fadeAlphaTo:0 duration:.15];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *seq = [SKAction sequence:@[fadeIn,fadeOut, remove]];
    [flash runAction:seq];
    [firstNodeToRemove removeFromParent];
    [secondNodeToRemove removeFromParent];
    localLaserHits = localLaserHits + 1;
}

-(void)autoCannonFinish {
    activePup = NO;
    [halfSecond invalidate];
    [GameState sharedGameData].maxLaserHits = MAX([GameState sharedGameData].maxLaserHits, localLaserHits);
}

#pragma mark --User Interface

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    if ([self.children containsObject:storyBadge] && [self.children containsObject:introduction] && [self.children containsObject:tapPlay]) {
        [storyBadge removeFromParent];
        [introduction removeFromParent];
        [tapPlay removeFromParent];
    }
    if (playerParent.physicsBody.dynamic == NO) {
        playerParent.physicsBody.dynamic = YES;
        playerNode.physicsBody.dynamic = YES;
        //playerParent.physicsBody.allowsRotation = YES;
        [self addChild:_score];
        [self createObstacles];
        [tapPlay removeFromParent];
        objectCreateTimer = [NSTimer scheduledTimerWithTimeInterval:0.45 target:self selector:@selector(createObstacles) userInfo:nil repeats:YES];
        multiTimer = [NSTimer scheduledTimerWithTimeInterval:2.7 target:self selector:@selector(createMultiplier) userInfo:nil repeats:YES];
        pupTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(createPowerUp) userInfo:nil repeats:YES];
        [playerParent removeActionForKey:@"bobbingAction"];
    }
    
    [playerParent thrustPlayer:playerParent withHeight:self.size.height];
    
    if (levelComplete == YES) {
        SKView *gameOverView = (SKView *)self.view;
        
        SKScene *gameOverScene = [[GameOverL1 alloc] initWithSize:gameOverView.bounds.size];
        
        SKColor *fadeColor = [SKColor colorWithRed:0 green:0 blue:0 alpha:1];
        SKTransition *gameOverTransition = [SKTransition fadeWithColor:fadeColor duration:.25];
        [gameOverView presentScene:gameOverScene transition:gameOverTransition];
    }
    
    [playerParent rotateNodeUpwards:playerParent];
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
    
    if ([self childNodeWithName:@"aerial"].position.x < playerParent.position.x && [self childNodeWithName:@"aerial"].position.x > 1)
    {
        [self scoreAdd];
        [self scorePlus];
        [self childNodeWithName:@"aerial"].name = @"aerialClose";
    }
    
}

-(void)timersInvalidate {
    [objectCreateTimer invalidate];
    [multiTimer invalidate];
    [pupTimer invalidate];
}

-(void)gameOver {
    [GameState sharedGameData].highScoreL1 = MAX([GameState sharedGameData].score, [GameState sharedGameData].highScoreL1);
    [_player removeAllChildren];
    SKView *gameOverView = (SKView *)self.view;
    
    SKScene *gameOverScene = [[GameOverL1 alloc] initWithSize:gameOverView.bounds.size];
    
    SKColor *fadeColor = [SKColor colorWithRed:1 green:1 blue:1 alpha:1];
    SKTransition *gameOverTransition = [SKTransition fadeWithColor:fadeColor duration:.25];
    [gameOverView presentScene:gameOverScene transition:gameOverTransition];
    
    [self timersInvalidate];
    [Engine stop];
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
    
    SKSpriteNode *firstNode = (SKSpriteNode *)firstBody.node;
    SKSpriteNode *secondNode = (SKSpriteNode *)secondBody.node;

    if (firstBody.categoryBitMask == CollisionCategoryPlayer && secondBody.categoryBitMask == CollisionCategoryObject) {
        [self gameOver];
    }
    
    if (firstBody.categoryBitMask == CollisionCategoryPlayer && secondBody.categoryBitMask == CollisionCategoryBottom) {
        [self gameOver];
    }
    
    if (firstBody.categoryBitMask == CollisionCategoryPlayer && secondBody.categoryBitMask == CollisionCategoryScore) {
        [self scoreMulti];
        }
    
    if (firstBody.categoryBitMask == CollisionCategoryPlayer && secondBody.categoryBitMask == CollisionCategoryPup) {
        [self checkPup];
    }
    
    if (firstBody.categoryBitMask == CollisionCategoryLaser && secondBody.categoryBitMask == CollisionCategoryObject) {
        [self laserContactRemove:firstNode andRemove:secondNode];
        
    }
    
}

@end
