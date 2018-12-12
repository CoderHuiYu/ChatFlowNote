// Copyright © 2017 Tellus, Inc. All rights reserved.

import Foundation

class Global : NSObject {
    @objc static func unqualifiedClassName(_ type: AnyClass) -> String {
        return String(describing: type) // Not the same as NSStringFromClass(…), which returns the fully-qualified name.
    }
}

protocol AnyOptional {
    static var any_none: Any { get }
}

extension Swift.Optional : AnyOptional {
    static var any_none: Any { return self.none as Any }

    mutating func take() -> Wrapped? {
        guard let value = self else { return nil }
        self = nil
        return value
    }
}

var 🔥: Never { preconditionFailure() }

/// A generic informationless error.
struct GenericError : Error { }
struct CancelledError : Error { }

// Common Closures
typealias SortingClosure<T> = (T, T) -> Bool
typealias ActionClosure = () -> Void
typealias ObjectClosure<Value> = (Value) -> Void
typealias ValueChangedHandler<Value> = (Value) -> Void
typealias FormatterClosure<Value> = (Value) -> String
typealias PredicateClosure<Value> = (Value) -> Bool
typealias FilterClosure<Value> = PredicateClosure<Value>
typealias SelectionHandler<Value> = (Value) -> Void
typealias ObjCCompletionHandler<Value> = (Value?, Error?) -> Void

/// Workaround for https://bugs.swift.org/browse/SR-6025
func downcast<T>(_ value: Any, to _: T.Type) -> T? { return value as? T }

func ~= <S : Sequence>(lhs: S, rhs: S.Element) -> Bool where S.Element : Equatable { return lhs.contains(rhs) }
func += <C : RangeReplaceableCollection>(lhs: inout C, rhs: C.Element) { lhs.append(rhs) }

extension Int {
    var nilIfZero: Int? { return self == 0 ? nil : self }
}

extension Decimal {
    var nilIfZero: Decimal? { return self == 0 ? nil : self }
}

extension Bool {
    var localizedYesOrNo: String { return self ? NSLocalizedString("Yes", comment: "") : NSLocalizedString("No", comment: "") }
}

typealias Distance = Measurement<UnitLength>
typealias Duration = Measurement<UnitDuration>

extension Measurement where UnitType == UnitDuration {
    var timeInterval: TimeInterval { return converted(to: .seconds).value }
}

extension Measurement {
    init(_ value: Double, _ unit: UnitType) { self.init(value: value, unit: unit) }
}

extension Sequence where Element : Comparable {
    /// Returns the range `min ... max`, or `nil` if the sequence is empty.
    func elementRange() -> ClosedRange<Element>? {
        var iterator = makeIterator()
        guard let first = iterator.next() else { return nil }
        var (min, max) = (first, first)
        while let element = iterator.next() {
            if element < min { min = element }
            else if element >= max { max = element } // >= to match stdlib behavior of max
        }
        return min ... max
    }
}

extension ClosedRange {
    func union(_ other: ClosedRange<Bound>) -> ClosedRange<Bound> {
        return Swift.min(lowerBound, other.lowerBound) ... Swift.max(upperBound, other.upperBound)
    }

    func union(_ other: Bound) -> ClosedRange<Bound> {
        return Swift.min(lowerBound, other) ... Swift.max(upperBound, other)
    }

    init(value: Bound) {
        self = value ... value
    }
}

extension ClosedRange where Bound : Numeric {
    var length: Bound { return upperBound - lowerBound }
}

extension Collection {
    /// Returns `self[index]` if `index` is a valid index, or `nil` otherwise.
    public subscript(ifValid index: Index) -> Iterator.Element? {
        return (index >= startIndex && index < endIndex) ? self[index] : nil
    }

    /// Given the collection contains only exactly one element, returns it; otherwise returns `nil`.
    var onlyElement: Element? { return count == 1 ? first : nil }

    var nilIfEmpty: Self? { return isEmpty ? nil : self }
}
