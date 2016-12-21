//
//  JBBullet.h
//  ProjectX
//
//  Created by Johan Boqvist on 30/10/14.
//  Copyright (c) 2014 ___johboq-7___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "JBTower.h"

@interface JBBullet : SKSpriteNode

-(id) initWithColor:(UIColor*)color andSize:(CGSize)size andPosition:(CGPoint)position;

@property int damage;
@property JBTower* parentTower;

@end
 