//
//  JBSettingsTableViewController.m
//  JBTowerDef
//
//  Created by Johan Boqvist on 03/11/14.
//  Copyright (c) 2014 ___johboq-7___. All rights reserved.
//

#import "JBSettingsTableViewController.h"

@interface JBSettingsTableViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *switchSound;
@property (weak, nonatomic) IBOutlet UISwitch *switchMusic;

@end

@implementation JBSettingsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)switchSoundChanged:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:_switchSound.on forKey:@"soundState"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (IBAction)switchMusicChanged:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:_switchMusic.on forKey:@"musicState"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"musicChangedNotification" object:_switchMusic];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Load current sound settings
    NSUserDefaults* pref = [NSUserDefaults standardUserDefaults];
    NSObject *object = [pref objectForKey:@"soundState"];
    
    if(object != nil)
    {
        [_switchSound setOn:[[NSUserDefaults standardUserDefaults] boolForKey: @"soundState"]];
    }
    else [_switchSound setOn:YES];
    
    
    //Load current music settings
    pref = [NSUserDefaults standardUserDefaults];
    object = [pref objectForKey:@"musicState"];
    
    if(object != nil)
    {
        [_switchMusic setOn:[[NSUserDefaults standardUserDefaults] boolForKey: @"musicState"]];
    }
    else [_switchMusic setOn:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
