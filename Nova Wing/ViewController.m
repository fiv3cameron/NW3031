//
//  ViewController.m
//  Nova Wing
//
//  Created by Bryan Todd on 8/11/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

@import GoogleMobileAds;

#import "ViewController.h"
#import "MainMenu.h"

@interface ViewController () {

}

@property (nonatomic) BOOL allowsBanner;

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
    
    self.interstitial = [self createAndLoadInterstitial];
    
        // Configure iAd
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"showAd" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"hideAd" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"showInterstitial" object:nil];
    
    NSLog(@"Google Mobile Ads SDK Version: %@",[GADRequest sdkVersion]);
    
    self.bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait origin:CGPointMake(0, self.view.frame.size.height-CGSizeFromGADAdSize(kGADAdSizeBanner).height)];
    self.bannerView.hidden = YES;
    self.bannerView.adUnitID = @"ca-app-pub-2182637269476458/9989623723";
    self.bannerView.rootViewController = self;
    [self.view addSubview:self.bannerView];
    
    // Configure the view.
    SKView * skView = (SKView *)self.originalContentView;
    // Create and configure the scene.
    SKScene * scene = [MainMenu sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
    //self.canDisplayBannerAds = YES;
    
    /*theBanner = [[ADBannerView alloc] initWithFrame:CGRectZero];
    theBanner.frame = CGRectMake(0, skView.bounds.size.height - theBanner.frame.size.height, theBanner.frame.size.width, theBanner.frame.size.height);
    theBanner.delegate = self;
    [self.view addSubview:theBanner];
    self.allowsBanner = YES;*/
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(showAuthenticationViewController)
     name:PresentAuthenticationViewController
     object:nil];

}

- (void)showAuthenticationViewController
{
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    UIViewController *vc = self.view.window.rootViewController;
    [vc presentViewController: gameKitHelper.authenticationViewController animated:YES completion:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    if (!self.bannerIsVisible) {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height);
        [UIView commitAnimations];
        self.bannerIsVisible = NO;
    }
}

-(void)bannerViewDidLoadAd:(ADBannerView *)banner {
    if (!self.bannerIsVisible && self.allowsBanner) {
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        banner.frame = CGRectOffset(banner.frame, 0, 0);
        [theBanner setAlpha:0.0];
        [UIView commitAnimations];
        self.bannerIsVisible = YES;
    }
}*/

-(void)handleNotification: (NSNotification *)notification {
    if ([notification.name isEqualToString:@"showAd"]) {
        //NSLog(@"Show Ad Notification received");
        [self showBanner];
    } else if ([notification.name isEqualToString:@"hideAd"]) {
        //NSLog(@"Hide Ad Notification received");
        [self hideBanner];
    } else if ([notification.name isEqualToString:@"showInterstitial"]) {
        if ([self.interstitial isReady]) {
            [self.interstitial presentFromRootViewController:self];
        }
    }
}

/*-(void)hidesBanner {
    //NSLog(@"Hiding Banner");
    [theBanner setAlpha:0.0];
    self.bannerIsVisible = NO;
    self.allowsBanner = NO;
}

-(void)showsBanner {
    //NSLog(@"Showing Banner");
    [theBanner setAlpha:1.0];
    self.bannerIsVisible = YES;
    self.allowsBanner = YES;
}*/

-(void)showBanner {
    self.bannerView.hidden = NO;
    GADRequest *request = [GADRequest request];
    request.testDevices = @[@"1ee8a254a93a6f089ce1fdf6553dd250"];
    [[self bannerView] loadRequest:request];
}

-(void)hideBanner {
    self.bannerView.hidden = YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

-(GADInterstitial *)createAndLoadInterstitial {
    GADInterstitial *interstitial = [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-2182637269476458/8512890523"];
    interstitial.delegate = self;
    GADRequest *request = [GADRequest request];
    request.testDevices = @[@"1ee8a254a93a6f089ce1fdf6553dd250"];
    [interstitial loadRequest:request];
    return interstitial;
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    self.interstitial = [self createAndLoadInterstitial];
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

-(void) gameCenterViewControllerDidFinish: (GKGameCenterViewController *)gameCenterViewController {
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
