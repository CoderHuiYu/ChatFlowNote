// Copyright © 2017 Tellus, Inc. All rights reserved.

#import "CGGeometry.h"

double constrain(double value, double min, double max) {
    if (value < min) { return min; }
    if (value > max) { return max; }
    return value;
}

double constrainMin(double value, double min) {
    if (value < min) { return min; }
    return value;
}

double constrainMax(double value, double max) {
    if (value > max) { return max; }
    return value;
}

// MARK: Point
CGPoint CGPointMakeUniform(CGFloat value) { return CGPointMake(value, value); }

CGPoint CGPointAdd(CGPoint lhs, CGPoint rhs) { return CGPointMake(lhs.x + rhs.x, lhs.y + rhs.y); }

CGPoint CGPointSubtract(CGPoint lhs, CGPoint rhs) { return CGPointMake(lhs.x - rhs.x, lhs.y - rhs.y); }

CGPoint CGPointMultiply(CGPoint lhs, CGPoint rhs) { return CGPointMake(lhs.x * rhs.x, lhs.y * rhs.y); }

CGPoint CGPointDivide(CGPoint lhs, CGPoint rhs) { return CGPointMake(lhs.x / rhs.x, lhs.y / rhs.y); }

CGPoint CGPointScale(CGPoint point, CGFloat scale) { return CGPointMake(point.x * scale, point.y * scale); }

// MARK: Size
CGSize CGSizeMakeUniform(CGFloat size) { return CGSizeMake(size, size); }

CGSize CGSizeAdd(CGSize lhs, CGSize rhs) { return CGSizeMake(lhs.width + rhs.width, lhs.height + rhs.height); }

CGSize CGSizeSubtract(CGSize lhs, CGSize rhs) { return CGSizeMake(lhs.width - rhs.width, lhs.height - rhs.height); }

CGSize CGSizeMultiply(CGSize lhs, CGSize rhs) { return CGSizeMake(lhs.width * rhs.width, lhs.height * rhs.height); }

CGSize CGSizeDivide(CGSize lhs, CGSize rhs) { return CGSizeMake(lhs.width / rhs.width, lhs.height / rhs.height); }

CGSize CGSizeScale(CGSize size, CGFloat scale) { return CGSizeMake(size.width * scale, size.height * scale); }

// MARK: Rect
CGRect CGRectMake2(CGPoint origin, CGSize size) { return CGRectMake(origin.x, origin.y, size.width, size.height); }

CGRect CGRectMake3(CGPoint center, CGSize size) { return CGRectMake2(CGPointMake(center.x-size.width/2, center.y-size.height/2), size); }

CGRect CGRectScale(CGRect rect, CGFloat scale) {
    return CGRectMake(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.height * scale);
}


// MARK: Other
CGFloat CGPointDistanceToPoint(CGPoint p1, CGPoint p2) { return hypot(p2.x - p1.x, p2.y - p1.y); }

CGPoint CGPointClampToRect(CGPoint p, CGRect rect) {
    p.x = constrain(p.x, CGRectGetMinX(rect), CGRectGetMaxX(rect));
    p.y = constrain(p.y, CGRectGetMinY(rect), CGRectGetMaxY(rect));
    return p;
}

CGFloat CGPointDistanceToRect(CGPoint p, CGRect rect) {
    CGPoint pInRect = CGPointClampToRect(p, rect);
    return CGPointDistanceToPoint(p, pInRect);
}

// MARK: Insets
UIEdgeInsets UIEdgeInsetsAdd(UIEdgeInsets lhs, UIEdgeInsets rhs) {
    return UIEdgeInsetsMake(lhs.top + rhs.top, lhs.left + rhs.left, lhs.bottom + rhs.bottom, lhs.right + rhs.right);
}

// MARK: Scale
CGSize CGSizeScaleToSize(CGSize size, CGSize targetSize, ZLScaleMode scaleMode) {
    CGSize scaling = CGSizeDivide(targetSize, size);
    // Adjust scale for aspect fit/fill
    switch (scaleMode) {
    case ZLScaleModeAspectFit: scaling = CGSizeMakeUniform(MIN(scaling.width, scaling.height)); break;
    case ZLScaleModeAspectFill: scaling = CGSizeMakeUniform(MAX(scaling.width, scaling.height)); break;
    case ZLScaleModeFill: break;
    }
    return CGSizeMultiply(size, scaling);
}

CGRect CGRectScaleToSize(CGRect rect, CGSize targetSize, ZLScaleMode scaleMode) {
    CGSize newSize = CGSizeScaleToSize(rect.size, targetSize, scaleMode);
    return CGRectMake2(rect.origin, newSize);
}
