//
//  JBMyScene.m
//  JBTowerDef
//
//  Created by Johan Boqvist on 31/10/14.
//  Copyright (c) 2014 ___johboq-7___. All rights reserved.
//

#import "JBMyScene.h"

float TILE_WIDTH;
float TILE_HEIGHT;
float SCALE_X;
float SCALE_Y;

static int currentlevel;

@interface JBMyScene()

@property (nonatomic) NSMutableArray      *tileMap;
@property (nonatomic) NSArray             *rawMap;
@property (nonatomic) CGMutablePathRef    path;
@property (nonatomic) SKSpriteNode        *towerSelection;
@property (nonatomic) NSMutableArray      *waves;
@property (nonatomic) Boolean             gamePaused;
@property (nonatomic) JBGUI               *GUI;
@property (nonatomic) NSMutableArray      *towers;
@property (nonatomic) NSMutableArray      *mobs;

@property (nonatomic) int                 gameCounter;
@property (nonatomic) int                 waveCounter;
@property (nonatomic) int                 gold;
@property (nonatomic) int                 life;
@property (nonatomic) float               pathLength;

@end

@implementation JBMyScene

/*init scene with the current level */
-(id)initWithSize:(CGSize)size andLevel:(NSString *)level {
    
    
    if (self = [super initWithSize:size]) {
        
        /* observe app transitions */
        [self registerAppTransitionObservers];
        
        /* setup start up values (property list-suitable?) */
        _gamePaused = YES;
        _gameCounter = 0;
        _waveCounter = 0;
        _gold = 75;
        _life = 3;
        currentlevel++;

        /* alloc arrays */
        _towers = [[NSMutableArray alloc] init];
        _mobs = [[NSMutableArray alloc] init];
        _tileMap = [[NSMutableArray alloc] init];
        
        /*scale tiles to fit screen size */
        SCALE_X = self.size.width / 480.0;
        SCALE_Y = self.size.height / 320.0;
        TILE_HEIGHT = 32 * SCALE_Y;
        TILE_WIDTH = 32 * SCALE_X;
       
        
        /* physics */
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        
        /* read plist data */
        [self loadPlistData:level];
        
        [self loadMap];
        
        //setup GUI class
        NSMutableDictionary *wave = [[NSMutableDictionary alloc] initWithDictionary:_waves[_waveCounter]];
        _GUI = [[JBGUI alloc] initWithScene:self];
      
        [_GUI setupBottomGUI];
        [_GUI waveChangedTo:1 andTotalWaves:(int)[_waves count] andNextNode:[wave allKeys][0]];
        [_GUI goldChanged:_gold];
        [_GUI lifeChanged:_life];
        [_GUI createTowerMenu];
   
        self.gamePaused = YES;
            
        _GUI.label = [JBGUI createLabel:CGPointMake(self.size.width / 2, self.size.height / 2) andText:@"Touch screen to start" andFontSize:32 andFontColor:[UIColor redColor]];
        [self addChild:_GUI.label];
        
        
        [self loadSound];
      
    }
   
    return self;
}


/*loads data from property list */
-(void) loadPlistData:(NSString *)pathForResource {
    

    NSString *plistPath = [[NSBundle mainBundle] pathForResource:pathForResource ofType:@"plist"];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    _rawMap = [[NSArray alloc] initWithArray: [dict valueForKey:@"map"]];
    _waves = [[NSMutableArray alloc] initWithArray: [dict valueForKey:@"waves"]];
    _path = CGPathCreateMutable();
    
    
    /* load path data */
    NSArray *paths = [[NSArray alloc] initWithArray:[dict valueForKey:@"path"]];
    int x = [paths[0][0] intValue];
    int y = [paths[0][1] intValue];
    
    CGPathMoveToPoint(_path, NULL, x * TILE_WIDTH, y * TILE_HEIGHT);
    for(int i = 1; i < [paths count]; i++){
        
        x = [paths[i][0] intValue];
        y = [paths[i][1] intValue];
        
        _pathLength = _pathLength + abs(x - [paths[i-1][0] intValue]) + abs(y - [paths[i-1][0] intValue]);  /* get total length of mob-path */
        CGPathAddLineToPoint(_path, NULL, x * TILE_WIDTH, y * TILE_HEIGHT);
    }
}

-(void) pauseGame {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pauseGame" object:nil];
}

/* load sound settings from NSDefaults */
-(void) loadSound {
    NSUserDefaults* pref = [NSUserDefaults standardUserDefaults];
    NSObject *object = [pref objectForKey:@"soundState"];
    Boolean value = [[NSUserDefaults standardUserDefaults] boolForKey: @"soundState"];
    
    if(object != nil)
    {
        if(value)
            _hasSound = YES;
            }
    else {
        _hasSound = YES;
    }
}

/* make raw map data into spritenode array */
-(void) loadMap {
    
    for(int y = 0; y < MAP_HEIGHT; y++){
        
        for(int x = 0; x < MAP_WIDTH; x++){
            
            SKSpriteNode *tile;
            NSString *s = _rawMap[y];
            
            if([s characterAtIndex:x] == '0'){
                tile = [SKSpriteNode spriteNodeWithImageNamed:@"grass"];
                tile.name = @"grass";
            }
            else if([s characterAtIndex:x] == '1'){
                tile = [SKSpriteNode spriteNodeWithImageNamed:@"dirt"];
                tile.name = @"path";
            }
            else if([s characterAtIndex:x] == '2'){
                tile = [SKSpriteNode spriteNodeWithImageNamed:@"tree"];
                tile.name = @"tree";
            }
            else if([s characterAtIndex:x] == '3'){
                tile = [SKSpriteNode spriteNodeWithImageNamed:@"water"];
                tile.name = @"water";
            }
            
            tile.position = CGPointMake(x * TILE_WIDTH, y * TILE_HEIGHT);
            tile.xScale = SCALE_X;
            tile.yScale = SCALE_Y;
            _tileMap[x + y * MAP_WIDTH] = tile;
        }
    }
    
    [self drawMap];
}


/* add mob to scene and make it start following path  (spawn duration is a delay before the mob appears )*/
-(void) addMobWithMobType:(NSString *)type andSpawnDuration:(float)spawnDuration {
    
    JBMob *mob = [[JBMob alloc ] initWithMobType:type];
    
    [_mobs addObject:mob];
    [self addChild:mob];

    SKAction *wait = [SKAction waitForDuration:spawnDuration];
    SKAction *follow = [SKAction followPath:_path asOffset:NO orientToPath:NO duration:mob.duration * _pathLength];

    SKAction *reachedDestination = [SKAction runBlock:^{
        _life -= 1;
        [_GUI lifeChanged:_life];
        [_mobs removeObject:mob];
        [mob removeFromParent];
        
        if(_life <= 0) [self gameOver];
    }];
    [mob runAction: [SKAction sequence:@[wait, follow, reachedDestination]]];
}

/* add spritenodes from the map array to scene */
-(void) drawMap{
    
    for(int y = 0; y < MAP_HEIGHT; y++){
        
        for(int x = 0; x < MAP_WIDTH; x++){
            
            [self addChild:_tileMap[x + y * MAP_WIDTH]];
            
        }
    }
    
}


/*handle touch inputs */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    for (UITouch *touch in touches) {
        
        CGPoint location = [touch locationInNode:self];
        
        if(_gamePaused){
            _gamePaused = NO;
            self.view.paused = NO;
            [_GUI.label removeFromParent];
            return;
        }
        
        /* get touched node */
        SKSpriteNode *sprite = (SKSpriteNode *)[self nodeAtPoint:location];
        
        /* input for the transition screens (game over, stage cleared */
        CGRect buttonRect = [_GUI.nextBox frame];
        if(CGRectContainsPoint(buttonRect, location)){

            _gamePaused = NO;
            self.view.paused = NO;
            
            NSString *level = [NSString stringWithFormat:@"level%d", currentlevel+1];
            if(_life <= 0) {
                level = @"level1";
                currentlevel = 0;
            }
            
             NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
             [dict setValue:level forKey:@"level"];
             
             [[NSNotificationCenter defaultCenter] postNotificationName:@"newLevel" object:self userInfo:dict];
        }
        
   
        
        /* if the tower menu is active, handle inputs */
        if([_GUI.tMenu parent] == self){
            
           CGPoint tMenuLoc = [touch locationInNode:_GUI.tMenu];
            JBTower *t;
            for(int i = 0; i < [[_GUI.tMenu children] count]-1; i++){
                SKSpriteNode *child = [_GUI.tMenu children][i];

                if(CGRectContainsPoint([child frame], tMenuLoc)){
                    t = [child children][0];
                    
                    if([self hasMoneyToBuy:t]){   /* bought a tower */
                        _gold -= t.cost;
                        [self playSoundEffect:@"kaching.wav"];
                        [_GUI goldChanged:_gold];
                    }
                    else {
                        [self playSoundEffect:@"wrong.wav"]; /* couldn't afford it */
                        return;
                    }
                        
                    break;
                }
            }
   
            [self addTower:t.name at:_towerSelection];
            
            [_GUI.tMenu removeFromParent];
            break;
           
        }
        
        /* a grass node was clicked, add the tower menu to scene */
        if([sprite.name isEqualToString:@"grass"]){
            
            if(![_GUI.tMenu parent]){
                _GUI.tMenu.position = sprite.position;
                
                [self addChild:_GUI.tMenu];
                _towerSelection = sprite;
            }
        }
        else {
            [self playSoundEffect:@"wrong.wav"]; /* you can't build a tower on this node! */
        }
        
        
      
    }
}


-(void) playSoundEffect:(NSString *) name {
    
    if(_hasSound){
        SKAction *sound = [SKAction playSoundFileNamed:name waitForCompletion:NO];
        [self runAction:sound];
    }
}



-(Boolean) hasMoneyToBuy:(JBTower *)tower {
    return (_gold - tower.cost >= 0);
}

-(void) addTower:(NSString *)type at:(SKSpriteNode *)sprite {
    
    JBTower *newSprite;
    
    if([@[@"rangeTower", @"slowTower", @"dmgTower", @"airTower"] containsObject:type]){
        newSprite = [[JBTower alloc] initWithTowerType:type andPosition:sprite.position];
    }
    else return;
    
    [self addChild:newSprite];
    [self.towers addObject: newSprite];
}


/*collision check */
-(void) didBeginContact:(SKPhysicsContact *)contact {
    
    SKNode *nodeA = contact.bodyA.node;
    SKNode *nodeB = contact.bodyB.node;
    
    
    /* mob entered tower range */
    if([nodeA isKindOfClass:[JBTower class]]){
        
        JBTower *t = (JBTower *) nodeA;
        JBMob *s = (JBMob *) nodeB;
        
        if(t.canTargetAir || !s.isFlying)
            [t.targets addObject:s];
    }
    
    if([nodeB isKindOfClass:[JBTower class]]){
        JBTower *t = (JBTower *) nodeB;
        JBMob *s = (JBMob *) nodeA;
        
        if(t.canTargetAir || !s.isFlying)
            [t.targets addObject:s];
        
    }
    
    /* bullet hit mob */
    if([nodeA isKindOfClass:[JBBullet class]]){
        
        JBBullet *b = (JBBullet *)nodeA;
        JBMob *m = (JBMob *) nodeB;
    
        [self collisionBullet:b andMob:m];
        
    }
    if([nodeB isKindOfClass:[JBBullet class]]){
        
        JBBullet *b = (JBBullet *)nodeB;
        JBMob *m = (JBMob *) nodeA;
        
        [self collisionBullet:b andMob:m];
    }
    
}


-(void) didEndContact:(SKPhysicsContact *) contact {
    
    SKNode *nodeA = contact.bodyA.node;
    SKNode *nodeB = contact.bodyB.node;
    
    /* mob left tower range */
    if([nodeA isKindOfClass:[JBTower class]]){
        
        JBTower *t = (JBTower *) nodeA;
        JBMob *s = (JBMob *) nodeB;
        [t.targets removeObject:s];
        s.colorBlendFactor = 0.0;
    }
    
    if([nodeB isKindOfClass:[JBTower class]]){
        JBTower *t = (JBTower *) nodeB;
        JBMob *s = (JBMob *) nodeA;
        [t.targets removeObject:s];
        s.colorBlendFactor = 0.0;
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
   
    // pause the game
    if(_gamePaused) [self pauseGame];
    
    [self updateWaves];
    [self updateTowers];
    [self updateMobs];
    
}


/*create a new bullet from parent tower */
-(JBBullet*) createBulletFromTower:(JBTower *)tower {
    
    JBBullet *bullet;
    
    if(tower.freeze > 0){
        bullet = [[JBBullet alloc] initWithColor: [UIColor greenColor] andSize:CGSizeMake(10, 10) andPosition:tower.position];
    }
    else bullet = [[JBBullet alloc] initWithColor: [UIColor orangeColor] andSize:CGSizeMake(10, 10) andPosition:tower.position];
    
    bullet.parentTower = tower;
    bullet.damage = tower.damage;
    
    return bullet;
    
}

/* bullet hit a mob so add damage and present particle effect */
-(void) collisionBullet:(JBBullet *)b andMob:(JBMob*)m {
    
    m.hp -= b.damage;
    
    if(m.hp <= 0){
        _gold += m.gold;
        [_GUI goldChanged:_gold];
        [m removeFromParent];
        [_mobs removeObject:m];
    }
    

    NSString *res;
    if(b.parentTower.freeze > 0){
        res = @"SlowParticle";
        if(!m.isFrozen) m.speed = m.speed / 2.0;
        
        m.isFrozen = YES;
    }
    else res = @"FireParticle";
    /* particle */
    
    SKEmitterNode *burstNode = [JBGUI createParticleType:res at:m.position];
    
    [self addChild:burstNode];
    
    SKAction *wait = [SKAction waitForDuration:0.2];
    SKAction *remove = [SKAction removeFromParent];
    [burstNode runAction:[SKAction sequence:@[wait, remove]]];
    
}

/* handle enemy waves */
-(void) updateWaves {
    
    /*add new wave if all mobs are gone and use start delay for first wave */
    if(_waveCounter < [_waves count] && [_mobs count] == 0 && _gameCounter >= START_DELAY){
        NSMutableDictionary *wave = [[NSMutableDictionary alloc] initWithDictionary:_waves[_waveCounter]];
        
        int mobAmount = (int)[[wave allValues][0] integerValue];
        
        for(int i = 0; i < mobAmount; i++){
            NSString *mob = [wave allKeys][0];
            [self addMobWithMobType:mob andSpawnDuration: i/1.5];
            
        }
        
        SKAction *wait = [SKAction waitForDuration:20];
        [self runAction:wait];
        _waveCounter++;
        
        
        /*update GUI */
        if(_waveCounter < [_waves count])
        {
            wave = [[NSMutableDictionary alloc] initWithDictionary:_waves[_waveCounter]];
            [_GUI waveChangedTo:_waveCounter andTotalWaves:(int)[_waves count] andNextNode:[wave allKeys][0]];
        }
        else [_GUI waveChangedTo:_waveCounter andTotalWaves:(int)[_waves count] andNextNode:[wave allKeys][0]];
        
    }
    else _gameCounter++;
    
    /* all waves cleared */
    if(_waveCounter >= [_waves count] && [_mobs count] == 0 && !self.view.paused){
        [self victory];
    }
}

/* make tower rotate to follow target mob and fire bullets */
-(void) updateTowers {
    
    for(JBTower *tower in _towers){
        
        if([tower.targets count] == 0) continue;
        
        //the tower has found a target and will follow it and fire bullets depending on cooldown
        float angle;
        float dx, dy;
        
        JBMob *mob = tower.targets[0];
        
        //another tower blew it away.
        if(!mob.parent) {
            [tower.targets removeObjectAtIndex:0];
            continue;
        }
        
        dy = (mob.frame.origin.y + mob.frame.size.height/2) - (tower.frame.origin.y + tower.frame.size.height / 2);
        dx = (mob.frame.origin.x + mob.frame.size.width/2) - (tower.frame.origin.x + tower.frame.size.width / 2);
        
        angle = atan2f(dy, dx);
        
        SKAction *rotate = [SKAction rotateToAngle:angle duration:0.1 shortestUnitArc:YES];
        [tower runAction:rotate];
        
        
        /*fire bullets */
        if(++tower.fireCounter > tower.coolDown){
            tower.fireCounter = 0;
            JBBullet *bullet = [self createBulletFromTower:tower];
            
            [self addChild:bullet];
            
            [self playSoundEffect:@"fire.wav"];
            
            SKAction *attack = [SKAction moveTo:mob.position duration:0.1];
            SKAction *remove = [SKAction removeFromParent];
            [bullet runAction:[SKAction sequence:@[attack, remove]]];
        }
        
    }
    
}

/* offset the flying mobs and slow down frozen mobs */
-(void) updateMobs {
    
    for(int i = 0; i < [_mobs count]; i++){
        JBMob *mob = _mobs[i];
        if(mob.isFlying){
            SKAction *offset = [SKAction moveBy:CGVectorMake(0, 15) duration:0];
            [mob runAction:offset];
        }
        if(mob.isFrozen){
            if(mob.freezeCounter++ > 40){
                mob.freezeCounter = 0;
                mob.isFrozen = NO;
                mob.speed = mob.speed * 2.0;
            }
        }
    }
}

-(void) gameOver {
    
     [_GUI presentTransitionScreenOnScene:self withHeadLabel:@"Game over!" andBoxType:@"nextBox" andBoxLabel:@"Play again!" andColor:[UIColor redColor]];
    
    SKAction *sound = [SKAction runBlock:^{ [self playSoundEffect:@"fail.wav"]; }];
    SKAction *pause = [SKAction runBlock:^{ self.view.paused = YES; }];
    [self runAction: [SKAction sequence:@[sound, pause]]];
}

-(void) victory {
    [_GUI presentTransitionScreenOnScene:self withHeadLabel:@"Stage cleared!" andBoxType:@"nextBox" andBoxLabel:@"Next stage ->" andColor:[UIColor blueColor]];
    
    SKAction *sound = [SKAction runBlock:^{ [self playSoundEffect:@"victory.wav"]; }];
    SKAction *pause = [SKAction runBlock:^{ self.view.paused = YES; }];
    [self runAction: [SKAction sequence:@[sound, pause]]];
}


/* observe notifications from AppDelegate */
-(void)registerAppTransitionObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:NULL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:NULL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:NULL];
}

-(void)applicationWillResignActive {
    if (!_gamePaused) { //Pause the game if necessary
        [self pauseGame];
    }
}

-(void)applicationDidEnterBackground {
    if (!_gamePaused) { //Pause the game if necessary
        [self pauseGame];
    }
}

-(void)applicationWillEnterForeground {
    self.view.paused = NO;
    if (_gamePaused) {
        self.paused = YES;
    }

}

@end
