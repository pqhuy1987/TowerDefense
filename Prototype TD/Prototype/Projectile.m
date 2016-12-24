//
//  Projectile.m
//  Prototype
//
//  Created by Nicolas Goles on 9/13/12.
//
//

#import "Projectile.h"

@implementation Projectile
+ (id)projectile
{
    Projectile *projectile = nil;

    if ((projectile = [[super alloc] initWithFile:@"Projectile.png"])) {

    }

    return projectile;
}

- (void) dealloc
{
    [super dealloc];
}
@end
