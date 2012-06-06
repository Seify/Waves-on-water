//
//  WaterViewController.h
//  Water
//
//  Created by Roman Smirnov on 13.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "ModelDataStructures.h"

@interface WaterViewController : GLKViewController <UIPopoverControllerDelegate>
{
    float time;
    vec3 rotation;
    vec3 rotationSpeed;
    vec3 scale;
    vec3 translation;
    
    GLuint _waterTexture;
    
    NSMutableArray *_waves;

    __weak IBOutlet UILabel *display;
}
@property (strong) UIPopoverController *popController;
@property (strong, readonly)     NSMutableArray *waves;
- (IBAction)sombreroPressed:(id)sender;
@end
