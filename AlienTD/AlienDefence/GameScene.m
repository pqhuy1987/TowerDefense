//
//  GameScene.m
//  AlienDefence
//
//  Created by Tharshan on 20/07/2014.
//  Copyright (c) 2014 Tharshan. All rights reserved.
//

#import "GameScene.h"
#import "CreepNode.h"
#import "TileNode.h"
#import "TowerNode.h"
#import "Util.h"
#import "GameOver.h"
#import "GameWin.h"
@implementation GameScene

-(id)initWithSize:(CGSize)size {
  if (self = [super initWithSize:size]) {
    /* Setup your scene here */
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"bg"];
    background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:background];
    
    SKSpriteNode *ship = [SKSpriteNode spriteNodeWithImageNamed:@"ship_dmg_low"];
    ship.position = CGPointMake(CGRectGetMaxX(self.frame)-ship.frame.size.width/2, CGRectGetMidY(self.frame));
    [self addChild:ship];
    _score = 90;
    SKSpriteNode *panels = [SKSpriteNode spriteNodeWithImageNamed:@"hud_points"];
    panels.position = CGPointMake(29, 15);
    panels.anchorPoint = CGPointMake(0, 0);
    panels.name = @"hud";
    SKLabelNode *score = [SKLabelNode labelNodeWithFontNamed:@"Menlo-Regular"];
    score.text = [NSString stringWithFormat:@"%d",_score];
    score.fontSize = 13;
    score.fontColor = [SKColor greenColor];
    score.position = CGPointMake(5, 6);
    score.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    score.name = @"scoreNode";
    _tiles.anchorPoint = CGPointMake(0, 0);
    [self addChild:panels];
    [panels addChild:score];
    _tiles = [TileNode drawTilesWithFrame:self.frame];
    [self addChild:_tiles];
    self.physicsWorld.contactDelegate = self;
    self.towerBases = @[
                        [NSValue valueWithCGPoint:CGPointMake(40+(69/4),60+(69/4))],
                        [NSValue valueWithCGPoint:CGPointMake(149*0.5+(69/4),60+(69/4))],
                        [NSValue valueWithCGPoint:CGPointMake(218*0.5+(69/4),120*0.5+(69/4))],
                        [NSValue valueWithCGPoint:CGPointMake(285*0.5+(69/4),120*0.5+(69/4))],
                        [NSValue valueWithCGPoint:CGPointMake(354*0.5+(69/4),120*0.5+(69/4))],
                        [NSValue valueWithCGPoint:CGPointMake(423*0.5+(69/4),120*0.5+(69/4))],
                        [NSValue valueWithCGPoint:CGPointMake(492*0.5+(69/4),120*0.5+(69/4))],
                        [NSValue valueWithCGPoint:CGPointMake(561*0.5+(69/4),120*0.5+(69/4))],
                        [NSValue valueWithCGPoint:CGPointMake(580*0.5+(69/4),189*0.5+(69/4))],
                        [NSValue valueWithCGPoint:CGPointMake(580*0.5+(69/4),258*0.5+(69/4))],
                        [NSValue valueWithCGPoint:CGPointMake(580*0.5+(69/4),327*0.5+(69/4))],
                        [NSValue valueWithCGPoint:CGPointMake(580*0.5+(69/4),396*0.5+(69/4))],
                        [NSValue valueWithCGPoint:CGPointMake(580*0.5+(69/4),327*0.5+(69/4))],
                        [NSValue valueWithCGPoint:CGPointMake(580*0.5+(69/4),464*0.5+(69/4))],
                        [NSValue valueWithCGPoint:CGPointMake(513*0.5+(69/4),464*0.5+(69/4))],
                        [NSValue valueWithCGPoint:CGPointMake(444*0.5+(69/4),464*0.5+(69/4))],
                        [NSValue valueWithCGPoint:CGPointMake(375*0.5+(69/4),464*0.5+(69/4))],
                        [NSValue valueWithCGPoint:CGPointMake(306*0.5+(69/4),464*0.5+(69/4))],
                        [NSValue valueWithCGPoint:CGPointMake(237*0.5+(69/4),464*0.5+(69/4))],
                        [NSValue valueWithCGPoint:CGPointMake(168*0.5+(69/4),464*0.5+(69/4))],
                        ];
    _waveData = @[
                  @{@"creepType": [NSNumber numberWithInteger:CreepOne], @"count": @10},
                  @{@"creepType": [NSNumber numberWithInteger:CreepTwo], @"count": @10}
                  ];
    _waveNumber = 0;
    _killCount = 0;
    SKAction *wait = [SKAction waitForDuration:50];
    SKAction *performSelector = [SKAction performSelector:@selector(addCreepWave) onTarget:self];
    SKAction *sequence = [SKAction sequence:@[performSelector, wait]];
    SKAction *repeat   = [SKAction repeatAction:sequence count:[_waveData count]];
    [self runAction:repeat];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, -10, 110);
    CGPathAddLineToPoint(path, NULL, 270, 110);
    CGPathAddLineToPoint(path, NULL, 270, 215);
    CGPathAddLineToPoint(path, NULL, 66, 215);
    CGPathAddLineToPoint(path, NULL, 68, 300);
    CGPathAddLineToPoint(path, NULL, 500, 300);
    _followline = [SKAction followPath:path asOffset:NO orientToPath:YES duration:100];
    
    
    //TODO Upgrade Tower Mechanism
    //SKSpriteNode *upgrade = [SKSpriteNode spriteNodeWithImageNamed:@"upgrade"];
    //upgrade.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    //upgrade.yScale = 1.5;
    //upgrade.xScale = 1.5;
    //[self addChild:upgrade];
    
    _isTowerSelected = NO;
    NSArray *turretIconNames = @[@"turret-1-icon",@"turret-2-icon",@"turret-3-icon", @"turret-4-icon",@"turret-5-icon"];
    for (NSString *turretIconName in turretIconNames) {
      SKSpriteNode *turretIconSprite = [SKSpriteNode spriteNodeWithImageNamed:turretIconName];
      [turretIconSprite setName:@"movable"];
      [turretIconSprite setColor:[SKColor blackColor]];
      [turretIconSprite setColorBlendFactor:0.8];
      turretIconSprite.userData = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:([turretIconNames indexOfObject:turretIconName]+1)*50] forKey:@"cost"];
      [turretIconSprite.userData setObject:[NSNumber numberWithInt:[turretIconNames indexOfObject:turretIconName]+1] forKey:@"number"];
      [turretIconSprite setPosition:CGPointMake(CGRectGetMaxX(self.frame)-250+[turretIconNames indexOfObject:turretIconName]*40, 30)];
      [self addChild:turretIconSprite];
    }
    [self didKillEnemy];
    _towers = [[NSMutableArray alloc] init];
    _creeps = [[NSMutableArray alloc] init];
    _towerBaseBounds = [[NSMutableArray alloc] init];
    for (NSValue *base in _towerBases) {
      CGPoint basePoint = [base CGPointValue];
      CGRect baseRect = CGRectMake(basePoint.x, basePoint.y, 0, 0);
      CGRect expandedRect = CGRectInset(baseRect, -69/4, -69/4);
      [_towerBaseBounds addObject:[NSValue valueWithCGRect:expandedRect]];
    }
    
  }
  return self;
}
- (void) addCreepWave {
  NSDictionary *creepWave = [_waveData objectAtIndex:_waveNumber];
  SKAction *wait = [SKAction waitForDuration:2];
  SKAction *performSelector = [SKAction performSelector:@selector(addCreep) onTarget:self];
  SKAction *sequence = [SKAction sequence:@[performSelector, wait]];
  SKAction *repeat   = [SKAction repeatAction:sequence count:[[creepWave objectForKey:@"count"] intValue]];
  [self runAction:repeat];
  _waveNumber++;
  NSLog(@"creep wave added");
}

-(void) addCreep {
  NSDictionary *creepWave = [_waveData objectAtIndex:_waveNumber-1];
  SKSpriteNode *creep = [CreepNode creepOfType:(CreepType)[[creepWave objectForKey:@"creepType"] intValue]];
  creep.position = CGPointMake(-10, 125);
  [self addChild:creep];
  [_creeps addObject:creep];
  [creep runAction:_followline completion:^{
    NSLog(@"game over");
    GameOver *gameOver = [GameOver sceneWithSize:self.frame.size];
    SKTransition *transition = [SKTransition crossFadeWithDuration:1.0];
    [self.view presentScene:gameOver transition:transition];
  }];
  NSLog(@"creep added");
  
}
- (void) didKillEnemy {
  SKNode *hud = [self childNodeWithName:@"hud"];
  SKLabelNode *label = (SKLabelNode*)[hud childNodeWithName:@"scoreNode"];
  [label setText:[NSString stringWithFormat:@"%d", _score+=10]];
  [self enumerateChildNodesWithName:@"movable" usingBlock:^(SKNode *node, BOOL *stop) {
    NSInteger cost = [[node.userData objectForKey:@"cost"] intValue];
    SKSpriteNode *towerIcon = (SKSpriteNode*) node;
    if (cost <= _score) {
      [towerIcon setColorBlendFactor:0];
    }else {
      [towerIcon setColorBlendFactor:0.8];
    }
  }];
  if (_killCount++ >= 20) {
    NSLog(@"You Win");
    GameWin *gameWin = [GameWin sceneWithSize:self.frame.size];
    SKTransition *transition = [SKTransition crossFadeWithDuration:1.0];
    [self.view presentScene:gameWin transition:transition];
  }
}
-(void) updateHUD {
  SKNode *hud = [self childNodeWithName:@"hud"];
  SKLabelNode *label = (SKLabelNode*)[hud childNodeWithName:@"scoreNode"];
  [label setText:[NSString stringWithFormat:@"%d", _score]];
  [self enumerateChildNodesWithName:@"movable" usingBlock:^(SKNode *node, BOOL *stop) {
    NSInteger cost = [[node.userData objectForKey:@"cost"] intValue];
    SKSpriteNode *towerIcon = (SKSpriteNode*) node;
    if (cost <= _score) {
      [towerIcon setColorBlendFactor:0];
    }else {
      [towerIcon setColorBlendFactor:0.8];
    }
  }];
}
-(void)didBeginContact:(SKPhysicsContact *)contact {
  SKPhysicsBody* firstBody;
  SKPhysicsBody* secondBody;
  
  if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
  {
    firstBody = contact.bodyA;
    secondBody = contact.bodyB;
  }
  else
  {
    firstBody = contact.bodyB;
    secondBody = contact.bodyA;
  }
  if (firstBody.categoryBitMask == CollisionMaskCreep && secondBody.categoryBitMask == CollisionMaskTower) {
    CreepNode *creep = (CreepNode*) firstBody.node;
    TowerNode *tower = (TowerNode*) secondBody.node;
    [tower.targets addObject:creep];
  }else if (firstBody.categoryBitMask == CollisionMaskCreep && secondBody.categoryBitMask == CollisionMaskBullet) {
    CreepNode *creep = (CreepNode*) firstBody.node;
    TowerNode *tower = (TowerNode*) secondBody.node.parent;
    if (creep.health > 0) {
      [tower damageEnemy:creep onKill:^{
        [self didKillEnemy];
      }];
    }
  }
}

-(void)didEndContact:(SKPhysicsContact *)contact {
  SKPhysicsBody* firstBody;
  SKPhysicsBody* secondBody;
  
  if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
  {
    firstBody = contact.bodyA;
    secondBody = contact.bodyB;
  }
  else
  {
    firstBody = contact.bodyB;
    secondBody = contact.bodyA;
  }
  if (firstBody.categoryBitMask == CollisionMaskCreep && secondBody.categoryBitMask == CollisionMaskTower) {
    TowerNode *tower = (TowerNode*) secondBody.node;
    CreepNode *creep = (CreepNode*) firstBody.node;
    [tower.targets removeObject:creep];
  }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint positionInScene = [touch locationInNode:self];
  [self selectNodeForTouch:positionInScene];
  
}

- (void) selectNodeForTouch:(CGPoint)touchLocation {
  bool spotTaken = false;
  SKSpriteNode *touchedNode = (SKSpriteNode*)[self nodeAtPoint:touchLocation];
	if(![_selectedTower isEqual:touchedNode]) {

    if (_isTowerSelected) {
      for (TowerNode *tower in _towers) {
        CGRect touchFrame = CGRectInset(tower.frame, -9, -8);
        if (CGRectContainsPoint(touchFrame, touchLocation)) {
          NSLog(@"%@", tower);
          spotTaken = true;
        }
      }
      if (spotTaken) {
        [_selectedTower removeAllActions];
        [_selectedTower runAction:[SKAction rotateToAngle:0.0f duration:0.1]];
        [_selectedTower setScale:1.0f];
        _isTowerSelected = NO;
      }else{
        for (NSValue *base in _towerBaseBounds) {
          CGRect baseRect = [base CGRectValue];
          if (CGRectContainsPoint(baseRect, touchLocation)) {
            if (_score >= [[_selectedTower.userData objectForKey:@"cost"] intValue]) {
              int turret_no = [[_selectedTower.userData objectForKey:@"number"] intValue];
              TowerNode *turretPlaced = [TowerNode towerOfType:(TowerType)turret_no withLevel:1];
              [turretPlaced setPosition:[[_towerBases objectAtIndex:[_towerBaseBounds indexOfObject:base]]CGPointValue]];
              //[turretPlaced debugDrawWithScene:self];
              _score -= [[_selectedTower.userData objectForKey:@"cost"] intValue];
              [self updateHUD];
              [self addChild:turretPlaced];
              [_towers addObject:turretPlaced];
              _isTowerSelected = NO;
            }
          }
        }
        
      }
    }
    
		[_selectedTower removeAllActions];
		[_selectedTower runAction:[SKAction rotateToAngle:0.0f duration:0.1]];
    [_selectedTower setScale:1.0f];
		_selectedTower = touchedNode;
  
    
		if([[touchedNode name] isEqualToString:@"movable"] && (_score >= [[_selectedTower.userData objectForKey:@"cost"] intValue])) {
      [_selectedTower setScale:1.5f];
      _isTowerSelected = YES;
			SKAction *sequence = [SKAction sequence:@[[SKAction rotateByAngle:degToRad(-6.0f) duration:0.1],
                                                [SKAction rotateByAngle:0.0 duration:0.1],
                                                [SKAction rotateByAngle:degToRad(6.0f) duration:0.1]]];
			[_selectedTower runAction:[SKAction repeatActionForever:sequence]];
		}
    if([[touchedNode name] isEqualToString:@"tower"]) {
      NSLog(@"tap turret");
    }
	}
}

- (void) update:(NSTimeInterval)currentTime {
  if (currentTime - self.timeOfLastMove < 0.5) return;
  [self enumerateChildNodesWithName:@"tower" usingBlock:^(SKNode *node, BOOL *stop) {
    TowerNode *tower = (TowerNode*) node;
    @try {
      CreepNode *target = [tower.targets objectAtIndex:0];
      if (target.health <= 0) {
        [tower.targets removeObjectAtIndex:0];
      }else {
        [tower shootAtTarget:target];
      }
    }
    @catch (NSException *exception) {
      //do nothing
    }
  }];
  self.timeOfLastMove = currentTime;
}

- (bool) isCreepinRange:(int) range creep:(CGPoint) creep tower:(CGPoint) tower {
  int rootDistance = sqrt(powf((tower.x-creep.x), 2)+powf((tower.y-creep.y), 2));
  if (rootDistance > range)
    return NO;
  return YES;
}


float degToRad(float degree) {
	return degree / 180.0f * M_PI;
}
@end
