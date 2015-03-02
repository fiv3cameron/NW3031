//
//  ViewController.m
//  Nova Wing
//
//  Created by Bryan Todd on 8/11/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import "ViewController.h"
#import "MainMenu.h"

@interface ViewController () <ADBannerViewDelegate>
    @property (nonatomic, strong) ADBannerView *theBanner;
@end

@implementation ViewController

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

-(void)viewWillLayoutSubviews {

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
        // Configure iAd
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"showAd" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"hideAd" object:nil];
    

    // Configure the view.
    SKView * skView = (SKView *)self.originalContentView;
    // Create and configure the scene.
    SKScene * scene = [MainMenu sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    if (banner.isBannerLoaded) {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height);
        [UIView commitAnimations];
    }
}

-(void)bannerViewDidLoadAd:(ADBannerView *)banner {
    if (!banner.isBannerLoaded) {
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);
        [UIView commitAnimations];
    }
}

-(void)handleNotification: (NSNotification *)notification {
    if ([notification.name isEqualToString:@"showAd"]) {
        NSLog(@"this should show twice..");
        self.theBanner = [[ADBannerView alloc] initWithFrame:CGRectZero];
        self.theBanner.delegate = self;
        [self.theBanner sizeToFit];
        self.canDisplayBannerAds = YES;
    } else if ([notification.name isEqualToString:@"hideAd"]) {
        self.theBanner.delegate = nil;
        self.canDisplayBannerAds =  NO;
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
