//
//  levelTwo.m
//  Nova Wing
//
//  Created by Bryan Todd on 8/11/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import "LevelTwo.h"
#import "GameOver.h"
#import "Obstacles.h"

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
NSTimer *pillarCreateTimer;

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
        [[Ships alloc] shipBobbing:_player];
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

-(void) anyPillarCreate
{
    int tempObjectSelector = arc4random()%12;
    switch (tempObjectSelector)
    {
        case 1:
        case 2:
        case 3:
            [self rockPillar1];
            break;
        case 4:
        case 5:
        case 6:
            [self rockPillar2];
            break;
        case 7:
        case 8:
        case 9:
            [self geyserPillar];
            break;
        case 10:
        case 11:
        case 12:
            [self radioPillar];
            break;
        default:
            break;
    }
    
}

-(void) rockPillar1
{
    //Instantiate pillar.
    SKSpriteNode *pillar = [SKSpriteNode node];
    
    //Position calculations.
    int randPillarHeight = arc4random()%99-50;
    double randPillarHeightPercent = randPillarHeight/100;

    double placedPillarTop = 0.5*self.size.height + randPillarHeightPercent*self.size.height;
    double actualPosition = placedPillarTop - pillar.size.height;
    
    //Pillar properties.
    pillar = [SKSpriteNode spriteNodeWithImageNamed:@"Pillar-1"];
    pillar.name = @"pillar";
    pillar.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pillar.size center:CGPointMake(pillar.size.width/2, pillar.size.height/2)];
    pillar.physicsBody.dynamic = NO;
    pillar.physicsBody.categoryBitMask = CollisionCategoryObject;
    pillar.physicsBody.allowsRotation = NO;
    pillar.anchorPoint = CGPointZero;
    
    //Set pillar position.
    pillar.position = CGPointMake(1.5*self.size.width, actualPosition);
    
    //Add to self and animate.
    [self addChild:pillar];
    [self movePillar:pillar];
}

-(void) rockPillar2
{
    //Instantiate pillar.
    SKSpriteNode *pillar = [SKSpriteNode node];
    
    //Position calculations.
    int randPillarHeight = arc4random()%100;
    double randPillarHeightPercent = randPillarHeight/100;
    double minHeightOfPillarTop = 0.2*self.size.height;
    double maxHeightOfPillarTop = 0.4*self.size.height;
    double placedPillarTop = minHeightOfPillarTop + (maxHeightOfPillarTop)*randPillarHeightPercent;
    double placedPillarBottom = placedPillarTop-pillar.size.height;
    
    //Pillar properties.
    pillar = [SKSpriteNode spriteNodeWithImageNamed:@"Pillar-2"];
    pillar.name = @"pillar";
    pillar.physicsBody.dynamic = NO;
    pillar.physicsBody.categoryBitMask = CollisionCategoryObject;
    pillar.physicsBody.allowsRotation = NO;
    
    //Physics body path.
    CGFloat offsetX = pillar.size.width * pillar.anchorPoint.x;
    CGFloat offsetY = pillar.size.height * pillar.anchorPoint.y;
    
    CGMutablePathRef thinPillarPath = CGPathCreateMutable();
    
    CGPathMoveToPoint(thinPillarPath, NULL, 13 - offsetX, 561 - offsetY);
    CGPathAddLineToPoint(thinPillarPath, NULL, 1 - offsetX, 0 - offsetY);
    CGPathAddLineToPoint(thinPillarPath, NULL, 73 - offsetX, 1 - offsetY);
    CGPathAddLineToPoint(thinPillarPath, NULL, 65 - offsetX, 341 - offsetY);
    
    CGPathCloseSubpath(thinPillarPath);
    
    pillar.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromPath:thinPillarPath];
    
    //Set pillar position.
    pillar.position = CGPointMake(1.5*self.size.width, placedPillarBottom);
    
    //Add to self and animate.
    [self addChild:pillar];
    [self movePillar:pillar];
    
}

-(void) geyserPillar
{
    //Instantiate pillar.
    SKSpriteNode *pillar = [SKSpriteNode node];
    
    //Scale calculations (IF NEEDED, PLACE HERE)
    
    //Pillar properties.
    pillar = [SKSpriteNode spriteNodeWithImageNamed:@"Pillar-3"];
    pillar.name = @"pillar";
    pillar.physicsBody.dynamic = NO;
    pillar.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:pillar.frame];
    pillar.physicsBody.categoryBitMask = CollisionCategoryObject;
    pillar.physicsBody.allowsRotation = NO;
    
    pillar.position = CGPointMake(1.5*self.size.width, 0) ;
    
    //Add to self and animate.
    [self addChild:pillar];
    [self movePillar:pillar];
}

-(void) radioPillar
{
    //Instantiate pillar.
    SKSpriteNode *pillar = [SKSpriteNode node];
    
    //Position calculations.
    int randPillarHeight = arc4random()%100;
    double randPillarHeightPercent = randPillarHeight/100;
    double minHeightOfPillarTop = 0.2*self.size.height;
    double maxHeightOfPillarTop = 0.4*self.size.height;
    double placedPillarTop = minHeightOfPillarTop + (maxHeightOfPillarTop)*randPillarHeightPercent;
    double placedPillarBottom = placedPillarTop-pillar.size.height;
    
    //Pillar properties.
    pillar = [SKSpriteNode spriteNodeWithImageNamed:@"Pillar-4"];
    pillar.name = @"pillar";
    pillar.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:pillar.frame];
    pillar.physicsBody.dynamic = NO;
    pillar.physicsBody.categoryBitMask = CollisionCategoryObject;
    pillar.physicsBody.allowsRotation = NO;
    
    //Set pillar position.
    pillar.position = CGPointMake(1.5*self.size.width, placedPillarBottom);
    
    //Add to self and animate.
    [self addChild:pillar];
    [self movePillar:pillar];
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
    
    /*[self enumerateChildNodesWithName:@"pillar" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.x < -node.frame.size.width) {
            [node removeFromParent];
            int randNewPillar = ceil((arc4random_uniform(3) + 1));
            SKSpriteNode *newPillar = (SKSpriteNode *)node;
            newPillar = [[Obstacles alloc] createObstacleWithNode:newPillar withName:@"pillar" withImage:[NSString stringWithFormat:@"Pillar-%i",randNewPillar]];
            newPillar = [[Obstacles alloc] createPillarPhysicsBody:newPillar withIdentifier:randNewPillar];
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
    }];*/
}

-(void) movePillar: (SKSpriteNode *)pillarNode
{
    //Time calculation to move pillar across screen.  Time = distance/velocity.
    SKAction *animateLeft = [SKAction moveToX:-0.5*self.size.width duration:3];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *moveSqnce = [SKAction sequence:@[animateLeft, remove]];
    
    [pillarNode runAction:moveSqnce];
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
        [self addChild:_score];
        scoreUpdate = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(scoreAdd) userInfo:nil repeats:YES];
        pillarCreateTimer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(anyPillarCreate) userInfo:nil repeats:YES];
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
        [[Ships alloc] rotateNodeDownwards:_player];
    }
    
}

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    [scoreUpdate invalidate];
    [pillarCreateTimer invalidate];
    [GameState sharedGameData].highScoreL2 = MAX([GameState sharedGameData].score, [GameState sharedGameData].highScoreL2);
    
    SKView *gameOverView = (SKView *)self.view;
    
    SKScene *gameOverScene = [[GameOver alloc] initWithSize:gameOverView.bounds.size];
    
    SKColor *fadeColor = [SKColor colorWithRed:1 green:1 blue:1 alpha:1];
    SKTransition *gameOverTransition = [SKTransition fadeWithColor:fadeColor duration:.25];
    [gameOverView presentScene:gameOverScene transition:gameOverTransition];
    
}




@end
