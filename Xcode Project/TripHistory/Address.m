//
//  Address.m
//  TripHistory
//
//  Created by Peng Fuyuzhen on 1/18/16.
//  Copyright © 2016 Peng Fuyuzhen. All rights reserved.
//

#import "Address.h"

@interface Address ()
@property (nonatomic, readwrite) double longitude;
@property (nonatomic, readwrite) double latitude;

@property (nonatomic, strong, readwrite) NSString *abbreviatedAddress;
@property (nonatomic, strong, readwrite) NSString *fullAddress;
@end

@implementation Address

+ (Address *) addressWithLongtitude: (double) longtitude latitude: (double) latitude abbreviatedAddress: (NSString *) abbreviatedAddress andFullAddress: (NSString *)fullAddress
{
    Address *address = [[Address alloc]init];
    address.latitude = latitude;
    address.longitude = longtitude;
    address.abbreviatedAddress = abbreviatedAddress;
    address.fullAddress = fullAddress;
    return address;
}

@end
