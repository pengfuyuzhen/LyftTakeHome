//
//  Trip.m
//  TripHistory
//
//  Created by Peng Fuyuzhen on 1/18/16.
//  Copyright © 2016 Peng Fuyuzhen. All rights reserved.
//

#import "Trip.h"
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "Address.h"
#import "Constants.h"

@implementation Trip

+ (Trip *) tripFromManagedObject: (NSManagedObject *)object
{
    Trip *trip = [Trip new];
    
    // Date
    trip.startDate = [object valueForKey:kPSStartDate];
    trip.endDate = [object valueForKey:kPSEndDate];
    
    // Location
    trip.startLocation = [[CLLocation alloc]initWithLatitude:[[object valueForKey:kPSStartLatitude] doubleValue] longitude:[[object valueForKey:kPSStartLongitude] doubleValue]];
    trip.endLocation = [[CLLocation alloc]initWithLatitude:[[object valueForKey:kPSEndLatitude] doubleValue] longitude:[[object valueForKey:kPSEndLongitude] doubleValue]];
    
    // Addresses
    trip.startAddress = [Address addressWithLongtitude:[[object valueForKey:kPSStartLongitude] doubleValue] latitude:[[object valueForKey:kPSStartLatitude] doubleValue] abbreviatedAddress:[object valueForKey:kPSAbbreviatedStartAddress] andFullAddress:[object valueForKey:kPSFullStartAddress]];
    
    trip.endAddress = [Address addressWithLongtitude:[[object valueForKey:kPSEndLongitude] doubleValue] latitude:[[object valueForKey:kPSEndLatitude] doubleValue] abbreviatedAddress:[object valueForKey:kPSAbbreviatedEndAddress] andFullAddress:[object valueForKey:kPSFullEndAddress]];
    
    return trip;
}

@end
