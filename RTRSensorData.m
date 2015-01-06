//
//  RTRSensorData.m
//  RunningTracker
//
//  Created by u on 10/28/14.
//  Copyright (c) 2014 lirre8. All rights reserved.
//

#import "RTRSensorData.h"

@implementation RTRSensorData

-(id)init {
    self = [super init];
    if (self) {
        [self reset];
    }
    return self;
}

-(void)addDataZangle:(float)z accZ:(float)accZ gyroZ:(float)gyroZ {
    [self.zAngles addObject:[NSNumber numberWithFloat:z]];
    [self.zAccAngles addObject:[NSNumber numberWithFloat:accZ]];
    [self.zGyroAngles addObject:[NSNumber numberWithFloat:gyroZ]];
}

-(void)reset {
    self.zAngles = [[NSMutableArray alloc] init];
    self.zAccAngles = [[NSMutableArray alloc] init];
    self.zGyroAngles = [[NSMutableArray alloc] init];
}

@end
