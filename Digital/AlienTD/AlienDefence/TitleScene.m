//
//  TitleScene.m
//  AlienDefence
//
//  Created by Tharshan on 20/07/2014.
//  Copyright (c) 2014 Tharshan. All rights reserved.
//

#import "TitleScene.h"
#import "GameScene.h"
@implementation TitleScene

-(id)initWithSize:(CGSize)size {
  if (self = [super initWithSize:size]) {
    /* Setup your scene here */
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"title_scene"];
    background.size = self.frame.size;
    background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:background];

  }
  return self;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  GameScene *gameScene = [GameScene sceneWithSize:self.frame.size];
  SKTransition *transition = [SKTransition crossFadeWithDuration:1.0];
  [self.view presentScene:gameScene transition:transition];
}

@end
