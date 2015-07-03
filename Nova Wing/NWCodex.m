//
//  NWCodex.m
//  Nova Wing
//
//  Created by Cameron Frank on 12/6/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import "NWCodex.h"
#import "MainMenu.h"
#import "Tutorial.h"

@interface NWCodex ()
    @property (nonatomic) BOOL codexIsActive;
    @property (nonatomic) SKSpriteNode *statsPage;
    @property (nonatomic) SKSpriteNode *codexPage;
    @property (nonatomic) SKSpriteNode *toggleButton;
@end


@implementation NWCodex
{
    SKSpriteNode *background;
    SKSpriteNode *tutorialButton;
    NSString *codexButton;
    NSString *codexPress;
    NSString *statsButton;
    NSString *statsPress;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        codexButton = @"buttonCodex.png";
        codexPress = @"buttonPressCodex.png";
        statsButton = @"buttonPressStats.png"; //yes, these are backwards...
        statsPress = @"buttonStats.png";
    
        self.backgroundColor = [SKColor blackColor];
        [self addChild: [self createBackground]];
        [self addChild: [self codexPopBackground]];
        [self addChild: [self backToMainButton]];
        [self addChild: [self playTutorialButton]];
        [self addChild: [self toggleButton]];
        
    }
    return self;
}

-(SKSpriteNode *)createBackground {
    background = [SKSpriteNode spriteNodeWithImageNamed:@"CodexBG.jpg"];
    background.anchorPoint = CGPointZero;
    background.position = CGPointMake(0, 0);
    return background;
}

#define POP_RoundRect 10

-(SKSpriteNode *)codexPopBackground {
    SKSpriteNode *node = [SKSpriteNode node];
    node.position = CGPointMake(self.size.width / 2, self.size.height / 2);
    
    CGRect rect = CGRectMake(-(self.size.width * 0.9)/2, -(self.size.height / 2)/2, self.size.width * 0.9, self.size.height / 2);
    SKShapeNode *blackStripe = [SKShapeNode node];
    [blackStripe setPath: CGPathCreateWithRoundedRect(rect, POP_RoundRect, POP_RoundRect, nil)];
    blackStripe.fillColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.75];
    blackStripe.strokeColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    
    [node addChild:blackStripe];
    
    return node;
}

-(SKSpriteNode *)toggleButton {
    _toggleButton = [SKSpriteNode spriteNodeWithImageNamed:statsButton];
    _toggleButton.position = CGPointMake(self.size.width/2, self.size.height * 0.8);
    _toggleButton.xScale = 0.5;
    _toggleButton.yScale = 0.5;
    _toggleButton.name = @"toggleButton";
    
    _codexIsActive = YES;
    
    return _toggleButton;
}

-(void)toggleButtonPressLogix {
    if (_codexIsActive) {
        _toggleButton.texture = [SKTexture textureWithImageNamed:statsPress];
    } else {
        _toggleButton.texture = [SKTexture textureWithImageNamed:codexPress];
    }
}

-(void)toggleButtonLogic {
    if (_codexIsActive) {
        _toggleButton.texture = [SKTexture textureWithImageNamed:codexButton];
        _codexIsActive = NO;
            //Logic for transitioning to stats page goes here
        
    } else {
        _toggleButton.texture = [SKTexture textureWithImageNamed:statsButton];
        _codexIsActive = YES;
            //Logic for transitioning to codex page goes here
        
    }
    
}

#pragma mark --Content Creation

-(void)createCodexParent {
        //codex parent stuff here...
    
}

-(SKSpriteNode *)createStats {
    _statsPage = [SKSpriteNode node];
        //stats page stuff here
    
    return _statsPage;
}


#define BTM_RoundRect 8

-(SKSpriteNode *)backToMainButton
{
    SKSpriteNode *node = [SKSpriteNode node];
    node.position = CGPointMake(45.0f, self.size.height - 40);
    
        //CGRect rect = CGRectMake(-60, -10, 120, 40);
    
    
    SKShapeNode *blackStripe = [SKShapeNode node];
    [blackStripe setPath:CGPathCreateWithRoundedRect(CGRectMake(-60, -10, 120, 40), BTM_RoundRect, BTM_RoundRect, nil)];
    blackStripe.fillColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    blackStripe.strokeColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    
    SKLabelNode *backToMain = [SKLabelNode labelNodeWithFontNamed:@"SF Movie Poster"];
    backToMain.alpha = 1.0;
    backToMain.fontColor = [SKColor whiteColor];
    backToMain.fontSize = 30;
    backToMain.name = @"backToMain";
    backToMain.text = @"BACK to MAIN";
    backToMain.position = CGPointMake(10.0f, 0);
    
    [node addChild:blackStripe];
    [node addChild:backToMain];
    
    return node;
}

-(SKSpriteNode *)playTutorialButton {
    tutorialButton = [SKSpriteNode spriteNodeWithTexture: [SKTexture textureWithImageNamed:@"buttonReplayTut.png"]];
    tutorialButton.position = CGPointMake(self.size.width/2, self.size.height / 5);
    tutorialButton.xScale = 0.5;
    tutorialButton.yScale = 0.5;
    tutorialButton.name = @"tutorialButton";
    return tutorialButton;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touchLift = [touches anyObject];
    CGPoint locationLift = [touchLift locationInNode:self];
    SKNode *nodeLift = [self nodeAtPoint:locationLift];
    
    if ([nodeLift.name isEqualToString:@"tutorialButton"]) {
        tutorialButton.texture = [SKTexture textureWithImageNamed:@"buttonPressReplayTut.png"];
    }
    
    if ([nodeLift.name isEqualToString:@"toggleButton"]) {
        [self toggleButtonPressLogix];
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
    
    if ([nodeLift.name isEqualToString:@"toggleButton"]) {
        [self toggleButtonLogic];
    }
    
}

@end
