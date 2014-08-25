//
//  GameObjects.m
//  Nova Wing
//
//  Created by Bryan Todd on 8/11/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#import "GameObjects.h"

@implementation GameObjects

- (BOOL) collisionOccured:(SKNode *)player
{
    return NO;
}

- (void) pillarsToRemove:(CGFloat)playerX
{
    if (playerX > self.position.x + 150.0f) {
        [self removeFromParent];
    }
}

@end