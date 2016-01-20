//
//  TripDetailTableViewCell.h
//  TripHistory
//
//  Created by Peng Fuyuzhen on 1/19/16.
//  Copyright © 2016 Peng Fuyuzhen. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const MapCellIdentifier;

@interface mapCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *mapImageView;

// Update image view's image and hide loading indicator
- (void) setMapImage: (UIImage *)image;
@end
