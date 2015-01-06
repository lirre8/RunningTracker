//
//  RTRDeviceSelector.h
//  RunningTracker
//
//  Created by Sebastian Andersson on 4/10/14.
//  Copyright (c) 2014 lirre8. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "RTRSensorTag.h"
#import "RTRMainViewController.h"
#import "RTRSensorHandler.h"

@interface RTRDeviceSelector : UITableViewController <CBCentralManagerDelegate,CBPeripheralDelegate>

@property (strong,nonatomic) CBCentralManager *central;
@property (strong,nonatomic) NSMutableArray *nDevices;
@property (strong,nonatomic) NSMutableArray *sensorTags;
@property (strong,nonatomic) NSNumber *stage;
@property (strong,nonatomic) RTRSensorTag *upperLegTag;
@property (strong,nonatomic) RTRSensorTag *lowerLegTag;


-(NSMutableDictionary *) makeSensorTagConfiguration;

@end
