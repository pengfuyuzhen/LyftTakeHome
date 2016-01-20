//
//  TripDetailViewController.m
//  TripHistory
//
//  Created by Peng Fuyuzhen on 1/19/16.
//  Copyright © 2016 Peng Fuyuzhen. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "TripDetailViewController.h"
#import "InterfaceHelper.h"
#import <MapKit/MapKit.h>
#import "GeoCoder.h"
#import "Address.h"
#import "mapCell.h"
#import "Trip.h"

enum {
    TableViewMapRow = 0,
    TableViewDepartureRow = 1,
    TableViewArrivalRow = 2
};


// Storyboard ID
NSString *const TripDetailViewControllerIdentifier = @"TripDetailViewController";

// Table view cell reuse identifier
NSString *const TripDetailCellIdentifier = @"TripDetailCellIdentifier";

@interface TripDetailViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *detailTableView;
@property (nonatomic, strong) Trip *trip;
@property (nonatomic, strong) UIImage *mapImage;
@end

@implementation TripDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self styleTableView];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Update UI for navigation bar
    self.navigationItem.titleView = nil;
    self.title = [InterfaceHelper dateStringFromDate:self.trip.startDate];
}

#pragma mark - Table View Data Source & Delegate Protocals

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // map + departure info + arrival info
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case TableViewMapRow:
            return self.view.bounds.size.width * 3 / 4.0;
        default:
            return 60.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case TableViewMapRow: {
            // cell displaying a snapshot of the map
            mapCell *cell = [tableView dequeueReusableCellWithIdentifier:MapCellIdentifier];
            [cell setMapImage:self.mapImage];
            return cell;
        }
        default:
        {
            // cells displaying departure and arrival information
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TripDetailCellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:TripDetailCellIdentifier];
                [self layoutCell:cell];
            }
            [self configureCell:cell atIndexPath:indexPath];
            return cell;
        }
    }
}

- (void) layoutCell: (UITableViewCell *)cell
{
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightRegular];
    cell.detailTextLabel.textColor = [InterfaceHelper textColor];
    cell.userInteractionEnabled = NO;
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void) configureCell: (UITableViewCell *)cell atIndexPath: (NSIndexPath *)indexPath
{
    // Attributed string containing trip information
    
    NSString *titleString;
    NSString *dateString;
    NSString *locationString;
    
    if (indexPath.row == TableViewDepartureRow) {
        titleString = @"Departure";
        locationString = self.trip.startAddress.fullAddress;
        dateString = [InterfaceHelper timeStringFromDate:self.trip.startDate];
        cell.imageView.image = [UIImage imageNamed:@"pin-departure"];
    }else{
        titleString = @"Arrival";
        locationString = self.trip.endAddress.fullAddress;
        dateString = [InterfaceHelper timeStringFromDate:self.trip.endDate];
        cell.imageView.image = [UIImage imageNamed:@"pin-arrival"];
    }
    NSMutableAttributedString *mainString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ %@", titleString, dateString]];
    [mainString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14 weight:UIFontWeightMedium] range:NSMakeRange(0, titleString.length)];
    [mainString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12 weight:UIFontWeightRegular] range:NSMakeRange(titleString.length+1, dateString.length)];
    
    [mainString addAttribute:NSForegroundColorAttributeName value:[InterfaceHelper textColor] range:NSMakeRange(0, titleString.length)];
    [mainString addAttribute:NSForegroundColorAttributeName value:[InterfaceHelper detailTextColor] range:NSMakeRange(titleString.length+1, dateString.length)];
    
    cell.textLabel.attributedText = mainString;
    cell.detailTextLabel.text = locationString;
}

#pragma mark - UI

- (void) loadViewWithTrip: (Trip *)trip
{
    self.trip = trip;
    
    // Draw Map
    [GeoCoder generateMapImageFromTrip:trip completion:^(UIImage *mapImage) {
        if (mapImage) {
            self.mapImage = mapImage;
            [self.detailTableView reloadData];
        }
    }];
}

- (void) styleTableView
{
    [self.detailTableView registerNib:[UINib nibWithNibName:MapCellIdentifier bundle:[NSBundle mainBundle]] forCellReuseIdentifier:MapCellIdentifier];
    self.detailTableView.delegate = self;
    self.detailTableView.dataSource = self;
    self.detailTableView.tableFooterView = [UIView new];
}

@end
