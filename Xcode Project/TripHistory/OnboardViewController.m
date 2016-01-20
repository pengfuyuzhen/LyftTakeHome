//
//  OnboardViewController.m
//  TripHistory
//
//  Created by Peng Fuyuzhen on 1/18/16.
//  Copyright © 2016 Peng Fuyuzhen. All rights reserved.
//

#import "OnboardViewController.h"
#import "LoggingManager.h"

@interface OnboardViewController () 
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *accessLocationButton;
@end

NSString *const OnboardViewControllerIdentifier = @"OnboardViewControllerIdentifier";

@implementation OnboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Update UI if location permission is already denied or device has location service turned off
    if (![[LoggingManager sharedManager] deviceLocationEnabled]
        || [[LoggingManager sharedManager] currentAuthorizationStatus] == kCLAuthorizationStatusDenied) {
        [self showPermissionDeniedUI];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Observe location permission change
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationPermissionUpdated:) name:kLocationAuthorizationStatusDidChangeNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLocationAuthorizationStatusDidChangeNotification object:nil];
}

- (IBAction)enableLocationAccessButtonPressed:(id)sender
{
    CLAuthorizationStatus status = [[LoggingManager sharedManager] currentAuthorizationStatus];
    
    // Ask user for permission if hasn't done so
    if (status == kCLAuthorizationStatusNotDetermined) {
        [[LoggingManager sharedManager] requestAccessPermissionFromUser];
    }
    // If permission is already denied, ask user to go to settings to turn it on
    else if (status == kCLAuthorizationStatusDenied){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }else{
        return;
    }
}

- (void) locationPermissionUpdated: (NSNotification *)sender
{
    CLAuthorizationStatus newStatus = [sender.userInfo[@"status"] intValue];
    
    // Permission granted, finish onboarding
    if (newStatus == kCLAuthorizationStatusAuthorizedAlways) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    // Permission denied, ask user to turn it on in settings
    else if (newStatus != kCLAuthorizationStatusNotDetermined){
        [self showPermissionDeniedUI];
    }
}

- (void) showPermissionDeniedUI
{
    [self.accessLocationButton setTitle:@"Go to settings" forState:UIControlStateNormal];
    self.titleLabel.text = @"Please go to \"Settings\" and enable access to location.";
    self.titleLabel.textColor = [UIColor redColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
