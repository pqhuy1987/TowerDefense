//
//  GameManager.m
//  Prototype
//
//  Created by Nicolas Goles on 9/12/12.
//
//

#import "GameManager.h"
#import "ConstantsAndMacros.h"

static GameManager *_sharedInstance = nil;

@implementation GameManager

// Singleton Access
+ (GameManager *) sharedManager
{
    if (!_sharedInstance) {
        _sharedInstance = [[self alloc] init];
    }

    return _sharedInstance;
}

#pragma mark -
#pragma mark NSCoder
- (void) encodeWithCoder:(NSCoder *)aCoder
{
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    return self;
}

#pragma mark -
#pragma mark Base Methods
- (id) init
{
    if (self = [super init]) {
        _targets = [[NSMutableArray alloc] init];
        _waypoints = [[NSMutableArray alloc] init];
        _waves = [[NSMutableArray alloc] init];
        _towers = [[NSMutableArray alloc] init];
        _projectiles = [[NSMutableArray alloc] init];

        // Load Default Dictionary
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *plistPath = [bundle pathForResource:DEFAULTS_FILE_NAME ofType:DEFAULTS_FILE_TYPE];
        _defaultSettings = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    }

    return self;
}

- (void) dealloc
{
    _gameLayer = nil;
    _gestureRecognizer = nil;
    _targets = nil;
    _waypoints = nil;
    _waves = nil;

    [_towers release];
    _towers = nil;

    [_projectiles release];
    _projectiles = nil;

    [super dealloc];
}


@end
