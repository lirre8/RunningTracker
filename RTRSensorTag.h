//
//  RTRSensorTag.h
//  RunningTracker
//
//  Created by Sebastian Andersson on 4/10/14.
//  Copyright (c) 2014 lirre8. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEUtility.h"
#import "Sensors.h"
#import "RTRSensorData.h"

@interface RTRSensorTag : NSObject <CBPeripheralDelegate>

/// Pointer to CoreBluetooth peripheral
@property (strong,nonatomic) CBPeripheral *p;
/// Pointer to dictionary with device setup data
@property NSMutableDictionary *setupData;
/// Pointer to the gyroscope sensor
@property (strong,nonatomic) sensorIMU3000 *gyroSensor;
/// Time when the latest values from the gyroscope was read
@property (strong,nonatomic) NSDate *gyroIntervalStart;
/// Object that stores the sensor data
@property (strong,nonatomic) RTRSensorData *storedData;

/// The angle of the sensortag in the x,y,z axes
//@property (nonatomic) float yAngle;
@property (nonatomic) float zAngle;
//@property (nonatomic) float yGyro;
@property (nonatomic) float zGyro;
@property (nonatomic) float zGyroAngle;
//@property (nonatomic) float yAccAngle;
@property (nonatomic) float zAccAngle;
@property (nonatomic) BOOL playbackRunning;
@property (nonatomic) BOOL readSensors;
@property (nonatomic) NSUInteger storedDataIndex;
@property (nonatomic) float ii;
@property (nonatomic) float accLowLimit;
@property (nonatomic) float accHiLimit;

#define INF_LT1 6.75964*pow(10.0,-6.0)
#define INF_GT1 48.0127
#define INF_EXP_LT1 10.5173
#define INF_EXP_GT1 -5.25867

-(void) configureSensorTag;
-(void) deconfigureSensorTag;
-(BOOL) stepPlayback;
-(void) updateStoredDataIndex:(int)index;

@end
