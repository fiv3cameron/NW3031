//
//  levelTwo.m
//  Nova Wing
//
//  Created by Bryan Todd on 8/11/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import "LevelTwo.h"
#import "GameOver.h"

typedef NS_OPTIONS(uint32_t, CollisionCategory) {
    CollisionCategoryPlayer     = 0x1 << 0,
    CollisionCategoryObject     = 0x1 << 1,
};

@interface LevelTwo() <SKPhysicsContactDelegate>
{
    SKNode *_player;
    SKNode *playerNode;
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

#pragma mark --Create Background

-(id)initWithSize:(CGSize)size andDirection:(PBParallaxBackgroundDirection)direction {
    if (self = [super initWithSize:size]) {
        
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
        [self createFloor];
        [self tapToPlay];
        
        _score.text = @"Score: 0";
    }
    return self;
}


-(SKNode *) createPlayerNode
{
    SKNode *tempPlayerNode = [SKNode node];
    [tempPlayerNode setPosition:CGPointMake(self.frame.size.width/5, self.frame.size.height/2)];
    
    playerNode = [[Ships alloc] createAnyShipFromParent:tempPlayerNode withImageNamed:@"Nova-L2"];

    playerNode.physicsBody.categoryBitMask = CollisionCategoryPlayer;
    playerNode.physicsBody.collisionBitMask = CollisionCategoryObject;
    playerNode.physicsBody.contactTestBitMask = CollisionCategoryPlayer | CollisionCategoryObject;
    
    // Keeps player ship on top of all other objects(unless other objects are assigned greater z position
    playerNode.zPosition = 100.0f;
    
    return playerNode;
}

-(void) createObstacles
{
    // Add pillar.
    SKSpriteNode *pillar1 = [SKSpriteNode node];
    pillar1 = [[ObstaclesL2 alloc] createAnyPillar];
    pillar1.physicsBody.categoryBitMask = CollisionCategoryObject;
    
    // Do it again.
    SKSpriteNode *pillar2 = [SKSpriteNode node];
    pillar2 = [[ObstaclesL2 alloc] createAnyPillar];
    pillar2.physicsBody.categoryBitMask = CollisionCategoryObject;
    
    pillar1.position = CGPointMake(self.size.width*1.5, -pillar1.frame.size.height/4);
    pillar2.position = CGPointMake(self.size.width*2.25, -pillar2.frame.size.height/4);
    
    // Available space calculation for minimum "window" to position aerial object.
    SKNode *testNode = [playerNode childNodeWithName:@"ship"];
    float ACOHeight1 = pillar1.position.y + pillar1.size.height/2 + testNode.frame.size.height*2;
    SKSpriteNode *aerialObject1 = [SKSpriteNode node];
    aerialObject1 = [[ObstaclesL2 alloc] createAnyACO];
    aerialObject1.position = CGPointMake(self.size.width/2, ACOHeight1);
    [aerialObject1 setScale:0.6];
    
    //Add as children to floor.
    [self addChild:pillar1];
    [self addChild:pillar2];
    [self addChild:aerialObject1];
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
    
    [self enumerateChildNodesWithName:@"pillar" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.x < -node.frame.size.width) {
            [node removeFromParent];
            int randNewPillar = ceil((arc4random_uniform(39) + 1)/10);
            SKSpriteNode *newPillar = (SKSpriteNode *)node;
            switch (randNewPillar) {
                case 1:
                    newPillar = [[ObstaclesL2 alloc] rockPillarCreate];
                    break;
                case 2:
                    newPillar = [[ObstaclesL2 alloc] thinRockPillarCreate];
                    break;
                case 3:
                    newPillar = [[ObstaclesL2 alloc] radioTowerCreate];
                    break;
                case 4:
                    newPillar = [[ObstaclesL2 alloc] lavaPillarCreate];
                    break;
                default:
                    break;
            }
            int heightInt = ceil(newPillar.frame.size.height*3/4) - ceil(newPillar.frame.size.height/4);
            float randHeight = (arc4random()%heightInt) - newPillar.frame.size.height/4;
            newPillar.position = CGPointMake(self.size.width*1.5-node.frame.size.width, randHeight);
            [self addChild:newPillar];
        } else {
            SKSpriteNode *pillar = (SKSpriteNode *)node;
            CGPoint pillarvelocity = CGPointMake(FG_VELOCITY, 0);
            CGPoint pillarmovement = CGPointMultiplyScalar(pillarvelocity, _dt);
            pillar.position = CGPointAdd(pillar.position, pillarmovement);
        }
    }];
}

#pragma mark --Create Audio
-(void)createAudio
{
    NSString *soundFile = [[NSBundle mainBundle] pathForResource:@"Level-2-Music" ofType:@"m4a"];
    NSURL *soundFileUrl = [NSURL fileURLWithPath:soundFile];
    bgPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileUrl error:nil];
    bgPlayer.numberOfLoops = -1;
    
    [bgPlayer play];
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
    [GameState sharedGameData].score = [GameState sharedGameData].score + 1;
    _score.text = [NSString stringWithFormat:@"Score: %li", [GameState sharedGameData].score];
}

#pragma mark --User Interface

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [tapPlay removeFromParent];
    
    if (playerNode.physicsBody.dynamic == NO) {
        playerNode.physicsBody.dynamic = YES;
        [self createObstacles];
        [self addChild:_score];
        scoreUpdate = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(scoreAdd) userInfo:nil repeats:YES];
    }
    
    if (_player.position.y > 500)
    {
        _player.physicsBody.velocity = CGVectorMake(0.0f, 0.0f);
    }
    else _player.physicsBody.velocity = CGVectorMake(0.0f, 400.0f);
    
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
    
}

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    [scoreUpdate invalidate];
    [GameState sharedGameData].highScoreL2 = MAX([GameState sharedGameData].score, [GameState sharedGameData].highScoreL2);
    
    SKView *gameOverView = (SKView *)self.view;
    
    SKScene *gameOverScene = [[GameOver alloc] initWithSize:gameOverView.bounds.size];
    
    SKColor *fadeColor = [SKColor colorWithRed:1 green:1 blue:1 alpha:1];
    SKTransition *gameOverTransition = [SKTransition fadeWithColor:fadeColor duration:.25];
    [gameOverView presentScene:gameOverScene transition:gameOverTransition];
    
}




@end
