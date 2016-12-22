//
//  Common.h
//  Prison Bust
//
//  Created by Mac Admin on 4/23/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#ifndef Prison_Bust_Common_h
#define Prison_Bust_Common_h



static NSString *fenceIdentifier = @"fence";
static NSString *missileIdentifier = @"missile";
static NSString *spikePitIdentifier = @"spikePit";

static const uint32_t playerCategory  = 0x1 << 0;
static const uint32_t backgroundCategory = 0x1 << 1;
static const uint32_t enemyCategory = 0x1 << 2;
static const uint32_t powerUpCategory = 0x1 << 3;
static const uint32_t groundBitMask = 0x1 << 4;
static const uint32_t nilBitMask = 0x1 << 6;
#endif
