// Copyright © 2017 Tellus, Inc. All rights reserved.

#import "ZLButton.h"

@interface ZLButton()

@property (strong, nonatomic) UIView *debugTappableAreaSizeLayer;

@end

@implementation ZLButton

- (void)setTappableAreaSize:(CGSize)tappableAreaSize {
    _tappableAreaSize = tappableAreaSize;
    _tappableAreaPadding = UIEdgeInsetsZero;

    if (self.debugTappableAreaSizeLayer) {
        [self.debugTappableAreaSizeLayer removeFromSuperview];
    }
    if (self.debugTappableArea) {
        self.debugTappableAreaSizeLayer = [UIView new];
        self.debugTappableAreaSizeLayer.backgroundColor = [UIColor.zillyBlue colorWithAlphaComponent:0.3];
        [self addSubview:self.debugTappableAreaSizeLayer];
        [self sendSubviewToBack:self.debugTappableAreaSizeLayer];
        self.debugTappableAreaSizeLayer.userInteractionEnabled = NO;
        self.debugTappableAreaSizeLayer.frame = CGRectMake2(CGPointZero, self.tappableAreaSize);
        self.debugTappableAreaSizeLayer.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    }
}

- (void)setTappableAreaPadding:(UIEdgeInsets)tappableAreaPadding {
    _tappableAreaPadding = tappableAreaPadding;
    _tappableAreaSize = CGSizeZero;

    if (self.debugTappableAreaSizeLayer) {
        [self.debugTappableAreaSizeLayer removeFromSuperview];
    }
}

// MARK: Changing Tappable Area
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect newBound;
    if (!CGSizeEqualToSize(self.tappableAreaSize, CGSizeZero)) { // If tappableAreaSize has been set
        newBound = CGRectMake(self.bounds.origin.x - (self.tappableAreaSize.width - self.bounds.size.width)/2, self.bounds.origin.y - (self.tappableAreaSize.height - self.bounds.size.height)/2, self.tappableAreaSize.width, self.tappableAreaSize.height);
    } else { // Otherwise, let's use tappableAreaPadding, even if it hasn't been initialized, it's safe.
        newBound = CGRectMake(self.bounds.origin.x - self.tappableAreaPadding.left, self.bounds.origin.y - self.tappableAreaPadding.top, self.bounds.size.width + self.tappableAreaPadding.left + self.tappableAreaPadding.right, self.bounds.size.height + self.tappableAreaPadding.top + self.tappableAreaPadding.bottom);
    }
    return CGRectContainsPoint(newBound, point);
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.debugTappableAreaSizeLayer.frame = CGRectMake2(CGPointZero, self.tappableAreaSize);
    self.debugTappableAreaSizeLayer.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

@end

@implementation UINavigationBar (ZLButton)

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (@available(iOS 11, *)) {
        return [self firstDescendantSatisfying:^BOOL(UIView * _Nonnull view) {
            if (![view isKindOfClass:UIControl.class]) { return NO; }
            CGPoint localCoordinates = [self convertPoint:point toView:view];
            return [view pointInside:localCoordinates withEvent:event];
        }];
    } else {
        return [super hitTest:point withEvent:event];
    }
}

@end

@implementation UIBarButtonItem (ZLButton)

// MARK: Image Setter Swizzling 
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSelector = @selector(setImage:);
        SEL swizzledSelector = @selector(zl_setImage:);
        ZLSwizzle(self.class, originalSelector, swizzledSelector);
    });
}

- (void)zl_setImage:(UIImage *)image {
    ZLButton *button = [self.customView as:ZLButton.class];
    if (button) {
        [button setImage:image forState:UIControlStateNormal];
    }
    [self zl_setImage:image];
}

- (void)zl_setRightBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated {
    [item setLargeTapArea];
    [self zl_setRightBarButtonItem:item animated:animated];
}

// MARK: Instantiate Using Blocks
+ (instancetype)barButtonItemWithImageNamed:(NSString *)imageName tintColor:(UIColor *)tintColor action:(ZLActionBlock _Nonnull)action {
    return [[UIBarButtonItem alloc] initWithCustomView:[self buttonWithImage:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] tintColor:tintColor actionBlock:action target:nil actionSelector:nil]];
}

+ (instancetype)barButtonItemWithImageNamed:(NSString *)imageName action:(ZLActionBlock)action {
    return [UIBarButtonItem barButtonItemWithImageNamed:imageName tintColor:UIColor.zillyBlue action:action];
}

+ (instancetype)barButtonItemWithImage:(UIImage *)image action:(ZLActionBlock)action {
    return [[UIBarButtonItem alloc] initWithCustomView:[self buttonWithImage:image tintColor:UIColor.zillyBlue actionBlock:action target:nil actionSelector:nil]];
}

// MARK: Instantiate Using Selectors
+ (instancetype)barButtonItemWithImageNamed:(NSString *)imageName tintColor:(UIColor *)tintColor target:(id)target action:(SEL)action {
    return [[UIBarButtonItem alloc] initWithCustomView:[self buttonWithImage:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] tintColor:tintColor actionBlock:nil target:target actionSelector:action]];
}

+ (instancetype)barButtonItemWithImageNamed:(NSString *)imageName target:(id)target action:(SEL)action {
    return [[UIBarButtonItem alloc] initWithCustomView:[self buttonWithImage:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] tintColor:UIColor.zillyBlue actionBlock:nil target:target actionSelector:action]];
}

+ (instancetype)barButtonItemWithImage:(UIImage *)image target:(id)target action:(SEL)action {
    return [[UIBarButtonItem alloc] initWithCustomView:[self buttonWithImage:image tintColor:UIColor.zillyBlue actionBlock:nil target:target actionSelector:action]];
}

// MARK: Helper
+ (ZLButton *)buttonWithImage:(UIImage *)image tintColor:(UIColor *)tintColor actionBlock:(ZLActionBlock)actionBlock target:(id)target actionSelector:(SEL)actionSelector {
    ZLButton *zillyButton = [[ZLButton alloc] initWithFrame:CGRectMake(0, 0, 32.0, 32.0)]; // This is the necessary button frame to make the icon fit in the nav bar with the desired spacing between them, according to the design.
    [zillyButton setImage:image forState:UIControlStateNormal];
    zillyButton.contentMode = UIViewContentModeCenter;
    zillyButton.tintColor = tintColor;
    if (isSet(actionBlock)) {
        [zillyButton addTapHandler:actionBlock];
    }
    if ([target respondsToSelector:actionSelector]) {
        [zillyButton addTarget:target action:actionSelector forControlEvents:UIControlEventTouchUpInside];
    }
    return zillyButton;
}

- (void)setSmallTapArea {
    ZLButton *button = [self.customView as:ZLButton.class];
    // We check if there is a ZLButton there instead of forcing it so it doesn't mess up with other components, so we're safely swizzling
    if (button) {
        button.tappableAreaSize = CGSizeMake(40.0, 44.0); // 40.0 is the max width that won't overlap the area of neighbor UIBarButtonItems, 44.0 is the nav bar height (max height)
    }
}

- (void)setLargeTapArea {
    ZLButton *button = [self.customView as:ZLButton.class];
    // We check if there is a ZLButton there instead of forcing it so it doesn't mess up with other components, so we're safely swizzling
    if (button) {
        button.tappableAreaSize = CGSizeMake(80.0, 44.0); // 80.0 is a tap area large enough to be used, but only allowed when there's only 1 bar button item in that side of the nav bar. 44.0 is the nav bar height (max height)
    }
}

/// Sets the tap area for a button that is the closest to the center of the nav bar for left bar button items.
- (void)setTapAreaForLeftInnerButton {
    ZLButton *button = [self.customView as:ZLButton.class];
    if (button) {
        button.tappableAreaPadding = UIEdgeInsetsMake(6.0, 4.0, 6.0, 4.0 + 24.0); // This is the same as `setSmallTapArea` but with extra 24pts on the right. At this point, all ZLButtons are 32x32pt.
    }
}

/// Sets the tap area for the button that is the farthest to the center of the nav bar for right bar button items.
- (void)setTapAreaForRightOuterButton {
    ZLButton *button = [self.customView as:ZLButton.class];
    if (button) {
        button.tappableAreaPadding = UIEdgeInsetsMake(6.0, 4.0, 6.0, 4.0 + 13.0); // This is the same as `setSmallTapArea` but with extra 13pts on the right. At this point, all ZLButtons are 32x32pt.
    }
}

/// Sets the tap area for a button that is the closest to the center of the nav bar for right bar button items.
- (void)setTapAreaForRightInnerButton {
    ZLButton *button = [self.customView as:ZLButton.class];
    if (button) {
        button.tappableAreaPadding = UIEdgeInsetsMake(6.0, 24.0 + 4.0, 6.0, 4.0); // This is the same as `setSmallTapArea` but with extra 24pts on the left. At this point, all ZLButtons are 32x32pt.
    }
}

/// Sets the tap area for the button that is the farthest to the center of the nav bar for left bar button items
- (void)setTapAreaForLeftOuterButton {
    ZLButton *button = [self.customView as:ZLButton.class];
    if (button) {
        button.tappableAreaPadding = UIEdgeInsetsMake(6.0, 13.0 + 4.0, 6.0, 4.0); // This is the same as `setSmallTapArea` but with extra 13pts on the left. At this point, all ZLButtons are 32x32pt.
    }
}

@end

@implementation UINavigationItem (ZLButton)

// MARK: Swizzling
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // iOS internally forwards the non-animated methods to the animated ones, so we only need to swizzle the animated ones here.
        SEL originalSelector1 = @selector(setRightBarButtonItem:animated:);
        SEL originalSelector2 = @selector(setRightBarButtonItems:animated:);
        SEL originalSelector3 = @selector(setLeftBarButtonItem:animated:);
        SEL originalSelector4 = @selector(setLeftBarButtonItems:animated:);

        SEL swizzledSelector1 = @selector(zl_setRightBarButtonItem:animated:);
        SEL swizzledSelector2 = @selector(zl_setRightBarButtonItems:animated:);
        SEL swizzledSelector3 = @selector(zl_setLeftBarButtonItem:animated:);
        SEL swizzledSelector4 = @selector(zl_setLeftBarButtonItems:animated:);

        ZLSwizzle(self.class, originalSelector1, swizzledSelector1);
        ZLSwizzle(self.class, originalSelector2, swizzledSelector2);
        ZLSwizzle(self.class, originalSelector3, swizzledSelector3);
        ZLSwizzle(self.class, originalSelector4, swizzledSelector4);
    });
}

- (void)zl_setRightBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated {
    [item setLargeTapArea];
    [self zl_setRightBarButtonItem:item animated:animated];
}

- (void)zl_setRightBarButtonItems:(NSArray *)items animated:(BOOL)animated {
    if (items.count == 1) {
        [items.firstObject setLargeTapArea];
    } else {
        // rightBarButtonItems are placed right to left with the first item in the list at the right outside edge and right aligned.
        [items.firstObject setTapAreaForRightOuterButton];
        [items.lastObject setTapAreaForRightInnerButton];
        for (UIBarButtonItem *item in items) {
            // Handles the items that are not the first and last (in case there are more than 2 bar button items)
            if (![item isEqual:items.firstObject] && ![item isEqual:items.lastObject]) {
                [item setSmallTapArea];
            }
        }
    }
    [self zl_setRightBarButtonItems:items animated:animated];
}

- (void)zl_setLeftBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated {
    [item setLargeTapArea];
    [self zl_setLeftBarButtonItem:item animated:animated];
}

- (void)zl_setLeftBarButtonItems:(NSArray *)items animated:(BOOL)animated {
    if (items.count == 1) {
        [items.firstObject setLargeTapArea];
    } else {
        // leftBarButtonItems are placed in the navigation bar left to right with the first item in the list at the left outside edge and left aligned.
        [items.firstObject setTapAreaForLeftOuterButton];
        [items.lastObject setTapAreaForLeftInnerButton];
        for (UIBarButtonItem *item in items) {
            // Handles the items that are not the first and last (in case there are more than 2 bar button items)
            if (![item isEqual:items.firstObject] && ![item isEqual:items.lastObject]) {
                [item setSmallTapArea];
            }
        }
    }
    [self zl_setLeftBarButtonItems:items animated:animated];
}

@end
