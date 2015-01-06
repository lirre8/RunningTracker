//
//  RTRDeviceSelector.m
//  RunningTracker
//
//  Created by Sebastian Andersson on 4/10/14.
//  Copyright (c) 2014 lirre8. All rights reserved.
//

#import "RTRDeviceSelector.h"

@interface RTRDeviceSelector ()

@end

@implementation RTRDeviceSelector
@synthesize central,nDevices,sensorTags,stage;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.central = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
        self.nDevices = [[NSMutableArray alloc]init];
        self.sensorTags = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Running Tracker";
    
    // Setup the ready button on the right side of navigation bar
    UIBarButtonItem *readyButton = [[UIBarButtonItem alloc]initWithTitle:@"Ready" style:UIBarButtonItemStylePlain target:self action:@selector(ready:)];
    self.navigationItem.rightBarButtonItem = readyButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated {
    self.central.delegate = self;
    // Reset stored data
    self.lowerLegTag = nil;
    self.upperLegTag = nil;
    self.stage = [NSNumber numberWithInt:0];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sensorTags.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[NSString stringWithFormat:@"%ld_Cell",(long)indexPath.row]];
    CBPeripheral *p = [self.sensorTags objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",p.name];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",CFUUIDCreateString(nil, (__bridge CFUUIDRef)(p.identifier))];
    if ([p isEqual:self.lowerLegTag.p] || [p isEqual:self.upperLegTag.p]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *header = @"";
    if (section == 0) {
        if (self.sensorTags.count == 0) {
            header = @"No SensorTag Devices Found";
        }
        switch ([self.stage intValue]) {
            case 0:
                header = @"Choose your lower leg SensorTag";
                break;
            case 1:
                header = @"Choose your upper leg SensorTag";
                break;
            case 2:
                header = @"Press ready to continue";
                break;
            default:
                break;
        }
    }
    
    return header;
}

-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 15.0f;
}

#pragma mark - Table view delegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CBPeripheral *p = [self.sensorTags objectAtIndex:indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RTRSensorTag *tag = [[RTRSensorTag alloc]init];
    tag.p = p;
    tag.setupData = [self makeSensorTagConfiguration];
    
    if ([self.stage intValue] == 0) {
        self.stage = [NSNumber numberWithInt:[self.stage intValue]+1];
        self.lowerLegTag = tag;
    }
    else if ([self.stage intValue] == 1 && ![tag.p isEqual:self.lowerLegTag.p]) {
        self.stage = [NSNumber numberWithInt:[self.stage intValue]+1];
        self.upperLegTag = tag;
    }
    
    [self.tableView reloadData];
}

-(IBAction)ready:(id)sender {
    if ([self.stage intValue] == 1) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Connect sensorTags" message:@"Please connect 2 sensorTags before continuing" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    else if ([self.stage intValue] == 2){
        RTRSensorHandler *sensorHandler = [[RTRSensorHandler alloc]initWithLowerLegTag:self.lowerLegTag upperLegTag:self.upperLegTag andCentralManager:self.central];
        RTRMainViewController *mainView = [[RTRMainViewController alloc]initWithNibName:nil bundle:nil andSensorHandler:sensorHandler];
        [self.navigationController pushViewController:mainView animated:YES];
    }
    else {
        RTRSensorTag *tag1 = [[RTRSensorTag alloc]init];
        RTRSensorTag *tag2 = [[RTRSensorTag alloc]init];
        RTRSensorHandler *sensorHandler = [[RTRSensorHandler alloc]initWithLowerLegTag:tag1 upperLegTag:tag2 andCentralManager:nil];
        RTRMainViewController *mainView = [[RTRMainViewController alloc]initWithNibName:nil bundle:nil andSensorHandler:sensorHandler];
        [self.navigationController pushViewController:mainView animated:YES];
    }
}

#pragma mark - CBCentralManager delegate

-(void)centralManagerDidUpdateState:(CBCentralManager *)m {
    if (m.state != CBCentralManagerStatePoweredOn) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"BLE not supported !" message:[NSString stringWithFormat:@"CoreBluetooth return state: %d",m.state] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    else {
        [m scanForPeripheralsWithServices:nil options:nil];
    }
}

-(void)centralManager:(CBCentralManager *)m didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSLog(@"Found a BLE Device : %@",peripheral);
    
    /* iOS 6.0 bug workaround : connect to device before displaying UUID !
     The reason for this is that the CFUUID .UUID property of CBPeripheral
     here is null the first time an unkown (never connected before in any app)
     peripheral is connected. So therefore we connect to all peripherals we find.
     */
    
    peripheral.delegate = self;
    [m connectPeripheral:peripheral options:nil];
    
    [self.nDevices addObject:peripheral];
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [peripheral discoverServices:nil];
}

#pragma  mark - CBPeripheral delegate

-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    BOOL replace = NO;
    BOOL found = NO;
    NSLog(@"Services scanned !");
    [self.central cancelPeripheralConnection:peripheral];
    for (CBService *s in peripheral.services) {
        NSLog(@"Service found : %@",s.UUID);
        if ([s.UUID isEqual:[CBUUID UUIDWithString:@"F000AA00-0451-4000-B000-000000000000"]])  {
            NSLog(@"This is a SensorTag !");
            found = YES;
        }
    }
    if (found) {
        // Match if we have this device from before
        for (int ii=0; ii < self.sensorTags.count; ii++) {
            CBPeripheral *p = [self.sensorTags objectAtIndex:ii];
            if ([p isEqual:peripheral]) {
                [self.sensorTags replaceObjectAtIndex:ii withObject:peripheral];
                replace = YES;
            }
        }
        if (!replace) {
            [self.sensorTags addObject:peripheral];
            [self.tableView reloadData];
        }
    }
}

-(void) peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didUpdateNotificationStateForCharacteristic %@ error = %@",characteristic,error);
}

-(void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didWriteValueForCharacteristic %@ error = %@",characteristic,error);
}


#pragma mark - SensorTag configuration

-(NSMutableDictionary *) makeSensorTagConfiguration {
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    
    // Setup the accelerometer
    [d setValue:@"1" forKey:@"Accelerometer active"];
    [d setValue:@"100" forKey:@"Accelerometer period"];
    [d setValue:@"F000AA10-0451-4000-B000-000000000000" forKey:@"Accelerometer service UUID"];
    [d setValue:@"F000AA11-0451-4000-B000-000000000000" forKey:@"Accelerometer data UUID"];
    [d setValue:@"F000AA12-0451-4000-B000-000000000000" forKey:@"Accelerometer config UUID"];
    [d setValue:@"F000AA13-0451-4000-B000-000000000000" forKey:@"Accelerometer period UUID"];
    
    // Setup the gyroscope
    [d setValue:@"1" forKey:@"Gyroscope active"];
    [d setValue:@"100" forKey:@"Gyroscope period"];
    [d setValue:@"F000AA50-0451-4000-B000-000000000000" forKey:@"Gyroscope service UUID"];
    [d setValue:@"F000AA51-0451-4000-B000-000000000000" forKey:@"Gyroscope data UUID"];
    [d setValue:@"F000AA52-0451-4000-B000-000000000000" forKey:@"Gyroscope config UUID"];
    [d setValue:@"F000AA53-0451-4000-B000-000000000000" forKey:@"Gyroscope period UUID"];
    
    NSLog(@"%@",d);
    
    return d;
}

@end
