//
//  JBMob.h
//  ProjectX
//
//  Created by Johan Boqvist on 30/10/14.
//  Copyright (c) 2014 ___johboq-7___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "JBDefaults.h"

@interface JBMob : SKSpriteNode

@property SKSpriteNode *sprite;
@property Boolean       isFrozen;
@property Boolean       isFlying;
@property float         duration;
@property int           hp;
@property int           freezeCounter;
@property int           gold;

-(id) initWithSprite:(NSString*)sprite;
-(id) initWithMobType:(NSString*)type;

@end
