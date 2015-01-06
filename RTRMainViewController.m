//
//  RTRMainViewController.m
//  RunningTracker
//
//  Created by Sebastian Andersson on 4/10/14.
//  Copyright (c) 2014 lirre8. All rights reserved.
//

#import "RTRMainViewController.h"

@interface RTRMainViewController ()

@end

@implementation RTRMainViewController

@synthesize sensorHandler, lowerLegAngle, upperLegAngle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andSensorHandler:(RTRSensorHandler *)handler {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.sensorHandler = handler;
        self.view.backgroundColor = [UIColor whiteColor];
        self.maxGyroUp = 0;
        self.maxGyroLow = 0;
        self.checkBoxSelected = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Running Tracker";
    
    UIBarButtonItem *mailer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(sendMail:)];
    UIBarButtonItem *uploader = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(uploadData:)];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:mailer, uploader, nil]];
	
    // Create the init, stop and calibrate buttons
    self.initializeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.initializeButton.frame = CGRectMake(self.view.bounds.size.width/4, 70, self.view.bounds.size.width/4, 25);
    [self.initializeButton setTitle:@"Init" forState:UIControlStateNormal];
    [self.initializeButton addTarget:self action:@selector(initButton:) forControlEvents:UIControlEventTouchUpInside];
    
    self.iiValueField = [[UITextField alloc] init];
    self.iiValueField.frame = CGRectMake(self.view.bounds.size.width/8, 70, self.view.bounds.size.width/8, 25);
    self.iiValueField.borderStyle = UITextBorderStyleRoundedRect;
    self.iiValueField.textColor = [UIColor blackColor];
    self.iiValueField.font = [UIFont systemFontOfSize:12.0];
    self.iiValueField.backgroundColor = [UIColor whiteColor];
    self.iiValueField.keyboardType = UIKeyboardTypeDecimalPad;
    self.iiValueField.placeholder = @"ii";
    
    self.accLimitField = [[UITextField alloc] init];
    self.accLimitField.frame = CGRectMake(0, 70, self.view.bounds.size.width/8, 25);
    self.accLimitField.borderStyle = UITextBorderStyleRoundedRect;
    self.accLimitField.textColor = [UIColor blackColor];
    self.accLimitField.font = [UIFont systemFontOfSize:12.0];
    self.accLimitField.backgroundColor = [UIColor whiteColor];
    self.accLimitField.keyboardType = UIKeyboardTypeDefault;
    self.accLimitField.placeholder = @"accLimit";
    
    self.startButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.startButton.frame = CGRectMake(0, 70, self.view.bounds.size.width/4, 25);
    [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
    [self.startButton addTarget:self action:@selector(startButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.startButton setHidden:YES];
    
    self.pauseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.pauseButton.frame = CGRectMake(0, 70, self.view.bounds.size.width/4, 25);
    [self.pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    [self.pauseButton addTarget:self action:@selector(pauseButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.pauseButton setHidden:YES];
    
    self.stopButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.stopButton.frame = CGRectMake(self.view.bounds.size.width/4, 70, self.view.bounds.size.width/4, 25);
    [self.stopButton setTitle:@"Stop" forState:UIControlStateNormal];
    [self.stopButton addTarget:self action:@selector(stopButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.stopButton setHidden:YES];
    
    // Calibrate button
    self.calibrateButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.calibrateButton.frame = CGRectMake(self.view.bounds.size.width/2, 70, self.view.bounds.size.width/2, 25);
    [self.calibrateButton setTitle:@"Calibrate" forState:UIControlStateNormal];
    [self.calibrateButton addTarget:self action:@selector(calibrate:) forControlEvents:UIControlEventTouchUpInside];
    
    // Test labels for angles
    self.upperLegAngle = [[UILabel alloc]init];
    self.upperLegAngle.frame = CGRectMake(0, 100, self.view.bounds.size.width/2, 30);
    self.upperLegAngle.textAlignment = NSTextAlignmentCenter;
    self.upperLegAngle.font = [UIFont systemFontOfSize:16];
    self.upperLegAngle.backgroundColor = [UIColor clearColor];
    self.upperLegAngle.text = @"Upper angle:-";
    
    self.upperAccAngle = [[UILabel alloc]init];
    self.upperAccAngle.frame = CGRectMake(self.view.bounds.size.width/2, 100, self.view.bounds.size.width/2, 30);
    self.upperAccAngle.textAlignment = NSTextAlignmentCenter;
    self.upperAccAngle.font = [UIFont systemFontOfSize:16];
    self.upperAccAngle.backgroundColor = [UIColor clearColor];
    self.upperAccAngle.text = @"Acc angle:-";
    
    self.lowerLegAngle = [[UILabel alloc]init];
    self.lowerLegAngle.frame = CGRectMake(0, 130, self.view.bounds.size.width/2, 30);
    self.lowerLegAngle.textAlignment = NSTextAlignmentCenter;
    self.lowerLegAngle.font = [UIFont systemFontOfSize:16];
    self.lowerLegAngle.backgroundColor = [UIColor clearColor];
    self.lowerLegAngle.text = @"Lower angle:-";
    
    self.lowerAccAngle = [[UILabel alloc]init];
    self.lowerAccAngle.frame = CGRectMake(self.view.bounds.size.width/2, 130, self.view.bounds.size.width/2, 30);
    self.lowerAccAngle.textAlignment = NSTextAlignmentCenter;
    self.lowerAccAngle.font = [UIFont systemFontOfSize:16];
    self.lowerAccAngle.backgroundColor = [UIColor clearColor];
    self.lowerAccAngle.text = @"Acc angle:-";
    
    self.maxGyro = [[UILabel alloc]init];
    self.maxGyro.frame = CGRectMake(0, 160, self.view.bounds.size.width, 30);
    self.maxGyro.textAlignment = NSTextAlignmentCenter;
    self.maxGyro.font = [UIFont systemFontOfSize:16];
    self.maxGyro.backgroundColor = [UIColor clearColor];
    self.maxGyro.text = @"Max gyro(Y,Z):-,-";
    
    /*    // Test labels for gyro angles
     self.gyroAngle = [[UILabel alloc]init];
     self.gyroAngle.frame = CGRectMake(0, 140, self.view.bounds.size.width, 30);
     self.gyroAngle.textAlignment = NSTextAlignmentCenter;
     self.gyroAngle.font = [UIFont boldSystemFontOfSize:17];
     self.gyroAngle.backgroundColor = [UIColor clearColor];
     self.gyroAngle.text = @"Gyro= Y:- Z:-";
     
     // Test labels for acc angles
     self.accAngle = [[UILabel alloc]init];
     self.accAngle.frame = CGRectMake(0, 180, self.view.bounds.size.width, 30);
     self.accAngle.textAlignment = NSTextAlignmentCenter;
     self.accAngle.font = [UIFont boldSystemFontOfSize:17];
     self.accAngle.backgroundColor = [UIColor clearColor];
     self.accAngle.text = @"Acc= Y:- Z:-";
     */
    
    // Drawing area
    UIView *graphicView = [[UIView alloc] initWithFrame:CGRectMake(0, 220, self.view.bounds.size.width, 240)];
    self.lineShape = nil;
    self.lineShape = [CAShapeLayer layer];
    self.lineShape.lineWidth = 14.0f;
    self.lineShape.lineCap = kCALineCapRound;;
    self.lineShape.fillColor = [[UIColor clearColor] CGColor];
    self.lineShape.strokeColor = [[UIColor orangeColor] CGColor];
    [graphicView.layer addSublayer:self.lineShape];
    
    // Buttons for playback of stored data
    // Play button
    self.startPlaybackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.startPlaybackButton.frame = CGRectMake(0, 470, self.view.bounds.size.width/2, 25);
    [self.startPlaybackButton setTitle:@"Play" forState:UIControlStateNormal];
    [self.startPlaybackButton addTarget:self action:@selector(playStoredData:) forControlEvents:UIControlEventTouchUpInside];
    
    // Pause button
    self.pausePlaybackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.pausePlaybackButton.frame = CGRectMake(0, 470, self.view.bounds.size.width/2, 25);
    [self.pausePlaybackButton setTitle:@"Pause" forState:UIControlStateNormal];
    [self.pausePlaybackButton addTarget:self action:@selector(pauseStoredData:) forControlEvents:UIControlEventTouchUpInside];
    [self.pausePlaybackButton setHidden:YES];
    
    // Reset button
    self.resetPlaybackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.resetPlaybackButton.frame = CGRectMake(self.view.bounds.size.width/2, 470, self.view.bounds.size.width/2, 25);
    [self.resetPlaybackButton setTitle:@"Reset" forState:UIControlStateNormal];
    [self.resetPlaybackButton addTarget:self action:@selector(resetStoredData:) forControlEvents:UIControlEventTouchUpInside];
    
    // Playback slider
    self.playbackSlider = [[UISlider alloc] init];
    self.playbackSlider.frame = CGRectMake(0, 500, self.view.bounds.size.width, 30);
    self.playbackSlider.maximumValue = 0.0;
    [self.playbackSlider addTarget:self action:@selector(playbackSliderChanged:) forControlEvents:UIControlEventValueChanged];
    
    // Playback label
    self.playbackLabel = [[UILabel alloc]init];
    self.playbackLabel.frame = CGRectMake(0, 530, self.view.bounds.size.width, 20);
    self.playbackLabel.textAlignment = NSTextAlignmentCenter;
    self.playbackLabel.font = [UIFont systemFontOfSize:12];
    self.playbackLabel.backgroundColor = [UIColor clearColor];
    self.playbackLabel.text = @"0.0";
    
    
    [self.view addSubview:self.initializeButton];
    [self.view addSubview:self.iiValueField];
    [self.view addSubview:self.accLimitField];
    [self.view addSubview:self.stopButton];
    [self.view addSubview:self.startButton];
    [self.view addSubview:self.pauseButton];
    [self.view addSubview:self.upperLegAngle];
    [self.view addSubview:self.lowerLegAngle];
    [self.view addSubview:self.upperAccAngle];
    [self.view addSubview:self.lowerAccAngle];
    [self.view addSubview:self.maxGyro];
    [self.view addSubview:self.calibrateButton];
    [self.view addSubview:graphicView];
    [self.view addSubview:self.startPlaybackButton];
    [self.view addSubview:self.pausePlaybackButton];
    [self.view addSubview:self.resetPlaybackButton];
    [self.view addSubview:self.playbackSlider];
    [self.view addSubview:self.playbackLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [self.sensorHandler deactivate];
}

-(IBAction)initButton:(id)sender {
    if ([self.iiValueField.text length] != 0 && [self.accLimitField.text length] != 0) {
        [self.iiValueField endEditing:YES];
        [self.accLimitField endEditing:YES];
        [self.initializeButton setHidden:YES];
        [self.iiValueField setHidden:YES];
        [self.accLimitField setHidden:YES];
        [self.startPlaybackButton setHidden:YES];
        [self.resetPlaybackButton setHidden:YES];
        [self.startButton setHidden:NO];
        [self.stopButton setHidden:NO];
        [self.playbackSlider setEnabled:NO];
        self.maxGyroUp = 0;
        self.maxGyroLow = 0;
        [self.sensorHandler activateWithII:[self.iiValueField.text floatValue] accLimit:self.accLimitField.text];
        self.readAngleTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(readAngle:) userInfo:nil repeats:YES];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"ii value" message:@"Please enter a valid ii value" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

-(IBAction)startButton:(id)sender {
    [self.stopButton setHidden:YES];
    [self.startButton setHidden:YES];
    [self.pauseButton setHidden:NO];
    [self.sensorHandler readSensors];
}

-(IBAction)pauseButton:(id)sender {
    [self.sensorHandler stopReadSensors];
    [self stopTimer];
    [self.stopButton setHidden:NO];
    [self.pauseButton setHidden:YES];
    [self.startButton setHidden:YES];
}

-(IBAction)stopButton:(id)sender {
    [self stopTimer];
    [self.stopButton setHidden:YES];
    [self.pauseButton setHidden:YES];
    [self.initializeButton setHidden:NO];
    [self.iiValueField setHidden:NO];
    [self.startPlaybackButton setHidden:NO];
    [self.resetPlaybackButton setHidden:NO];
    [self.playbackSlider setEnabled:YES];
    self.playbackSlider.maximumValue = [self.sensorHandler totalPlaybackTime];
    [self.sensorHandler deactivate];
}

-(IBAction)calibrate:(id)sender {
    [self.sensorHandler.lowerLegTag.gyroSensor calibrate];
    [self.sensorHandler.upperLegTag.gyroSensor calibrate];
}

-(IBAction)playStoredData:(id)sender {
    [self.resetPlaybackButton setHidden:YES];
    [self.startPlaybackButton setHidden:YES];
    [self.initializeButton setHidden:YES];
    [self.pausePlaybackButton setHidden:NO];
    self.readAngleTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(readAngle:) userInfo:nil repeats:YES];
    [self.sensorHandler playStoredData];
}

-(IBAction)pauseStoredData:(id)sender {
    [self.sensorHandler stopPlayback];
    [self stopTimer];
    [self.pausePlaybackButton setHidden:YES];
    [self.resetPlaybackButton setHidden:NO];
    [self.startPlaybackButton setHidden:NO];
    [self.initializeButton setHidden:NO];
}

-(IBAction)resetStoredData:(id)sender {
    [self.sensorHandler resetPlayback];
}

-(IBAction)playbackSliderChanged:(id)sender {
    [self.sensorHandler setPlaybackIndex:(int)(self.playbackSlider.value*10)];
    [self readAngle:self];
}

-(void)stopTimer {
    [self.readAngleTimer invalidate];
    self.readAngleTimer = nil;
}

-(IBAction)readAngle:(id)sender {
    //    int yLow = (int)self.sensorHandler.lowerLegTag.yAngle;
    int zLow = (int)self.sensorHandler.lowerLegTag.zAngle;
    //    int yUp = (int)self.sensorHandler.upperLegTag.yAngle;
    int zUp = (int)self.sensorHandler.upperLegTag.zAngle;
    float gyroUp = fabsf(self.sensorHandler.upperLegTag.zGyro);
    float gyroLow = fabsf(self.sensorHandler.lowerLegTag.zGyro);
    NSLog(@"%f", gyroLow);
    //    int accY = (int)self.sensorHandler.lowerLegTag.yAccAngle;
    int zAccLow = round(self.sensorHandler.lowerLegTag.zAccAngle);
    int zAccUp = round(self.sensorHandler.upperLegTag.zAccAngle);
    self.upperLegAngle.text = [NSString stringWithFormat:@"Upper angle:%d", zUp];
    self.lowerLegAngle.text = [NSString stringWithFormat:@"Lower angle:%d", zLow];
    self.upperAccAngle.text = [NSString stringWithFormat:@"Acc angle:%d", zAccUp];
    self.lowerAccAngle.text = [NSString stringWithFormat:@"Acc angle:%d", zAccLow];
    self.maxGyroUp = fmaxf(gyroUp, self.maxGyroUp);
    self.maxGyroLow = fmaxf(gyroLow, self.maxGyroLow);
    self.maxGyro.text = [NSString stringWithFormat:@"Max gyro(Up,Low):%.0f,%.0f", self.maxGyroUp, self.maxGyroLow];
    [self drawGraphicsLowAngle:zLow upAngle:zUp];
    if (self.playbackSlider.isEnabled) {
        self.playbackSlider.value = [self.sensorHandler currentPlaybackTime];
        self.playbackLabel.text = [NSString stringWithFormat:@"%.01f", self.playbackSlider.value];
    }
}

-(void)drawGraphicsLowAngle:(int)lowAngle upAngle:(int)upAngle {
    CGMutablePathRef linePath = nil;
    linePath = CGPathCreateMutable();
    // Calculate upperLegTag start and end positions
    double radians = upAngle*M_PI/180;
    int upEndX = START_X - LINE_LENGTH*cos(radians);
    int upEndY = START_Y + LINE_LENGTH*sin(radians);
    // Calculate lowerLegTag start and end positions
    radians = lowAngle*M_PI/180;
    int lowEndX = upEndX - LINE_LENGTH*cos(radians);
    int lowEndY = upEndY + LINE_LENGTH*sin(radians);
    // Create the lines
    CGPathMoveToPoint(linePath, NULL, START_X, START_Y);
    CGPathAddLineToPoint(linePath, NULL, upEndX, upEndY);
    CGPathAddLineToPoint(linePath, NULL, lowEndX, lowEndY);
    self.lineShape.path = linePath;
    CGPathRelease(linePath);
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)sendMail:(id)sender {
    NSMutableString *sensorDataLow = [[NSMutableString alloc] init];
    NSMutableString *sensorDataUp = [[NSMutableString alloc] init];
    [sensorDataLow appendString:@"angle,accAngle,gyroAngle\n"];
    [sensorDataUp appendString:@"angle,accAngle,gyroAngle\n"];
    RTRSensorData *lowSensorData = self.sensorHandler.lowerLegTag.storedData;
    RTRSensorData *upSensorData = self.sensorHandler.upperLegTag.storedData;
    for (int i=0; i < [upSensorData.zAngles count]; i++) {
        // Append lower tag data
        [sensorDataLow appendFormat:@"%0.1f,%0.1f,%0.1f\n", [[lowSensorData.zAngles objectAtIndex:i] doubleValue], [[lowSensorData.zAccAngles objectAtIndex:i] doubleValue], [[lowSensorData.zGyroAngles objectAtIndex:i] doubleValue]];
        // Append upper tag data
        [sensorDataUp appendFormat:@"%0.1f,%0.1f,%0.1f\n", [[upSensorData.zAngles objectAtIndex:i] doubleValue], [[upSensorData.zAccAngles objectAtIndex:i] doubleValue], [[upSensorData.zGyroAngles objectAtIndex:i] doubleValue]];
    }
    MFMailComposeViewController *mFMCVC = [[MFMailComposeViewController alloc]init];
    if (mFMCVC) {
        if ([MFMailComposeViewController canSendMail]) {
            mFMCVC.mailComposeDelegate = self;
            [mFMCVC setSubject:@"Data from Running Tracker"];
            [self presentViewController:mFMCVC animated:YES completion:nil];
            
            [mFMCVC addAttachmentData:[sensorDataLow dataUsingEncoding:NSUTF8StringEncoding] mimeType:@"text/csv" fileName:@"lower-leg-data.csv"];
            [mFMCVC addAttachmentData:[sensorDataUp dataUsingEncoding:NSUTF8StringEncoding] mimeType:@"text/csv" fileName:@"upper-leg-data.csv"];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mail error" message:@"Device has not been set up to send mail" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    }
}

-(IBAction)uploadData:(id)sender {
    RTRDataSelector *dataSelctor = [[RTRDataSelector alloc]initWithStyle:UITableViewStyleGrouped];
    dataSelctor.delegate = self;
    [self.navigationController pushViewController:dataSelctor animated:YES];
}

-(void)dataWasSelectedLowerLeg:(NSString *)lowData upperLeg:(NSString *)upData {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* inboxPath = [documentsDirectory stringByAppendingPathComponent:@"Inbox"];
    NSString* lowFilePath = [inboxPath stringByAppendingPathComponent:lowData];
    NSString* upFilePath = [inboxPath stringByAppendingPathComponent:upData];
    
    NSError *error;
    NSString* lowerLegContent = [NSString stringWithContentsOfFile:lowFilePath encoding:NSUTF8StringEncoding error:&error];
    
    NSString* upperLegContent = [NSString stringWithContentsOfFile:upFilePath encoding:NSUTF8StringEncoding error:NULL];
    
    [self.sensorHandler readDataFromCsvLowerLeg:lowerLegContent upperLeg:upperLegContent];
    self.playbackSlider.maximumValue = [self.sensorHandler totalPlaybackTime];
}

@end
