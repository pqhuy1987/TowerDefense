//
//  JBTower.m
//  ProjectX
//
//  Created by Johan Boqvist on 30/10/14.
//  Copyright (c) 2014 ___johboq-7___. All rights reserved.
//
/* Factory class which creates towers */

#import "JBTower.h"
#import "JBMob.h"

extern const uint32_t bulletCategory;


@implementation JBTower


-(id) initWithTowerType:(NSString*)type andPosition:(CGPoint)position {
    
    
    self = [super initWithImageNamed:type];
    
    if (self) {
        
        _canTargetAir = NO;
        _targets = [[NSMutableArray alloc] init];
        _fireCounter = 0;
        
        if([type isEqualToString:@"dmgTower"]){
            _range = 1.9;
            _coolDown = 22;
            _damage = 7;
            _freeze = 0;
            _cost = 25;
            _menuName = @"Dmg";
        }
        
        else if([type isEqualToString:@"rangeTower"]){
            _range = 4.2;
            _coolDown = 31;
            _damage = 3;
            _freeze = 0;
            _cost = 15;
            _menuName = @"Range";
        }
        
        else if([type isEqualToString:@"slowTower"]){
            _range = 3.6;
            _coolDown = 37;
            _damage = 0;
            _freeze = 1;
            _cost = 18;
            _menuName = @"Freeze";
        }
        
        else if([type isEqualToString:@"airTower"]){
            _range = 3.2;
            _coolDown = 42;
            _damage = 4;
            _freeze = 0;
            _canTargetAir = YES;
            _cost = 20;
            _menuName = @"Air";
        }
        
        self.position = position;
        self.xScale = SCALE_X;
        self.yScale = SCALE_Y;
        
        /*set up physics */
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.range * TILE_WIDTH];
        self.physicsBody.dynamic = YES;
        self.physicsBody.categoryBitMask = towerCategory;
        self.physicsBody.contactTestBitMask = mobCategory;
        self.physicsBody.collisionBitMask = 0;
        
    }
    
    return self;
    
}



@end




