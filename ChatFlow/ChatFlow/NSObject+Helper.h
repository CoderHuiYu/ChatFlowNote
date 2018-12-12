// Copyright © 2017 Tellus, Inc. All rights reserved.

@interface NSObject (Helper)

- (id)as:(Class)clss;
- (BOOL)valuesForKeyPaths:(NSArray<NSString *> *)keyPaths containSearchQuery:(NSString *)searchQuery;

@end
