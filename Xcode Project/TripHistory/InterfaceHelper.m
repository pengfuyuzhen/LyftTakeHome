//
//  InterfaceHelper.m
//  TripHistory
//
//  Created by Peng Fuyuzhen on 1/18/16.
//  Copyright © 2016 Peng Fuyuzhen. All rights reserved.
//

#import "InterfaceHelper.h"
#import "AppDelegate.h"
#import "Constants.h"
#import <ImageIO/ImageIO.h>

@implementation InterfaceHelper

#pragma mark - Colors

+ (UIColor *) textColor {
    return [UIColor darkGrayColor];
}

+ (UIColor *) detailTextColor {
    return [UIColor lightGrayColor];
}

+ (UIColor *) highlightColor {
    return [UIColor colorWithRed:0 green:0.7 blue:0.69 alpha:1];
}

+ (UIColor *) separatorColor {
    return [UIColor colorWithRed:0.84 green:0.84 blue:0.82 alpha:1];
}

#pragma mark - String Formatter

+ (NSMutableAttributedString *) formatAddressStringForTrip: (NSManagedObject *)trip
{
    @autoreleasepool {
        // Arrow Icon
        NSTextAttachment *icon = [[NSTextAttachment alloc]init];
        icon.image = [UIImage imageNamed:@"arrow"];
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:icon];
        
        // Start and End Address Strings
        NSString *startAddress = [[trip valueForKey:kPSAbbreviatedStartAddress] stringByAppendingString:@"  "];
        NSString *endAddress = [@"  " stringByAppendingString:[trip valueForKey:kPSAbbreviatedEndAddress]];
        
        NSMutableAttributedString *startString = [[NSMutableAttributedString alloc]initWithString:startAddress];
        NSMutableAttributedString *endString = [[NSMutableAttributedString alloc]initWithString:endAddress];
        
        [startString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14 weight:UIFontWeightMedium] range:NSMakeRange(0, startString.length)];
        [startString addAttribute:NSForegroundColorAttributeName value:[InterfaceHelper textColor] range:NSMakeRange(0, startString.length)];
        [endString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14 weight:UIFontWeightMedium] range:NSMakeRange(0, endString.length)];
        [endString addAttribute:NSForegroundColorAttributeName value:[InterfaceHelper textColor] range:NSMakeRange(0, endString.length)];
        
        // Combine Strings
        [startString appendAttributedString:attachmentString];
        [startString appendAttributedString:endString];
        
        return startString;
    }
}

+ (NSString *) formatTimeStringForTrip: (NSManagedObject *)trip
{
    @autoreleasepool {
        NSDate *startDate = [trip valueForKey:@"startDate"];
        NSDate *endDate = [trip valueForKey:@"endDate"];
        
        // Format trip start and end time
        NSString *startTime = [InterfaceHelper timeStringFromDate:startDate];
        NSString *endTime = [InterfaceHelper timeStringFromDate:endDate];
        
        return [NSString stringWithFormat:@"%@-%@ (%@)",
                startTime, endTime, [InterfaceHelper durationStringFromStartDate:startDate andEndDate:endDate]];
    }
}

+ (NSString *) durationStringFromStartDate: (NSDate *)startDate andEndDate: (NSDate *)endDate
{
    // Format trip duration
    NSTimeInterval duration = [endDate timeIntervalSinceDate:startDate];
    NSInteger min = MAX(1, ceil(duration / 60));
    NSInteger hour = (int)duration / 3600;
    NSString *durationString;
    if (hour > 0) {
        durationString = [NSString stringWithFormat:@"%luhour %lumin", (long)hour, (long)min];
    }else{
        durationString = [NSString stringWithFormat:@"%lumin", (long)min];
    }
    return durationString;
}

+ (NSString *) timeStringFromDate: (NSDate *)date
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"h:mma"];
    NSString *time = [formatter stringFromDate:date];
    return [time lowercaseString];
}

+ (NSString *) dateStringFromDate: (NSDate *)date
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"MMM dd '-' h:mma"];
    return [[formatter stringFromDate:date] uppercaseString];
}

#pragma mark - Image

+ (UIImage *) compressImage: (UIImage *)image // Lossless compression by removing EXIF data
{
    NSData *data = UIImageJPEGRepresentation(image, 1);
    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)data, NULL);
    NSMutableData *mutableData = nil;
    
    if (source) {
        CFStringRef type = CGImageSourceGetType(source);
        size_t count = CGImageSourceGetCount(source);
        mutableData = [NSMutableData data];
        
        CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)mutableData, type, count, NULL);
        NSDictionary *removeExifProperties = @{(id)kCGImagePropertyExifDictionary: (id)kCFNull,
                                               (id)kCGImagePropertyGPSDictionary : (id)kCFNull};
        if (destination) {
            for (size_t index = 0; index < count; index++) {
                CGImageDestinationAddImageFromSource(destination, source, index, (__bridge CFDictionaryRef)removeExifProperties);
            }
            if (!CGImageDestinationFinalize(destination)) {
                NSLog(@"CGImageDestinationFinalize failed");
            }
            CFRelease(destination);
        }
        CFRelease(source);
    }
    return [UIImage imageWithData:mutableData];
}

@end
