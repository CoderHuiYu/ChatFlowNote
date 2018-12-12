// Copyright © 2017 Tellus, Inc. All rights reserved.

#import "ZLLabel.h"

@implementation ZLLabel

- (instancetype)initWithFrame:(CGRect)frame {
    return [[super initWithFrame:frame] initialize];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    return [[super initWithCoder:decoder] initialize];
}

- (instancetype)initialize {
    // Enforce line breaking convention
    self.lineBreakMode = NSLineBreakByTruncatingTail;
    // Update line height
    [self updateLineHeight];
    return self;
}

// Any of the below properties invalidate the attributed string we set in `updateLineHeight`.
- (void)setText:(NSString *)text {
    [super setText:text];
    [self updateLineHeight];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self updateLineHeight];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    [super setTextAlignment:textAlignment];
    [self updateLineHeight];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    [self updateLineHeight];
}

- (void)updateLineHeight {
    NSMutableAttributedString *result = [super.attributedText mutableCopy];
    [result enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, result.length) options:0 usingBlock:^(UIFont *font, NSRange fontRange, BOOL *stop) {
        // Map font size to line height according to Tellus style guide
        CGFloat fontSize = font.pointSize;
        CGFloat lineHeight = 0;
        if (fontSize == 40) { lineHeight = 40; }
        if (fontSize == 32) { lineHeight = 36; }
        if (fontSize == 24) { lineHeight = 32; }
        if (fontSize == 19) { lineHeight = 24; }
        if (fontSize == 17) { lineHeight = 22; }
        if (fontSize == 14) { lineHeight = 18; }
        if (fontSize == 12) { lineHeight = 16; }
        if (fontSize == 10) { lineHeight = 12; }
        if (fontSize == 8) { lineHeight = 10; }
        // Update paragraph style with correct line heights
        [result enumerateAttribute:NSParagraphStyleAttributeName inRange:fontRange options:0 usingBlock:^(NSParagraphStyle *value, NSRange range, BOOL *stop) {
            NSMutableParagraphStyle *paragraphStyle = [value mutableCopy] ?: [NSMutableParagraphStyle new];
            paragraphStyle.minimumLineHeight = lineHeight;
            // iOS 10 has bug when minimum and maximum lineHeight are set at same time, bug is fixed in iOS 11
            if (@available(iOS 11, *)) {  paragraphStyle.maximumLineHeight = lineHeight; }
            [result addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
        }];
    }];
    super.attributedText = result;
}

@end
