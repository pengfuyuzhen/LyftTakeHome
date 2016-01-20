//
//  Address.h
//  TripHistory
//
//  Created by Peng Fuyuzhen on 1/18/16.
//  Copyright © 2016 Peng Fuyuzhen. All rights reserved.
//

#import <Foundation/Foundation.h>

// Address is used to keep track of a trip's starting point and ending point
// Address contains geo coordinates, and formatted address strings

@interface Address : NSObject

@property (nonatomic, strong, readonly) NSString *abbreviatedAddress; // street number + street
@property (nonatomic, strong, readonly) NSString *fullAddress;  // abbre.address + neighborhood + city

@property (nonatomic, readonly) double longitude;
@property (nonatomic, readonly) double latitude;

// initializer
+ (Address *) addressWithLongtitude: (double) longtitude latitude: (double) latitude abbreviatedAddress: (NSString *) abbreviatedAddress andFullAddress: (NSString *)fullAddress;

@end
