//
//  RTRDataSelector.h
//  RunningTracker
//
//  Created by u on 11/18/14.
//  Copyright (c) 2014 lirre8. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RTRDataSelectorDelegate <NSObject>
@required
- (void)dataWasSelectedLowerLeg:(NSString *)lowData upperLeg:(NSString *)upData;
@end

@interface RTRDataSelector : UITableViewController
{
    // Delegate to respond back
    id <RTRDataSelectorDelegate> _delegate;
    
}
@property (nonatomic,strong) id delegate;

@property (strong,nonatomic) NSArray *dataFiles;
@property (strong,nonatomic) NSNumber *stage;
@property (strong,nonatomic) NSString *lowerLegData;
@property (strong,nonatomic) NSString *upperLegData;

@end
