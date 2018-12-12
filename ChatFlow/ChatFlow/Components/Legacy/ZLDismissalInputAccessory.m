// Copyright © 2017 Tellus, Inc. All rights reserved.

#import "ZLDismissalInputAccessory.h"

static CGFloat const kZLDismissalInputAccessoryHeight = 44.f;

@interface ZLDismissalInputAccessory ()

@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;

@end

@implementation ZLDismissalInputAccessory

// MARK: Initialization
+ (instancetype)loadFromNib {
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(self.class) bundle:nil];
    return [nib instantiateWithOwner:nil options:nil].firstObject;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Clear mock content
    self.title = nil;
    [NSLayoutConstraint activateConstraints:@[ [self.heightAnchor constraintEqualToConstant:kZLDismissalInputAccessoryHeight] ]];
}

// MARK: Updating
- (NSString *)title { return self.titleLabel.text; }
- (void)setTitle:(NSString *)title { self.titleLabel.text = title; }

// MARK: Actions
- (IBAction)handleCancelTapped {
    if ([self.delegate respondsToSelector:@selector(dismissalInputAccessoryCancelTapped:)]) {
        [self.delegate dismissalInputAccessoryCancelTapped:self];
    }
    BLOCK_EXEC(self.cancelActionBlock);
}

- (IBAction)handleDoneTapped {
    if ([self.delegate respondsToSelector:@selector(dismissalInputAccessoryDoneTapped:)]) {
        [self.delegate dismissalInputAccessoryDoneTapped:self];
    }
    BLOCK_EXEC(self.actionBlock);
}

// MARK: Setters
- (void)setCancelButtonHidden:(BOOL)cancelButtonHidden {
    _cancelButtonHidden = cancelButtonHidden;
    self.cancelButton.hidden = _cancelButtonHidden;
}

@end
