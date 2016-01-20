//
//  ViewController.m
//  TripHistory
//
//  Created by Peng Fuyuzhen on 1/18/16.
//  Copyright © 2016 Peng Fuyuzhen. All rights reserved.
//

#import "ViewController.h"
#import "InterfaceHelper.h"
#import "HeaderView.h"
#import "LoggingManager.h"
#import "OnboardViewController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "Trip.h"
#import "TripDetailViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, HeaderViewDelegate, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchResultsController;

@end

// Reuse Identifer for table view cells
NSString *const cellIdentifier = @"cellIdentifier";

// Cache results from core data
NSString *const FetchControllerCacheName = @"TripCache";

// Height of table view cells
CGFloat const cellHeight = 56.0;

// Height of header view
CGFloat const headerHeight = cellHeight * 1.25;

@implementation ViewController
{
    // Display this label when table view is empty
    UILabel *emptyLoggingLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self styleNavBar];
    [self styleTableView];
    [self setupFetchResultsController];   // sync with core data
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    // Update UI if location service availability has changed
    [self updateHeaderView];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Onboard user if user hasn't 'Logged in' yet
    if ([[LoggingManager sharedManager] loggingEnabledByUser] == LoggingStateNotDetermined) {
        OnboardViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:OnboardViewControllerIdentifier];
        [self.navigationController presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark - Header View Delegate Protocal

- (void) headerView:(HeaderView *)headerView switchStateChanged:(HeaderViewSwitchState)newState
{
    // User has switched on / off trip logging
    if (newState == HeaderViewSwitchStateOff) {
        [[LoggingManager sharedManager] turnOffTripLogging];
    }else{
        [[LoggingManager sharedManager] turnOnTripLogging];
    }    
}

#pragma mark - Table View Data Source & Delegate Protocals

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = self.fetchResultsController.fetchedObjects.count;
    
    // Label indicating there's no trip history yet
    if (count == 0) {
        [self showEmptyLoggingUI];
    }else{
        [self hideEmptyLoggingUI];
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        [self layoutCell:cell];
    }
    NSManagedObject *trip = [self.fetchResultsController objectAtIndexPath:indexPath];
    
    // String displaying addresses
    cell.textLabel.attributedText = [InterfaceHelper formatAddressStringForTrip:trip];
    
    // String display time lapse
    cell.detailTextLabel.text = [InterfaceHelper formatTimeStringForTrip:trip];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get the corresponding object from core data
    NSManagedObject *tripObject = [self.fetchResultsController objectAtIndexPath:indexPath];
    Trip * trip = [Trip tripFromManagedObject:tripObject];
    
    // Show trip detail information
    TripDetailViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:TripDetailViewControllerIdentifier];
    [viewController loadViewWithTrip:trip];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Data Management

// Update table view when there's new trip being logged into core data

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default: break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] endUpdates];
}

#pragma mark - UI & Helpers

- (void) styleNavBar
{
    UIImageView *imgView = [UIImageView new];
    imgView.bounds = CGRectMake(0, 0, self.navigationController.navigationBar.bounds.size.width, self.navigationController.navigationBar.bounds.size.height);
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.image = [UIImage imageNamed:@"navbar"];
    imgView.clipsToBounds = YES;
    self.navigationItem.titleView = imgView;
    self.navigationController.navigationBar.tintColor = [InterfaceHelper highlightColor];
}

- (void) styleTableView
{
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorColor = [InterfaceHelper separatorColor];
    HeaderView *header = [HeaderView headerViewWithTitle:@"Trip logging" size:CGSizeMake(self.view.bounds.size.width, headerHeight)];
    header.delegate = self;
    self.tableView.tableHeaderView = header;
}

- (void) showEmptyLoggingUI
{
    if (!emptyLoggingLabel) {
        emptyLoggingLabel = [UILabel new];
        emptyLoggingLabel.bounds = CGRectMake(0, 0, self.view.bounds.size.width *0.8, 60);
        emptyLoggingLabel.center = CGPointMake(self.view.center.x, self.tableView.center.y - headerHeight);
        emptyLoggingLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        emptyLoggingLabel.textColor = [InterfaceHelper detailTextColor];
        emptyLoggingLabel.textAlignment = NSTextAlignmentCenter;
        emptyLoggingLabel.text = @"No Recent History";
    }
    [self.tableView insertSubview:emptyLoggingLabel atIndex:0];
}

- (void) hideEmptyLoggingUI
{
    [emptyLoggingLabel removeFromSuperview];
    emptyLoggingLabel = nil;
}

- (void) setupFetchResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Trip"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    
    self.fetchResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:FetchControllerCacheName];
    self.fetchResultsController.delegate = self;
    
    NSError *fetchError;
    if (![self.fetchResultsController performFetch:&fetchError]) {
        NSLog(@"Fetch from Core Data failed - %@", fetchError.localizedDescription);
        abort();
    }
}

- (void) layoutHeaderView
{
    if (self.navigationController.topViewController != self) {
        return;
    }
    HeaderView *header = (HeaderView *)self.tableView.tableHeaderView;
    [header setNeedsLayout];
    [header layoutIfNeeded];
    header.bounds = CGRectMake(0, 0, header.bounds.size.width, headerHeight);
    self.tableView.tableHeaderView = header;
}

- (void) layoutCell: (UITableViewCell *)cell
{
    cell.detailTextLabel.font = [UIFont italicSystemFontOfSize:12.0];
    cell.detailTextLabel.textColor = [InterfaceHelper detailTextColor];
    cell.imageView.image = [UIImage imageNamed:@"icon_car"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

// When location access is not available, show corresponding UI

- (void) updateHeaderView
{
    if ([[LoggingManager sharedManager] loggingEnabledByUser] == LoggingStateNotDetermined) return;
    HeaderView *header = (HeaderView *)self.tableView.tableHeaderView;
    [header turnOnSwitchView:[[LoggingManager sharedManager] canLogTrip]];
    if ([[LoggingManager sharedManager] loggingEnabledBySystem]) {
        [header updateTitleWithMessage:@"Trip Logging"];
    }else{
        [header updatetitleWithWarningMessage:@"Please go to \"Settings\" to enable location access"];
    }
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self layoutHeaderView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
