//
//  hud.m
//  Prototype
//
//  Created by Nicolas Goles on 9/13/12.
//
//

#import "hud.h"
#import "GameManager.h"
#import "GameScene.h"

@implementation Hud

+ (Hud *) sharedManager
{
    static dispatch_once_t once;
    static Hud *sharedInstance = nil;

    dispatch_once(&once, ^{
        if (!sharedInstance) {
            sharedInstance = [[self alloc] init];
        }
    });

    return sharedInstance;
}

- (id) init
{
    if (self = [super init]) {
        CGSize windowSize = [CCDirector sharedDirector].winSize;
        
        // Init background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        _background = [CCSprite spriteWithFile:@"hud_background.png"];
        _background.anchorPoint = ccp(0,0);
        [self addChild:_background];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        // Init sprites
        _movable = [[NSMutableArray alloc] init];
        NSArray *movableImages = @[@"tower1.png"];
        
        int imageCounter = 0;
        for (NSString *image in movableImages) {
            CCSprite *sprite = [CCSprite spriteWithFile:image];
            float offset = (imageCounter + 1.0) / (movableImages.count + 1);
            sprite.position = ccp(windowSize.width * offset, 16);
            [self addChild:sprite];
            [_movable addObject:sprite];
            ++imageCounter;
        }
        
        [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    }
    
    return self;
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    
    for (CCSprite *sprite in _movable) {
        if (CGRectContainsPoint(sprite.boundingBox, touchLocation)) {
            [GameManager sharedManager].gestureRecognizer.enabled = NO;
            _selectedSpriteRange = [CCSprite spriteWithFile:@"tower_range.png"];
            _selectedSprite.scale = 1.0;
            [self addChild:_selectedSpriteRange z:-1];
            _selectedSpriteRange.position = sprite.position;
            
            CCSprite *newSprite = [CCSprite spriteWithTexture:[sprite texture]];
            newSprite.position = sprite.position;
            newSprite.scale = 2.0f;
            _selectedSprite = newSprite;
            [self addChild:newSprite];
            
            break;
        }
    }
    
    return YES;
}

- (void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    [self convertToNodeSpace:oldTouchLocation]; // TODO: Ojo con touch
    CGPoint translation = ccpSub(touchLocation, oldTouchLocation);
    
    if (_selectedSprite) {
        CGPoint newPosition = ccpAdd(_selectedSprite.position, translation);
        if (!_didStartDraggingSprite) {
            newPosition.y += 32.0f;
            _didStartDraggingSprite = YES;
        }

        _selectedSprite.position = newPosition;
        _selectedSpriteRange.position = newPosition;
        CGPoint touchLocationInGameLayer = [[GameManager sharedManager].gameLayer convertTouchToNodeSpace:touch];
        
        BOOL isBuildable = [(GameScene *)[GameManager sharedManager].gameLayer canBuildAtPosition:touchLocationInGameLayer];
        
        if (isBuildable) {
            _selectedSprite.opacity = 200;
        } else {
            _selectedSprite.opacity = 25;
        }
    }
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];


    if (_selectedSprite) {
        CGRect backgroundRect = CGRectMake(_background.position.x,
                                           _background.position.y,
                                           _background.contentSize.width,
                                           _background.contentSize.height);
		
		if (!CGRectContainsPoint(backgroundRect, touchLocation)) {
			CGPoint touchLocationInGameLayer = [[GameManager sharedManager].gameLayer convertTouchToNodeSpace:touch];
			[(GameScene *)[GameManager sharedManager].gameLayer addTowerAtPoint: touchLocationInGameLayer];
		}
		
		[self removeChild:_selectedSprite cleanup:YES];
		_selectedSprite = nil;
		[self removeChild:_selectedSpriteRange cleanup:YES];
		_selectedSpriteRange = nil;

        if (_didStartDraggingSprite) {
            _didStartDraggingSprite = NO;
        }
    }
    
    [GameManager sharedManager].gestureRecognizer.enabled = YES;
}

@end
