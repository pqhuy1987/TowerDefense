//
//  GameStateHud.m
//  Prototype
//
//  Created by Nicolas Goles on 10/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GameStateHud.h"

@implementation GameStateHud

+ (GameStateHud *) sharedManager
{
    static dispatch_once_t once;
    static GameStateHud *sharedInstance = nil;

    dispatch_once(&once, ^{
        if (!sharedInstance) {
            sharedInstance = [[self alloc] init];
        }
    });

    return sharedInstance;
}

- (id) init
{
    if (self = [super init]) {
       // Init the background Sprite
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        _background = [CCSprite spriteWithFile:@"GameStateHud.png"];
        _background.anchorPoint = ccp(0, 0);
        _background.position = ccp(0, 320 - _background.texture.contentSizeInPixels.height * 0.75f);
        _background.scale = 0.75;
        _background.opacity = 150;
        [self addChild:_background];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];

        // Init the money amount string
        _moneyAmountLabel = [CCLabelTTF labelWithString:@"Money: 0" fontName:@"Helvetica" fontSize:16];
        _moneyAmountLabel.position = ccp(0 + _moneyAmountLabel.texture.contentSizeInPixels.width/(1.5),
                                         320 - _moneyAmountLabel.texture.contentSizeInPixels.height);
        _moneyAmountLabel.color = ccc3(255, 255, 255);
        [self addChild:_moneyAmountLabel];
    }

    return self;
}

- (void) updateMoneyLabel:(int)amount
{
   [_moneyAmountLabel setString:[NSString stringWithFormat:@"Money: %d", amount]];
}

@end
