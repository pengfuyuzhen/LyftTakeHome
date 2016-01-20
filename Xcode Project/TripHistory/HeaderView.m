//
//  HeaderView.m
//  TripHistory
//
//  Created by Peng Fuyuzhen on 1/18/16.
//  Copyright © 2016 Peng Fuyuzhen. All rights reserved.
//

#import "HeaderView.h"
#import "InterfaceHelper.h"

@interface HeaderView()
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UISwitch *switchView;
@end

@implementation HeaderView

+ (HeaderView *) headerViewWithTitle: (NSString *)title size: (CGSize) size
{
    HeaderView *view = [[[NSBundle mainBundle]loadNibNamed:@"HeaderView" owner:nil options:nil]objectAtIndex:0];
    view.bounds = CGRectMake(0, 0, size.width, size.height);

    view.switchView.onTintColor = [InterfaceHelper highlightColor];
    if (!(view.switchView.isOn)) {
        [view.switchView setOn:YES animated:NO];
    }
    [view updateTitleWithMessage:title];

    CAShapeLayer *line = [CAShapeLayer layer];
    line.frame = CGRectMake(0, size.height - 0.5, size.width, 0.5);
    line.backgroundColor = [InterfaceHelper separatorColor].CGColor;
    [view.layer addSublayer:line];
    
    return view;
}

- (void) updateTitleWithMessage: (NSString *)message
{
    self.textLabel.font = [UIFont boldSystemFontOfSize:17];
    self.textLabel.textColor = [InterfaceHelper textColor];
    self.textLabel.text = message;
    self.switchView.enabled = YES;
}

// Service not available, show UI and disalbe switch

- (void) updatetitleWithWarningMessage: (NSString *)message
{
    self.textLabel.font = [UIFont systemFontOfSize:13];
    self.textLabel.textColor = [UIColor redColor];
    self.textLabel.text = message;
    self.switchView.enabled = NO;
}

- (void) turnOnSwitchView: (BOOL) on
{
    [self.switchView setOn:on];
}

- (IBAction)switchViewValueChanged:(id)sender {
    
    // Present Warning view before switching off
    
    if (![self.switchView isOn] && [self.delegate isKindOfClass:[UIViewController class]]) {
        UIViewController *controller = (UIViewController *)self.delegate;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Turn off Logging" message:@"We won't be able to log your trips anymore" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *turnOff = [UIAlertAction actionWithTitle:@"Turn off" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            if ([self.delegate respondsToSelector:@selector(headerView:switchStateChanged:)]) {
                [self.delegate headerView:self switchStateChanged:[(UISwitch *)sender isOn]];
            }
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.switchView setOn:YES animated:NO];
        }];
        [alert addAction:turnOff];
        [alert addAction:cancel];
        
        [controller presentViewController:alert animated:YES completion:nil];
        return;
    }
    if ([self.delegate respondsToSelector:@selector(headerView:switchStateChanged:)]) {
        [self.delegate headerView:self switchStateChanged:[(UISwitch *)sender isOn]];
    }
}

@end
