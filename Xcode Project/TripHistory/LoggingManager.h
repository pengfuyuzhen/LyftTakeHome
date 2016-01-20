//
//  LocationManager.h
//  TripHistory
//
//  Created by Peng Fuyuzhen on 1/18/16.
//  Copyright © 2016 Peng Fuyuzhen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString *const kLocationAuthorizationStatusDidChangeNotification;

@interface LoggingManager : NSObject

typedef NS_ENUM(int, LoggingState) { // Logging controlled manually by user
    LoggingStateTurnedOff = 0,
    LoggingStateTurnedOn = 1,
    LoggingStateNotDetermined = 2
};

// Initializers
+ (LoggingManager *) sharedManager;

// Location Service Availability Checking
- (CLAuthorizationStatus) currentAuthorizationStatus;
- (BOOL) deviceLocationEnabled;
- (BOOL) canLogTrip;
- (void) requestAccessPermissionFromUser;

// Location tracking
- (void) startLocationUpdating;
- (void) stopLocationUpdating;

// Logging Control
- (void) turnOffTripLogging; // by UISwitchView
- (void) turnOnTripLogging;  // by UISwitchView

- (LoggingState) loggingEnabledByUser;  // if switch view is turned on/off by user
- (BOOL) loggingEnabledBySystem;        // if device has location service available & user permission granted

@end
