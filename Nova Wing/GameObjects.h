//
//  GameObjects.h
//  Nova Wing
//
//  Created by Bryan Todd on 8/11/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameObjects : SKNode

- (BOOL) collisionOccured:(SKNode *)player;
- (void) pillarsToRemove:(CGFloat)playerX;

@end
