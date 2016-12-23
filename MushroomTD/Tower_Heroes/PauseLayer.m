//
//  PauseLayer.m
//  Tower_Defense_Take3
//
//  Created by Mark Kim on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PauseLayer.h"
#import "PreLoadScene.h"

@implementation PauseLayer


- (void) initPauseButtons {
    
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    CCSprite *resumeNormal = [CCSprite spriteWithSpriteFrameName: @"resume_button_1.png"];
    CCSprite *resumeSelected = [CCSprite spriteWithSpriteFrameName: @"resume_button_2.png"];
    CCSprite *levelsNormal = [CCSprite spriteWithSpriteFrameName: @"levels_button_1.png"];
    CCSprite *levelsSelected = [CCSprite spriteWithSpriteFrameName: @"levels_button_2.png"];
    CCSprite *quitNormal = [CCSprite spriteWithSpriteFrameName: @"quit_button_1.png"];
    CCSprite *quitSelected = [CCSprite spriteWithSpriteFrameName: @"quit_button_2.png"];
    
    CCMenuItemSprite *resumeButton = [CCMenuItemSprite itemWithNormalSprite: resumeNormal
                                                             selectedSprite: resumeSelected
                                                                     target: self
                                                                   selector: @selector(popSceneOutResume)];
    
    CCMenuItemSprite *levelsButton = [CCMenuItemSprite itemWithNormalSprite: levelsNormal
                                                             selectedSprite: levelsSelected
                                                                     target: self
                                                                   selector: @selector(levelSelectionSceneQuit)];
    
    CCMenuItemSprite *quitButton = [CCMenuItemSprite itemWithNormalSprite: quitNormal
                                                           selectedSprite: quitSelected
                                                                   target: self
                                                                 selector: @selector(playSceneQuit)];
    
    float padding = 7.0f;
    
    CCMenu *menu = [CCMenu menuWithItems: resumeButton, levelsButton, quitButton, nil];
    [menu alignItemsVerticallyWithPadding: padding];
    menu.position = ccp(screenSize.width/2, screenSize.height/2);
    menu.zOrder = 1;
    
    [self addChild: menu];
}

- (void) insertSoundButton {
    
    GameManager *m = [GameManager sharedGameManager];
    
    CCSprite *soundButtonNormal = [CCSprite spriteWithSpriteFrameName: @"sound_button_1.png"];
    CCSprite *soundButtonSelected = [CCSprite spriteWithSpriteFrameName: @"sound_button_2.png"];
    
    CCMenuItemSprite *soundButton1 = [CCMenuItemSprite itemWithNormalSprite: soundButtonNormal
                                                             selectedSprite: nil];
    CCMenuItemSprite *soundButton2 = [CCMenuItemSprite itemWithNormalSprite: soundButtonSelected
                                                             selectedSprite: nil];
    
    CCMenuItemToggle *toggleButton = [CCMenuItemToggle itemWithTarget: m selector: @selector(muteSoundToggle:) items: soundButton1, soundButton2, nil];
    
    // check which setting the button should be on
    if (m.isMusicON == YES) {
        toggleButton.selectedIndex = 0;
    } else {
        toggleButton.selectedIndex = 1;
    }
    
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    float offsetX = 40.0f;
    float offsetY = 40.0f;
    
    CCMenu *soundMenu = [CCMenu menuWithItems: toggleButton, nil];
    soundMenu.position = ccp(offsetX, screenSize.height -  offsetY);
    soundMenu.zOrder = 9999;
    
    [self addChild: soundMenu];
    
}

- (id) init {
    
    if (self = [super init]) {
        
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        CCSprite *pauseScreen = [CCSprite spriteWithFile: @"pause_background_1.png"];
        pauseScreen.zOrder = 0;
        pauseScreen.position = ccp(screenSize.width/2, screenSize.height/2);
        
        [self addChild: pauseScreen];
        
        [self initPauseButtons];
        
        [self insertSoundButton];
        
    }
    
    return self;
}

- (void) onEnter {
    
    //1
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    UINavigationController *viewController = [app navController];  
    

    [super onEnter];
}

- (void) onExit {
    

    [super onExit];
}

@end
