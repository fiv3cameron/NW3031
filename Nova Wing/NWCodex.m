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
@property (nonatomic, assign) CGPoint startPosition;
@property (nonatomic, assign) CGPoint endPosition;
@property (nonatomic, assign) NSMutableDictionary *statsDictionary;
@end


@implementation NWCodex
{
    SKSpriteNode *background;
    SKSpriteNode *tutorialButton;
    NSString *codexButton;
    NSString *codexPress;
    NSString *statsButton;
    NSString *statsPress;
    CGFloat deltaXSwipe;
    CGFloat deltaXRelease;
    SKSpriteNode *codexParent;
    int currentCodexIndex;
    SKCropNode *codexMask;
    CGPoint codexPointStart;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        codexButton = @"buttonCodex.png";
        codexPress = @"buttonPressCodex.png";
        statsButton = @"buttonPressStats.png"; //yes, these are backwards...
        statsPress = @"buttonStats.png";
        
        currentCodexIndex = 0;
        codexPointStart = CGPointMake(self.size.width * 0.1, self.size.height * 3 / 4);
        
        self.backgroundColor = [SKColor blackColor];
        [self addChild: [self createBackground]];
        [self addChild: [self codexPopBackground]];
        [self addChild: [self backToMainButton]];
        [self addChild: [self playTutorialButton]];
        [self addChild: [self toggleButton]];
        [self createCodexParent];
        [self createCodex];
        [self fadeNodeInWithNode:codexParent];
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
    node.name = @"black_square";
    
    CGRect rect = CGRectMake(-(self.size.width * 0.9)/2, -(self.size.height / 2)/2, self.size.width * 0.9, self.size.height / 2);
    SKShapeNode *blackStripe = [SKShapeNode node];
    [blackStripe setPath: CGPathCreateWithRoundedRect(rect, POP_RoundRect, POP_RoundRect, nil)];
    blackStripe.fillColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.75];
    blackStripe.strokeColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    blackStripe.name = @"black_shape";
    
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
        [self fadeNodeOutWithNode:codexParent];
        [self addChild:[self createStats]];
        [self fadeNodeInWithNode:_statsPage];
        _codexIsActive = NO;
    } else {
        _toggleButton.texture = [SKTexture textureWithImageNamed:statsButton];
        [self fadeNodeOutWithNode:_statsPage];
        [self fadeNodeInWithNode:codexParent];
        _codexIsActive = YES;
    }
}

-(void)fadeNodeInWithNode: (SKSpriteNode *)node {
    SKAction *fade = [SKAction fadeInWithDuration:0.75];
    [node runAction:fade];
}

-(void)fadeNodeOutWithNode: (SKSpriteNode *)node {
    SKAction *fade = [SKAction fadeOutWithDuration:0.75];
    //SKAction *remove = [SKAction removeFromParent];
    //[node runAction:[SKAction sequence:@[fade, remove]]];
    [node runAction:fade];
}

#pragma mark --Content Creation

-(void)createCodexParent {
    //codex parent stuff here...
    codexParent = [[SKSpriteNode alloc] init];
    codexParent.position = codexPointStart;
    codexParent.anchorPoint = CGPointMake(0, 1.0);
    codexParent.alpha = 0.0;
    
    //Add animation lines here.
    [self addChild:codexParent];
}

#define SCROLL_WIDTH self.size.width

-(void)createCodex {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Codex" ofType:@".plist"];
    NSDictionary *codexDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    NSArray *imageNames = [codexDictionary objectForKey:@"Image Strings"];
    NSArray *scaleFactors = [codexDictionary objectForKey:@"Image Scale Factors"];
    
    SKNode *blackSquare = [self childNodeWithName:@"black_square"];
    
    //Image loading loop starts at array index 0, but nothing happens at image zero because "codex" page has no image.
    for (int i = 0; i<=[imageNames count]-1; i++) {
        if (i == 0) {
            //do nothing, codex page has no image.
        } else {
            NSString *tempImageString = [imageNames objectAtIndex:i];
            SKSpriteNode *tempAddToCodex = [SKSpriteNode spriteNodeWithImageNamed:tempImageString];
            tempAddToCodex.position = CGPointMake(i*SCROLL_WIDTH + [blackSquare childNodeWithName:@"black_shape"].frame.size.width*0.82, -2.5*([blackSquare childNodeWithName:@"black_shape"].frame.size.height/20));
            NSNumber *tempScale = [scaleFactors objectAtIndex:i];
            tempAddToCodex.xScale = tempScale.floatValue;
            tempAddToCodex.yScale = tempScale.floatValue;
            [codexParent addChild:tempAddToCodex];
        }
        
        //Text descriptions --> CANNOT LOAD THIS INTO PLIST OR NORLABELNODE WILL NOT WORK!!
        NORLabelNode *description = [[NORLabelNode alloc] initWithFontNamed:@"SF Movie Poster"];
        NSString *tempText = [NSString string];
        
        switch (i) {
            case 0:
                tempText = @"THIS IS THE NOVA WING CODEX.  THIS DOCUMENT HOUSES\nDESCRIPTIONS OF THE VARIOUS ITEMS IN-GAME, AND WILL SERVE AS A\nUSEFUL REFERENCE IN TIMES OF GREAT PERIL, OR JUST WHEN YOU\nWANT TO KNOW MORE ABOUT A PARTICULAR ITEM.\n \nSWIPE TO NAVIGATE BETWEEN PAGES.";
                break;
            case 1:
                tempText = @"--NOVA--\nTHE IRIDON INDUSTRIES T-77 “NOVA” WAS DESIGNED\nAS A SPACE-COMBAT TRAINING VESSEL. ENGINEERED FOR TRAINING,\nITS BATTLE MANAGEMENT SYSTEMS LEAVE MUCH TO BE DESIRED.\nHOWEVER, IN TRUE IRIDON FASHION, WHAT IT DOES, IT DOES WELL.\nMORE MANEUVERABLE THAN ANY SHIP IN UAA’S FLEET, IT ALLOWS\nTRAINEES TO HONE THEIR REACTION TIMES USING A MODIFIED IRIDON\nSUPER-LIGHT ENGINE SALVAGED FROM THE RETIRED FLEET OF M-CAT’S.\nTHE MODIFICATION PORTS ENGINE THRUST THROUGH FORWARD APERTURES,\nALLOWING FOR EXTREME PITCH-UP MANEUVERS AND RAPID RESPONSE\nIN ALL POSSIBLE TRAINING MISSIONS.";
                break;
            case 2:
                tempText = @"--AUTOCANNON--\nSPECIFICALLY ENGINEERED FOR TRAINING, THE NOVA’S\nOFFENSIVE AND DEFENSIVE SYSTEMS LEAVE MUCH TO BE\nDESIRED.  WHILE THE NOVA IS OUTFITTED WITH A SINGLE LASER\nCANNON, THE OFFENSIVE/DEFENSIVE CAPABILITY MANAGEMENT SYSTEM\nHAS BEEN DISABLED FOR TRAINING MISSIONS AND IS ONLY TO BE\nENABLED IN DIRE CIRCUMSTANCES AT THE DIRECTION OF THE TRAINING\nSUPERVISOR.  PER UAA’S REQUEST, IRIDON FIXED-MOUNTED THE\nLASERS AND REGULATED THE SPEED OF FIRE TO ELIMINATE ANY\nROOM FOR “PILOT ERROR”.";
                break;
            case 3:
                tempText = @"--WINGMAN--\nIN THE EVENT OF AN EMERGENCY, EACH NOVA COMES\nEQUIPPED WITH A “HAIL SUPPORT” FEATURE, ALLOWING\nFOR RAPID MATERIALIZATION OF AN AVAILABLE PILOT FROM\nTHE “ON-CALL” LIST.  THIS SHOULD ONLY BE USED IN THE MOST\nDANGEROUS OF CIRCUMSTANCES, AND PROVIDES AUTOMATIC\nAUTHORIZATION FOR ACTIVATION OF THE AUTOCANNON.  THIS PROVIDES\nMISSION CONTINUITY - SHOULD A TERRIBLE FATE BEFALL A PILOT, THE\nWINGMAN WILL ENSURE THAT THE MISSION GOES ON.";
                break;
            case 4:
                tempText = @"--OVERSHIELD--\nEACH NOVA COMES EQUIPPED WITH A SHIELD\nGENERATOR.  THE (PATENT-PENDING) IRIDON INDUSTRIES\nPROGRESSIVE FACET OVERSHIELD IS THE NEXT GENERATION OF SHIELD\nTECHNOLOGY.  HOWEVER, THE ISL ENGINES SALVAGED FROM THE M-CAT\nFLEET WERE NOT DESIGNED TO PROVIDE THE MASSIVE AMOUNTS OF\nPOWER NEEDED FOR THESE SHIELDS.  THE IRIDON ENGINEERING CORPS\nDEVISED A WORKAROUND, BUT THE NOVA’S MANEUVERABILITY STILL\nSUFFERS WHEN SHIELDED.";
                break;
            case 5:
                tempText = @"--TINY NOVA--\nTHERE’S NO SCIENTIFIC, LOGICAL, NUMERICAL,\nALPHABETICAL, OR HIPPO-THETICAL REASON WHY THE\nNOVA RANDOMLY SHRINKS IN SIZE.  STRANGELY, IT DOESN’T SHRINK\nENGINE POWER.  WHILE THE SHIP HAS BEEN REDUCED IN SIZE, ITS\nFORWARD APERTURE THRUSTERS CAN POWER THE NOVA TO ESCAPE\nFROM ANYTHING, EVEN BENEATH THE EVENT HORIZON OF A BLACK HOLE.\nALSO, DOUBLE POINTS!";
                break;
            case 6:
                tempText = @"--MULTIPLIERS--\nPOSITION WITHIN THE RANKS OF THE UAA\nAERONAUTIC AND SPACE DIVISION IS DETERMINED BY YOUR\nSCORE.  YOU MAY ASK “WHAT SCORE?” AND WE WOULD HAVE NO\nGOOD ANSWER FOR YOU.  BUT WE DO KNOW THIS - COLLECTING\nMULTIPLIERS ALLOWS YOUR SCORE TO BUILD EVEN FASTER, BUT NOT\nWITHOUT COST.  THE MULTIPLIER BOOSTS ENGINE THRUST, PROPELLING\nYOU EVEN FASTER AND FASTER TOWARDS WHAT MAY OR MAY NOT\nBE CERTAIN DOOM.";
                break;
            case 7:
                tempText = @"--RANK: FLIGHT SCHOOL GRADUATE--\nCONGRATULATIONS, YOU’VE GRADUATED FROM FLIGHT\nSCHOOL, WHICH MEANS YOU ARE NOW AUTHORIZED TO\nPERFORM THE SAME TRAINING MISSIONS AS DONE IN FLIGHT SCHOOL,\nEXCEPT IN MORE DANGEROUS SITUATIONS.  DON’T WRECK THAT NOVA.\nEACH ONE COSTS UAA 8.4 MILLION TRINITS.";
                break;
            case 8:
                tempText = @"--RANK: CADET--\nALRIGHT CADET, YOU’VE PROVEN YOURSELF WORTHY\nOF TAKING ON MORE COMPLICATED MISSIONS.  IT’S\nTOO BAD THOSE COMPLICATED MISSIONS AREN’T REALLY AVAILABLE\nIN THIS SECTOR.  THE UAA TRAINING GROUNDS AREN’T QUITE THE\nFIRESTORM THEY USED TO BE, BUT MAYBE WE CAN FIND SOME\nSPACE-CANS TO SET ON A SPACE-FENCE-POST SO YOU CAN\nSPACE-SHOOT THEM.";
                break;
            case 9:
                tempText = @"--RANK: PRIVATE I--\nYOU’VE PROGRESSED TO THE LEVEL OF PRIVATE,\nRANK I.  BY NOW YOU’VE UNDOUBTEDLY LEARNED\n(ALMOST) ALL THE CONTROLS IN THE NOVA.  THEY TOLD YOU\nABOUT THE RADIATION SUPPRESSION SYSTEMS INSTALLED ON THE ISL\nENGINES, RIGHT?  THE SYSTEMS COULD BE DESCRIBED AS\n“GLITCHY” AT BEST.";
                break;
            case 10:
                tempText = @"--RANK: PRIVATE II--\nYOU’VE EARNED THE RESPECT OF YOUR FELLOW\nTRAINEES AND HAVE SHOWN YOUR SKILLS TO BE\nEXEMPLARY.  MORE COMPLEX TRAINING MISSIONS WILL HONE YOUR\nSKILLS BEYOND RAZOR SHARP, BUT MOST IMPORTANTLY, YOU GET\nTO LINE UP EARLIER AT MESS HALL.";
                break;
            case 11:
                tempText = @"--RANK: SERGEANT I--\nRECOGNITION AS A LEADER AMONGST TRAINEES\nIN YOUR DIVISION HAS EARNED YOU THE RANK OF\nSERGEANT I.  GREATER RESPONSIBILITY WITHIN THE SQUADRON\nSHOULD IMBUE A FEELING OF PRIDE AND ACCOMPLISHMENT IN A\nSEASONED PILOT SUCH AS YOURSELF.  PAY RAISE?  HA, NO.";
                break;
            case 12:
                tempText = @"--RANK: SERGEANT II--\nMANY TRAINEES DON’T MAKE IT TO THIS RANK\nIN TRAINING SCHOOL, SO YOU SHOULD FEEL PROUD.\nTYPICALLY THEY’VE EITHER TRANSFERRED TO A MORE TROPICAL\nASSIGNMENT, RUN HEADLONG INTO AN ASTEROID, OR EJECTED\nINTO EMPTY SPACE.  WE SHOULD REALLY MOVE THE EJECT BUTTON\nAWAY FROM THE ESPRESSO DISPENSER.";
                break;
            case 13:
                tempText = @"--RANK: FLIGHT COMMANDER--\nCONGRATULATIONS ON YOUR FIRST OFFICER\nCOMMISSION.  YOU’VE BEEN PLACED IN CHARGE OF\nTHE 84TH TRAINING FLIGHT AT LENNIS IV.  IN RECENT DAYS,\nTHE RECRUITS AT THIS FACILITY HAVE BEEN SKEPTICAL OF\nOUR COMMISSIONED OFFICERS, SO CONTINUE FLYING TRAINING MISSIONS\nALONGSIDE THEM TO GAIN THEIR TRUST.";
                break;
            case 14:
                tempText = @"--RANK: LIEUTENANT COMMANDER--\nTHE LIEUTENANT COMMANDER HAS ULTIMATE\nAUTHORITY OVER SOME DECISIONS IN THE OFFICE\nENVIRONMENT.  AS LIEUTENANT COMMANDER, YOU WILL BE ALLOWED\nTO SELECT THE BRAND OF TONER WE USE IN THE OFFICE PRINTERS.\nMAYBE YOU’RE MORE LIKE A “LIEUTENANT TO THE COMMANDER”.";
                break;
            case 15:
                tempText = @"--RANK: COMMANDER--\nYOU’VE BEEN PROMOTED TO THE HIGHEST POSITION\nWITHIN A TRAINING WING.  YOUR AUTHORITY IS\nOUTMATCHED ONLY BY THOSE IN COMMAND OF THE FLEET DIVISIONS.\nSINCE YOU INSIST ON FLYING THE NOVA ISSUED TO YOU IN TRAINING,\nWE’VE OUTFITTED IT WITH LEATHER SEATS, CUPHOLDERS,\nAND COMPLEMENTARY AIR FRESHENERS.";
                break;
            case 16:
                tempText = @"--RANK: FLEET GENERAL--\nPLACED OVER DIVISIONS INSTEAD OF TROOPS, YOU’VE\nFINALLY MADE THE BIG LEAGUES.  YOUR MOTHER WILL\nSURELY BE PROUD NOW.  NO?  SHE STILL FAVORS YOUR OLDER\nBROTHER BECAUSE HE WON THE FOOTBALL CHAMPIONSHIP IN HIGH SCHOOL,\nAND YOU ONLY RE-EVALUATED FROENHOFF’S WARP CALCULATIONS\nFOR TRAVEL THROUGH SOLID MATTER?  SORRY, BIG GUY…";
                break;
            case 17:
                tempText = @"--RANK: FLEET ADMIRAL--\nYOU’VE REACHED THE TOP.  YOU’VE NOT ONLY PROVEN\nYOUR WORTH IN COMBAT (WELL, TRAINING MISSIONS), BUT\nYOU’VE MANAGED TO WEAR OUT 4 ISL ENGINES AND COMPLETELY\nERODE THE PROTECTIVE COATING ON YOUR NOVA’S FORWARD\nAPERTURES.  AS SUCH, UAA HIGHLY RECOMMENDS THAT ITS SENIOR\nOFFICERS UTILIZE APPROVED FORMS OF EXECUTIVE TRANSPORT.\nHOWEVER, SOME SENIOR OFFICERS HAVE BEEN KNOWN TO MAINTAIN DEEP\nEMOTIONAL CONNECTIONS TO THEIR TRAINING SHIPS.  UAA ENTERTAINS \nTHESE SENTIMENTALITIES SINCE THE OFFICERS ARE CLOSE TO\nRETIREMENT ANYWAY.";
                break;
            default:
                break;
        }
        [description setFontSize:23];
        [description setLineSpacing:1.0];
        [description setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeLeft];
        [description setVerticalAlignmentMode:SKLabelVerticalAlignmentModeTop];
        [description setText:tempText];
        [description setPosition: CGPointMake(0 + i*self.size.width, -([blackSquare childNodeWithName:@"black_shape"].frame.size.height/20))];
        description.fontColor = [UIColor colorWithWhite:1 alpha:1];
        description.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        description.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
        [codexParent addChild:description];
    }
}

#define STATS_LINE_SPACING 1.0
#define STATS_FONT_SIZE 28

-(SKSpriteNode *)createStats {
    _statsPage = [SKSpriteNode node];
    _statsPage.alpha = 0.0;

    //Stats Page
    NSString *highScore = [NSString stringWithFormat:@"%ld", [GameState sharedGameData].highScoreL1];
    NSString *totalLaserHits = [NSString stringWithFormat:@"%d", [GameState sharedGameData].totalLaserHits];
    NSString *totalLasersFired = [NSString stringWithFormat:@"%d", [GameState sharedGameData].totalLasersFired];
    NSString *totalAsteroidsDestroyed = [NSString stringWithFormat:@"%d", [GameState sharedGameData].totalAsteroidsDestroyed];
    //NSString *totalDebrisDestroyed = [NSString stringWithFormat:@"%d", [GameState sharedGameData].totalDebrisDestroyed];
    //NSString *totalChallengePoints = [NSString stringWithFormat:@"%d", [GameState sharedGameData].totalChallengePoints];
    NSString *totalGames = [NSString stringWithFormat:@"%d", [GameState sharedGameData].totalGames];
    NSString *totalBlackHoleDeaths = [NSString stringWithFormat:@"%d", [GameState sharedGameData].totalBlackHoleDeaths];
    NSString *totalAsteroidDeaths = [NSString stringWithFormat:@"%d", [GameState sharedGameData].totalAsteroidDeaths];
    //NSString *totalDebrisDeaths = [NSString stringWithFormat:@"%d", [GameState sharedGameData].totalDebrisDeaths];
    NSString *averageScore = [NSString stringWithFormat:@"%f", (float)[GameState sharedGameData].allTimeAverageScore];
    NSString *accuracy = [NSString stringWithFormat:@"%f%%", (float)[GameState sharedGameData].allTimeAverageAccuracy*100];
    NSArray *infoStrings = [[NSArray alloc] initWithObjects:highScore, totalLaserHits, totalLasersFired, totalAsteroidsDestroyed, totalGames, totalBlackHoleDeaths, totalAsteroidDeaths, averageScore, accuracy, nil];
    NSString *statsInfoText = [infoStrings componentsJoinedByString:@"\n"];
    
    NSString *statsDescriptorsText = @"High Score:\nTotal Laser Hits:\nTotal Lasers Fired:\nTotal Asteroids Destroyed:\nTotal Games:\nTotal Black Hole Deaths:\nTotal Asteroid Deaths:\nAll Time Average Score:\nAll Time Average Accuracy:";
    SKNode *blackSquare = [self childNodeWithName:@"black_square"];
    
    NORLabelNode *statsDescriptors = [[NORLabelNode alloc] initWithFontNamed:@"SF Movie Poster"];
    [statsDescriptors setFontSize:STATS_FONT_SIZE];
    [statsDescriptors setLineSpacing:STATS_LINE_SPACING];
    [statsDescriptors setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeLeft];
    [statsDescriptors setVerticalAlignmentMode:SKLabelVerticalAlignmentModeTop];
    [statsDescriptors setText:statsDescriptorsText];
    [statsDescriptors setPosition:CGPointMake(codexPointStart.x,codexPointStart.y-([blackSquare childNodeWithName:@"black_shape"].frame.size.height/20))];
    
    NORLabelNode *statsInfo = [[NORLabelNode alloc] initWithFontNamed:@"SF Movie Poster"];
    [statsInfo setFontSize:STATS_FONT_SIZE];
    [statsInfo setLineSpacing:STATS_LINE_SPACING];
    [statsInfo setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeRight];
    [statsInfo setVerticalAlignmentMode:SKLabelVerticalAlignmentModeTop];
    [statsInfo setText:statsInfoText];
    [statsInfo setPosition:CGPointMake([blackSquare childNodeWithName:@"black_shape"].frame.size.width, codexPointStart.y-([blackSquare childNodeWithName:@"black_shape"].frame.size.height/20))];
    
    [_statsPage addChild:statsInfo];
    [_statsPage addChild:statsDescriptors];
    return _statsPage;
}

#pragma mark --Create Audio

-(void)playSoundEffectsWithAction: (SKAction *)action {
    if ([GameState sharedGameData].audioVolume == 1.0) {
        [self runAction:action];
    }
}

#define BTM_RoundRect 8

-(SKSpriteNode *)backToMainButton
{
    SKSpriteNode *node = [SKSpriteNode node];
    node.position = CGPointMake(45.0f, self.size.height - 40);
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
    self.startPosition = [touchLift locationInNode:self];
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
    self.endPosition = [touchLift locationInNode:self];
    SKNode *nodeLift = [self nodeAtPoint:locationLift];
    
    SKAction *createSound = [SKAction playSoundFileNamed:@"Button-Press.caf" waitForCompletion:NO];
    SKAction *playSound = [SKAction runBlock:^{
        [self playSoundEffectsWithAction:createSound];
    }];
    
    deltaXRelease = _endPosition.x - _startPosition.x;
    int swipeDirection;
    
    if (deltaXRelease >= 20) {
        swipeDirection = 1;
    } else if (deltaXRelease <= -20) {
        swipeDirection = -1;
    } else {
        swipeDirection = 0;
    }
    
    //Global Transition Properties
    
    if ([nodeLift.name isEqualToString:@"backToMain"]) {
        SKView *mainMenuView = (SKView *)self.view;
        SKScene *mainMenuScene = [[MainMenu alloc] initWithSize:mainMenuView.bounds.size];
        SKTransition *menuTransition = [SKTransition fadeWithDuration:.5];
        SKAction *newSceneAction = [SKAction runBlock:^() {
            // Present the scene.
            [mainMenuView presentScene:mainMenuScene transition:menuTransition];
        }];
        [self runAction:[SKAction sequence:@[playSound,newSceneAction]]];
    };
    
    if ([nodeLift.name isEqualToString:@"tutorialButton"]) {
        //Start Tutorial
        SKView * tutView = (SKView *)self.view;
        //tutView.showsFPS = YES;
        //tutView.showsNodeCount = YES;
        //levelOneView.showsPhysics = YES;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAd" object:nil];
        
        // Create and configure the scene.
        SKScene * tutScene = [[Tutorial alloc] initWithSize:tutView.bounds.size];
        tutScene.scaleMode = SKSceneScaleModeAspectFill;
        SKTransition *tutTrans = [SKTransition fadeWithColor:[SKColor whiteColor] duration:0.5];
        SKAction *newSceneAction = [SKAction runBlock:^() {
            // Present the scene.
            [tutView presentScene:tutScene transition:tutTrans];
        }];
        [self runAction:[SKAction sequence:@[playSound,newSceneAction]]];
    }
    
    if ([nodeLift.name isEqualToString:@"toggleButton"]) {
        SKAction *newSceneAction = [SKAction runBlock:^() {
            // Present the scene.
            [self toggleButtonLogic];
        }];
        [self runAction:[SKAction group:@[playSound,newSceneAction]]];
    }
    
    int swipeAllowed;
    
    //Codex functions.
    if ((currentCodexIndex == 0 && swipeDirection > 0) || (currentCodexIndex == 17 && swipeDirection < 0) || !(_codexIsActive)) {
        //Attempted swipe left at index zero or swipe right at index 17 should return to initial codex position.  Do nothing.
        swipeAllowed = 0;
    } else {
        currentCodexIndex = currentCodexIndex - swipeDirection*1; //Swipe right indicates positive swipe direction, but current codex index should decrease.
        swipeAllowed = 1;
    }
    
    CGVector newCodexMove = CGVectorMake(swipeDirection*self.size.width*swipeAllowed, 0);
    SKAction *move = [SKAction moveBy:newCodexMove duration:0.15];
    [codexParent runAction:move];
}

@end