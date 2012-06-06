//
//  WaveTypeSelectorTableViewController.h
//  Water
//
//  Created by Roman Smirnov on 11.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaterViewController.h"
#import "Wave.h"
#import "DetailSettingsTableViewController.h"

@interface WaveTypeSelectorTableViewController : UITableViewController
{
    __weak WaterViewController *delegate;
    __weak DetailSettingsTableViewController *parentDelegate;
}
@property (weak) WaterViewController *delegate;
@property (weak) DetailSettingsTableViewController *parentDelegate;
@property (weak) Wave *wave;
@end
