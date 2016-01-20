//
//  InterfaceHelper.h
//  TripHistory
//
//  Created by Peng Fuyuzhen on 1/18/16.
//  Copyright © 2016 Peng Fuyuzhen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class NSManagedObject;

@interface InterfaceHelper : NSObject

// Colors - consistancy across the app
+ (UIColor *) textColor;
+ (UIColor *) detailTextColor;
+ (UIColor *) highlightColor;
+ (UIColor *) separatorColor;

// String Formatter
+ (NSMutableAttributedString *) formatAddressStringForTrip: (NSManagedObject *)trip;
+ (NSString *) formatTimeStringForTrip: (NSManagedObject *)trip;
+ (NSString *) durationStringFromStartDate: (NSDate *)startDate andEndDate: (NSDate *)endDate;
+ (NSString *) timeStringFromDate: (NSDate *)date;
+ (NSString *) dateStringFromDate: (NSDate *)date;

// Image compressor - lossless compression
+ (UIImage *) compressImage: (UIImage *)image;
@end
