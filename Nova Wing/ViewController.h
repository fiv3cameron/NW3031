//
//  ViewController.h
//  Nova Wing
//

//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <iAd/iAd.h>

@import GoogleMobileAds;

@interface ViewController : UIViewController <ADBannerViewDelegate,GADInterstitialDelegate>

@property (strong,nonatomic) GADBannerView *bannerView;
@property (strong, nonatomic) GADInterstitial *interstitial;

@end
