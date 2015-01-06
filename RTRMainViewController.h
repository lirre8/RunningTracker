//
//  RTRMainViewController.h
//  RunningTracker
//
//  Created by Sebastian Andersson on 4/10/14.
//  Copyright (c) 2014 lirre8. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTRSensorTag.h"
#import "RTRSensorHandler.h"
#import "RTRDataSelector.h"
#import <MessageUI/MessageUI.h>

@interface RTRMainViewController : UIViewController <MFMailComposeViewControllerDelegate, RTRDataSelectorDelegate>

@property (strong,nonatomic) RTRSensorHandler *sensorHandler;
@property (strong,nonatomic) UIButton *initializeButton;
@property (strong,nonatomic) UIButton *startButton;
@property (strong,nonatomic) UITextField *iiValueField;
@property (strong,nonatomic) UITextField *accLimitField;
@property (strong,nonatomic) UIButton *pauseButton;
@property (strong,nonatomic) UIButton *stopButton;
@property (strong,nonatomic) UIButton *calibrateButton;
@property (strong,nonatomic) UIButton *startPlaybackButton;
@property (strong,nonatomic) UIButton *pausePlaybackButton;
@property (strong,nonatomic) UIButton *resetPlaybackButton;
@property (strong,nonatomic) UILabel *lowerLegAngle;
@property (strong,nonatomic) UILabel *upperLegAngle;
@property (strong,nonatomic) UILabel *upperAccAngle;
@property (strong,nonatomic) UILabel *lowerAccAngle;
@property (strong,nonatomic) UILabel *maxGyro;
//@property (strong,nonatomic) UILabel *gyroAngle;
//@property (strong,nonatomic) UILabel *accAngle;
@property (strong,nonatomic) NSTimer *readAngleTimer;
@property (strong,nonatomic) CAShapeLayer *lineShape;
@property (strong,nonatomic) UISlider *playbackSlider;
@property (strong,nonatomic) UILabel *playbackLabel;
@property (nonatomic) float maxGyroUp;
@property (nonatomic) float maxGyroLow;
@property (nonatomic) BOOL checkBoxSelected;

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andSensorHandler:(RTRSensorHandler *)handler;

#define START_X self.view.bounds.size.width/2
#define START_Y 40
#define LINE_LENGTH 90

@end
