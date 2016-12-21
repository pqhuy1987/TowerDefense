//
//  JBViewController.m
//  JBTowerDef
//
//  Created by Johan Boqvist on 31/10/14.
//  Copyright (c) 2014 ___johboq-7___. All rights reserved.
//

#import "JBViewController.h"
#import "JBMyScene.h"

@interface JBViewController()
@property SKScene *scene;
@end

@implementation JBViewController

-(void) awakeFromNib {
    
    /*observe transititions in scene */
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLevelNotification:) name:@"newLevel" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseGameNotification:) name:@"pauseGame" object:nil];
    
}

/*receives change level notifications from scene */
-(void) changeLevelNotification: (NSNotification*) notification {
    
    NSDictionary *levelInfo = [notification userInfo];
    NSString* level = [levelInfo valueForKey:@"level"];
    
    if([level isEqualToString:@"level4"]){
        
        /* return back to main menu AKA lame ending */
        [self dismissViewControllerAnimated: YES completion: nil];
    }
    else {
        [self setLevel:level]; /*start new level */
    }
}

/*pause the game */
-(void) pauseGameNotification: (NSNotification*) notification {
    
    _scene.view.paused = YES;
}


/*start the new level */
-(void) setLevel:(NSString *)level {
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
 
    // Create and configure the scene.
    _scene = [[JBMyScene alloc ]initWithSize:CGSizeMake(480.0, 320.0) andLevel:level];
   
    // Present the scene.
    [skView presentScene:_scene];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setLevel:@"level1"];

}

-(void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
   
}


- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
