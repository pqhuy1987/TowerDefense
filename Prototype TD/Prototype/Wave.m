//
//  Wave.m
//  Prototype
//
//  Created by Nicolas Goles on 9/12/12.
//
//

#import "Wave.h"

@implementation Wave

- (id) init
{
    if (self = [super init]) {
        // init stuff.
    }
    
    return self;
}

- (id) initWithCreepType:(Creep *)creep spawnRate:(float)spawningRate creepNumber:(int)number
{
    if (self = [self init]) {
        _creepType = creep;
        _spawnRate = spawningRate;
        _totalCreeps = number;
    }
    
    return self;
}

@end
