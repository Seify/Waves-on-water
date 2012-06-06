//
//  DetailSettingsTableViewController.h
//  Water
//
//  Created by Roman Smirnov on 21.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaterViewController.h"
#import "Wave.h"

@class WaterViewController;


@interface DetailSettingsTableViewController : UITableViewController
{
    __weak WaterViewController *delegate;
}
@property (weak) WaterViewController *delegate;
@property (weak) Wave *wave;

@end
