//
//  ViewController.h
//  Nova Wing
//

//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <iAd/iAd.h>

@interface ViewController : UIViewController <ADBannerViewDelegate>
{
        ADBannerView *theBanner;
}

@property (nonatomic) BOOL bannerIsVisible;

@end
