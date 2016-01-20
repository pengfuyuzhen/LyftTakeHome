//
//  GeoCoder.m
//  TripHistory
//
//  Created by Peng Fuyuzhen on 1/18/16.
//  Copyright © 2016 Peng Fuyuzhen. All rights reserved.
//

#import "GeoCoder.h"
#import <CoreLocation/CoreLocation.h>
#import <Contacts/Contacts.h>
#import <AddressBookUI/AddressBookUI.h>
#import "Address.h"
#import "Trip.h"
#import <MapKit/MapKit.h>
#import <SDWebImage/SDImageCache.h>
#import "InterfaceHelper.h"

@implementation GeoCoder

NSString *const ImageCacheNameSpace = @"MapImageCache";

+ (void) decodeTripFrom: (CLLocation *)startLocation to: (CLLocation *)endLocation completion: (void(^)(Address *startAddress, Address*endAddress))completion
{
    __block Address *address1 = nil;
    __block Address *address2 = nil;
    
    dispatch_group_t group = dispatch_group_create();

    // Decode Start Location
    dispatch_group_enter(group);
    [[CLGeocoder new] reverseGeocodeLocation:startLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks.count > 0) {
            address1 = [GeoCoder addressFromPlaceMark:placemarks.firstObject andLocation:startLocation];
        }
        dispatch_group_leave(group);
    }];
    
    // Decode End Location
    dispatch_group_enter(group);
    [[CLGeocoder new] reverseGeocodeLocation:endLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks.count > 0) {
            address2 = [GeoCoder addressFromPlaceMark:placemarks.firstObject andLocation:endLocation];
        }
        dispatch_group_leave(group);
    }];

    // Return both decoded addresses
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (completion) {
            completion(address1, address2);
        }
    });
}

+ (Address *) addressFromPlaceMark: (CLPlacemark *)placeMark andLocation: (CLLocation *) location
{
    NSString *abbreviatedAddress = @"";
    
    // number
    if (placeMark.subThoroughfare && placeMark.subThoroughfare.length > 0) {
        abbreviatedAddress = [abbreviatedAddress stringByAppendingString:[NSString stringWithFormat:@"%@ ", placeMark.subThoroughfare]];
    }
    // street
    if (placeMark.thoroughfare && placeMark.thoroughfare.length > 0) {
        abbreviatedAddress = [abbreviatedAddress stringByAppendingString:[NSString stringWithFormat:@"%@", placeMark.thoroughfare]];
    }
    
    NSString *fullAddress = [[NSString stringWithString:abbreviatedAddress] stringByAppendingString:@", "];
    
    // neighborhood
    if (placeMark.subLocality && placeMark.subLocality.length > 0) {
        fullAddress = [fullAddress stringByAppendingString:[NSString stringWithFormat:@"%@ ", placeMark.subLocality]];
    }
    // city
    if (placeMark.locality && placeMark.locality.length > 0) {
        fullAddress = [fullAddress stringByAppendingString:[NSString stringWithFormat:@"%@", placeMark.locality]];
    }
    Address *address = [Address addressWithLongtitude:location.coordinate.longitude latitude:location.coordinate.latitude abbreviatedAddress:abbreviatedAddress andFullAddress:fullAddress];
    return address;
}

+ (void) generateMapImageFromTrip: (Trip *)trip completion: (void(^)(UIImage *mapImage))completion;
{
    // Fetch image from cache if possible
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache queryDiskCacheForKey:[GeoCoder imageCacheKeyFromTrip:trip] done:^(UIImage *image, SDImageCacheType cacheType) {
        if (image) {
            if (completion) {
                completion(image);
            }
            return;
        }

        // Image not found in cache, generate new image
        
        // Create map snapshot
        MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc]init];
        double lat = (trip.startAddress.latitude + trip.endAddress.latitude)*0.5;
        double log = (trip.startAddress.longitude + trip.endAddress.longitude)*0.5;
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat, log);
        
        // Get map region
        double width = fabs(trip.startAddress.longitude-trip.endAddress.longitude)*1.4;
        double height = fabs(trip.startAddress.latitude - trip.endAddress.latitude)*1.4;
        MKCoordinateSpan span = MKCoordinateSpanMake(width, height);
        options.region = MKCoordinateRegionMake(coordinate, span);
        options.scale = [UIScreen mainScreen].scale;
        CGFloat ratio = 3/4.0;
        options.size = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width * ratio);
        
        MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
        
        // Generate image
        [snapshotter startWithCompletionHandler:^(MKMapSnapshot * _Nullable snapshot, NSError * _Nullable error) {
            
            // Draw Pin on image
            CGPoint startPin = [snapshot pointForCoordinate:trip.startLocation.coordinate];
            CGPoint endPin = [snapshot pointForCoordinate:trip.endLocation.coordinate];
            
            UIGraphicsBeginImageContextWithOptions(snapshot.image.size, NO, [UIScreen mainScreen].scale);
            [snapshot.image drawAtPoint:CGPointZero];
            UIImage *pin = [UIImage imageNamed:@"pin-departure"];
            [pin drawAtPoint:CGPointMake(startPin.x - pin.size.width/2.0, startPin.y - pin.size.width/2.0)];
            [[UIImage imageNamed:@"pin-arrival"] drawAtPoint:CGPointMake(endPin.x - pin.size.width/2.0, endPin.y - pin.size.width/2.0)];
            UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            // Store compressed image in cache
            [[SDImageCache sharedImageCache] storeImage:[InterfaceHelper compressImage:outputImage] forKey:[GeoCoder imageCacheKeyFromTrip:trip]];
            
            if (completion) {
                completion(outputImage);
            }
        }];
    }];
}

// Key for map image in cache

+ (NSString *) imageCacheKeyFromTrip: (Trip *)trip
{
    // Key is generated according the trip's start and end locations
    return [NSString stringWithFormat:@"%f%f%f%f", trip.startAddress.longitude, trip.startAddress.latitude, trip.endAddress.longitude, trip.endAddress.latitude];
}

@end
