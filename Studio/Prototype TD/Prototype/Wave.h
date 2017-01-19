//
//  Wave.h
//  Prototype
//
//  Created by Nicolas Goles on 9/12/12.
//
//

#import "cocos2d.h"

@class Creep;

@interface Wave : CCNode

@property (assign) float spawnRate;
@property (assign) int totalCreeps;
@property (strong) Creep *creepType;

- (id) initWithCreepType:(Creep *) creep spawnRate:(float) spawningRate creepNumber:(int) number;

@end
