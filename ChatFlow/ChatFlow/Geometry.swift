// Copyright © 2017 Tellus, Inc. All rights reserved.

import CoreGraphics

// MARK: Point
func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint { return CGPoint(x: lhs.x+rhs.x, y: lhs.y+rhs.y) }
func + (lhs: CGPoint, rhs: CGSize) -> CGPoint { return CGPoint(x: lhs.x+rhs.width, y: lhs.y+rhs.height) }
func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint { return CGPoint(x: lhs.x-rhs.x, y: lhs.y-rhs.y) }
func - (lhs: CGPoint, rhs: CGSize) -> CGPoint { return CGPoint(x: lhs.x-rhs.width, y: lhs.y-rhs.height) }
func / (lhs: CGPoint, rhs: CGPoint) -> CGPoint { return CGPoint(x: lhs.x/rhs.x, y: lhs.y/rhs.y) }
func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint { return CGPoint(x: lhs.x/rhs, y: lhs.y/rhs) }
func * (lhs: CGPoint, rhs: CGPoint) -> CGPoint { return CGPoint(x: lhs.x*rhs.x, y: lhs.y*rhs.y) }
func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint { return CGPoint(x: lhs.x*rhs, y: lhs.y*rhs) }
func += (lhs: inout CGPoint, rhs: CGPoint) { return lhs = lhs + rhs }
func -= (lhs: inout CGPoint, rhs: CGPoint) { return lhs = lhs - rhs }
func *= (lhs: inout CGPoint, rhs: CGPoint) { return lhs = lhs * rhs }
func *= (lhs: inout CGPoint, rhs: CGFloat) { return lhs = lhs * rhs }
func /= (lhs: inout CGPoint, rhs: CGPoint) { return lhs = lhs / rhs }
func /= (lhs: inout CGPoint, rhs: CGFloat) { return lhs = lhs / rhs }
prefix func -(p: CGPoint) -> CGPoint { return CGPoint(x: -p.x, y: -p.y) }

extension CGPoint {
    /// Return the Euclidian distance from `self` to `p`.
    func distance(to p: CGPoint) -> CGFloat {
        let dx = p.x-x
        let dy = p.y-y
        return hypot(dx, dy)
    }

    /// Return the Euclidian distance from `self` to the closest point inside `rect`.
    func distance(to rect: CGRect) -> CGFloat {
        return distance(to: self.constrained(to: rect))
    }

    /// The Euclidian distance between `self` and the point (0, 0).
    var distanceToOrigin: CGFloat { return distance(to: CGPoint.zero) }

    init(radius: CGFloat, angle: CGFloat) {
        self.init(x: cos(angle)*radius, y: sin(angle)*radius)
    }

    /// In the range `(-π, +π]`.
    func direction(to other: CGPoint) -> CGFloat {
        let delta = other - self
        return atan2(delta.y, delta.x)
    }

    init(angle: CGFloat, radius: CGFloat) {
        let x = cos(angle) * radius
        let y = sin(angle) * radius
        self.init(x: x, y: y)
    }

    /// Return a copy of `self` with both components constrained to `rect`.
    func constrained(to rect: CGRect) -> CGPoint {
        var p = self
        p.x = p.x.constrained(to: rect.minX...rect.maxX)
        p.y = p.y.constrained(to: rect.minY...rect.maxY)
        return p
    }

    /// Constrain both components to `rect`.
    mutating func constrain(rect: CGRect) {
        self = self.constrained(to: rect)
    }
}

// MARK: Size
extension CGSize {
    init(uniform value: CGFloat) {
        self.init(width: value, height: value)
    }

    // MARK: Scaling
    func scaling(to targetSize: CGSize, scaleMode: ScaleMode = .fill) -> CGSize {
        var scaling = targetSize / self
        // Adjust scale for aspect fit/fill
        switch scaleMode {
        case .aspectFit: scaling = CGSize(uniform: min(scaling.width, scaling.height))
        case .aspectFill: scaling = CGSize(uniform: max(scaling.width, scaling.height))
        case .fill: break
        }
        // New size
        return self * scaling
    }
}

func + (lhs: CGSize, rhs: CGSize) -> CGSize { return CGSize(width: lhs.width+rhs.width, height: lhs.height+rhs.height) }
func - (lhs: CGSize, rhs: CGSize) -> CGSize { return CGSize(width: lhs.width-rhs.width, height: lhs.height-rhs.height) }
func * (lhs: CGSize, rhs: CGSize) -> CGSize { return CGSize(width: lhs.width*rhs.width, height: lhs.height*rhs.height) }
func * (lhs: CGSize, rhs: CGFloat) -> CGSize { return CGSize(width: lhs.width*rhs, height: lhs.height*rhs) }
func / (lhs: CGSize, rhs: CGSize) -> CGSize { return CGSize(width: lhs.width/rhs.width, height: lhs.height/rhs.height) }
func / (lhs: CGSize, rhs: CGFloat) -> CGSize { return CGSize(width: lhs.width/rhs, height: lhs.height/rhs) }
func += (lhs: inout CGSize, rhs: CGSize) { return lhs = lhs + rhs }
func -= (lhs: inout CGSize, rhs: CGSize) { return lhs = lhs - rhs }
func *= (lhs: inout CGSize, rhs: CGSize) { return lhs = lhs * rhs }
func *= (lhs: inout CGSize, rhs: CGFloat) { return lhs = lhs * rhs }
func /= (lhs: inout CGSize, rhs: CGSize) { return lhs = lhs / rhs }
func /= (lhs: inout CGSize, rhs: CGFloat) { return lhs = lhs / rhs }

// MARK: Rect
extension CGRect {
    var x: CGFloat { get { return origin.x } set { origin.x = newValue } }
    var y: CGFloat { get { return origin.y } set { origin.y = newValue } }
    var width: CGFloat { get { return size.width } set { size.width = newValue } }
    var height: CGFloat { get { return size.height } set { size.height = newValue } }

    var center: CGPoint { return CGPoint(x: midX, y: midY) }

    init(center: CGPoint, size: CGSize) {
        self.init(origin: center - size/2, size: size)
    }

    func point(atFractionOfX xFraction: CGFloat, y yFraction: CGFloat) -> CGPoint {
        let x = xFraction.linearMap(from: 0...1, to: minX...maxX)
        let y = yFraction.linearMap(from: 0...1, to: minY...maxY)
        return CGPoint(x: x, y: y)
    }

    // MARK: Scaling
    func scaling(to target: CGRect, scaleMode: ScaleMode = .fill) -> CGRect {
        // Compute new size & center
        let newSize = size.scaling(to: target.size, scaleMode: scaleMode)
        let newCenter = target.center
        return CGRect(center: newCenter, size: newSize)
    }
}

enum ScaleMode {
    case fill, aspectFit, aspectFill

    init?(_ contentMode: UIView.ContentMode) {
        switch contentMode {
        case .scaleToFill: self = .fill
        case .scaleAspectFit: self = .aspectFit
        case .scaleAspectFill: self = .aspectFill
        default: return nil
        }
    }
}

// MARK: Insets
extension UIEdgeInsets {
    init(uniform value: CGFloat) {
        self.init(top: value, left: value, bottom: value, right: value)
    }

    init(horizontal horizontalInset: CGFloat = 0, vertical verticalInset: CGFloat = 0) {
        self.init(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }
}

// MARK: Transform
extension CGAffineTransform {
    init(rotationAngle: CGFloat, around center: CGPoint) {
        let (sn, cs) = (sin(rotationAngle), cos(rotationAngle))
        let (a, b, c, d) = (cs, sn, -sn, cs)
        let tx = (a * -center.x) + (c * -center.y) + center.x
        let ty = (b * -center.x) + (d * -center.y) + center.y
        self.init(a: a, b: b, c: c, d: d, tx: tx, ty: ty)
    }

    init(scaleX: CGFloat, y scaleY: CGFloat, around center: CGPoint) {
        let (a, b, c, d) = (scaleX, 0 as CGFloat, 0 as CGFloat, scaleY)
        let tx = center.x - (scaleX * center.x)
        let ty = center.y - (scaleY * center.y)
        self.init(a: a, b: b, c: c, d: d, tx: tx, ty: ty)
    }
}
