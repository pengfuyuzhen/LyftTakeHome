//
//  GeoCoder.h
//  TripHistory
//
//  Created by Peng Fuyuzhen on 1/18/16.
//  Copyright © 2016 Peng Fuyuzhen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLLocation;
@class CLPlacemark;
@class UIImage;
@class Address;
@class Trip;

@interface GeoCoder : NSObject

// Decode longitude-latitude locations into formatted address
+ (void) decodeTripFrom: (CLLocation *)startLocation to: (CLLocation *)endLocation completion: (void(^)(Address *startAddress, Address *endAddress))completion;

// Create a snapshot of a map with pins to visually display the trip
+ (void) generateMapImageFromTrip: (Trip *)trip completion: (void(^)(UIImage *mapImage))completion;

@end
