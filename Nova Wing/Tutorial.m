//
//  LevelOne.m
//  Nova Wing
//
//  Created by Cameron Frank on 8/19/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import "LevelOne.h"
#import "Tutorial.h"
#import "GameOverL1.h"
#import "Obstacles.h"
#import "Multipliers.h"
#import "PowerUps.h"

@interface Tutorial() <SKPhysicsContactDelegate>
{
    Ships *playerNode;
    Ships *playerParent;
    pupType powerUp;
    SKSpriteNode *shield;
    BOOL activePup;
    NORLabelNode *tapPlay;
}
@end

@implementation Tutorial


NSTimeInterval _lastUpdateTime;
NSTimeInterval _dt;
SKLabelNode* _score;


#pragma mark --CreateBackground

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor colorWithRed:0 green:0 blue:0 alpha:1];
        
        self.physicsWorld.gravity = CGVectorMake(0.0f, -8.0f);
        self.physicsWorld.contactDelegate = self;
        self.scaleMode = SKSceneScaleModeAspectFit;
        
        NSString *starsPath = [[NSBundle mainBundle] pathForResource:@"Stars-L1" ofType:@"sks"];
        SKEmitterNode *stars = [NSKeyedUnarchiver unarchiveObjectWithFile:starsPath];
        stars.position = CGPointMake(self.size.width, self.size.height / 2);
        
        //Pre emits particles so layer is populated when scene begins
        [stars advanceSimulationTime:1.5];
        
        playerParent = [self createPlayerParent];
        [self createPlayerNode: playerNode];
        
        [self createAudio];
        
        [self addChild:stars];
        [self createBlackHole];
        [self addChild:playerParent];
        [playerParent addChild:playerNode];
        [self addChild:[self skipButtonBG]];
        
        //Physics Joint
        SKPhysicsJointFixed *test = [SKPhysicsJointFixed jointWithBodyA:playerParent.physicsBody bodyB:playerNode.physicsBody anchor:CGPointMake(playerParent.position.x+50, playerParent.position.y+50)];
        [self.physicsWorld addJoint:test];
        
        //shipBobbing is factory method within playerNode.
        [playerParent shipBobbing:playerParent];
        
        [self createScoreNode];
        [self tapToPlay];
        _score.text = @"Score: 0";
        
    }
    
    return self;
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
    [self objectPhysicsStandards: obstacle1];
    
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
    [self objectPhysicsStandards: obstacle2];
    
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
    [self objectPhysicsStandards: obstacle2];
    
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
    [self objectPhysicsStandards: obstacle2];
    
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
    [self objectPhysicsStandards: obstacle2];
    
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
    [self objectPhysicsStandards: obstacle2];
    
    [self addChild: obstacle2];
    [self moveAerialNode:obstacle2 allowsRotation: YES];
}

-(void)objectPhysicsStandards: (SKSpriteNode *)object {
    object.physicsBody.categoryBitMask = CollisionCategoryObject;
    object.physicsBody.dynamic = YES;
    object.physicsBody.affectedByGravity = NO;
    object.physicsBody.collisionBitMask = CollisionCategoryObject;
    object.physicsBody.usesPreciseCollisionDetection = YES;
    object.physicsBody.friction = 0.2f;
    object.physicsBody.restitution = 0.0f;
    object.physicsBody.linearDamping = 0.0;
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
    tapPlay = [NORLabelNode labelNodeWithFontNamed:@"SF Movie Poster"];
    tapPlay.fontSize = 35;
    tapPlay.lineSpacing = .8;
    tapPlay.fontColor = [SKColor whiteColor];
    tapPlay.position = CGPointMake(self.size.width/2, self.size.height / 5);
    tapPlay.text = @"Welcome to Nova Wing: 3031!\nLet's take a look around!\nTap the screen to continue,\nor just tap SKIP below!";
    
    [self addChild:tapPlay];
}

-(NORLabelNode *)skipButtonWithColor: (NSString*)color andOffset: (int)offset {
    NORLabelNode *skip = [NORLabelNode labelNodeWithFontNamed:@"SF Movie Poster"];
    skip.fontSize = 35;
    skip.lineSpacing = .8;
    if ([color isEqualToString:@"white"]) {
        skip.fontColor = [SKColor whiteColor];
    } else
        skip.fontColor = [SKColor blackColor];
    skip.position = CGPointMake(25 + offset, 15 - offset);
    skip.zPosition = 111;
    skip.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    skip.text = @"SKIP";
    
    return skip;
}

-(SKShapeNode *)skipButtonBG {
    SKShapeNode *rect = [SKShapeNode node];
    [rect setPath: CGPathCreateWithRoundedRect(CGRectMake(-5, 13, 75, 30),4,4, nil)];
    rect.position = CGPointMake(0, 0);
    rect.zPosition = 10;
    rect.fillColor = [NWColor NWBlue];
    rect.alpha = 0.6;
    rect.lineWidth = 0;
    rect.name = @"skipButton";
    
    [rect addChild:[self skipButtonWithColor:@"black" andOffset:1]];
    [rect addChild:[self skipButtonWithColor:@"white" andOffset:0]];

    
    return rect;
}

#pragma mark --Create Audio
-(void)createAudio
{
    [[NWAudioPlayer sharedAudioPlayer] createAllMusicWithAudio:Level_1];
    [NWAudioPlayer sharedAudioPlayer].songName = Level_1;
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
    
    SKSpriteNode *multiplier = [Multipliers createMultiplier];
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


#pragma mark --User Interface

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touchLift = [touches anyObject];
    CGPoint locationLift = [touchLift locationInNode:self];
    SKNode *nodeLift = [self nodeAtPoint:locationLift];
    
    if ([nodeLift.name isEqualToString:@"skipButton"]) {
        SKView * levelOneView = (SKView *)self.view;
        levelOneView.showsFPS = YES;
        levelOneView.showsNodeCount = YES;
        //levelOneView.showsPhysics = YES;
        
        // Create and configure the scene.
        SKScene * levelOneScene = [[LevelOne alloc] initWithSize:levelOneView.bounds.size];
        levelOneScene.scaleMode = SKSceneScaleModeAspectFill;
        SKTransition *levelOneTrans = [SKTransition fadeWithColor:[SKColor whiteColor] duration:0.5];
        
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
    
    /*if ([self childNodeWithName:@"aerial"].position.x < self.size.width / 2) {
     [[self childNodeWithName:@"aerial"].physicsBody applyImpulse:CGVectorMake(0, -0.2)];
     }*/

    
}

-(void)gameOver {
    [GameState sharedGameData].highScoreL1 = MAX([GameState sharedGameData].score, [GameState sharedGameData].highScoreL1);
    [playerNode removeAllChildren];
    SKView *gameOverView = (SKView *)self.view;
    
    SKScene *gameOverScene = [[GameOverL1 alloc] initWithSize:gameOverView.bounds.size];
    
    SKColor *fadeColor = [SKColor colorWithRed:1 green:1 blue:1 alpha:1];
    SKTransition *gameOverTransition = [SKTransition fadeWithColor:fadeColor duration:.25];
    [gameOverView presentScene:gameOverScene transition:gameOverTransition];
    
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
    
    //SKSpriteNode *firstNode = (SKSpriteNode *)firstBody.node;
    //SKSpriteNode *secondNode = (SKSpriteNode *)secondBody.node;

    
}

@end
