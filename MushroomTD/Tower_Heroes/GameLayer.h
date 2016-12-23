//
//  GameLayer.h
//  Tower_Defense_Take3
//
//  Created by Mark Kim on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameManager.h"

#import "AppDelegate.h"
#import "FlurryAnalytics.h"

@interface GameLayer : CCLayer  {

    GameState gameState;

}

@property (nonatomic, assign) GameState gameState;

- (void) insertBackgroundImage;
- (void) insertTitle;
- (void) insertTitleWithString: (NSString *) titleString;
- (void) insertBackButton;
- (void) insertBackButtonWithSelector: (SEL) sceneSelector withAds: (BOOL) adsOnLayer;
- (CCMenuItemSprite *) insertNextButtonWithSelector: (SEL) sceneSelector withAds: (BOOL) adsOnLayer;
- (void) popSceneOut;

- (void) pushTalentScene;

- (void) playSceneWithoutSound;
- (void) playScene;
- (void) playSceneQuit;
- (void) popSceneOutResume;
- (void) levelSelectionSceneQuit;
- (void) creditScene;
- (void) optionScene;
- (void) fileScene;
- (void) characterSelectionScene;
- (void) nameScene;
- (void) introScene;
- (void) levelSelectionScene;
- (void) loadingSceneWithoutSound;
- (void) loadingScene;
- (void) gameSceneWithoutSound;
- (void) gameScene;
- (void) pauseScene;
- (void) itemScene;
- (void) infoScene;
- (void) talentScene;
- (void) itemScene2;
- (void) infoScene2;
- (void) talentScene2;
- (void) characterSelectionScene2;

@end
