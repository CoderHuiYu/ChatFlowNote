// Copyright © 2017 Tellus, Inc. All rights reserved.

struct KeyPath : Hashable {
    let segments: [String]

    var isEmpty: Bool { return segments.isEmpty }

    /// Strips off the first segment and returns a pair consisting of the first segment and the remaining key path.
    /// Returns `nil` if the key path has no segments.
    func headAndTail() -> (head: String, tail: KeyPath)? {
        guard !isEmpty else { return nil }
        var tail = segments
        let head = tail.removeFirst()
        return (head, KeyPath(segments: tail))
    }

    func head() -> String? { return headAndTail()?.head }
    func tail() -> KeyPath? { return headAndTail()?.tail }

    var hashValue: Int { return description.hashValue }
}

extension KeyPath {
    init(_ string: String) {
        segments = string.components(separatedBy: ".")
    }
}

extension KeyPath : ExpressibleByStringLiteral {
    init(stringLiteral value: String) { self.init(value) }
    init(unicodeScalarLiteral value: String) { self.init(value) }
    init(extendedGraphemeClusterLiteral value: String) { self.init(value) }
}

extension KeyPath : CustomStringConvertible {
    var description: String { return segments.joined(separator: ".") }
}

func + (lhs: KeyPath, rhs: KeyPath) -> KeyPath {
    return KeyPath(lhs.description + "." + rhs.description)
}

extension Dictionary where Key == String, Value == Any {
    subscript(keyPath keyPath: KeyPath) -> Any? {
        get {
            guard let (head, tail) = keyPath.headAndTail() else { return self } // The key path is empty
            let key = head
            if tail.isEmpty { return self[key] } // The end of the key path
            guard let nestedDictionary = self[key] as? [Key:Any] else { return nil }
            return nestedDictionary[keyPath: tail]
        }
        set {
            guard let (head, tail) = keyPath.headAndTail() else { preconditionFailure("Trying to assign to an empty key path.") }
            let key = head
            if tail.isEmpty { return self[key] = newValue } // The end of the key path
            let value = self[key] ?? [:]
            var nestedDictionary = value as? [Key:Any] ?? {
                ZLWarn("Expected nested JSON object at key \"\(key)\", but found \(value). Value will be overwritten.")
                return [:]
            }()
            nestedDictionary[keyPath: tail] = newValue
            self[key] = nestedDictionary
        }
    }
}
