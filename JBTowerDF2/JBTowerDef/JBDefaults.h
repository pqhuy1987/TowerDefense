//
//  JBDefaults.h
//  JBTowerDef
//
//  Created by Johan Boqvist on 02/11/14.
//  Copyright (c) 2014 ___johboq-7___. All rights reserved.
//

#import <Foundation/Foundation.h>

static const uint32_t towerCategory     = 0x1 << 0;
static const uint32_t mobCategory      = 0x1 << 1;
static const uint32_t bulletCategory      = 0x1 << 2;
static const int MAP_WIDTH = 16;
static const int MAP_HEIGHT = 11;
static const int START_DELAY = 100;

extern float SCALE_X;
extern float SCALE_Y;
extern float TILE_WIDTH;
extern float TILE_HEIGHT;


@interface JBDefaults : NSObject


@end
