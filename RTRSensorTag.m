//
//  RTRSensorTag.m
//  RunningTracker
//
//  Created by Sebastian Andersson on 4/10/14.
//  Copyright (c) 2014 lirre8. All rights reserved.
//

#import "RTRSensorTag.h"

@implementation RTRSensorTag

@synthesize p;

-(id)init {
    self = [super init];
    if (self) {
        self.gyroSensor = [[sensorIMU3000 alloc] init];
        self.playbackRunning = NO;
        self.zAngle = 90;
    }
    return self;
}

// Run playback of stored data
-(BOOL)stepPlayback {
    if (self.storedDataIndex < self.storedData.zAngles.count) {
        self.zAngle = [[self.storedData.zAngles objectAtIndex:self.storedDataIndex] floatValue];
        self.storedDataIndex++;
        return NO;
    }
    return YES;
}

// Update storedDataIndex. Updates the angles.
-(void)updateStoredDataIndex:(int)index {
    if (index < [self.storedData.zAngles count]) {
        self.storedDataIndex = index;
        self.zAngle = [[self.storedData.zAngles objectAtIndex:self.storedDataIndex] floatValue];
    }
}


-(void) configureSensorTag {
    self.storedData = [[RTRSensorData alloc] init];
    self.storedDataIndex = 0;
    self.gyroIntervalStart = nil;
    self.readSensors = NO;
    // Configure the sensorTag, turning on wanted sensors and setting update periods
    if (self.playbackRunning == NO) {
        if ([self sensorEnabled:@"Accelerometer active"]) {
            CBUUID *sUUID = [CBUUID UUIDWithString:[self.setupData valueForKey:@"Accelerometer service UUID"]];
            CBUUID *cUUID = [CBUUID UUIDWithString:[self.setupData valueForKey:@"Accelerometer config UUID"]];
            CBUUID *pUUID = [CBUUID UUIDWithString:[self.setupData valueForKey:@"Accelerometer period UUID"]];
            NSInteger period = [[self.setupData valueForKey:@"Accelerometer period"] integerValue];
            uint8_t periodData = (uint8_t)(period / 10);
            NSLog(@"%d",periodData);
            [BLEUtility writeCharacteristic:self.p sCBUUID:sUUID cCBUUID:pUUID data:[NSData dataWithBytes:&periodData length:1]];
            uint8_t data = 0x01;
            [BLEUtility writeCharacteristic:self.p sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
            cUUID = [CBUUID UUIDWithString:[self.setupData valueForKey:@"Accelerometer data UUID"]];
            [BLEUtility setNotificationForCharacteristic:self.p sCBUUID:sUUID cCBUUID:cUUID enable:YES];
            //   [self.sensorsEnabled addObject:@"Accelerometer"];
        }
        
        if ([self sensorEnabled:@"Gyroscope active"]) {
            CBUUID *sUUID =  [CBUUID UUIDWithString:[self.setupData valueForKey:@"Gyroscope service UUID"]];
            CBUUID *cUUID =  [CBUUID UUIDWithString:[self.setupData valueForKey:@"Gyroscope config UUID"]];
            CBUUID *pUUID = [CBUUID UUIDWithString:[self.setupData valueForKey:@"Gyroscope period UUID"]];
            NSInteger period = [[self.setupData valueForKey:@"Gyroscope period"] integerValue];
            uint8_t periodData = (uint8_t)(period / 10);
            NSLog(@"%d",periodData);
            [BLEUtility writeCharacteristic:self.p sCBUUID:sUUID cCBUUID:pUUID data:[NSData dataWithBytes:&periodData length:1]];
            uint8_t data = 0x06;
            [BLEUtility writeCharacteristic:self.p sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
            cUUID =  [CBUUID UUIDWithString:[self.setupData valueForKey:@"Gyroscope data UUID"]];
            [BLEUtility setNotificationForCharacteristic:self.p sCBUUID:sUUID cCBUUID:cUUID enable:YES];
            //    [self.sensorsEnabled addObject:@"Gyroscope"];
        }
    }
}

-(void) deconfigureSensorTag {
    if ([self sensorEnabled:@"Accelerometer active"]) {
        CBUUID *sUUID =  [CBUUID UUIDWithString:[self.setupData valueForKey:@"Accelerometer service UUID"]];
        CBUUID *cUUID =  [CBUUID UUIDWithString:[self.setupData valueForKey:@"Accelerometer config UUID"]];
        uint8_t data = 0x00;
        [BLEUtility writeCharacteristic:self.p sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
        cUUID =  [CBUUID UUIDWithString:[self.setupData valueForKey:@"Accelerometer data UUID"]];
        [BLEUtility setNotificationForCharacteristic:self.p sCBUUID:sUUID cCBUUID:cUUID enable:NO];
    }
    
    if ([self sensorEnabled:@"Gyroscope active"]) {
        CBUUID *sUUID =  [CBUUID UUIDWithString:[self.setupData valueForKey:@"Gyroscope service UUID"]];
        CBUUID *cUUID =  [CBUUID UUIDWithString:[self.setupData valueForKey:@"Gyroscope config UUID"]];
        uint8_t data = 0x00;
        [BLEUtility writeCharacteristic:self.p sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
        cUUID =  [CBUUID UUIDWithString:[self.setupData valueForKey:@"Gyroscope data UUID"]];
        [BLEUtility setNotificationForCharacteristic:self.p sCBUUID:sUUID cCBUUID:cUUID enable:NO];
    }
}

-(bool)sensorEnabled:(NSString *)Sensor {
    NSString *val = [self.setupData valueForKey:Sensor];
    if (val) {
        if ([val isEqualToString:@"1"]) return TRUE;
    }
    return FALSE;
}


#pragma mark - CBPeripheral delegate functions

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSLog(@".");
    for (CBService *s in peripheral.services) [peripheral discoverCharacteristics:nil forService:s];
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    NSLog(@"..");
    if ([service.UUID isEqual:[CBUUID UUIDWithString:[self.setupData valueForKey:@"Gyroscope service UUID"]]]) {
        [self configureSensorTag];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didUpdateNotificationStateForCharacteristic %@, error = %@",characteristic.UUID, error);
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didWriteValueForCharacteristic %@ error = %@",characteristic.UUID,error);
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:[self.setupData valueForKey:@"Accelerometer data UUID"]]]) {
        // The axises X and Y on the accelerometer is switched to synchronize with gyroscopes roll, pitch, yaw
        float y = [sensorKXTJ9 calcXValue:characteristic.value];
        float x = [sensorKXTJ9 calcYValue:characteristic.value];
        float z = [sensorKXTJ9 calcZValue:characteristic.value];
        float totalAcc = fabsf(x) + fabsf(y) + fabsf(z);
        if (totalAcc < self.accHiLimit && totalAcc > self.accLowLimit) {
            NSLog(@"hi:%f, lo:%f", self.accHiLimit, self.accLowLimit);
            //          self.yAccAngle = atan2f(x, z)*180/M_PI;
            self.zAccAngle = atan2f(x, y)*180.0/M_PI;
            //          if (self.yAccAngle < -90) {
            //              self.yAccAngle += 360;
            //          }
            if (self.zAccAngle < -90) {
                self.zAccAngle += 360;
            }
            if (self.readSensors == YES) {
                float accInfluence = self.ii;
                /*     if (totalAcc <= 1.0) {
                 accInfluence = INF_LT1*powf(M_E, INF_EXP_LT1*totalAcc);
                 }
                 else {
                 accInfluence = INF_GT1*powf(M_E, INF_EXP_GT1*totalAcc);
                 }
                 */
                //     NSLog(@"accInf: %f totalAcc: %f", accInfluence, totalAcc);
                //        self.yAngle = self.yAngle*(1 - accInfluence) + self.yAccAngle*accInfluence;
                self.zAngle = self.zAngle*(1 - accInfluence) + self.zAccAngle*accInfluence;
            }
            else {
                self.zAngle = self.zAccAngle;
                self.zGyroAngle = self.zAccAngle;
            }
        }
        else {
            self.zAccAngle = 0;
        }
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:[self.setupData valueForKey:@"Gyroscope data UUID"]]] && self.readSensors == YES) {
        if (self.gyroIntervalStart != nil) {
            double timePassed = [self.gyroIntervalStart timeIntervalSinceNow] * -1;
            //         self.yGyro = [self.gyroSensor calcYValue:characteristic.value];
            self.zGyro = [self.gyroSensor calcZValue:characteristic.value];
            //         self.yAngle += self.yGyro * timePassed;
            self.zAngle += self.zGyro * timePassed;
            self.zGyroAngle += self.zGyro * timePassed;
            //      NSLog(@"gyro time passed: %f", timePassed);
            //      NSLog(@"gyro y:%f z:%f", self.yGyro, self.zGyro);
            [self.storedData addDataZangle:self.zAngle accZ:self.zAccAngle gyroZ:self.zGyroAngle];
        }
        self.gyroIntervalStart = [NSDate date];
    }
}

@end
