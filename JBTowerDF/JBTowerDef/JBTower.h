//
//  JBTower.h
//  ProjectX
//
//  Created by Johan Boqvist on 30/10/14.
//  Copyright (c) 2014 ___johboq-7___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JBMob.h"
#import "JBDefaults.h"

@interface JBTower : SKSpriteNode

@property SKSpriteNode *sprite;
@property NSMutableArray *targets;
@property int range;
@property int fireCounter;
@property int coolDown;
@property int damage;
@property int freeze;
@property Boolean canTargetAir;
@property int cost;
@property NSString* menuName;


-(id) initWithTowerType:(NSString*)type andPosition:(CGPoint)position;


@end
