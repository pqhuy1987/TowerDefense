//
//  hud.h
//  Prototype
//
//  Created by Nicolas Goles on 9/13/12.
//
//

#import "cocos2d.h"

@interface Hud : CCLayer

@property (strong) CCSprite *background;
@property (strong) CCSprite *selectedSprite;
@property (strong) CCSprite *selectedSpriteRange;
@property (strong) NSMutableArray *movable;
@property (assign) BOOL didStartDraggingSprite;

+ (Hud *) sharedManager;

@end
