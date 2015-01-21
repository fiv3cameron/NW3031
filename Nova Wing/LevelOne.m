//
//  LevelOne.m
//  Nova Wing
//
//  Created by Cameron Frank on 8/19/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//  test

#import <AudioToolbox/AudioToolbox.h>

#import "LevelOne.h"
#import "Obstacles.h"
#import "Multipliers.h"
#import "PowerUps.h"
#import "MainMenu.h"

@interface LevelOne() <SKPhysicsContactDelegate>
{
    Ships *playerNode;
    Ships *wingmanNode;
    Ships *playerParent;
    Ships *wingmanParent;
    pupType powerUp;
    SKSpriteNode *shield;
    BOOL activePup;
    BOOL wingmanActive;
    BOOL isSceneLoading;
    SKPhysicsJointSpring *wingmanSpring;
    
        //Game Over ivars
    SKLabelNode *backToMain;
    SKSpriteNode *playAgain;
    
        //Strings for Action Keys (To ensure safety)
    NSString *multiKey;
    NSString *objectCreateKey;
    NSString *powerUpKey;
    NSString *autocannonKey;
    NSString *wingmanCannonKey;
    
        //Set Up Atlases
    NSArray *asteroid_1;
    
}
        //Preloading Sound Actions -> Properties Here
    @property (strong, nonatomic) SKAction* AutoCannonFire;
    @property (strong, nonatomic) SKAction* AutoCannonSpool;
    @property (strong, nonatomic) SKAction* CannonHitExplode;
    @property (strong, nonatomic) SKAction* Explosion;
    @property (strong, nonatomic) SKAction* MultiplierCollection;
    @property (strong, nonatomic) SKAction* ScoreCollect;
    @property (strong, nonatomic) SKAction* ShieldPowerUp;
    @property (strong, nonatomic) SKAction* ShieldBreak;
    @property (strong, nonatomic) SKAction* ShieldCollision;
    @property (strong, nonatomic) SKAction* ShipExplode;
    @property (strong, nonatomic) SKAction* TinyNovaCollect;
    @property (strong, nonatomic) SKAction* WingmanCollect;

        //Atlas Properties
    @property (strong, nonatomic) SKTextureAtlas *Asteroid_1_Atlas;

@end


@implementation LevelOne

NSTimeInterval _lastUpdateTime;
NSTimeInterval _dt;
SKLabelNode* _score;
int shieldIndex;
SKColor *playerLaserColorCast;
SKColor *wingmanLaserColorCast;

#define AUTOCANNON_INTERVAL 0.3
#define AUTOCANNON_SHOTS_FIRED 25

#pragma mark --CreateBackground

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        [GameState sharedGameData].scoreMultiplier = 1;
        [GameState sharedGameData].maxLaserHits = 0;
        activePup = NO;
        wingmanActive = NO;
        isSceneLoading = YES;
        
        multiKey = @"multiKey";
        objectCreateKey = @"objectCreateKey";
        powerUpKey = @"powerUpKey";
        autocannonKey = @"autocannonKey";
        wingmanCannonKey = @"wingmanCannonKey";
        localTotalLaserHits = 0;
        localTotalLasersFired = 0;
        localTotalAsteroidHits = 0;
        localTotalDebrisHits = 0;
        localChallengePoints = 0;
        
        //Preload Sound Actions
        [self preloadSoundActions];
        
            //Set up Arrays
    }
    return self;
}

-(void)didMoveToView:(SKView *)view {
    NSMutableArray *textureAtlases = [NSMutableArray array];
    
    self.Asteroid_1_Atlas = [SKTextureAtlas atlasNamed:@"Asteroid-1"];
    
    [textureAtlases addObject:self.Asteroid_1_Atlas];
    
    [SKTextureAtlas preloadTextureAtlases:textureAtlases withCompletionHandler:^{
        [self setUpScene];
        isSceneLoading = NO;
    }];
}

-(void)setUpScene {
    NSMutableArray *Asteroid_1_Frames = [NSMutableArray array];
    for (int i=1; i <= _Asteroid_1_Atlas.textureNames.count; i++) {
        NSString *textureName = [NSString stringWithFormat:@"Asteroid-1-%d", i];
        SKTexture *temp = [_Asteroid_1_Atlas textureNamed:textureName];
        [Asteroid_1_Frames addObject:temp];
    }
    asteroid_1 = Asteroid_1_Frames;
    
    self.backgroundColor = [SKColor colorWithRed:0 green:0 blue:0 alpha:1];
    
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
    wingmanParent = [self createWingmanParent];
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
    
        //Set initial laser colors.
    playerLaserColorCast = [NWColor NWGreen];
    wingmanLaserColorCast = [NWColor NWGreen];
    
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
        //[self scoreTrack];
    
    [self tapToPlay];
    _score.text = @"Score: 0";
    
}

-(void)preloadSoundActions {
    _AutoCannonFire = [SKAction playSoundFileNamed:@"AutoCannon-Fire.caf" waitForCompletion:NO];
    _AutoCannonSpool = [SKAction playSoundFileNamed:@"AutoCannon-Spool.caf" waitForCompletion:NO];
    _CannonHitExplode = [SKAction playSoundFileNamed:@"Cannon-Hit-Explode.caf" waitForCompletion:NO];
    _Explosion = [SKAction playSoundFileNamed:@"Explosion.caf" waitForCompletion:NO];
    _MultiplierCollection = [SKAction playSoundFileNamed:@"Multiplier-Collection.caf" waitForCompletion:NO];
    _ScoreCollect = [SKAction playSoundFileNamed:@"Score-Collect.caf" waitForCompletion:NO];
    _ShieldPowerUp = [SKAction playSoundFileNamed:@"Shield-PowerUp.caf" waitForCompletion:NO];
    _ShieldBreak = [SKAction playSoundFileNamed:@"ShieldBreak.caf" waitForCompletion:NO];
    _ShieldCollision = [SKAction playSoundFileNamed:@"ShieldCollision.caf" waitForCompletion:NO];
    _ShipExplode = [SKAction playSoundFileNamed:@"Ship-Explode.caf" waitForCompletion:NO];
    _TinyNovaCollect = [SKAction playSoundFileNamed:@"TinyNova-Collect.caf" waitForCompletion:NO];
    _WingmanCollect = [SKAction playSoundFileNamed:@"Wingman-Collect.caf" waitForCompletion:NO];
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

-(Ships *)createWingmanParent {
    wingmanParent = [Ships node];
    wingmanParent.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:50];
    wingmanParent.position = CGPointMake(self.frame.size.width/5, self.frame.size.height/2);
    wingmanParent.physicsBody.dynamic = NO;
    wingmanParent.physicsBody.allowsRotation = YES;
    wingmanParent.physicsBody.categoryBitMask = 0;
    wingmanParent.physicsBody.contactTestBitMask = 0;
    wingmanParent.physicsBody.collisionBitMask = 0;
    
    return wingmanParent;
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
    playerNode.physicsBody.contactTestBitMask = CollisionCategoryBottom | CollisionCategoryObject | CollisionCategoryMulti | CollisionCategoryPup;
    
    return tempPlayer;
}

-(Ships *) createWingmanNode: (Ships *)tempWingman {
    wingmanNode = [[Ships alloc] initWithImageNamed:@"Nova-L1"];
    wingmanNode.position = CGPointMake(0, 0);
    wingmanNode.physicsBody.categoryBitMask = CollisionCategoryPlayer;
    wingmanNode.physicsBody.collisionBitMask = 0;
    wingmanNode.physicsBody.contactTestBitMask = CollisionCategoryBottom | CollisionCategoryObject | CollisionCategoryMulti | CollisionCategoryPup;
    
    return tempWingman;
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
    SKTexture *temp = asteroid_1[0];
    SKSpriteNode *obstacle = [SKSpriteNode spriteNodeWithTexture:temp];
    
    int tempRand = arc4random()%80;
    double randYPosition = (tempRand+10)/100.0;
    obstacle.position = CGPointMake(self.size.width+obstacle.size.width, self.size.height*randYPosition);
    //obstacle.name = @"aerial";
    obstacle.zPosition = 10;
    
    int tempRand2 = arc4random()%200;
    double randScale = (tempRand2-100)/10000.0;
    obstacle.xScale = 0.4 + randScale;
    obstacle.yScale = 0.4 + randScale;
    
    obstacle.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:obstacle.size.height/2];
    [self objectPhysicsStandards: obstacle];
    obstacle.name = @"asteroid";
    
    [self addChild: obstacle];
    [obstacle runAction:[SKAction repeatActionForever:
                         [SKAction animateWithTextures:asteroid_1
                                          timePerFrame:0.06f
                                                resize:NO
                                               restore:YES]] withKey:@"Asteroid 1 Animate"];
    [self moveAerialNode:obstacle allowsRotation:YES];
}

-(void)asteroid2 {
    
    SKSpriteNode *obstacle = [SKSpriteNode spriteNodeWithImageNamed:@"L1-AOb-2"];
    
    int tempRand = arc4random()%80;
    double randYPosition = (tempRand+10)/100.0;
    obstacle.position = CGPointMake(self.size.width+obstacle.size.width, self.size.height*randYPosition);
    obstacle.anchorPoint = CGPointZero;
    obstacle.zPosition = 10;
    obstacle.xScale = 0.4;
    obstacle.yScale = 0.4;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, 5, 5);
    CGPathAddLineToPoint(path, NULL, 50, 5);
    CGPathAddLineToPoint(path, NULL, 55, 15);
    CGPathAddLineToPoint(path, NULL, 50, 25);
    CGPathAddLineToPoint(path, NULL, 10, 25);
    
    CGPathCloseSubpath(path);
    
    obstacle.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
    [self objectPhysicsStandards: obstacle];
    obstacle.name = @"asteroid";
    
    [self addChild: obstacle];
    [self moveAerialNode:obstacle allowsRotation:YES];
}

-(void)asteroid3 {
    SKSpriteNode *obstacle = [SKSpriteNode spriteNodeWithImageNamed:@"L1-AOb-3"];
    
    int tempRand = arc4random()%80;
    double randYPosition = (tempRand+10)/100.0;
    obstacle.position = CGPointMake(self.size.width+obstacle.size.width, self.size.height*randYPosition);
    //obstacle.name = @"aerial";
    obstacle.zPosition = 10;
    
    int tempRand2 = arc4random()%100;
    double randScale = (tempRand2)/1000.0;
    obstacle.xScale = 0.4 + randScale;
    obstacle.yScale = 0.4 + randScale;
    
    obstacle.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:obstacle.size.height/2];
    [self objectPhysicsStandards: obstacle];
    obstacle.name = @"asteroid";
    
    [self addChild: obstacle];
    [self moveAerialNode:obstacle allowsRotation:YES];
}

-(void)asteroid4 {
    
    SKSpriteNode *obstacle = [SKSpriteNode spriteNodeWithImageNamed:@"L1-AOb-4"];
    
    int tempRand = arc4random()%80;
    double randYPosition = (tempRand+10)/100.0;
    obstacle.position = CGPointMake(self.size.width+obstacle.size.width, self.size.height*randYPosition);
    //obstacle.name = @"aerial";
    obstacle.zPosition = 10;
    
    int tempRand2 = arc4random()%100;
    double randScale = (tempRand2)/1000.0;
    obstacle.xScale = 0.4 + randScale;
    obstacle.yScale = 0.4 + randScale;
    
    obstacle.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:obstacle.size.height/2];
    [self objectPhysicsStandards: obstacle];
    obstacle.name = @"red_asteroid";
    
    [self addChild: obstacle];
    [self moveAerialNode:obstacle allowsRotation:YES];
}

-(void)shipChunk {
    SKSpriteNode *obstacle = [SKSpriteNode spriteNodeWithImageNamed:@"Ship-Chunk-1"];
    
    int tempRand = arc4random()%80;
    double randYPosition = (tempRand+10)/100.0;
    obstacle.position = CGPointMake(self.size.width+obstacle.size.width, self.size.height*randYPosition);
    obstacle.anchorPoint = CGPointZero;
    obstacle.zPosition = 10;
    obstacle.xScale = 0.5;
    obstacle.yScale = 0.5;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, 10, 0);
    CGPathAddLineToPoint(path, NULL, 50, 20);
    CGPathAddLineToPoint(path, NULL, 60, 60);
    CGPathAddLineToPoint(path, NULL, 50, 60);
    CGPathAddLineToPoint(path, NULL, 10, 20);
    
    CGPathCloseSubpath(path);
    
    obstacle.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
    [self objectPhysicsStandards: obstacle];
    obstacle.name = @"debris";
    
    [self addChild: obstacle];
    [self moveAerialNode:obstacle allowsRotation: YES];
}

-(void)objectPhysicsStandards: (SKSpriteNode *)object {
    object.physicsBody.categoryBitMask = CollisionCategoryObject;
    object.physicsBody.dynamic = YES;
    object.physicsBody.affectedByGravity = NO;
    object.physicsBody.collisionBitMask = CollisionCategoryObject;
    object.physicsBody.friction = 0.2f;
    object.physicsBody.restitution = 0.0f;
    object.physicsBody.linearDamping = 0.0;
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
    _score.text = [NSString stringWithFormat:@"Score: %li", [GameState sharedGameData].score];
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

-(void)scorePlusLaser: (SKSpriteNode *)hitObject {
    SKLabelNode *plusOne = [SKLabelNode labelNodeWithFontNamed:@"SF Movie Poster"];
    plusOne.position = CGPointMake(MIN(hitObject.position.x, self.size.width-25), hitObject.position.y);
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
    [self playSoundEffectsWithAction:_MultiplierCollection];
    
    [trail removeFromParent];
    [wingmanTrail removeFromParent];
    
    SKShapeNode *flash = [Multipliers createFlash];
    flash.path = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, self.size.width, self.size.height)].CGPath;
    flash.position = CGPointMake(0, 0);
    [self addChild:flash];
    [Multipliers popActionWithNode:flash];
    
    //Create Main Player Trail
    trail = [Multipliers createShipTrail];
    trail.position = CGPointMake(-30, 8);
    trail.zPosition = 1;
    trail.targetNode = self.scene;
    trail.name = @"particleTrail";
    [playerNode addChild:trail];
    
    //Create Wingman Trail
    wingmanTrail = [Multipliers createShipTrail];
    wingmanTrail.position = CGPointMake(trail.position.x,trail.position.y);
    wingmanTrail.zPosition = trail.zPosition;
    wingmanTrail.targetNode = trail.targetNode;
    wingmanTrail.name = trail.name;
    [wingmanNode addChild:wingmanTrail];
    
    switch ([GameState sharedGameData].scoreMultiplier) {
        case 1:
            [[self childNodeWithName:@"multiplier"] removeFromParent];
            [GameState sharedGameData].scoreMultiplier ++;
            [self removeActionForKey:objectCreateKey];
            [self initializeObstaclesWithInterval:0.35];
            break;
        case 2:
            [[self childNodeWithName:@"multiplier"] removeFromParent];
            [GameState sharedGameData].scoreMultiplier ++;
            [self removeActionForKey:objectCreateKey];
            [self initializeObstaclesWithInterval:0.3];
            break;
        case 3:
            [[self childNodeWithName:@"multiplier"] removeFromParent];
            [GameState sharedGameData].scoreMultiplier ++;
            [self removeActionForKey:objectCreateKey];
            [self initializeObstaclesWithInterval:0.28];
            break;
        case 4:
            [[self childNodeWithName:@"multiplier"] removeFromParent];
            [GameState sharedGameData].scoreMultiplier ++;
            [self removeActionForKey:objectCreateKey];
            [self initializeObstaclesWithInterval:0.27];
            [self removeActionForKey:multiKey];
            break;
        default:
            break;
    }
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
    double aerialSpeed = 0.9 - ([GameState sharedGameData].scoreMultiplier/10);
    
    int tempRand = arc4random()%150;
    double randDuration = (tempRand-100)/1000.0;
    double totalDuration = aerialSpeed + randDuration;
    
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

#pragma mark --Power Ups

#define MULTI_INTERVAL 2.7

-(void)initializeMultipliers {
    SKAction *wait = [SKAction waitForDuration:MULTI_INTERVAL];
    SKAction *run = [SKAction runBlock:^{
        [self createMultiplier];
    }];
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[wait,run]]] withKey:multiKey];
}

-(void)createMultiplier {
    int tempRand = arc4random()%80;
    double randYPosition = (tempRand+10)/100.0;
    
    SKSpriteNode *multiplier = [Multipliers createMultiplier];
    multiplier.position = CGPointMake(self.size.width + multiplier.size.width, self.size.height * randYPosition);
    multiplier.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: multiplier.size];
    multiplier.physicsBody.categoryBitMask = CollisionCategoryMulti;
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

-(void)initializePowerUps {
    SKAction *wait = [SKAction waitForDuration:5.0];
    SKAction *run = [SKAction runBlock:^{
        [self createPowerUp];
    }];
    
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[wait, run]]] withKey:@"pupRun"];
}

-(void)createPowerUp {
    
    if (!activePup) {
        int tempRand = arc4random()%80;
        double randYPos = (tempRand + 10) / 100.0;
        
        powerUp = [[PowerUps alloc] powerUpTypes];
        SKSpriteNode *Pup = [PowerUps createPupsWithType:powerUp];
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
            [self wingmanRun];
            break;
        case Over_shield:
            [self createPupTitleWithText:@"Overshield!"];
            [self overShield];
            break;
        case Auto_Cannon:
            [self createPupTitleWithText:@"Auto Cannon!"];
            [self autoCannonRunFromPlayer:playerParent withColor: playerLaserColorCast withKey:autocannonKey];
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

-(void)wingmanRun {
    [self playSoundEffectsWithAction:_WingmanCollect];
    //Pop color.
    SKShapeNode *flash = [SKShapeNode node];
    flash.fillColor = [SKColor colorWithRed:0.67 green:0.05 blue:0.05 alpha:1]; //Deep red.
    flash.alpha = 0;
    flash.zPosition = 103;
    flash.path = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, self.size.width, self.size.height)].CGPath;
    flash.position = CGPointMake(0, 0);
    [self addChild:flash];
    [Multipliers popActionWithNode:flash];
    
    //Create wingman laser colors.
    int tempInt = arc4random() % 6;
    switch (tempInt) {
        case 1:
            wingmanLaserColorCast = [NWColor NWBlue];
            break;
        case 2:
            wingmanLaserColorCast = [NWColor NWRed];
            break;
        case 3:
            wingmanLaserColorCast = [NWColor NWGreen];
            break;
        case 4:
            wingmanLaserColorCast = [NWColor NWPurple];
            break;
        case 5:
            wingmanLaserColorCast = [NWColor NWYellow];
            break;
        case 6:
            wingmanLaserColorCast = [NWColor NWSilver];
            break;
        default:
            break;
    }
    
    //Create wingmanNode and wingmanParent.
    [self createWingmanNode: wingmanNode];
    wingmanNode.physicsBody.allowsRotation = YES;
    wingmanNode.physicsBody.dynamic = YES;
    wingmanParent.physicsBody.allowsRotation = YES;
    wingmanParent.physicsBody.dynamic = YES;
    [self addChild:wingmanParent];
    [wingmanParent addChild:wingmanNode];
    wingmanParent.name = @"wingman";
    wingmanParent.alpha = 1;
    wingmanParent.position = CGPointMake(playerParent.position.x, playerParent.position.y + 150); //Shift wingmanParent upward 150 pix from original location.
    wingmanParent.zRotation = playerParent.zRotation;
    
    //Add particle trail if existent.
    if ([GameState sharedGameData].scoreMultiplier > 1) {
        [wingmanNode addChild:wingmanTrail];
    }
    
    //Create spring joint & add to physicsWorld.
    //Physics Joint
    SKPhysicsJointFixed *test = [SKPhysicsJointFixed jointWithBodyA:wingmanParent.physicsBody bodyB:wingmanNode.physicsBody anchor:CGPointMake(wingmanParent.position.x+50, wingmanParent.position.y+50)];
    [self.physicsWorld addJoint:test];
    wingmanSpring = [SKPhysicsJointSpring jointWithBodyA:playerNode.physicsBody bodyB:wingmanNode.physicsBody anchorA:CGPointMake(playerParent.position.x+playerParent.size.width/2, playerParent.position.y+playerParent.size.height/2) anchorB:CGPointMake(wingmanParent.position.x+wingmanParent.size.width/2, wingmanParent.position.y+wingmanParent.size.height/2)];
    [self.physicsWorld addJoint:wingmanSpring];
    
    //Set variables to reflect state.
    activePup = YES;
    wingmanActive = YES;
    [self makeNodeSafe:playerNode];
    [self makeNodeSafe:wingmanNode];
    //wingmanParent.alpha = 0.5;
    [PowerUps wingmanInvincibilityFlicker:playerParent];
    [PowerUps wingmanInvincibilityFlicker:wingmanParent];
    
    //Time 2 second safe period
    SKAction *wait = [SKAction waitForDuration:2.0];
    SKAction *activate = [SKAction runBlock:^{
        [self makePlayerNodeActive:playerNode];
        [self makePlayerNodeActive:wingmanNode];
    }];
    [self runAction:[SKAction sequence:@[wait, activate]]];
    
    //Run autocannon from each player.
    SKAction *wingmanCannonWait = [SKAction waitForDuration:0.15];
    SKAction *wingmanCannonRunBlock = [SKAction runBlock:^{
        [self autoCannonRunFromPlayer:wingmanParent withColor:wingmanLaserColorCast withKey:wingmanCannonKey];
    }];
    SKAction *wingmanCannonRun = [SKAction sequence:@[wingmanCannonWait,wingmanCannonRunBlock]];
    [self runAction:wingmanCannonRun];
    
    SKAction *playerCannonRunBlock = [SKAction runBlock:^{
        [self autoCannonRunFromPlayer:playerParent withColor:playerLaserColorCast withKey:autocannonKey];
    }];
    [self runAction:playerCannonRunBlock];
    
}

-(void)makeNodeSafe: (SKSpriteNode *)node {
    //node.physicsBody.categoryBitMask = 0;
    node.physicsBody.contactTestBitMask = CollisionCategoryBottom | CollisionCategoryMulti | CollisionCategoryPup;
}

-(void)makePlayerNodeActive: (SKSpriteNode *)node {
    //node.physicsBody.categoryBitMask = CollisionCategoryPlayer;
    node.physicsBody.contactTestBitMask = CollisionCategoryBottom | CollisionCategoryObject | CollisionCategoryMulti | CollisionCategoryPup;
}

-(void)wingmanRemove: (SKSpriteNode *)nodeToRemove objectRemove:(SKSpriteNode *)objectToRemove {
    //Pop color.
    SKShapeNode *flash = [SKShapeNode node];
    flash.fillColor = [SKColor colorWithRed:0.97 green:0.79 blue:0.22 alpha:1]; //Gold.
    flash.alpha = 0;
    flash.zPosition = 103;
    flash.path = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, self.size.width, self.size.height)].CGPath;
    flash.position = CGPointMake(0, 0);
    [self addChild:flash];
    [Multipliers popActionWithNode:flash];
    
    [objectToRemove removeFromParent];
    
    if ([nodeToRemove.parent.name isEqual:@"wingman"]) {
        //Remove wingman.
        [wingmanNode removeFromParent];
        [wingmanParent removeFromParent];
    } else {
        //Swap player & wingman.
        playerParent.physicsBody.dynamic = NO;
        playerNode.physicsBody.dynamic = NO;
        SKAction *movePlayerParentToWingmansPosition = [SKAction moveBy:CGVectorMake(0, wingmanParent.position.y-playerParent.position.y) duration:0.0];
        SKAction *rotatePlayerParentToWingmansRotation = [SKAction rotateToAngle:wingmanParent.zRotation duration:0.0];
        SKAction *swapGroup = [SKAction group: @[movePlayerParentToWingmansPosition, rotatePlayerParentToWingmansRotation]];
        [playerParent runAction:swapGroup];
        playerParent.physicsBody.dynamic = YES;
        playerNode.physicsBody.dynamic = YES;
        
        //Update laser color casting to match wingman that survived.  Update new wingman color casting.
        playerLaserColorCast = wingmanLaserColorCast;
        
        [wingmanNode removeFromParent];
        [wingmanParent removeFromParent];
    }
    
    [self.physicsWorld removeJoint:wingmanSpring];
    [self removeActionForKey:autocannonKey];
    [self removeActionForKey:wingmanCannonKey];
    
    //Safe remaining player & update globals.
    activePup = NO;
    wingmanActive = NO;
    [self makeNodeSafe:playerNode];
    [self makeNodeSafe:wingmanNode];
    [PowerUps wingmanInvincibilityFlicker:playerParent];
    //Time 2 second safe period
    SKAction *wait = [SKAction waitForDuration:2.0];
    SKAction *activate = [SKAction runBlock:^{
        [self makePlayerNodeActive:playerNode];
        [self makePlayerNodeActive:wingmanNode];
    }];
    [self runAction:[SKAction sequence:@[wait, activate]]];
}

-(void)wingmanRemoveCollideWithBottom {
    //Pop color.
    SKShapeNode *flash = [SKShapeNode node];
    flash.fillColor = [SKColor colorWithRed:0.97 green:0.79 blue:0.22 alpha:1]; //Gold.
    flash.zPosition = 103;
    flash.path = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, self.size.width, self.size.height)].CGPath;
    flash.position = CGPointMake(0, 0);
    [self addChild:flash];
    [Multipliers popActionWithNode:flash];
    
    //Swap player & wingman.
    playerParent.physicsBody.dynamic = NO;
    playerNode.physicsBody.dynamic = NO;
    SKAction *movePlayerParentToWingmansPosition = [SKAction moveBy:CGVectorMake(0, wingmanParent.position.y-playerParent.position.y) duration:0.0];
    SKAction *rotatePlayerParentToWingmansRotation = [SKAction rotateToAngle:wingmanParent.zRotation duration:0.0];
    SKAction *swapGroup = [SKAction group: @[movePlayerParentToWingmansPosition, rotatePlayerParentToWingmansRotation]];
    [playerParent runAction:swapGroup];
    playerParent.physicsBody.dynamic = YES;
    playerNode.physicsBody.dynamic = YES;
    
    //Update laser color casting to match wingman that survived.  Update new wingman color casting.
    playerLaserColorCast = wingmanLaserColorCast;
    int tempInt = arc4random()%6;
    switch (tempInt) {
        case 1:
            wingmanLaserColorCast = [NWColor NWBlue];
            break;
        case 2:
            wingmanLaserColorCast = [NWColor NWRed];
            break;
        case 3:
            wingmanLaserColorCast = [NWColor NWGreen];
            break;
        case 4:
            wingmanLaserColorCast = [NWColor NWPurple];
            break;
        case 5:
            wingmanLaserColorCast = [NWColor NWYellow];
            break;
        case 6:
            wingmanLaserColorCast = [NWColor NWSilver];
            break;
        default:
            break;
    }
    
    [self.physicsWorld removeJoint:wingmanSpring];
    [wingmanNode removeFromParent];
    [wingmanParent removeFromParent];
    [self removeActionForKey:autocannonKey];
    [self removeActionForKey:wingmanCannonKey];
    
    //Safe remaining player & update globals.
    activePup = NO;
    wingmanActive = NO;
    [self makeNodeSafe:playerNode];
    //[self makeNodeSafe:wingmanNode];
    [PowerUps wingmanInvincibilityFlicker:playerParent];
    //Time 2 second safe period
    SKAction *wait = [SKAction waitForDuration:2.0];
    SKAction *activate = [SKAction runBlock:^{
        [self makePlayerNodeActive:playerNode];
        //[self makePlayerNodeActive:wingmanNode];
    }];
    [self runAction:[SKAction sequence:@[wait, activate]]];
}

-(void)tinyNova {
    [self playSoundEffectsWithAction:_TinyNovaCollect];
    [playerNode logicTinyNova];
    activePup = YES;
    
    SKAction *wait = [SKAction waitForDuration:10.0];
    SKAction *closeTinyNova = [SKAction runBlock:^{
        [playerNode closeTinyNova];
        activePup = NO;
    }];
    [self runAction:[SKAction sequence:@[wait,closeTinyNova]]];
}

-(void)autoCannonRunFromPlayer: (Ships *)tempPlayer withColor: (SKColor *)tempColor withKey: (NSString *)tempKey {
    localLaserHits = 0;
    
    [self playSoundEffectsWithAction:_AutoCannonSpool];
    
    //Time firing function
    SKAction *wait = [SKAction waitForDuration:AUTOCANNON_INTERVAL];
    SKAction *fire = [SKAction runBlock:^{
        [self autoCannonFireFromPlayer:tempPlayer withColor:tempColor];
        [self playSoundEffectsWithAction:_AutoCannonFire];
    }];
    SKAction *run = [SKAction repeatAction: [SKAction sequence:@[wait, fire]] count:AUTOCANNON_SHOTS_FIRED];
    SKAction *close = [SKAction runBlock:^{
        [self autoCannonFinish];
    }];
    SKAction *autocannon = [SKAction sequence:@[run, close]];
    [self runAction:autocannon withKey:tempKey];
    
    activePup = YES;
}

-(void)autoCannonFireFromPlayer: (Ships *)tempPlayer withColor: (SKColor *)tempColor {
    SKSpriteNode *laser = [PowerUps autoCannonFire:tempPlayer withColor:tempColor];
    laser.position = CGPointMake(tempPlayer.position.x, tempPlayer.position.y);
    laser.zRotation = tempPlayer.zRotation;
    laser.physicsBody.categoryBitMask = CollisionCategoryLaser;
    laser.physicsBody.collisionBitMask = 0;
    laser.physicsBody.contactTestBitMask = CollisionCategoryObject;
    laser.name = @"laser";
    [self addChild:laser];
    [PowerUps animateLaser:laser withWidth: self.size.width];
    
    localTotalLasersFired = localTotalLasersFired + 1;
}

-(void)laserContactRemove: (SKSpriteNode *)firstNodeToRemove andRemove: (SKSpriteNode *)secondNodeToRemove {
    [self playSoundEffectsWithAction:_CannonHitExplode];
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
    if (!wingmanActive) {
        activePup = NO;
    }
    [GameState sharedGameData].maxLaserHits = MAX([GameState sharedGameData].maxLaserHits, localLaserHits);
}

-(void)overShield {
    [self playSoundEffectsWithAction:_ShieldPowerUp];
    
    shield = [SKSpriteNode spriteNodeWithImageNamed:@"Shield"];
    shield.xScale = 1.2;
    shield.yScale = 1.2;
    shield.zPosition = 111;
    shield.alpha = 1.0;
    
    CGFloat offsetX = (shield.frame.size.width * 1.2) * shield.anchorPoint.x;
    CGFloat offsetY = (shield.frame.size.height * 1.2) * shield.anchorPoint.y;
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, 5 - offsetX, 45 - offsetY);
    CGPathAddLineToPoint(path, NULL, 22 - offsetX, 13 - offsetY);
    CGPathAddLineToPoint(path, NULL, 64 - offsetX, 3 - offsetY);
    CGPathAddLineToPoint(path, NULL, 100 - offsetX, 23 - offsetY);
    CGPathAddLineToPoint(path, NULL, 79 - offsetX, 61 - offsetY);
    CGPathAddLineToPoint(path, NULL, 35 - offsetX, 70 - offsetY);
    
    CGPathCloseSubpath(path);
    
    shield.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
    
    CGPathRelease(path);
    
    shield.physicsBody.dynamic = YES;
    shield.physicsBody.restitution = 0.0f;
    shield.physicsBody.friction = 0.1f;
    shield.physicsBody.linearDamping = 1.0f;
    shield.physicsBody.allowsRotation = NO;
    shield.physicsBody.affectedByGravity = NO;
    shield.physicsBody.usesPreciseCollisionDetection = YES;
    shield.physicsBody.categoryBitMask = CollisionCategoryShield;
    shield.physicsBody.collisionBitMask = 0;
    shield.physicsBody.contactTestBitMask = CollisionCategoryObject;
    shield.name = @"shield";
    
    [playerParent addChild:shield];
    SKPhysicsJointFixed *shieldJoint = [SKPhysicsJointFixed jointWithBodyA:playerParent.physicsBody bodyB:shield.physicsBody anchor:CGPointMake(playerParent.position.x, playerParent.position.y)];
    [self.physicsWorld addJoint:shieldJoint];
    
    playerNode.physicsBody.contactTestBitMask = CollisionCategoryBottom  | CollisionCategoryMulti;
    shieldIndex = 0;
    activePup = YES;
}

-(void)collideOvershieldandRemove: (SKSpriteNode *)object {
    if (shieldIndex < 3 ) {
        if (shieldIndex < 2) {
            [self playSoundEffectsWithAction:_ShieldCollision];
        } else {
            [self playSoundEffectsWithAction:_ShieldBreak];
        }
        SKShapeNode *flash = [SKShapeNode node];
        flash.path = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, self.size.width, self.size.height)].CGPath;
        flash.position = CGPointMake(0, 0);
        flash.zPosition = 111;
        flash.fillColor = [NWColor NWShieldHit];
        [self addChild:flash];
        [Multipliers popActionWithNode:flash];
        
        [object removeFromParent];
        shield.alpha = shield.alpha - 0.3;
        shieldIndex ++;
        
        if(shieldIndex == 3) {
            [shield removeFromParent];
            playerNode.physicsBody.contactTestBitMask = CollisionCategoryBottom | CollisionCategoryObject | CollisionCategoryMulti | CollisionCategoryPup;
            activePup = NO;
        }
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
            [self initializeMultipliers];
            [self initializePowerUps];
            [playerParent removeActionForKey:@"bobbingAction"];
        }
        
        [playerParent thrustPlayer:playerParent withHeight:self.size.height];
        if (wingmanActive == YES) {
            float tempheight = self.size.height + 50;
            [wingmanParent thrustPlayer:wingmanParent withHeight:tempheight];
        }

        [playerParent rotateNodeUpwards:playerParent];
        if (wingmanActive == YES) {
            [wingmanParent rotateNodeUpwards:wingmanParent];
        }
    }
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"playButton"]) {
        playAgain.texture = [SKTexture textureWithImageNamed:@"buttonPressPlay"];
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
        
        playAgain.texture = [SKTexture textureWithImageNamed:@"buttonPlay"];
        SKColor *fadeColor = [SKColor colorWithRed:0 green:0 blue:0 alpha:1];
        
        SKView * levelOneView = (SKView *)self.view;
        levelOneView.showsFPS = YES;
        levelOneView.showsNodeCount = YES;
        
            // Create and configure the scene.
        SKScene * levelOneScene = [[LevelOne alloc] initWithSize:levelOneView.bounds.size];
        levelOneScene.scaleMode = SKSceneScaleModeAspectFill;
        SKTransition *levelOneTrans = [SKTransition fadeWithColor:fadeColor duration:0.5];
        
            // Present the scene.
        [levelOneView presentScene:levelOneScene transition:levelOneTrans];
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
    
    if (wingmanParent.physicsBody.velocity.dy < 0) {
        [wingmanParent rotateNodeDownwards:wingmanParent];
    }
    
    /*if ([self childNodeWithName:@"aerial"].position.x < self.size.width / 2) {
        [[self childNodeWithName:@"aerial"].physicsBody applyImpulse:CGVectorMake(0, -0.2)];
    }
    
    if ([self childNodeWithName:@"aerial"].position.x < playerParent.position.x - playerParent.size.width && [self childNodeWithName:@"aerial"].position.x > 1)
    {
        [self childNodeWithName:@"aerial"].name = @"aerialClose";
    }
    
    if ([self childNodeWithName:@"aerialClose"].position.x < -self.size.width / 2) {
        [[self childNodeWithName:@"aerialClose"] removeFromParent];
    }*/
}

#pragma mark --Game Over

-(void)gameOver {
    //Update GameState data & stats tracking.
    [GameState sharedGameData].highScoreL1 = MAX([GameState sharedGameData].score, [GameState sharedGameData].highScoreL1);
    [GameState sharedGameData].totalLaserHits = [GameState sharedGameData].totalLaserHits + localTotalLaserHits;
    [GameState sharedGameData].totalLasersFired = [GameState sharedGameData].totalLasersFired + localTotalLasersFired;
    [GameState sharedGameData].totalAsteroidsDestroyed = [GameState sharedGameData].totalAsteroidsDestroyed + localTotalAsteroidHits;
    [GameState sharedGameData].totalDebrisDestroyed = [GameState sharedGameData].totalDebrisDestroyed + localTotalDebrisHits;
    [GameState sharedGameData].totalChallengePoints = [GameState sharedGameData].totalChallengePoints + localChallengePoints;
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
}

-(void)gameOverComplete {

    [self addChild:[self backToMenu]];
    [self createCurrentScore];
    [self createHighScore];
    [self playAgainButton];
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
    curScore.text = [NSString stringWithFormat:@"SCORE: %li", [GameState sharedGameData].score];
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
        [self vibrate];
        [self playSoundEffectsWithAction:_ShipExplode];
            if (wingmanActive == YES) {
                //Run wingman or player removal
                [self wingmanRemove:firstNode objectRemove:secondNode];
            } else {
                [self gameOver];
            }
        if ([secondNode.name isEqualToString:@"asteroid"] || [secondNode.name isEqualToString:@"red_asteroid"]) {
            [GameState sharedGameData].totalAsteroidDeaths = [GameState sharedGameData].totalAsteroidDeaths + 1;
        } else if ([secondNode.name isEqualToString:@"debris"]) {
            [GameState sharedGameData].totalDebrisDeaths = [GameState sharedGameData].totalDebrisDeaths + 1;
        }
        
    }
    
    if (firstBody.categoryBitMask == CollisionCategoryPlayer && secondBody.categoryBitMask == CollisionCategoryBottom) {
        [self vibrate];
        [self playSoundEffectsWithAction:_ShipExplode];
        if (wingmanActive == YES) {
            //Run wingman removal.
            [self wingmanRemoveCollideWithBottom];
        } else {
            [self gameOver];
        }
        [GameState sharedGameData].totalBlackHoleDeaths = [GameState sharedGameData].totalBlackHoleDeaths + 1;
    }
    
    if (firstBody.categoryBitMask == CollisionCategoryPlayer && secondBody.categoryBitMask == CollisionCategoryMulti) {
        [self scoreMulti];
        }
    
    if (firstBody.categoryBitMask == CollisionCategoryPlayer && secondBody.categoryBitMask == CollisionCategoryPup) {
        [self checkPup];
    }
    
    if (firstBody.categoryBitMask == CollisionCategoryLaser && secondBody.categoryBitMask == CollisionCategoryObject) {
        [self scorePlusLaser: secondNode];
        [self laserContactRemove:firstNode andRemove:secondNode];
        localTotalLaserHits = localTotalLaserHits + 1;
        
        if ([secondNode.name isEqualToString:@"asteroid"]) {
            localTotalAsteroidHits = localTotalAsteroidHits + 1;
        } else if ([secondNode.name isEqualToString:@"debris"]) {
            localTotalDebrisHits = localTotalDebrisHits + 1;
        } else if ([secondNode.name isEqualToString:@"red_asteroid"]) {
            localChallengePoints = localChallengePoints + 1;
        }
        
    }
    
    if (firstBody.categoryBitMask == CollisionCategoryShield && secondBody.categoryBitMask == CollisionCategoryObject) {
        [self vibrate];
        [self collideOvershieldandRemove: secondNode];
        [self scoreAddWithMultiplier:1];
        [self scorePlusWithMultiplier:1 fromNode:secondNode];
    }
    
    if (firstBody.categoryBitMask == CollisionCategoryScore && secondBody.categoryBitMask == CollisionCategoryObject) {
        //Object has passed scoring threshold.  Run score function.
        if (wingmanActive) {
            [self scoreAddWithMultiplier:2];
            [self scorePlusWithMultiplier:2 fromNode:secondNode];
        } else {
            [self scoreAddWithMultiplier:1];
            [self scorePlusWithMultiplier:1 fromNode:secondNode];
        }
        secondNode.physicsBody.categoryBitMask = 0;
    }
}

@end
