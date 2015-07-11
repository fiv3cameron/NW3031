//
//  NWCollisions.h
//  Nova Wing
//
//  Created by Cameron Frank on 11/25/14.
//  Copyright (c) 2014 FIV3 Interactive, LLC. All rights reserved.
//

#ifndef Nova_Wing_NWCollisions_h
#define Nova_Wing_NWCollisions_h

typedef NS_OPTIONS(uint32_t, CollisionCategory) {
    CollisionCategoryPlayer     = 0x1 << 0,
    CollisionCategoryShield     = 0x1 << 1,
    CollisionCategoryLaser      = 0x1 << 2,
    CollisionCategoryScore      = 0x1 << 3,
    CollisionCategoryObject     = 0x1 << 4,
    CollisionCategoryBottom     = 0x1 << 5,
    CollisionCategoryMulti      = 0x1 << 6,
    CollisionCategoryPup        = 0x1 << 7,
};

#endif