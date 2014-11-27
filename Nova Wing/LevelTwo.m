//
//  levelTwo.m
//  Nova Wing
//
//  Created by Bryan Frank on 8/11/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import "LevelTwo.h"
#import "GameOver.h"
#import "Obstacles.h"

@interface LevelTwo() <SKPhysicsContactDelegate>
{
    Ships *_player;
    Ships *playerNode;
}

@property (nonatomic, strong) PBParallaxScrolling * parallaxBackground;

@end

static const float FG_VELOCITY = -175.0;

static inline CGPoint CGPointAdd(const CGPoint a, const CGPoint b)
{
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint CGPointMultiplyScalar(const CGPoint a, const CGFloat b)
{
    return CGPointMake(a.x * b, a.y * b);
}

SKLabelNode *tapPlay;

@implementation LevelTwo

NSTimeInterval _lastUpdateTime;
NSTimeInterval _dt;
SKLabelNode* _score;
NSTimer *scoreUpdate;
NSTimer *pillarCreateTimer;
NSTimer *aerialCreateTimer;

#pragma mark --Create Background

-(id)initWithSize:(CGSize)size andDirection:(PBParallaxBackgroundDirection)direction {
    if (self = [super initWithSize:size]) {
        
        [GameState sharedGameData].scoreMultiplier = 1;
        self.physicsWorld.gravity = CGVectorMake(0.0f, -5.0f);
        self.physicsWorld.contactDelegate = self;
        self.scaleMode = SKSceneScaleModeAspectFit;
        self.direction = kPBParallaxBackgroundDirectionLeft;
        
        SKTexture *midBG = [SKTexture textureWithImageNamed:@"Level-1-Mid"];
        SKTexture *farBG = [SKTexture textureWithImageNamed:@"Level-1-Far"];
        SKTexture *skyBG = [SKTexture textureWithImageNamed:@"Level-1-Sky"];
        
        NSArray * imageNames;
        imageNames = @[midBG, farBG, skyBG];
        PBParallaxScrolling * parallax = [[PBParallaxScrolling alloc] initWithBackgrounds:imageNames size:size direction:kPBParallaxBackgroundDirectionLeft fastestSpeed:3 andSpeedDecrease:1];
        self.parallaxBackground = parallax;
        [self addChild:parallax];
        
        _player = [self createPlayerNode];
        
        [self createAudio];
        
        [self createScoreNode];
        [self addChild:_player];
        [playerNode shipBobbing:_player];
        [self createFloor];
        [self tapToPlay];
        
        _score.text = @"Score: 0";
    }
    return self;
}


-(Ships *) createPlayerNode
{
    playerNode = [[Ships alloc] initWithImageNamed:@"Nova-L1"];
    playerNode.position = CGPointMake(self.frame.size.width/5, self.frame.size.height/2);
    playerNode.physicsBody.categoryBitMask = CollisionCategoryPlayer;
    playerNode.physicsBody.collisionBitMask = 0;
    playerNode.physicsBody.contactTestBitMask = CollisionCategoryObject;
    
    return playerNode;
}

-(void) anyPillarCreate
{
    int tempObjectSelector = arc4random()%12;
    switch (tempObjectSelector)
    {
        case 1:
            break;
        case 2:
        case 3:
            [self rockPillar1];
            break;
        case 4:
            break;
        case 5:
        case 6:
            [self rockPillar2];
            break;
        case 7:
            break;
        case 8:
        case 9:
            [self geyserPillar];
            break;
        case 10:
            break;
        case 11:
        case 12:
            [self radioPillar];
            break;
        default:
            break;
    }
    
}

-(void)rockPillar1 {
    SKSpriteNode *pillar = [SKSpriteNode spriteNodeWithImageNamed:@"Pillar-1"];
    pillar.name = @"pillar";
    pillar.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: pillar.size];

    [self createPillarWith: pillar];
    [self addChild:pillar];
    [self movePillar:pillar];
}

-(void)rockPillar2 {
    SKSpriteNode *pillar = [SKSpriteNode spriteNodeWithImageNamed:@"Pillar-2"];
    pillar.name = @"pillar";
    pillar.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: pillar.size];

    [self createPillarWith: pillar];
    [self addChild:pillar];
    [self movePillar:pillar];
}

-(void)geyserPillar {
    SKSpriteNode *pillar = [SKSpriteNode spriteNodeWithImageNamed:@"Pillar-3"];
    //pillar.anchorPoint = CGPointZero;
    //pillar.position = CGPointMake(1.5 * self.size.width, 10);
    pillar.name = @"pillar";
    pillar.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: pillar.size /*center:CGPointMake(pillar.size.width / 2, pillar.size.height / 2)*/];
    //pillar.physicsBody.dynamic = NO;
    //pillar.physicsBody.allowsRotation = NO;
    
    [self createPillarWith:pillar];
    [self addChild:pillar];
    [self movePillar:pillar];
}

-(void)radioPillar {
    SKSpriteNode *pillar = [SKSpriteNode spriteNodeWithImageNamed:@"Pillar-4"];
    pillar.name = @"pillar";
    pillar.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: pillar.size];
    
    [self createPillarWith: pillar];
    [self addChild:pillar];
    [self movePillar:pillar];
}

-(void)createPillarWith: (SKSpriteNode *)pillar {
    int pillarPosMod = arc4random()%150;
    pillar.position = CGPointMake(1.5 * self.size.width, (-pillar.size.height / 5) + pillarPosMod);
    
    pillar.physicsBody.dynamic = NO;
    pillar.physicsBody.allowsRotation = NO;
    pillar.physicsBody.categoryBitMask = CollisionCategoryObject;
    pillar.physicsBody.collisionBitMask = 0;
}

-(void) createAerial{
    int tempObjectSelector = arc4random()%12;
    switch (tempObjectSelector)
    {
        case 1:
            break;
        case 2:
        case 3:
            [self createAObj1];
            break;
        case 4:
            break;
        case 5:
        case 6:
            [self createAObj2];
            break;
        case 7:
            break;
        case 8:
        case 9:
            [self createAObj3];
            break;
        case 10:
            break;
        case 11:
            break;
        case 12:
            [self createAObj1];
            break;
        default:
            break;
    }
}

-(void) createAObj1 {
    SKSpriteNode *aerial = [SKSpriteNode spriteNodeWithImageNamed:@"AOb-1"];
    aerial.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius: (aerial.size.width + aerial.size.height) / 4];
    aerial.xScale = 0.5;
    aerial.yScale = 0.5;
    
    [self aerialProperties: aerial];
    [self addChild: aerial];
    [self moveAerial: aerial];
}

-(void) createAObj2 {
    SKSpriteNode *aerial = [SKSpriteNode spriteNodeWithImageNamed:@"AOb-2"];
    aerial.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius: (aerial.size.width + aerial.size.height) / 4];
    aerial.xScale = 0.5;
    aerial.yScale = 0.5;
    
    [self aerialProperties: aerial];
    [self addChild: aerial];
    [self moveAerial: aerial];
}

-(void) createAObj3 {
    SKSpriteNode *aerial = [SKSpriteNode spriteNodeWithImageNamed:@"AOb-3"];
    aerial.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius: (aerial.size.width + aerial.size.height) / 4];
    aerial.xScale = 0.5;
    aerial.yScale = 0.5;
    
    [self aerialProperties: aerial];
    [self addChild: aerial];
    [self moveAerial: aerial];
}

-(void)aerialProperties: (SKSpriteNode *)aerial {
    //Common
    aerial.name = @"aerial";
    aerial.physicsBody.dynamic = NO;
    aerial.physicsBody.allowsRotation = YES;
    int tempRotate = arc4random()%100;
    double angularPosInit = tempRotate*3.14159*2.0/100.0;
    aerial.zRotation = angularPosInit;
    
    //Collision Properties
    aerial.physicsBody.categoryBitMask = CollisionCategoryObject;
    aerial.physicsBody.collisionBitMask = 0;
    
    //Random height.
    int tempRandHeight = arc4random() % 100;
    double RandHeight = (tempRandHeight - 50.0) / 100.0 * 0.2 * self.size.height;
    aerial.position = CGPointMake(self.size.width * 1.5, 0.85 * self.size.height + RandHeight);
}

-(void) createFloor
{
    SKSpriteNode *floorNode;
    for (int i = 0; i < 2; i++) {
        floorNode = [SKSpriteNode spriteNodeWithImageNamed:@"Level-1-Floor"];
        floorNode.position = CGPointMake(i * floorNode.size.width, 0);
        floorNode.anchorPoint = CGPointZero;
        floorNode.zPosition = 50;
        
        //Physics for floor
        floorNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:floorNode.size];
        floorNode.physicsBody.dynamic = NO;
        floorNode.physicsBody.categoryBitMask = CollisionCategoryObject;
        floorNode.physicsBody.collisionBitMask = CollisionCategoryPlayer;
        
        floorNode.name = @"floorGround";
        [self addChild:floorNode];
        
    }
}

-(void)tapToPlay {
    tapPlay = [SKLabelNode labelNodeWithFontNamed:@"SF Movie Poster"];
    tapPlay.fontSize = 60;
    tapPlay.fontColor = [SKColor whiteColor];
    tapPlay.position = CGPointMake(self.size.width/2, self.size.height / 3);
    tapPlay.text = @"Tap the screen to play!";
    [self addChild:tapPlay];
}

#pragma mark --Animate GameObjects

-(void) moveFloor
{
    [self enumerateChildNodesWithName:@"floorGround" usingBlock:^(SKNode *node, BOOL *stop) {
        SKSpriteNode *floorNode = (SKSpriteNode *)node;
        CGPoint groundVelocity = CGPointMake(FG_VELOCITY, 0);
        CGPoint movement = CGPointMultiplyScalar(groundVelocity, _dt);
        floorNode.position = CGPointAdd(floorNode.position, movement);
        
        if (floorNode.position.x <= -floorNode.size.width)
        {
            floorNode.position = CGPointMake(floorNode.position.x + floorNode.size.width*2, floorNode.position.y);
        }
    }];
}

-(void) movePillar: (SKSpriteNode *)pillarNode
{
    //Time calculation to move pillar across screen.  Time = distance/velocity.
    SKAction *animateLeft = [SKAction moveToX:-0.5*self.size.width duration:3];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *moveSqnce = [SKAction sequence:@[animateLeft, remove]];
    
    [pillarNode runAction:moveSqnce];
}

-(void) moveAerial: (SKSpriteNode *)aerialNode {
    SKAction *animateLeft = [SKAction moveToX:-0.5*self.size.width duration:1.5];
    SKAction *remove = [SKAction removeFromParent];
    
    //Random rotate calcs.
    int tempRotate = arc4random()%100;
    double angularRotation = tempRotate*3.14159*2.0/100.0;
    
    SKAction *rotate = [SKAction rotateByAngle:angularRotation duration:1.5];
    
    SKAction *aerialGroup = [SKAction group: @[animateLeft, rotate]];
    SKAction *aerialSqnce = [SKAction sequence: @[aerialGroup,remove]];
    
    [aerialNode runAction:aerialSqnce];
}

#pragma mark --Create Audio
-(void)createAudio
{
    [[NWAudioPlayer sharedAudioPlayer] createAllMusicWithAudio:Level_2];
    [NWAudioPlayer sharedAudioPlayer].songName = Level_2;
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

-(void)timerInvalidate {
    [pillarCreateTimer invalidate];
    [aerialCreateTimer invalidate];
}

#pragma mark --User Interface

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [tapPlay removeFromParent];
    
    if (playerNode.physicsBody.dynamic == NO) {
        playerNode.physicsBody.dynamic = YES;
        [self addChild:_score];
        pillarCreateTimer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(anyPillarCreate) userInfo:nil repeats:YES];
        aerialCreateTimer = [NSTimer scheduledTimerWithTimeInterval:0.75 target:self selector:@selector(createAerial) userInfo:nil repeats:YES];
    }
    
    if (_player.position.y > self.size.height - 50)
    {
        _player.physicsBody.velocity = CGVectorMake(0.0f, 0.0f);
    }
    else _player.physicsBody.velocity = CGVectorMake(0.0f, 300.0f);
    
    [_player removeActionForKey:@"bobbingAction"];
    [[Ships alloc] rotateNodeUpwards:_player];
    
}

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
    [self.parallaxBackground update:currentTime];
    [self moveFloor];
    
    if (_player.physicsBody.velocity.dy < 0) {
        [playerNode rotateNodeDownwards:_player];
    }
    
    if ([self childNodeWithName:@"aerial"].position.x < _player.position.x && [self childNodeWithName:@"aerial"].position.x > 1)
    {
        [self scoreAdd];
        [self scorePlus];
        [self childNodeWithName:@"aerial"].name = @"aerialClose";
    }
    
    if ([self childNodeWithName:@"pillar"].position.x < _player.position.x && [self childNodeWithName:@"pillar"].position.x > 1)
    {
        [self scoreAdd];
        [self scorePlus];
        [self childNodeWithName:@"pillar"].name = @"pillarClose";
    }
}

-(void)gameOver {
    
}

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    if (contact.bodyA.categoryBitMask == CollisionCategoryPlayer && contact.bodyB.categoryBitMask == CollisionCategoryObject) {
        [self timerInvalidate];
        [GameState sharedGameData].highScoreL2 = MAX([GameState sharedGameData].score, [GameState sharedGameData].highScoreL2);
        
        SKView *gameOverView = (SKView *)self.view;
        
        SKScene *gameOverScene = [[GameOver alloc] initWithSize:gameOverView.bounds.size];
        
        SKColor *fadeColor = [SKColor colorWithRed:1 green:1 blue:1 alpha:1];
        SKTransition *gameOverTransition = [SKTransition fadeWithColor:fadeColor duration:.25];
        [gameOverView presentScene:gameOverScene transition:gameOverTransition];
    }
}




@end
