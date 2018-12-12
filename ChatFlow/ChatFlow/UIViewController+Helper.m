// Copyright © 2017 Tellus, Inc. All rights reserved.

#import "UIViewController+Helper.h"

@implementation UIViewController (Helper)

- (void)useDismissSingleArrowButton {
    [self setLeftBarButtonWithSelector:@selector(dismissModal:)];
}

- (void)usePopSingleArrowButton { // TODO: Improve this to be iOS identical and include a pop gesture recongizer
    [self setLeftBarButtonWithSelector:@selector(popViewController:)];
}

- (void)useDismissArrowButtonWithTitle:(NSString *)title {
    [self setLeftBarButtonWithTitle:title selector:@selector(dismissModal:)];
}

- (void)usePopArrowButtonWithTitle:(NSString *)title {
    [self setLeftBarButtonWithTitle:title selector:@selector(popViewController:)];
}

- (void)setNextViewControllerBackButtonTitleToGeneric {
    [self setNextViewControllersBackButtonTitle:NSLocalizedString(@"Back", nil)];
}

- (void)setNextViewControllersBackButtonTitle:(NSString *)backButtonTitle {
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:backButtonTitle style:UIBarButtonItemStylePlain target:nil action:nil];
}

// MARK: Private Methods
- (void)setLeftBarButtonWithTitle:(NSString *)title selector:(SEL)selector {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:selector];
}

- (void)setLeftBarButtonWithSelector:(SEL)selector {
    UIImage *image = [[UIImage imageNamed:@"navbar-back-white"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *leftBarButton = [UIBarButtonItem barButtonItemWithImage:image target:self action:selector];
    self.navigationItem.leftBarButtonItem = leftBarButton;
}

// MARK: Initializers
- (void)setCustomBackButtonAction:(SEL)action {
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 32)];
    [backButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitle:NSLocalizedString(@"Back", nil) forState:UIControlStateNormal];
    [backButton setTitleColor:UIColor.zillyBlue forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont objc_zillyFontWithSize:14];
    [backButton setImage:[UIImage imageNamed:@"navbar-back-blue-native"] forState:UIControlStateNormal];
    backButton.titleEdgeInsets = UIEdgeInsetsMake(0, 11, 0, 0);
    backButton.adjustsImageWhenHighlighted = NO;
    UIView *backButtonContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 64, 32)];
    [backButtonContainerView addSubview:backButton];
    backButton.transform = CGAffineTransformMakeTranslation(-18, 0);
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonContainerView];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
}

+ (instancetype)loadFromNib {
    NSString *name = [Global unqualifiedClassName:self.class];
    UINib *nib = [UINib nibWithNibName:name bundle:nil];
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    ZAssert(objects.count == 1, @"More than one top-level object found in nib \"%@\".", name);
    ZAssert([objects.firstObject isKindOfClass:self], @"Top-level object has unexpected class %@ (expected %@). Note that [UIViewController loadFromNib] expects the VC as top-level object, not file owner.", NSStringFromClass([objects.firstObject class]), name);
    return objects.firstObject;
}

- (void)scrollToTop {
    NSArray<UIView*> *subviews = self.view.subviews;
    if ([subviews.firstObject as:UIStackView.class] && subviews.count == 1) {
        subviews = subviews.firstObject.subviews;
    }

    for (UIView *subview in subviews) {
        UIScrollView *scrollView = [subview as:UIScrollView.class];
        if (scrollView && [scrollView scrollsToTop]) {
            [scrollView setContentOffset:CGPointZero animated:YES];
        }
    }
}

// MARK: Navigation
- (IBAction)dismiss {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissModal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)popViewController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIViewController *)previousViewController {
    if (!self.navigationController) { return nil; }
    NSArray *stack = self.navigationController.viewControllers;
    NSInteger indexOfSelf = [stack indexOfObject:self];
    if (indexOfSelf == 0 || indexOfSelf == NSNotFound) { return nil; }
    return stack[indexOfSelf - 1];
}

+ (UIViewController *)findBestViewController:(UIViewController *)vc {

    if (vc.presentedViewController) {

        // Return presented view controller
        return [UIViewController findBestViewController:vc.presentedViewController];

    } else if ([vc isKindOfClass:UISplitViewController.class]) {

        // Return right hand side
        UISplitViewController *svc = (UISplitViewController *) vc;
        if (svc.viewControllers.count > 0)
            return [UIViewController findBestViewController:svc.viewControllers.lastObject];
        else
            return vc;

    } else if ([vc isKindOfClass:UINavigationController.class]) {

        // Return top view
        UINavigationController *svc = (UINavigationController *) vc;
        if (svc.viewControllers.count > 0)
            return [UIViewController findBestViewController:svc.topViewController];
        else
            return vc;

    } else if ([vc isKindOfClass:UITabBarController.class]) {

        // Return visible view
        UITabBarController *svc = (UITabBarController *) vc;
        if (svc.viewControllers.count > 0)
            return [UIViewController findBestViewController:svc.selectedViewController];
        else
            return vc;

    } else {
        // Unknown view controller type, return last child view controller
        return vc;

    }
}

+ (UIViewController *)currentViewController {
    // Find best view controller
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (!viewController) {
        viewController = [[UIApplication sharedApplication].delegate window].rootViewController;
    }
    return [UIViewController findBestViewController:viewController];
}

@end
