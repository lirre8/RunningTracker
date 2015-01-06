//
//  RTRSensorHandler.m
//  RunningTracker
//
//  Created by Sebastian Andersson on 4/10/14.
//  Copyright (c) 2014 lirre8. All rights reserved.
//

#import "RTRSensorHandler.h"

@implementation RTRSensorHandler

-(id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

-(id) initWithLowerLegTag:(RTRSensorTag *)lowerTag upperLegTag:(RTRSensorTag *)upperTag andCentralManager:(CBCentralManager *)central {
    self = [super init];
    if (self) {
        self.lowerLegTag = lowerTag;
        self.upperLegTag = upperTag;
        self.centralManager = central;
    }
    return self;
}

-(void)activateWithII:(float)ii accLimit:(NSString *)accLimit {
    self.lowerLegTag.ii = ii;
    self.upperLegTag.ii = ii;
    
    NSArray* accLimits = [accLimit componentsSeparatedByString:@"-"];
    self.lowerLegTag.accLowLimit = [[accLimits objectAtIndex:0] floatValue];
    self.lowerLegTag.accHiLimit = [[accLimits objectAtIndex:1] floatValue];
    self.upperLegTag.accLowLimit = [[accLimits objectAtIndex:0] floatValue];
    self.upperLegTag.accHiLimit = [[accLimits objectAtIndex:1] floatValue];
    
    self.centralManager.delegate = self;
    // Lower leg sensortag
    if (self.lowerLegTag.p.state != CBPeripheralStateConnected)
        [self.centralManager connectPeripheral:self.lowerLegTag.p options:nil];
    else
        [self.lowerLegTag configureSensorTag];
    // Upper leg sensortag
    if (self.upperLegTag.p.state != CBPeripheralStateConnected)
        [self.centralManager connectPeripheral:self.upperLegTag.p options:nil];
    else
        [self.upperLegTag configureSensorTag];
}

-(void)deactivate {
    [self.lowerLegTag deconfigureSensorTag];
    [self.upperLegTag deconfigureSensorTag];
    self.centralManager.delegate = nil;
}

-(void)readSensors {
    self.lowerLegTag.readSensors = YES;
    self.upperLegTag.readSensors = YES;
}

-(void)stopReadSensors {
    self.lowerLegTag.readSensors = NO;
    self.upperLegTag.readSensors = NO;
}

-(void)playStoredData {
    self.runPlaybackTimerLow = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(runPlayback:) userInfo:nil repeats:YES];
}

-(IBAction)runPlayback:(id)sender {
    BOOL ended = [self.lowerLegTag stepPlayback] || [self.upperLegTag stepPlayback];
    if (ended) {
        [self stopPlayback];
    }
}

-(void)stopPlayback {
    [self.runPlaybackTimerLow invalidate];
    self.runPlaybackTimerLow = nil;
}

-(void)resetPlayback {
    self.lowerLegTag.storedDataIndex = 0;
    self.upperLegTag.storedDataIndex = 0;
}

-(int)totalPlaybackTime {
    return [self.upperLegTag.storedData.zAngles count]/10.0;
}

-(double)currentPlaybackTime {
    return self.upperLegTag.storedDataIndex/10.0;
}

// Sets the index of both tags.
-(void)setPlaybackIndex:(int)index {
    [self.lowerLegTag updateStoredDataIndex:index];
    [self.upperLegTag updateStoredDataIndex:index];
}

// Upload data from csv file
-(void)readDataFromCsvLowerLeg:(NSString *)lowerLeg upperLeg:(NSString *)upperLeg {
    // Lower leg data
    RTRSensorData* newLowerData = [[RTRSensorData alloc] init];
    NSArray* lines = [lowerLeg componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for (int i=2; i<lines.count-1; i+=2) {
        float angle = [[[[lines objectAtIndex:i] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]] objectAtIndex:0] floatValue];
        [newLowerData addDataZangle:angle accZ:0 gyroZ:0];
    }
    // Upper leg data
    RTRSensorData* newUpperData = [[RTRSensorData alloc] init];
    lines = [upperLeg componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for (int i=2; i<lines.count-1; i+=2) {
        float angle = [[[[lines objectAtIndex:i] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]] objectAtIndex:0] floatValue];
        [newUpperData addDataZangle:angle accZ:0 gyroZ:0];
    }
    [self setStoredDataOfLowerTag:newLowerData upperTag:newUpperData];
}

-(void)setStoredDataOfLowerTag:(RTRSensorData *)lowerTag upperTag:(RTRSensorData *)upperTag {
    self.lowerLegTag.storedData = lowerTag;
    self.upperLegTag.storedData = upperTag;
}

#pragma mark - CBCentralManager delegate function

-(void) centralManagerDidUpdateState:(CBCentralManager *)central {
}

-(void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    if ([self.lowerLegTag.p isEqual:peripheral]){
        self.lowerLegTag.p.delegate = self.lowerLegTag;
    }
    else if ([self.upperLegTag.p isEqual:peripheral]){
        self.upperLegTag.p.delegate = self.upperLegTag;
    }
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [self peripheralDisconnected: peripheral];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [self peripheralDisconnected: peripheral];
}

-(void)peripheralDisconnected:(CBPeripheral *)p {
    [self.lowerLegTag deconfigureSensorTag];
    [self.upperLegTag deconfigureSensorTag];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Device disconnected!" message:@"Please reconnect to the sensorTag" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}


@end
