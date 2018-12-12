// Copyright © 2017 Tellus, Inc. All rights reserved.

extension Sequence {
    /// Returns an `Array` containing the results of mapping `transform` over `self`. Returns `nil` if `transform` returns `nil` at any point.
    func failableMap<T>(_ transform: (Element) throws -> T?) rethrows -> [T]? {
        var result: [T] = []
        for element in self {
            guard let transformedElement = try transform(element) else { return nil }
            result.append(transformedElement)
        }
        return result
    }

    func anyMatch(_ predicate: (Element) throws -> Bool) rethrows -> Bool {
        return try contains(where: predicate)
    }

    func allMatch(_ predicate: (Element) throws -> Bool) rethrows -> Bool {
        return try !contains { try !predicate($0) }
    }

    func noneMatch(_ predicate: (Element) throws -> Bool) rethrows -> Bool {
        return try !contains(where: predicate)
    }

    func count(_ predicate: (Element) throws -> Bool) rethrows -> Int {
        var count = 0
        for element in self {
            if try predicate(element) { count += 1 }
        }
        return count
    }

    func first<T>(with transform: (Element) throws -> T?) rethrows -> T? {
        for element in self {
            if let transformedElement = try transform(element) { return transformedElement }
        }
        return nil
    }
}

extension Sequence where Element : Equatable {
    func count(_ element: Element) -> Int {
        return count { $0 == element }
    }

    /// Returns one collection with all elements that satisfy a given predicate, and another collection with all that elements that do not.
    func divided(_ predicate: (Element) throws -> Bool) rethrows -> ([Element], [Element]) {
        var result: [Element] = []
        var rest: [Element] = []
        for element in self {
            if try predicate(element) {
                result.append(element)
            } else {
                rest.append(element)
            }
        }
        return (result, rest)
    }
}

extension BidirectionalCollection {
    func last(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        return try reversed().first(where: predicate)
    }

    func lastIndex(where predicate: (Element) throws -> Bool) rethrows -> Index? {
        var index = endIndex
        while index != startIndex {
            formIndex(before: &index)
            if try predicate(self[index]) { return index }
        }
        return nil
    }
}

enum SearchAlgorithm { case binarySearch }

extension Collection {

    /// - Note: Using binary search requires that if the predicate is `true` for a given element, it will be `true` for all subsequent elements.
    func index(where predicate: (Element) throws -> Bool, using searchAlgorithm: SearchAlgorithm) rethrows -> Index? {
        var (low, high) = (startIndex, endIndex)
        while low != high {
            let mid = index(low, offsetBy: distance(from: low, to: high)/2)
            if try predicate(self[mid]) {
                high = mid
            } else {
                low = index(after: mid)
            }
        }
        return low != endIndex ? low : nil
    }

    /// - Note: Using binary search requires that if the predicate is `false` for a given element, it will be `false` for all subsequent elements.
    func prefix(while predicate: (Element) throws -> Bool, using searchAlgorithm: SearchAlgorithm) rethrows -> SubSequence {
        let indexFailingPredicate = try self.index(where: { try !predicate($0) }, using: searchAlgorithm) ?? endIndex
        return self[startIndex..<indexFailingPredicate]
    }

    subscript(ifPresent index: Index) -> Element? {
        guard index >= startIndex && index < endIndex else { return nil }
        return self[index]
    }

    /// A sequence of all index-element pairs in the collection.
    var indexed: AnySequence<(Index, Element)> {
        let sequence = indices.lazy.map { ($0, self[$0]) }
        return AnySequence(sequence)
    }

    /// Splits the collection into two subsequences, at the first index where the predicate returns `true`.
    ///
    /// If the predicate does not return `true` for any element in the collection, the collection will be split at `endIndex`.
    func split(where precidate: (Element) throws -> Bool) rethrows -> (SubSequence, SubSequence) {
        let splitIndex = try index(where: precidate) ?? endIndex
        return split(at: splitIndex)
    }

    func split(at index: Index) -> (SubSequence, SubSequence) {
        return (self[..<index], self[index...])
    }

    func splitFirst() -> (Element, SubSequence)? {
        return (self[startIndex], self[index(after: startIndex)...])
    }
}

extension BidirectionalCollection {
    func splitLast() -> (SubSequence, Element)? {
        guard !isEmpty else { return nil }
        let lastElementIndex = index(before: endIndex)
        return (self[..<lastElementIndex], self[lastElementIndex])
    }
}

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d = Int(arc4random_uniform(UInt32(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}
