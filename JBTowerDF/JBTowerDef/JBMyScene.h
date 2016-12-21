//
//  JBMyScene.h
//  JBTowerDef
//

//  Copyright (c) 2014 ___johboq-7___. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>
#import "JBTower.h"
#import "JBMob.h"
#import "JBBullet.h"
#import "JBGUI.h"
#import "JBDefaults.h"


@interface JBMyScene : SKScene <SKPhysicsContactDelegate>

-(id)initWithSize:(CGSize)size andLevel:(NSString *)level;


@property (nonatomic) Boolean             hasSound;
@end
