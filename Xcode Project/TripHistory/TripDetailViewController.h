//
//  TripDetailViewController.h
//  TripHistory
//
//  Created by Peng Fuyuzhen on 1/19/16.
//  Copyright © 2016 Peng Fuyuzhen. All rights reserved.
//

#import "ViewController.h"
@class Trip;

extern NSString *const TripDetailViewControllerIdentifier;

@interface TripDetailViewController : ViewController

// Update view controller with trip's information
- (void) loadViewWithTrip: (Trip *)trip;
@end
