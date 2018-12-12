// Copyright © 2017 Tellus, Inc. All rights reserved.

double constrain(double value, double min, double max);
double constrainMin(double value, double min);
double constrainMax(double value, double max);

// MARK: Point
CGPoint CGPointMakeUniform(CGFloat value);
CGPoint CGPointAdd(CGPoint lhs, CGPoint rhs);
CGPoint CGPointSubtract(CGPoint lhs, CGPoint rhs);
CGPoint CGPointMultiply(CGPoint lhs, CGPoint rhs);
CGPoint CGPointDivide(CGPoint lhs, CGPoint rhs);
CGPoint CGPointScale(CGPoint point, CGFloat scale);

// MARK: Size
CGSize CGSizeMakeUniform(CGFloat size);
CGSize CGSizeAdd(CGSize lhs, CGSize rhs);
CGSize CGSizeSubtract(CGSize lhs, CGSize rhs);
CGSize CGSizeMultiply(CGSize lhs, CGSize rhs);
CGSize CGSizeDivide(CGSize lhs, CGSize rhs);
CGSize CGSizeScale(CGSize size, CGFloat scale);

// MARK: Rect
CGRect CGRectMake2(CGPoint origin, CGSize size);
CGRect CGRectMake3(CGPoint center, CGSize size);
CGRect CGRectScale(CGRect rect, CGFloat scale);

// MARK: Other
CGFloat CGPointDistanceToPoint(CGPoint p1, CGPoint p2);
CGPoint CGPointClampToRect(CGPoint p, CGRect rect);
CGFloat CGPointDistanceToRect(CGPoint p, CGRect rect);

// MARK: Insets
UIEdgeInsets UIEdgeInsetsAdd(UIEdgeInsets lhs, UIEdgeInsets rhs);

// MARK: Scale
typedef NS_ENUM(NSInteger, ZLScaleMode) { ZLScaleModeFill, ZLScaleModeAspectFit, ZLScaleModeAspectFill };

CGSize CGSizeScaleToSize(CGSize size, CGSize targetSize, ZLScaleMode scaleMode);
CGRect CGRectScaleToSize(CGRect rect, CGSize targetSize, ZLScaleMode scaleMode);
