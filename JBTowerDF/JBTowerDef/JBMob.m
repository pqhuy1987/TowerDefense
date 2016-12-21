//
//  JBMob.m
//  ProjectX
//
//  Created by Johan Boqvist on 30/10/14.
//  Copyright (c) 2014 ___johboq-7___. All rights reserved.
//
/* Factory class which creates mobs */

#import "JBMob.h"


@interface JBMob()

@property NSMutableArray *animationFrames;

@end

@implementation JBMob

-(id) initWithSprite:(NSString*)sprite {
    
    
    self = [super initWithImageNamed:sprite];
    
    if (self) {
        
    }
    
    return self;
    
}

-(id) initWithMobType:(NSString *)type {
    
    
    self = [super initWithImageNamed:[NSString stringWithFormat:@"%@1",type]];
    
    if (self) {
        
        _animationFrames = [NSMutableArray array];
        
        _isFrozen = NO;
        _freezeCounter = 0;
        _isFlying = NO;
        
        
        if([type isEqualToString:@"ghost"]){
        
            _hp = 14;
            _duration = 0.23;
            
            self.alpha = 0.6;
            _gold = 5;
            
        }
        
        else if([type isEqualToString:@"dwarf"]){
        
            _hp = 10;
            _duration = 0.14;
            _gold = 6;
        
        }
        else if([type isEqualToString:@"bat"]){
            
            _hp = 4;
            _duration = 0.18;
            _isFlying = YES;
            _gold = 8;
        
            SKSpriteNode *shadow = [SKSpriteNode spriteNodeWithImageNamed:@"shadow"];
           
            [self addChild:shadow];
            
            shadow.position = CGPointMake(0, -20);
            
        }
        
        [self loadAnimationWith:type andTimePerFrame:0.2];
        
        self.position = CGPointMake(-100, -100);
        self.xScale = SCALE_X;
        self.yScale = SCALE_Y;
        
        /*setup physics */
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
        self.physicsBody.dynamic = YES;
        self.physicsBody.categoryBitMask = mobCategory;
        self.physicsBody.contactTestBitMask = towerCategory | bulletCategory;
        self.physicsBody.collisionBitMask = 0;
        
    }
    
    
    return self;
    
}


/*loads animation frames into array and starts animation action */
-(void) loadAnimationWith:(NSString*) type andTimePerFrame:(float)tpf {
    for(int i = 1; i < 3; i++){
        NSString *textureName = [NSString stringWithFormat:@"%@%d", type, i];
        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
        [_animationFrames addObject:texture];
        
    }
    
    [self runAction:[SKAction repeatActionForever: [SKAction animateWithTextures:_animationFrames timePerFrame:tpf]]];
}

@end
