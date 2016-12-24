//
//  GameStateHud.h
//  Prototype
//
//  Created by Nicolas Goles on 10/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameStateHud : CCLayer

@property (strong) CCSprite *background;
@property (strong) CCLabelTTF *waveLabel;
@property (strong) CCLabelTTF *moneyAmountLabel;

+ (GameStateHud *) sharedManager;
- (void) updateMoneyLabel:(int) amount;
- (void) updateWaveLabel:(int) wave;
- (void) updateScoreLabel:(int) points;

@end
