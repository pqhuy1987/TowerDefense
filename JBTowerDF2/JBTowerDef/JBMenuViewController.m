//
//  JBMenuViewController.m
//  JBTowerDef
//
//  Created by Johan Boqvist on 03/11/14.
//  Copyright (c) 2014 ___johboq-7___. All rights reserved.
//

#import "JBMenuViewController.h"

@interface JBMenuViewController ()

@end

@implementation JBMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

/*music settings changed */
-(void) musicChangedNotification:(NSNotification *)notification {
    
    UISwitch *object = notification.object;
    
    if(object.on){
        [_player play];
    }
    else {
        [_player stop];
    }
}

-(void) awakeFromNib {
    
      /*observe changes to music settings */
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(musicChangedNotification:) name:@"musicChangedNotification" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*load music resource */
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                         pathForResource:@"Gymnopedie1"
                                         ofType:@"mp3"]];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    _player.numberOfLoops = -1;
    
    [self playMusic];
}



/*plays music (or not) based on music settings in NSUserDefaults */
-(void) playMusic {
    NSUserDefaults* pref = [NSUserDefaults standardUserDefaults];
    NSObject *object = [pref objectForKey:@"musicState"];
    Boolean value = [[NSUserDefaults standardUserDefaults] boolForKey: @"musicState"];
    
    if(object != nil)
    {
        if(value)
            [_player play];
    }
    else {
        [_player play];
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
