//
//  JBBullet.m
//  ProjectX
//
//  Created by Johan Boqvist on 30/10/14.
//  Copyright (c) 2014 ___johboq-7___. All rights reserved.
//

#import "JBBullet.h"

@implementation JBBullet

-(id) initWithColor:(UIColor*)color andSize:(CGSize) size andPosition:(CGPoint)position {
    
    
    self = [super initWithColor:color size:size];
    
    if (self) {
        self.position = position;
        self.name = @"bullet";
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
        self.physicsBody.dynamic = YES;
        self.physicsBody.categoryBitMask = bulletCategory;
        //bullet.physicsBody.contactTestBitMask = mobCategory;
        self.physicsBody.collisionBitMask = 0;
    }
    return self;
    
}

@end
