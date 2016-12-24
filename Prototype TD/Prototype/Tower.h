//
//  Tower.h
//  Prototype
//
//  Created by Nicolas Goles on 9/13/12.
//
//

#import "cocos2d.h"

@class Creep;
@class Projectile;

@interface Tower : CCSprite

@property (assign) int range;
@property (assign) int cost;
@property (strong) CCSprite *rangeSprite;
@property (strong) Creep *target;
@property (strong) NSMutableArray *projectiles;
@property (strong) Projectile *nextProjectile;

@end


@interface BasicTower : Tower
+ (id) tower;
- (void) logic:(ccTime) dt;
@end
