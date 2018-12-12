// Copyright © 2017 Tellus, Inc. All rights reserved.

@protocol ZLDismissalInputAccessoryDelegate;

typedef void (^ZLActionBlock)(void);

@interface ZLDismissalInputAccessory : UIView

@property (assign, nonatomic, getter=isCancelButtonHidden) BOOL cancelButtonHidden;
@property (copy, nonatomic) NSString *title;
@property (weak, nonatomic) id<ZLDismissalInputAccessoryDelegate> delegate;
@property (strong, nonatomic) ZLActionBlock actionBlock;
@property (strong, nonatomic) ZLActionBlock cancelActionBlock;

+ (instancetype)loadFromNib;

@end

// MARK: End
@protocol ZLDismissalInputAccessoryDelegate <NSObject>

@optional
- (void)dismissalInputAccessoryCancelTapped:(ZLDismissalInputAccessory *)inputAccessory;
- (void)dismissalInputAccessoryDoneTapped:(ZLDismissalInputAccessory *)inputAccessory;

@end
