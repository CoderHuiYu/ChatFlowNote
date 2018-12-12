// Copyright © 2017 Tellus, Inc. All rights reserved.

#import "NSObject+Helper.h"

@implementation NSObject (Helper)

- (id)as:(Class)clss {
    return [self isKindOfClass:clss] ? self : nil;
}

- (BOOL)valuesForKeyPaths:(NSArray<NSString *> *)keyPaths containSearchQuery:(NSString *)searchQuery {
    if (searchQuery.length == 0) { return YES; }
    for (NSString *keyPath in keyPaths) {
        NSString *propertyValue = [[self valueForKeyPath:keyPath] description];
        if ([propertyValue localizedCaseInsensitiveContainsString:searchQuery]) { return YES; }
    }
    return NO;
}


@end
