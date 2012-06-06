//
//  Wave.h
//  Water
//
//  Created by Roman Smirnov on 20.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define WAVE_TYPE_HARMONIC 1
#define WAVE_TYPE_SPHERICAL 2
#define WAVE_TYPE_SPIRAL 3

#import <Foundation/Foundation.h>

@interface Wave : NSObject
@property int type;
@property float amplitude;
@property float wavenumber;
@property float angularFrequency;
@property float phase;
@property float direction;
@property float positionX;
@property float positionY;
@property (strong) NSString *name;
@end
