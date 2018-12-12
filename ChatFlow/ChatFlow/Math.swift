// Copyright © 2018 Tellus, Inc. All rights reserved.

extension FloatingPoint {
    /// Maps `self` from its relative position in `source` to the equivalent in `target`.
    /// - parameter constrained: If `true`, constrains the result to be within `target`.
    func linearMap(from source: ClosedRange<Self>, to target: ClosedRange<Self>, constrained: Bool = true) -> Self {
        return linearMap(from: (source.lowerBound, source.upperBound), to: (target.lowerBound, target.upperBound), constrained: constrained)
    }

    /// Maps `self` from its relative position between `source.a` and `source.b` to the equivalent between `target.a` and `target.b`.
    ///
    /// Allows `b < a` (which inverts the relative position) as well as `self` being outside of `source`.
    /// - parameter constrained: If `true`, constrains the result to be between `target.a` and `target.b`.
    func linearMap(from source: (a: Self, b: Self), to target: (a: Self, b: Self), constrained: Bool = true) -> Self {
        // Map value, multiplying before division because Self could be an integer type.
        // Use intermediate because otherwise expression is too complex for the compiler
        let intermediate = (self-source.a) * (target.b-target.a)
        let result = intermediate / (source.b-source.a) + target.a
        // Return, constrained if needed
        if constrained {
            let targetMin = min(target.a, target.b)
            let targetMax = max(target.a, target.b)
            return result.constrained(to: targetMin...targetMax)
        } else {
            return result
        }
    }

    func signum() -> Int {
        if self > 0 { return 1 }
        if self < 0 { return -1 }
        return 0
    }
}

extension BinaryInteger {
    func divide(by divisor: Self, roundingUp: Void) -> Self {
        return (self + (divisor-1)) / divisor
    }

    func isMultiple(of other: Self) -> Bool { // SWIFT 5: Remove since this will be in the stdlib
        return self % other == 0
    }
}

extension Sequence where Element : Numeric {
    func sum() -> Element { return reduce(0, +) }
}
