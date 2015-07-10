//
//  NWCodex.m
//  Nova Wing
//
//  Created by Cameron Frank on 12/6/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

@import CoreMotion;

#import "NWCodex.h"
#import "MainMenu.h"
#import "Tutorial.h"


@implementation NWCodex
{
    CMMotionManager *motionManager;
    SKSpriteNode *background;
    SKSpriteNode *tutorialButton;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
    
        self.backgroundColor = [SKColor blackColor];
        [self addChild: [self createBackground]];
        
        [self addChild: [self codexTitleLabel]];
        [self addChild: [self backToMainButton]];
        [self addChild: [self playTutorialButton]];

        
    }
    return self;
}

-(SKSpriteNode *)createBackground {
    background = [SKSpriteNode spriteNodeWithImageNamed:@"Codex_Constr.jpg"];
    background.anchorPoint = CGPointZero;
    background.position = CGPointMake(0, 0);
    return background;
}

-(SKSpriteNode *)codexTitleLabel {
    SKSpriteNode *node = [SKSpriteNode node];
    node.position = CGPointMake(self.size.width / 2, self.size.height / 2);
    
    CGRect rect = CGRectMake(-self.size.width / 2, -5, self.size.width, 50);
    SKShapeNode *blackStripe = [SKShapeNode shapeNodeWithRect:rect];
    blackStripe.fillColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    blackStripe.strokeColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    
    SKLabelNode *codex = [SKLabelNode labelNodeWithFontNamed:@"SF Movie Poster"];
    codex.fontColor = [SKColor whiteColor];
    codex.fontSize = 50;
    codex.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    codex.text = @"CODEX UNDER CONSTRUCTION";
    
    [node addChild:blackStripe];
    [node addChild:codex];
    
    return node;
}

-(SKSpriteNode *)playTutorialButton {
    tutorialButton = [SKSpriteNode spriteNodeWithTexture: [SKTexture textureWithImageNamed:@"buttonReplayTut.png"]];
    tutorialButton.position = CGPointMake(self.size.width/2, self.size.height / 4);
    tutorialButton.xScale = 0.5;
    tutorialButton.yScale = 0.5;
    tutorialButton.name = @"tutorialButton";
    return tutorialButton;
}

-(SKSpriteNode *)backToMainButton
{
    SKSpriteNode *node = [SKSpriteNode node];
    node.position = CGPointMake(60.0f, self.size.height - 40);
    
    CGRect rect = CGRectMake(-60, -10, 120, 40);
    SKShapeNode *blackStripe = [SKShapeNode shapeNodeWithRect:rect];
    blackStripe.fillColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    blackStripe.strokeColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    
    SKLabelNode *backToMain = [SKLabelNode labelNodeWithFontNamed:@"SF Movie Poster"];
    backToMain.alpha = 1.0;
    backToMain.fontColor = [SKColor whiteColor];
    backToMain.fontSize = 30;
    backToMain.name = @"backToMain";
    backToMain.text = @"BACK to MAIN";
    
    [node addChild:blackStripe];
    [node addChild:backToMain];
    
    return node;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touchLift = [touches anyObject];
    CGPoint locationLift = [touchLift locationInNode:self];
    SKNode *nodeLift = [self nodeAtPoint:locationLift];
    
    if ([nodeLift.name isEqualToString:@"tutorialButton"]) {
        tutorialButton.texture = [SKTexture textureWithImageNamed:@"buttonPressReplayTut.png"];
    }
}




-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //Called when a touch ends
    UITouch *touchLift = [touches anyObject];
    CGPoint locationLift = [touchLift locationInNode:self];
    SKNode *nodeLift = [self nodeAtPoint:locationLift];
    
    //Global Transition Properties
    
    if ([nodeLift.name isEqualToString:@"backToMain"]) {
        SKView *mainMenuView = (SKView *)self.view;
        SKScene *mainMenuScene = [[MainMenu alloc] initWithSize:mainMenuView.bounds.size];
        SKTransition *menuTransition = [SKTransition fadeWithDuration:.5];
        [mainMenuView presentScene:mainMenuScene transition:menuTransition];
    };
    
    if ([nodeLift.name isEqualToString:@"tutorialButton"]) {
        //Start Tutorial
        SKView * tutView = (SKView *)self.view;
        tutView.showsFPS = YES;
        tutView.showsNodeCount = YES;
        //levelOneView.showsPhysics = YES;
        
        // Create and configure the scene.
        SKScene * tutScene = [[Tutorial alloc] initWithSize:tutView.bounds.size];
        tutScene.scaleMode = SKSceneScaleModeAspectFill;
        SKTransition *tutTrans = [SKTransition fadeWithColor:[SKColor whiteColor] duration:0.5];
        
        // Present the scene.
        [tutView presentScene:tutScene transition:tutTrans];
    }
    
}

@end
