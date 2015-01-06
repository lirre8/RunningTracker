//
//  RTRSensorData.h
//  RunningTracker
//
//  Created by u on 10/28/14.
//  Copyright (c) 2014 lirre8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RTRSensorData : NSObject

/// Collection to store the Z angles
@property (strong,nonatomic) NSMutableArray *zAngles;
/// Collection to store the z angles from accelerometer calculations only
@property (strong,nonatomic) NSMutableArray *zAccAngles;
/// Collection to store the z angles from gyroscope integration calculations only
@property (strong,nonatomic) NSMutableArray *zGyroAngles;

-(void) addDataZangle:(float)z accZ:(float)accZ gyroZ:(float)gyroZ;
-(void) reset;

@end
