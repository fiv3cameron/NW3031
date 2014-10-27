//
//  PowerUps.h
//  Nova Wing
//
//  Created by Cameron Frank on 10/25/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(int, pupType) {
    null_pup,
    Wing_man,
    Over_shield,
    Auto_Cannon,
};

@interface PowerUps : NSObject

@property (nonatomic, assign) pupType powerUp;

-(SKSpriteNode *)createPupsWithType: (pupType)type;
-(pupType)powerUpTypes;


@end
