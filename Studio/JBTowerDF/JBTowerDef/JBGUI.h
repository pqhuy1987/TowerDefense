//
//  JBGUI.h
//  JBTowerDef
//
//  Created by Johan Boqvist on 02/11/14.
//  Copyright (c) 2014 ___johboq-7___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

#import "JBDefaults.h"
#import "JBTower.h"


@interface JBGUI : NSObject

+(SKLabelNode *)createLabel:(CGPoint)position andText:(NSString *)text andFontSize:(int)size andFontColor:(UIColor*)color;
+(void) addTowerItemWithType:(NSString *)type andItemNode:(SKSpriteNode *)item;
+(SKEmitterNode *) createParticleType:(NSString *)type at:(CGPoint)position;
-(void) createTowerMenu;
-(id) initWithScene:scene;
-(void) setupBottomGUI;
-(void) waveChangedTo:(int)waveNumber andTotalWaves:(int)total andNextNode:(NSString*)next;
-(void) goldChanged:(int)gold;
-(void) lifeChanged:(int) life;
-(void) presentTransitionScreenOnScene:(SKScene *)scene withHeadLabel:(NSString *)headLabel andBoxType:(NSString *)boxType andBoxLabel:(NSString *)boxLabel andColor:color;

@property SKSpriteNode  *nextBox;
@property SKLabelNode   *label;
@property SKSpriteNode  *bottomGUI;
@property SKNode        *tMenu;


@end
