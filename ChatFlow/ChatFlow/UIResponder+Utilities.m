// Copyright © 2017 Tellus, Inc. All rights reserved.

static __weak UIResponder *currentFirstResponder;

@implementation UIResponder (Utilities)

+ (UIResponder * _Nullable)currentFirstResponder {
    currentFirstResponder = nil;
    [UIApplication.sharedApplication sendAction:@selector(findFirstResponder:) to:nil from:nil forEvent:nil];
    return currentFirstResponder;
}

- (void)findFirstResponder:(id)sender {
    currentFirstResponder = self;
}

@end
