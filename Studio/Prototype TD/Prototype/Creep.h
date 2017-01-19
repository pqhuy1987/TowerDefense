//
//  Creep.h
//  Prototype
//
//  Created by Nicolas Goles on 9/12/12.
//
//

#import "cocos2d.h"

@class Waypoint;

#pragma mark -
#pragma mark For Tracking Creeps
@protocol CreepTracker

@optional
-(void) creepDiedWithScore:(int)score andMoney:(int)money;
@end

#pragma mark -
#pragma mark Creep
@interface Creep : CCSprite

@property (assign) int currentHitPoints;
@property (assign) int moveDuration;
@property (assign) int currentWaypointIndex;
@property (assign) int score;
@property (assign) int money;
@property (nonatomic, retain) id < CreepTracker > delegate;

- (Waypoint *) currentWaypoint;
- (Waypoint *) nextWaypoint;
- (Creep *) initWithCreep:(Creep *) aCreep;

@end

#pragma mark -
#pragma mark Fast Red
@interface FastRed : Creep
+ (id) creep;
@end

#pragma mark -
#pragma mark Strong Green
@interface StrongGreen: Creep
+ (id) creep;
@end



