//
//  JBGUI.m
//  JBTowerDef
//
//  Created by Johan Boqvist on 02/11/14.
//  Copyright (c) 2014 ___johboq-7___. All rights reserved.
//
/* Class that creates and modifies GUI elements in the scene */

#import "JBGUI.h"

@interface JBGUI()

@property SKLabelNode   *goldLabel;
@property SKSpriteNode  *nextNode;
@property SKLabelNode   *waveLabel;
@property SKLabelNode   *lifeLabel;
@property SKScene       *scene;

@end

@implementation JBGUI



-(id) initWithScene:s {
    
    self = [super init];
    
    if(self){
        
        _scene = s;
        _tMenu = [[SKNode alloc] init];
        
        _bottomGUI = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(1000, 64)];
        _bottomGUI.position = CGPointMake(0, 1);
        _bottomGUI.alpha = 0.8;
        
        [_scene addChild:_bottomGUI];
        
    }
    return self;
}


/* creates label */
+(SKLabelNode *)createLabel:(CGPoint)position andText:(NSString *)text andFontSize:(int)size andFontColor:(UIColor *)color {
    
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Noteworthy-Bold"];
    label.text = text;
    label.position = position;
    label.fontSize = size;
    label.fontColor = color;
    
    return label;
}


/* adds tower item to the tower menu */
+(void) addTowerItemWithType:(NSString *)type andItemNode:(SKSpriteNode *)item {
    
    SKLabelNode *towerLabel;
    SKLabelNode *goldLabel;
    
    JBTower *tower = [[JBTower alloc] initWithTowerType:type andPosition:CGPointMake(-10,4)];
    tower.name = type;
    towerLabel = [self createLabel:CGPointMake(0, -15) andText:tower.menuName andFontSize:12 andFontColor: [UIColor whiteColor]];
    goldLabel = [self createLabel:CGPointMake(14, 6) andText:[NSString stringWithFormat:@"%d", tower.cost] andFontSize:10 andFontColor: [UIColor yellowColor]];
    
    [item addChild:tower];
    [item addChild:goldLabel];
    [item addChild:towerLabel];
    
    item.name = type;
}

/*creates particle effect */
+(SKEmitterNode *) createParticleType:(NSString *)type at:(CGPoint)position {
    
    NSString *burstPath =
    [[NSBundle mainBundle]
     pathForResource:type ofType:@"sks"];
    
    SKEmitterNode *burstNode =
    [NSKeyedUnarchiver unarchiveObjectWithFile:burstPath];
    
    burstNode.position = CGPointMake(position.x, position.y);
    
    return burstNode;
}

/*creates the tower menu */
-(void) createTowerMenu {
    
    int c = 0;
    for(int x = -1; x <= 1; x++){
        
        for(int y = -1; y <= 1; y++){
            
            if((c++)%2 == 1 ){
                
                SKSpriteNode *box = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(TILE_WIDTH + 10, TILE_HEIGHT)];
                
                int xOff = -5;
                if(x < 0) xOff = 5;
                if(x == 0) xOff = 0;
                
                box.position = CGPointMake(TILE_WIDTH * x -xOff, TILE_HEIGHT * y);
                box.alpha = 0.7;
                box.color = [UIColor brownColor];
                [_tMenu addChild:box];
            }
        }
    }
    
    SKSpriteNode *box = [SKSpriteNode spriteNodeWithImageNamed:@"spark"];
    box.alpha = 0.8;
    box.name = @"spark";
    [_tMenu addChild:box];
    
    [JBGUI addTowerItemWithType:@"rangeTower" andItemNode:[_tMenu children][0]];
    [JBGUI addTowerItemWithType:@"airTower" andItemNode:[_tMenu children][1]];
    [JBGUI addTowerItemWithType:@"dmgTower" andItemNode:[_tMenu children][2]];
    [JBGUI addTowerItemWithType:@"slowTower" andItemNode:[_tMenu children][3]];
   
}


/* presents game over and stage cleared screen */
-(void) presentTransitionScreenOnScene:(SKScene *)scene withHeadLabel:(NSString *)headLabel andBoxType:(NSString *)boxType andBoxLabel:(NSString *)boxLabel andColor:color {
    
    SKLabelNode *label = [JBGUI createLabel:CGPointMake(scene.size.width / 2, scene.size.height / 2) andText:headLabel andFontSize:32 andFontColor:[UIColor redColor]];
    [scene addChild:label];
    
    
    SKSpriteNode *bigBox = [SKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:CGSizeMake(1000, 1000)];
    bigBox.alpha = 0.4;
    
    [scene addChild:bigBox];
    
    _nextBox = [SKSpriteNode spriteNodeWithColor:[UIColor grayColor] size:CGSizeMake(184, 50)];
    _nextBox.position = CGPointMake(230, 110);
    _nextBox.name = boxType;
    
    SKLabelNode *nextLabel = [JBGUI createLabel:CGPointMake(4, -10) andText:boxLabel andFontSize:32 andFontColor:[UIColor whiteColor]];
    
    [_nextBox addChild:nextLabel];
    
    [scene addChild:_nextBox];
    
}

-(void) lifeChanged:(int)life {
    _lifeLabel.text = [NSString stringWithFormat:@"Life: %d", life];
}

-(void)goldChanged:(int)gold {
    _goldLabel.text = [NSString stringWithFormat:@"Gold: %d", gold];
}

-(void)waveChangedTo:(int)waveNumber andTotalWaves:(int)total andNextNode:(NSString *)next {
    _waveLabel.text = [NSString stringWithFormat:@"Wave: %d/%d             Incoming: ", waveNumber, total];
    
    _nextNode.texture = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%@1",next]];
}

-(void) setupBottomGUI {
    _waveLabel = [JBGUI createLabel:CGPointMake(100, 6) andText:@"" andFontSize:16 andFontColor:[UIColor redColor]];
    [_bottomGUI addChild: _waveLabel];
    
    _goldLabel = [JBGUI createLabel:CGPointMake(300, 6) andText:@"" andFontSize:16 andFontColor:[UIColor redColor]];
    [_bottomGUI addChild:_goldLabel];
    
    _lifeLabel = [JBGUI createLabel:CGPointMake(420, 6) andText:@"" andFontSize:16 andFontColor:[UIColor redColor]];
    [_bottomGUI addChild:_lifeLabel];

    _nextNode = [[SKSpriteNode alloc] init];
    _nextNode.position = CGPointMake(220, 14);
    _nextNode.size = CGSizeMake(TILE_WIDTH, TILE_HEIGHT);
    [_bottomGUI addChild:_nextNode];
    
    
}

@end
