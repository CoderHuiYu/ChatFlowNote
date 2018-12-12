// Copyright © 2017 Tellus, Inc. All rights reserved.

extension Comparable {
    func constrained(to range: ClosedRange<Self>) -> Self {
        if self > range.upperBound { return range.upperBound }
        if self < range.lowerBound { return range.lowerBound }
        return self
    }

    func constrained(toAtLeast min: Self) -> Self {
        if self < min { return min }
        return self
    }

    func constrained(toAtMost max: Self) -> Self {
        if self > max { return max }
        return self
    }

    func constrained(toMin min: Self) -> Self { return constrained(toAtLeast: min) }
    func constrained(toMax max: Self) -> Self { return constrained(toAtMost: max) }

    mutating func constrain(to range: ClosedRange<Self>) { self = self.constrained(to: range) }
    mutating func constrain(toMin min: Self) { self = self.constrained(toMin: min) }
    mutating func constrain(toMax max: Self) { self = self.constrained(toMax: max) }
    mutating func constrain(toAtLeast min: Self) { self = self.constrained(toAtLeast: min) }
    mutating func constrain(toAtMost max: Self) { self = self.constrained(toAtMost: max) }
    
}

extension BinaryInteger {
    func wrappingAround(inRange range: ClosedRange<Self>) -> Self {
        return wrappingAround(inRange: range.lowerBound ..< (range.upperBound + 1))
    }

    func wrappingAround(inRange range: Range<Self>) -> Self {
        precondition(!range.isEmpty)
        var offset = self - range.lowerBound
        let length = range.upperBound - range.lowerBound
        offset %= length
        if offset < 0 { offset += length }
        return offset + range.lowerBound
    }
}
