//
//  GameScene.h
//  Prototype
//
//  Created by Nicolas Goles on 9/12/12.
//
//

#import "cocos2d.h"
#import "Creep.h"

@class Creep;
@class Waypoint;
@class Wave;
@class Hud;

@interface GameScene : CCLayer <CreepTracker>

@property (strong) CCTMXTiledMap *tileMap;
@property (strong) CCTMXLayer *background;
@property (strong) CCLabelTTF *totalMoneyLabel;
@property (assign) int currentLevel;
@property (assign) int totalMoney;

+ (id) scene;

// To add Game Elements
- (void) addWaypoints;
- (void) addWaves;
- (void) addTowerAtPoint:(CGPoint) point;

// To Performn Checks
- (BOOL) canBuildAtPosition:(CGPoint) point;

// For Global Operations
- (BOOL) substractMoney:(int) amount;
- (void) addMoney:(int) amount;

@end
