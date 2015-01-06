//
//  RTRSensorHandler.h
//  RunningTracker
//
//  Created by Sebastian Andersson on 4/10/14.
//  Copyright (c) 2014 lirre8. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#include <math.h>
#import "RTRSensorTag.h"

@interface RTRSensorHandler : NSObject <CBCentralManagerDelegate>

@property (strong,nonatomic) RTRSensorTag *lowerLegTag;
@property (strong,nonatomic) RTRSensorTag *upperLegTag;
@property (strong,nonatomic) CBCentralManager *centralManager;
@property (strong,nonatomic) NSTimer *runPlaybackTimerLow;

-(id) initWithLowerLegTag:(RTRSensorTag *)lowerTag upperLegTag:(RTRSensorTag *)upperTag andCentralManager:(CBCentralManager *)central;
-(void)activateWithII:(float)ii accLimit:(NSString *)accLimit;
-(void)deactivate;
-(void)readSensors;
-(void)stopReadSensors;
-(void) playStoredData;
-(void) stopPlayback;
-(void) resetPlayback;
-(int) totalPlaybackTime;
-(double) currentPlaybackTime;
-(void) setPlaybackIndex:(int)index;
-(void)readDataFromCsvLowerLeg:(NSString *)lowerLeg upperLeg:(NSString *)upperLeg;

@end
