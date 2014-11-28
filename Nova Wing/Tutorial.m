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
    BOOL activePup;
    NORLabelNode *tapPlay;
    NORLabelNode *tutorialText;
    SKSpriteNode *blackHole;
    SKSpriteNode *bottom;
    SKEmitterNode *trail;
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    SKLabelNode* _score;
    int tutorialStage;
}
@end

@implementation Tutorial


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
        tutorialStage = 1;
        
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

-(SKNode *)createObstacles {
    
    SKNode *node = [SKNode node];
    
    int tempObjectSelector = arc4random()%6;
    switch (tempObjectSelector)
    {
        case 1:
            node = [self rocket];
            break;
        case 2:
            node = [self asteroid1];
            break;
        case 3:
            node = [self shipChunk];
            break;
        case 4:
            node = [self asteroid2];
            break;
        case 5:
            node = [self asteroid3];
            break;
        case 6:
            node = [self asteroid4];
            break;
        default:
            break;
    }
    
    return node;
    
    
}

-(SKNode *)asteroid1 {
    
    SKSpriteNode *tempNode = [SKSpriteNode node];
    SKSpriteNode *obstacle1 = [[Obstacles alloc] createObstacleWithNode:tempNode withName:@"aerial" withImage:@"L1-AOb-1"];
    
    int tempRand = arc4random()%80;
    double randYPosition = (tempRand+10)/100.0;
    obstacle1.position = CGPointMake(self.size.width * 1.7, self.size.height*randYPosition);
    //obstacle1.name = @"aerial";
    obstacle1.zPosition = 10;
    
    int tempRand2 = arc4random()%200;
    double randScale = (tempRand2-100)/1000.0;
    obstacle1.xScale = 0.5 + randScale;
    obstacle1.yScale = 0.5 + randScale;
    
    obstacle1.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:obstacle1.size.height/2];
    [self objectPhysicsStandards: obstacle1];
    
    return obstacle1;
}

-(SKNode *)asteroid2 {
    
    SKSpriteNode *tempNode = [SKSpriteNode node];
    SKSpriteNode *obstacle2 = [[Obstacles alloc] createObstacleWithNode:tempNode withName:@"aerial" withImage:@"L1-AOb-2"];
    
    int tempRand = arc4random()%80;
    double randYPosition = (tempRand+10)/100.0;
    obstacle2.position = CGPointMake(self.size.width * 1.7, self.size.height*randYPosition);
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
    
    return obstacle2;
    
}

-(SKNode *)asteroid3 {
    
    SKSpriteNode *tempNode = [SKSpriteNode node];
    SKSpriteNode *obstacle2 = [[Obstacles alloc] createObstacleWithNode:tempNode withName:@"aerial" withImage:@"L1-AOb-3"];
    
    int tempRand = arc4random()%80;
    double randYPosition = (tempRand+10)/100.0;
    obstacle2.position = CGPointMake(self.size.width * 1.7, self.size.height*randYPosition);
    //obstacle1.name = @"aerial";
    obstacle2.zPosition = 10;
    
    int tempRand2 = arc4random()%100;
    double randScale = (tempRand2)/1000.0;
    obstacle2.xScale = 0.4 + randScale;
    obstacle2.yScale = 0.4 + randScale;
    
    obstacle2.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:obstacle2.size.height/2];
    [self objectPhysicsStandards: obstacle2];
    
    return obstacle2;
}

-(SKNode *)asteroid4 {
    
    SKSpriteNode *tempNode = [SKSpriteNode node];
    SKSpriteNode *obstacle2 = [[Obstacles alloc] createObstacleWithNode:tempNode withName:@"aerial" withImage:@"L1-AOb-4"];
    
    int tempRand = arc4random()%80;
    double randYPosition = (tempRand+10)/100.0;
    obstacle2.position = CGPointMake(self.size.width * 1.7, self.size.height*randYPosition);
    //obstacle1.name = @"aerial";
    obstacle2.zPosition = 10;
    
    int tempRand2 = arc4random()%100;
    double randScale = (tempRand2)/1000.0;
    obstacle2.xScale = 0.4 + randScale;
    obstacle2.yScale = 0.4 + randScale;
    
    obstacle2.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:obstacle2.size.height/2];
    [self objectPhysicsStandards: obstacle2];
    
    return obstacle2;
    
}

-(SKNode *)rocket {
    SKSpriteNode *tempNode = [SKSpriteNode node];
    SKSpriteNode *obstacle2 = [[Obstacles alloc] createObstacleWithNode:tempNode withName:@"aerial" withImage:@"Rocket-1"];
    
    int tempRand = arc4random()%80;
    double randYPosition = (tempRand+10)/100.0;
    obstacle2.position = CGPointMake(self.size.width * 1.7, self.size.height*randYPosition);
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
    
    return obstacle2;
}

-(SKNode *)shipChunk {
    SKSpriteNode *tempNode = [SKSpriteNode node];
    SKSpriteNode *obstacle2 = [[Obstacles alloc] createObstacleWithNode:tempNode withName:@"aerial" withImage:@"Ship-Chunk-1"];
    
    int tempRand = arc4random()%80;
    double randYPosition = (tempRand+10)/100.0;
    obstacle2.position = CGPointMake(self.size.width * 1.7, self.size.height*randYPosition);
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
    
    return obstacle2;
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

-(NORLabelNode *)tutorialText: (NSString *)text {
    tutorialText = [NORLabelNode labelNodeWithFontNamed:@"SF Movie Poster"];
    tutorialText.fontSize = 30;
    tutorialText.lineSpacing = .8;
    tutorialText.fontColor = [SKColor whiteColor];
    tutorialText.position = CGPointMake(self.size.width + (self.size.width/4), self.size.height / 5);
    tutorialText.zPosition = 111;
    tutorialText.text = text;
    
    return tutorialText;
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

#pragma mark --Tutorial Stages

-(void)tutStageTwo {
    [self animateObjectOut:tapPlay withDelay:0.0];
    tutorialText = [self tutorialText:@"This is your Nova\nTap the screen to fly\nand just keep on tapping!"];
    [self addChild:tutorialText];
    [self animateObjectIn:tutorialText withDelay:0.5];
}

-(void)tutStageThree {
    [self animateObjectOut:tutorialText withDelay:0.0];
    for (int i = 0; i < 3; i++) {
        SKNode *node = [self createObstacles];
        node.name = [NSString stringWithFormat:@"aerial-%i", i];
        [self addChild:node];
        [self animateObjectIn:node withDelay:i/5];
    }
    tutorialText = [self tutorialText:@"These are obstacles.\nDon't run into these,\nthese are bad.\nAvoid at all costs!"];
    [self addChild:tutorialText];
    [self animateObjectIn:tutorialText withDelay:0.5];
}

-(void)tutStageFour {
    [self animateObjectOut:tutorialText withDelay:0.0];
    for (int x = 0; x < 3; x++) {
        [self animateObjectOut:[self childNodeWithName:[NSString stringWithFormat:@"aerial-%i", x]] withDelay:0.0];
    }
    for (int i = 0; i < 3; i++) {
        SKNode *node = [self createPowerUp];
        node.name = [NSString stringWithFormat:@"PowerUp-%i", i];
        [self addChild:node];
        [self animateObjectIn:node withDelay:i/5];
    }
        tutorialText = [self tutorialText:@"These are Power Ups.\nDefinitely collect these."];
        [self addChild:tutorialText];
        [self animateObjectIn:tutorialText withDelay:0.5];
}

-(void)tutStageFive {
    [self animateObjectOut:tutorialText withDelay:0.0];
    for (int x = 0; x < 3; x++) {
        [self animateObjectOut:[self childNodeWithName:[NSString stringWithFormat:@"PowerUp-%i", x]] withDelay:0.0];
    }
    for (int i = 0; i < 3; i++) {
        SKNode *node = [self createMultiplier];
        node.name = [NSString stringWithFormat:@"Multi-%i", i];
        [self addChild:node];
        [self animateObjectIn:node withDelay:i/5];
    }
    tutorialText = [self tutorialText:@"These are Multipliers.\nDefinitely collect these.\nThey boost your score\nexponentially."];
    [self addChild:tutorialText];
    [self animateObjectIn:tutorialText withDelay:0.5];
}

-(void)tutStageSix {
    [self animateObjectOut:tutorialText withDelay:0.0];
    for (int x = 0; x < 3; x++) {
        [self animateObjectOut:[self childNodeWithName:[NSString stringWithFormat:@"Multi-%i", x]] withDelay:0.0];
    }
    tutorialText = [self tutorialText:@"Oh yea,\nat the bottom of the screen?\nThat's a black hole.\nSteer clear, the closer\nyou get, the harder\nit is to escape!"];
    [self addChild:tutorialText];
    [self animateObjectIn:tutorialText withDelay:0.5];
}


#pragma mark --Power Ups

-(SKNode *)createMultiplier {
    int tempRand = arc4random()%80;
    double randYPosition = (tempRand+10)/100.0;
    
    SKSpriteNode *multiplier = [self createMultiplierRandom];
    multiplier.position = CGPointMake(self.size.width * 1.7, self.size.height * randYPosition);
    multiplier.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: multiplier.size];
    multiplier.physicsBody.categoryBitMask = CollisionCategoryScore;
    multiplier.physicsBody.dynamic = NO;
    multiplier.physicsBody.collisionBitMask = 0;
    multiplier.name = @"multiplier";
    multiplier.xScale = 0.6;
    multiplier.yScale = 0.6;
    multiplier.zPosition = 11;
    
    return multiplier;
}

-(SKSpriteNode *)createMultiplierRandom {
    SKSpriteNode *multitemp = [SKSpriteNode node];
    int randPup = (arc4random()% 4) + 1;
    
    switch (randPup) {
        case 1:
            multitemp = [SKSpriteNode spriteNodeWithImageNamed:@"2xMulti"];
            break;
        case 2:
            multitemp = [SKSpriteNode spriteNodeWithImageNamed:@"3xMulti"];
            break;
        case 3:
            multitemp = [SKSpriteNode spriteNodeWithImageNamed:@"4xMulti"];
            break;
        case 4:
            multitemp = [SKSpriteNode spriteNodeWithImageNamed:@"5xMulti"];
            break;
        default:
            break;
    }
    
    return multitemp;
}

-(SKNode *)createPowerUp {
    
        int tempRand = arc4random()%80;
        double randYPos = (tempRand + 10) / 100.0;
        
        powerUp = [[PowerUps alloc] powerUpTypes];
        SKSpriteNode *Pup = [[PowerUps alloc] createPupsWithType:powerUp];
        Pup.position = CGPointMake(self.size.width * 1.7, self.size.height * randYPos);
        Pup.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius: Pup.size.width * .3];
        Pup.physicsBody.categoryBitMask = CollisionCategoryPup;
        Pup.physicsBody.dynamic = NO;
        Pup.physicsBody.collisionBitMask = 0;
        Pup.name = @"PowerUp";
        Pup.zPosition = 11;
        
        return Pup;
        
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

#pragma mark --Animations

static const float duration = 0.7;

-(void)animateObjectOut: (SKNode *)node withDelay: (float)delay {
    SKAction *wait = [SKAction waitForDuration:delay];
    SKAction *move = [SKAction moveByX:self.size.width y:0.0 duration:duration];
    move.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *remove = [SKAction removeFromParent];
    [node runAction:[SKAction sequence:@[wait, move, remove]]];
}

-(void)animateObjectIn: (SKNode *)node withDelay: (float)delay {
    SKAction *wait = [SKAction waitForDuration:delay];
    SKAction *move = [SKAction moveByX:-self.size.width y:0.0 duration:duration];
    move.timingMode = SKActionTimingEaseInEaseOut;
    [node runAction:[SKAction sequence:@[wait, move]]];
}


#pragma mark --User Interface

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touchLift = [touches anyObject];
    CGPoint locationLift = [touchLift locationInNode:self];
    SKNode *nodeLift = [self nodeAtPoint:locationLift];
    
    SKView * levelOneView = (SKView *)self.view;
    levelOneView.showsFPS = YES;
    levelOneView.showsNodeCount = YES;
    //levelOneView.showsPhysics = YES;
    
    // Create and configure the scene.
    SKScene * levelOneScene = [[LevelOne alloc] initWithSize:levelOneView.bounds.size];
    levelOneScene.scaleMode = SKSceneScaleModeAspectFill;
    SKTransition *levelOneTrans = [SKTransition fadeWithColor:[SKColor whiteColor] duration:0.5];
    
    if ([nodeLift.name isEqualToString:@"skipButton"]) {
        
        // Present the scene.
        [levelOneView presentScene:levelOneScene transition:levelOneTrans];
    } else
        switch (tutorialStage) {
            case 1:
                [self tutStageTwo];
                break;
            case 2:
                [self tutStageThree];
                break;
            case 3:
                [self tutStageFour];
                break;
            case 4:
                [self tutStageFive];
                break;
            case 5:
                [self tutStageSix];
                break;
            case 6:
                [levelOneView presentScene:levelOneScene transition:levelOneTrans];
                break;
            default:
                break;
        }
        tutorialStage ++;
    
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
