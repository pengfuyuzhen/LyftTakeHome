//
//  TripDetailTableViewCell.m
//  TripHistory
//
//  Created by Peng Fuyuzhen on 1/19/16.
//  Copyright © 2016 Peng Fuyuzhen. All rights reserved.
//

#import "mapCell.h"

NSString *const MapCellIdentifier = @"mapCell";

@interface mapCell()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loader;
@end

@implementation mapCell

- (void) setMapImage: (UIImage *)image;
{
    if (!image) {
        return;
    }
    self.mapImageView.image = image;
    [self.loader removeFromSuperview];
    [self.loader stopAnimating];
}

@end
