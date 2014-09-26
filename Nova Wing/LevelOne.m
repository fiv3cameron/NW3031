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

typedef NS_OPTIONS(uint32_t, CollisionCategory) {
    CollisionCategoryPlayer     = 0x1 << 0,
    CollisionCategoryObject     = 0x1 << 1,
    CollisionCategoryBottom     = 0x1 << 2,
};

@interface LevelOne() <SKPhysicsContactDelegate>
{
    SKNode *_player;
    SKNode *playerNode;
    
}
@end

/*static const float FG_VELOCITY = -100.0;*/

/*static inline CGPoint CGPointAdd(const CGPoint a, const CGPoint b)
{
    return CGPointMake(a.x + b.x, a.y + b.y);
}*/

/*static inline CGPoint CGPointMultiplyScalar(const CGPoint a, const CGFloat b)
{
    return CGPointMake(a.x * b, a.y * b);
}*/

@implementation LevelOne

NSTimeInterval _lastUpdateTime;
NSTimeInterval _dt;
SKLabelNode* _score;
NSTimer *scoreUpdate;
NSTimer *objectCreateTimer;


#pragma mark --CreateBackground

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        /*if ([GameState sharedGameData].highScoreL1 == 0) {
            storymodeL1 = YES;
        } else if ([GameState sharedGameData].highScoreL1 > 0) {
            storymodeL1 = NO;
        }*/
        
        levelComplete = NO;
        storymodeL1 = NO;
        
        self.backgroundColor = [SKColor colorWithRed:0 green:0 blue:0 alpha:1];
        
        self.physicsWorld.gravity = CGVectorMake(0.0f, -5.0f);
        self.physicsWorld.contactDelegate = self;
        self.scaleMode = SKSceneScaleModeAspectFit;
        
        NSString *starsPath = [[NSBundle mainBundle] pathForResource:@"Stars-L1" ofType:@"sks"];
        
        SKEmitterNode *stars = [NSKeyedUnarchiver unarchiveObjectWithFile:starsPath];
        stars.position = CGPointMake(self.size.width, self.size.height / 2);
        
        //Pre emits particles so layer is populated when scene begins
        [stars advanceSimulationTime:1.1];
        
        _player = [self createPlayerNode];
        
        [self createAudio];
        [self addChild:stars];
        [self createBlackHole];
        [self bottomCollide];
        [self addChild:_player];
        [[Ships alloc] shipBobbing:_player];
        [self createScoreNode];
        if (storymodeL1 == YES) {
            [self intro];
            [self tapToPlay];
        } else if (storymodeL1 == NO)
            [self tapToPlay];
        _score.text = @"0";
        
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

-(SKNode *) createPlayerNode
{
    SKNode *tempPlayerNode = [SKNode node];
    [tempPlayerNode setPosition:CGPointMake(self.frame.size.width/5, self.frame.size.height/2)];
    
    playerNode = [[Ships alloc] createAnyShipFromParent:tempPlayerNode withImageNamed:@"Nova-L1"];
    playerNode.physicsBody.categoryBitMask = CollisionCategoryPlayer;
    playerNode.physicsBody.collisionBitMask = 0;
    playerNode.physicsBody.contactTestBitMask = CollisionCategoryBottom | CollisionCategoryObject;
    
    // Keeps player ship on top of all other objects(unless other objects are assigned greater z position
    playerNode.zPosition = 100.0f;
    
    return playerNode;
}

-(void)createObstacles {
    
    int tempObjectSelector = arc4random()%10;
    switch (tempObjectSelector)
    {
        case 1:
        case 2:
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
        case 7:
            [self asteroid2];
            break;
        case 8:
        case 9:
            [self asteroid3];
            break;
        case 10:
            //Red asteroid
            break;

        default:
            break;
    }
    

}

-(void)asteroid1 {
    
    SKSpriteNode *tempNode = [SKSpriteNode node];
    SKSpriteNode *obstacle1 = [[Obstacles alloc] createObstacleWithNode:tempNode withName:@"aerial" withImage:@"AOb-1"];
    
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
    
    [self addChild: obstacle1];
    [self moveAerialNode:obstacle1];
}

-(void)asteroid2 {
    
    SKSpriteNode *tempNode = [SKSpriteNode node];
    SKSpriteNode *obstacle2 = [[Obstacles alloc] createObstacleWithNode:tempNode withName:@"aerial" withImage:@"AOb-2"];
    
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
    
    [self addChild: obstacle2];
    [self moveAerialNode:obstacle2];
    
}

-(void)asteroid3 {
    
    SKSpriteNode *tempNode = [SKSpriteNode node];
    SKSpriteNode *obstacle2 = [[Obstacles alloc] createObstacleWithNode:tempNode withName:@"aerial" withImage:@"AOb-3"];
    
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
    
    [self addChild: obstacle2];
    [self moveAerialNode:obstacle2];
    
}

-(void)rocket {
    SKSpriteNode *tempNode = [SKSpriteNode node];
    SKSpriteNode *obstacle2 = [[Obstacles alloc] createObstacleWithNode:tempNode withName:@"aerial" withImage:@"Rocket-1"];
    
    int tempRand = arc4random()%80;
    double randYPosition = (tempRand+10)/100.0;
    obstacle2.position = CGPointMake(self.size.width+obstacle2.size.width, self.size.height*randYPosition);
    //obstacle1.name = @"aerial";
    obstacle2.zPosition = 10;
    
    int tempRand2 = arc4random()%100;
    double randScale = (tempRand2)/1000.0;
    obstacle2.xScale = 0.4 + randScale;
    obstacle2.yScale = 0.4 + randScale;
    
    obstacle2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: obstacle2.size];
    obstacle2.physicsBody.categoryBitMask = CollisionCategoryObject;
    obstacle2.physicsBody.dynamic = NO;
    obstacle2.physicsBody.collisionBitMask = 0;
    
    [self addChild: obstacle2];
    [self moveAerialNode:obstacle2];
}

-(void)shipChunk {
    SKSpriteNode *tempNode = [SKSpriteNode node];
    SKSpriteNode *obstacle2 = [[Obstacles alloc] createObstacleWithNode:tempNode withName:@"aerial" withImage:@"Ship-Chunk-1"];
    
    int tempRand = arc4random()%80;
    double randYPosition = (tempRand+10)/100.0;
    obstacle2.position = CGPointMake(self.size.width+obstacle2.size.width, self.size.height*randYPosition);
    //obstacle1.name = @"aerial";
    obstacle2.zPosition = 10;
    
    int tempRand2 = arc4random()%100;
    double randScale = (tempRand2)/1000.0;
    obstacle2.xScale = 0.5 + randScale;
    obstacle2.yScale = 0.5 + randScale;
    
    obstacle2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: obstacle2.size];
    obstacle2.physicsBody.categoryBitMask = CollisionCategoryObject;
    obstacle2.physicsBody.dynamic = NO;
    obstacle2.physicsBody.collisionBitMask = 0;
    
    [self addChild: obstacle2];
    [self moveAerialNode:obstacle2];
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

-(void)outro {
    NORLabelNode *outroText = [NORLabelNode labelNodeWithFontNamed:@"SF Movie Poster"];
    outroText.fontColor = [SKColor whiteColor];
    outroText.fontSize = 30;
    outroText.lineSpacing = 1;
    outroText.position = CGPointMake(self.size.width / 2, self.size.height / 2 - 50);
    outroText.zPosition = 102;
    outroText.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    outroText.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    outroText.text = @"I can't... I'm sorry \nDart... I wish I could have told you... \nAgh... too much...no engines... ";
    
    storyBadge = [SKSpriteNode spriteNodeWithImageNamed:@"CMDR-FletcherPop"];
    storyBadge.position = CGPointMake(self.size.width / 2, self.size.height / 2);
    storyBadge.zPosition = 101;
    
    tapPlay = [SKLabelNode labelNodeWithFontNamed:@"SF Movie Poster"];
    tapPlay.fontSize = 35;
    tapPlay.fontColor = [SKColor whiteColor];
    tapPlay.position = CGPointMake(self.size.width/2, self.size.height / 5);
    tapPlay.text = @"Tap the screen to continue.";
    
    [self addChild:storyBadge];
    [self addChild:outroText];
    [self addChild:tapPlay];
}

#pragma mark --Create Audio
-(void)createAudio
{
    NSString *soundFile = [[NSBundle mainBundle] pathForResource:@"Level-1-Music" ofType:@"m4a"];
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

#pragma mark --Animate Obstacles
/*-(void) moveAerialNode: (SKSpriteNode *)incomingNode
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
    
    int tempRand = arc4random()%200;
    double randDuration = (tempRand-100)/1000.0;
    double totalDuration =0.6+randDuration;
    
    int tempRand2 = arc4random()%100;
    double tempRandSigned = tempRand2-50.0;
    double randAngleRad = (tempRandSigned)*180/100.0;
    double randAngleDeg = randAngleRad*3.141592654/180;
    
    //Action Definitions.
    SKAction *horzMove1 = [SKAction moveByX: -(self.size.width/2 + incomingNode.size.width/2) y: 0 duration:totalDuration];
    SKAction *horzMove2 = [SKAction moveToX: -incomingNode.size.width duration:totalDuration];
    SKAction *vertMoveUp = [SKAction moveByX:0 y:deltaHeight duration:totalDuration];
    SKAction *vertMoveDwn = [SKAction moveByX:0 y:-deltaHeight duration:totalDuration];
    SKAction *rotate = [SKAction rotateByAngle:randAngleDeg duration:totalDuration];
    vertMoveUp.timingMode = SKActionTimingEaseOut;
    vertMoveDwn.timingMode = SKActionTimingEaseIn;
    
    //Groups & Sequences
    SKAction *groupUp = [SKAction group:@[horzMove1,vertMoveUp,rotate]];
    SKAction *groupDwn = [SKAction group:@[horzMove2, vertMoveDwn,rotate]];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *aerialSqnce = [SKAction sequence:@[groupUp, groupDwn,remove]];
    
    //Run sequence
    [incomingNode runAction:aerialSqnce];
} */

-(void) moveAerialNode: (SKSpriteNode *)incomingNode
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
    
    int tempRand = arc4random()%200;
    double randDuration = (tempRand-100)/1000.0;
    double totalDuration =0.6+randDuration;
    
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
    SKAction *vertMove = [SKAction sequence:@[vertMoveUp, vertMoveDwn]];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *aerialGroup = [SKAction group:@[vertMove,horzMove,rotate]];
    SKAction *aerialSqnce = [SKAction sequence:@[aerialGroup, remove]];
    //Run sequence
    [incomingNode runAction:aerialSqnce];
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    if ([self.children containsObject:storyBadge] && [self.children containsObject:introduction] && [self.children containsObject:tapPlay]) {
        [storyBadge removeFromParent];
        [introduction removeFromParent];
        [tapPlay removeFromParent];
    }
    if (playerNode.physicsBody.dynamic == NO) {
        playerNode.physicsBody.dynamic = YES;
        [self addChild:_score];
        [self createObstacles];
        [tapPlay removeFromParent];
        scoreUpdate = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(scoreAdd) userInfo:nil repeats:YES];
        objectCreateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(createObstacles) userInfo:nil repeats:YES];
    }
    
    if (_player.position.y > 500)
    {
        _player.physicsBody.velocity = CGVectorMake(0.0f, 0.0f);
    }
    else _player.physicsBody.velocity = CGVectorMake(0.0f, 400.0f);
    
    if (levelComplete == YES) {
        SKView *gameOverView = (SKView *)self.view;
        
        SKScene *gameOverScene = [[GameOverL1 alloc] initWithSize:gameOverView.bounds.size];
        
        SKColor *fadeColor = [SKColor colorWithRed:0 green:0 blue:0 alpha:1];
        SKTransition *gameOverTransition = [SKTransition fadeWithColor:fadeColor duration:.25];
        [gameOverView presentScene:gameOverScene transition:gameOverTransition];
    }
    [_player removeActionForKey:@"bobbingAction"];
    [[Ships alloc] rotateNodeUpwards:_player];
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
    
    if (_player.physicsBody.velocity.dy < 0) {
        [[Ships alloc] rotateNodeDownwards:_player];
    }
    
}

-(void)didBeginContact:(SKPhysicsContact *)contact {
    if (storymodeL1 == YES) {
        [self outro];
        [scoreUpdate invalidate];
        [GameState sharedGameData].highScoreL1 = MAX([GameState sharedGameData].score, [GameState sharedGameData].highScoreL1);
    
        levelComplete = YES;
    } else {
        
        [scoreUpdate invalidate];
        [GameState sharedGameData].highScoreL1 = MAX([GameState sharedGameData].score, [GameState sharedGameData].highScoreL1);
        
        SKView *gameOverView = (SKView *)self.view;
    
        SKScene *gameOverScene = [[GameOverL1 alloc] initWithSize:gameOverView.bounds.size];
    
        SKColor *fadeColor = [SKColor colorWithRed:1 green:1 blue:1 alpha:1];
        SKTransition *gameOverTransition = [SKTransition fadeWithColor:fadeColor duration:.25];
        [gameOverView presentScene:gameOverScene transition:gameOverTransition];
    }
    [objectCreateTimer invalidate];
    
}

@end
