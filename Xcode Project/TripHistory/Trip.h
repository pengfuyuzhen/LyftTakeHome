//
//  Trip.h
//  TripHistory
//
//  Created by Peng Fuyuzhen on 1/18/16.
//  Copyright © 2016 Peng Fuyuzhen. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Address;
@class CLLocation;
@class NSManagedObject;

// Trip is the basic represention of a trip that's logged into the core data
// It has a convenient initializer that takes a core data object

@interface Trip : NSObject

@property (nonatomic, strong) CLLocation *startLocation;
@property (nonatomic, strong) CLLocation *endLocation;

@property (nonatomic, strong) Address *startAddress;
@property (nonatomic, strong) Address *endAddress;

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

// intialize from a core data object
+ (Trip *) tripFromManagedObject: (NSManagedObject *)object;

@end
