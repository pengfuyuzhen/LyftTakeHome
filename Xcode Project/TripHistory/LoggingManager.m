//
//  LocationManager.m
//  TripHistory
//
//  Created by Peng Fuyuzhen on 1/18/16.
//  Copyright © 2016 Peng Fuyuzhen. All rights reserved.
//

#import "LoggingManager.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "GeoCoder.h"
#import "Address.h"
#import "Trip.h"

double const MOVEMENT_THRESHOLD = 10.0;    // movement below 10 meters won't detected
double const TIME_THRESHOLD = 15.0;        // event older than 15s won't detected
double const SPEED_THRESHOLD = 4.47;       // speed over 4.47 meters marks trip continuation (10mph)
double const END_TRIP_TIME_LIMIT = 60.0;   // idle over 60 seconds signals the end of trip

// Locaiton Authorization Status did change notification
NSString *const kLocationAuthorizationStatusDidChangeNotification = @"kLocationAuthorizationStatusDidChangeNotification";

// Key for storing logging on/off state in persistent storage
NSString *const kLoggingStateKey = @"kLoggingStateKey";

// static variable keep track of trip information
static Trip *CurrentTrip;

@interface LoggingManager () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;   // for location tracking
@property (nonatomic, strong) NSTimer *tripTimer;   // tracking idle time lapse
@end

@implementation LoggingManager {
    BOOL isTravelling;     // binary indicating whether user is on a trip
}

#pragma mark - Location Tracking

- (void) startLocationUpdating
{
    if (![[LoggingManager sharedManager] canLogTrip]) {
        NSLog(@">>> Can't log trip yet!");
        return;
    }
    if (self.locationManager != nil) {
        [self.locationManager startUpdatingLocation];
        NSLog(@">>> Start Location Updating...");
    }
}

- (void) stopLocationUpdating
{
    NSLog(@">>> Location Updating Stopped");
    [self.locationManager stopUpdatingLocation];
    [self invalidateTripTimer];
    isTravelling = NO;
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *newLocation = locations.lastObject;
    NSTimeInterval howRecent = [[newLocation timestamp] timeIntervalSinceNow];
    
    // Discard below threshold events
    if (howRecent > TIME_THRESHOLD || newLocation.speed < SPEED_THRESHOLD) {
        NSLog(@">>> Insignificant Movement Detected");
        return;
    }
    if (newLocation.speed >= SPEED_THRESHOLD) {
        
        // Mark trip continuation
        [self continueTripFrom:newLocation];
    }
    
    // As long as user is not standing still, update trip's end point
    CurrentTrip.endLocation = newLocation;
}

#pragma mark - Trip Management

- (void) continueTripFrom: (CLLocation *)location
{
    if (!isTravelling) {
        NSLog(@">>> Trip started, here we go...");
        CurrentTrip = [Trip new];
        CurrentTrip.startLocation = location;
        CurrentTrip.startDate = [NSDate date];
        isTravelling = YES;
    }
    NSLog(@">>> Traveling at %f meters / second", location.speed);
    
    // User is still traveling, refresh timer
    [self invalidateTripTimer];
    self.tripTimer = [NSTimer scheduledTimerWithTimeInterval:END_TRIP_TIME_LIMIT target:self selector:@selector(endTrip) userInfo:nil repeats:NO];
}

- (void) endTrip
{
    CurrentTrip.endDate = [NSDate date];
    
    // Trip is done, let's decode coordinates and log trip into core data
    [self finalizeTrip];
    
    // Terminate timer
    [self invalidateTripTimer];
    isTravelling = NO;
}

- (void) finalizeTrip
{
    NSLog(@">>> End of Trip!");
    NSLog(@">>> Decoding start and stop locations...");
    [GeoCoder decodeTripFrom:CurrentTrip.startLocation to:CurrentTrip.endLocation completion:^(Address *startAddress, Address *endAddress)
    {
        if (startAddress && endAddress) {
            
            CurrentTrip.startAddress = startAddress;
            CurrentTrip.endAddress = endAddress;
            
            // Log trip into core data
            [self logTrip];
            
        }else{
            NSLog(@"Decoding failed");
        }
    }];
}

// Sync with core data

- (BOOL) logTrip
{
    if (!CurrentTrip) return NO;
    
    NSLog(@">>> Logging trip data to storage...");
    // Save to persistant storage
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    NSEntityDescription *TripEntity = [NSEntityDescription entityForName:@"Trip" inManagedObjectContext:context];
    NSManagedObject *TripObject = [[NSManagedObject alloc]initWithEntity:TripEntity insertIntoManagedObjectContext:context];

    // Store attributes - addresses, dates and coordinates
    [TripObject setValue:CurrentTrip.endAddress.abbreviatedAddress forKey:kPSAbbreviatedEndAddress];
    [TripObject setValue:CurrentTrip.startAddress.abbreviatedAddress forKey:kPSAbbreviatedStartAddress];
    [TripObject setValue:CurrentTrip.endDate forKey:kPSEndDate];
    [TripObject setValue:@(CurrentTrip.endAddress.latitude) forKey:kPSEndLatitude];
    [TripObject setValue:@(CurrentTrip.endAddress.longitude) forKey:kPSEndLongitude];
    [TripObject setValue:CurrentTrip.endAddress.fullAddress forKey:kPSFullEndAddress];
    [TripObject setValue:CurrentTrip.startAddress.fullAddress forKey:kPSFullStartAddress];
    [TripObject setValue:CurrentTrip.startDate forKey:kPSStartDate];
    [TripObject setValue:@(CurrentTrip.startAddress.latitude) forKey:kPSStartLatitude];
    [TripObject setValue:@(CurrentTrip.startAddress.longitude) forKey:kPSStartLongitude];
    
    // Save to Core Data
    NSError *saveError;
    [context save:&saveError];
    if (saveError) {
        NSLog(@"Save Trip failed - %@", saveError.localizedDescription);
        return NO;
    }
    NSLog(@">>> Trip logged!");
    return YES;
}

- (void) invalidateTripTimer
{
    if (self.tripTimer) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(endTrip) object:nil];
        [self.tripTimer invalidate];
        self.tripTimer = nil;
    }
}

#pragma mark - Logging Control

// User manually switched off trip logging

- (void) turnOffTripLogging
{
    NSLog(@">>> Trip Logging turned off by user");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:@(LoggingStateTurnedOff) forKey: kLoggingStateKey];
    [defaults synchronize];
    [[LoggingManager sharedManager] stopLocationUpdating];
}

// User manually switched on trip logging

- (void) turnOnTripLogging
{
    NSLog(@">>> Trip Logging turned on by user");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:@(LoggingStateTurnedOn) forKey: kLoggingStateKey];
    [defaults synchronize];
    [[LoggingManager sharedManager] startLocationUpdating];
}

// Tells whether trip logging is enabled by user

- (LoggingState) loggingEnabledByUser
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *stateNumber = [defaults valueForKey:kLoggingStateKey];
    if (stateNumber) {
        LoggingState state = [stateNumber intValue];
        return state;
    }
    return LoggingStateNotDetermined;
}

// Tells whether trip logging is enabled by system: device availability + location authorization

- (BOOL) loggingEnabledBySystem
{
    return [[LoggingManager sharedManager] deviceLocationEnabled]
    && ([[LoggingManager sharedManager]currentAuthorizationStatus] == kCLAuthorizationStatusAuthorizedAlways);
}

#pragma mark - Initializations

+ (LoggingManager *) sharedManager
{
    static LoggingManager *sharedManager = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedManager = [[LoggingManager alloc]init];
    });
    return sharedManager;
}

// Returns YES only when: switched on by user + system available + location access authorized

- (BOOL) canLogTrip
{
    return ([[LoggingManager sharedManager] deviceLocationEnabled]
            && ([[LoggingManager sharedManager]currentAuthorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)
            && [[LoggingManager sharedManager] loggingEnabledByUser] == LoggingStateTurnedOn);
}

- (BOOL) deviceLocationEnabled
{
    return [CLLocationManager locationServicesEnabled];
}

- (id) init
{
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc]init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = MOVEMENT_THRESHOLD;
        self.locationManager.allowsBackgroundLocationUpdates = YES; // background tracking
    }
    return self;
}

// Prompt user with location access warning view

- (void) requestAccessPermissionFromUser
{
    if (self.locationManager != nil) {
        [self.locationManager requestAlwaysAuthorization];
    }
}

- (CLAuthorizationStatus) currentAuthorizationStatus
{
    return [CLLocationManager authorizationStatus];
}

- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        
        // If user just 'logged in', switch trip logging on by default
        if ([[LoggingManager sharedManager] loggingEnabledByUser] == LoggingStateNotDetermined) {
            [[LoggingManager sharedManager] turnOnTripLogging];
        }else{
            // If user has already 'logged in', start location tracking if possible
            [[LoggingManager sharedManager] startLocationUpdating];
        }
    }else if (status == kCLAuthorizationStatusDenied) {
        if (isTravelling) {
            [[LoggingManager sharedManager] stopLocationUpdating];
        }
    }
    // Notify receivers for UI updates
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationAuthorizationStatusDidChangeNotification object:nil userInfo:@{@"status": @(status)}];
}

@end
