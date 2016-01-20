//
//  HeaderView.h
//  TripHistory
//
//  Created by Peng Fuyuzhen on 1/18/16.
//  Copyright © 2016 Peng Fuyuzhen. All rights reserved.
//

#import <UIKit/UIKit.h>

// Header view has a title label and a switch

typedef NS_ENUM(int, HeaderViewSwitchState) {
    HeaderViewSwitchStateOff = 0,
    HeaderViewSwitchStateOn = 1
};

@protocol HeaderViewDelegate;

@interface HeaderView : UIView
@property (nonatomic, weak) id<HeaderViewDelegate>delegate;

// Initializer
+ (HeaderView *) headerViewWithTitle: (NSString *)title size: (CGSize) size;

// UI
- (void) updateTitleWithMessage: (NSString *)message;
- (void) updatetitleWithWarningMessage: (NSString *)message;

// Switch Control
- (void) turnOnSwitchView: (BOOL) on;
@end

@protocol HeaderViewDelegate <NSObject>
// Notify delegate that switch state has changed
- (void) headerView: (HeaderView *) headerView switchStateChanged: (HeaderViewSwitchState) newState;
@end
