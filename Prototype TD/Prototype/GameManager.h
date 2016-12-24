//
//  GameManager.h
//  Prototype
//
//  Created by Nicolas Goles on 9/12/12.
//
//

#import "cocos2d.h"

@interface GameManager : NSObject <NSCoding>

@property (strong) CCLayer *gameLayer;
@property (strong) CCLayer *hudLayer;
@property (strong) CCLayer *gameStateHudLayer;
@property (strong) NSMutableArray *towers;
@property (strong) NSMutableArray *targets;
@property (strong) NSMutableArray *waypoints;
@property (strong) NSMutableArray *waves;
@property (strong) NSMutableArray *projectiles;
@property (strong) UIPanGestureRecognizer *gestureRecognizer;
@property (strong) NSMutableDictionary *defaultSettings;

+ (GameManager *) sharedManager;

@end
