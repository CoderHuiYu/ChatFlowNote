// Copyright © 2017 Tellus, Inc. All rights reserved.

#import <UIKit/UIKit.h>

@interface UIViewController (Helper)

/*
 *  Sets a single white arrow as back button.
 *  - Pop option for stack navigation.
 *  - Dismiss for presented modally.
 */
- (void)useDismissSingleArrowButton;
- (void)usePopSingleArrowButton;
/// Sets an arrow with title back button.
- (void)useDismissArrowButtonWithTitle:(NSString *)title;
- (void)usePopArrowButtonWithTitle:(NSString *)title;
/// Sets the next view controller's back button title to "Back"
- (void)setNextViewControllerBackButtonTitleToGeneric;
/// Sets the next view controller's back button title to your custom string.
- (void)setNextViewControllersBackButtonTitle:(NSString *)backButtonTitle;
- (void)setCustomBackButtonAction:(SEL)action;
+ (instancetype)loadFromNib;
- (void)scrollToTop;
/// DEPRECATED: Use -dismissSelf instead.
- (IBAction)dismiss;
- (UIViewController *)previousViewController;
+ (UIViewController *)currentViewController;

@end
