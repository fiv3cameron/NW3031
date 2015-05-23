//
//  GameOverL1.m
//  Nova Wing
//
//  Created by Bryan Todd on 8/11/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import "GameOverL1.h"
#import "MainMenu.h"
#import "LevelOne.h"

@implementation GameOverL1



-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor colorWithRed:0 green:0 blue:0 alpha:1];
        
        SKSpriteNode *bgImg = [SKSpriteNode spriteNodeWithImageNamed:@"GameOver-L1"];
        bgImg.anchorPoint = CGPointMake(0.5f, 0.0f);
        bgImg.position = CGPointMake(160.0f, 0.0f);
        
        [[GameState sharedGameData] save];
        
        
        [self addChild:bgImg];
        [self addChild:[self backToMenu]];
        [self createCurrentScore];
        [self createHighScore];
        [self playAgainButton];
        
        
    }
    return self;
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
    playAgain.position = CGPointMake(self.size.width / 2, self.size.height/6);
    playAgain.name = @"playButton";
    [self addChild:playAgain];
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

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
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

@end
