//
//  Tower.m
//  Prototype
//
//  Created by Nicolas Goles on 9/13/12.
//
//

#import "Tower.h"
#import "Creep.h"
#import "GameManager.h"
#import "Projectile.h"

#pragma mark -
#pragma mark Tower
@implementation Tower
- (Creep *) getClosestTarget
{
    Creep *closestCreep = nil;
    double bigDistance = 999999;
    NSMutableArray *targets = [[GameManager sharedManager] targets];
    for (CCSprite *target in targets) {
        Creep *creep = (Creep *)target;
        double distanceToCreep = ccpDistance(self.position, creep.position);
        if (distanceToCreep < bigDistance) {
            closestCreep = creep;
            bigDistance = distanceToCreep;
        }
    }

    if (bigDistance <= _range) {
        return closestCreep;
    }

    return nil;
}

@end

#pragma mark -
#pragma mark Basic Tower
@implementation BasicTower

- (id) init
{
    if (self = [super init]) {
    }

    return self;
}

+ (id) tower
{
    Tower *tower = [[[super alloc] initWithFile:@"tower1.png"] autorelease];
    if (tower) {
        tower.range = 100; // Range in Pixels
        tower.cost = 20;
        [tower schedule:@selector(logic:) interval:1.0f];
    }

    return tower;
}

- (void) logic:(ccTime)dt
{
    self.target = [self getClosestTarget];

    if (self.target) {
        // Rotate tower to face shooting direction
        CGPoint shootVector = ccpSub(self.target.position, self.position);
        CGFloat shootAngle = ccpToAngle(shootVector);
        CGFloat cocosAngle = CC_RADIANS_TO_DEGREES(-1 * shootAngle);

        float rotateSpeed = 0.5 / M_PI;
        float rotateDuration = fabs(shootAngle * rotateSpeed);

        [self runAction:[CCSequence actions:[CCRotateTo actionWithDuration:rotateDuration angle:cocosAngle],
                                             [CCCallFunc actionWithTarget:self selector:@selector(finishFiring)], nil]];
    }
}


- (void)finishFiring
{
    GameManager *m = [GameManager sharedManager];
    self.nextProjectile = [Projectile projectile];
    self.nextProjectile.position = self.position;
    [self.parent addChild:self.nextProjectile z:1];
    [m.projectiles addObject:self.nextProjectile];

    ccTime delta = 1.0;
    CGPoint shootVector = ccpSub(self.target.position, self.position);
    CGPoint normalizedShootVector = ccpNormalize(shootVector);
    CGPoint overshotVector = ccpMult(normalizedShootVector, 320);
    CGPoint offscreenPoint = ccpAdd(self.position, overshotVector);

    [self.nextProjectile runAction:[CCSequence actions:[CCMoveTo actionWithDuration:delta position:offscreenPoint],
                                                       [CCCallFuncN actionWithTarget:self selector:@selector(creepMoveFinished:)], nil]];
    self.nextProjectile.tag = 2;
}

-(void)creepMoveFinished:(id)sender
{
    GameManager *m = [GameManager sharedManager];
    CCSprite *sprite = (CCSprite *)sender;
    [self.parent removeChild:sprite cleanup:YES];
    [m.projectiles removeObject:sprite];
}

@end
