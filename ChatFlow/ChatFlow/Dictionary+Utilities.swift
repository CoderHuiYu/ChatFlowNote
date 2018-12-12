// Copyright © 2017 Tellus, Inc. All rights reserved.

extension Dictionary {
    func map<K, V>(_ transform: (Key, Value)->(K, V)) -> [K:V] {
        var result = [K:V](minimumCapacity: count)
        for (key, value) in self {
            let (transformedKey, transformedValue) = transform(key, value)
            result[transformedKey] = transformedValue
        }
        return result
    }

    func failableMap<K, V>(_ transform: (Key, Value)->(K, V)?) -> [K:V]? {
        var result = [K:V](minimumCapacity: count)
        for (key, value) in self {
            guard let (transformedKey, transformedValue) = transform(key, value) else { return nil }
            result[transformedKey] = transformedValue
        }
        return result
    }
    
    func compactMap<K, V>(_ transform: (Key, Value)->(K, V)?) -> [K:V] {
        var result = [K:V]()
        for (key, value) in self {
            if let (transformedKey, transformedValue) = transform(key, value) {
                result[transformedKey] = transformedValue
            }
        }
        return result
    }
}

extension Dictionary where Key == String {
    subscript(firstDescendantWithKey target: String) -> Any? {
        get {
            if let result = self[target] { return result }
            for value in values {
                if let nestedDictionary = value as? [String:Any], let result = nestedDictionary[firstDescendantWithKey: target] { return result }
                if let array = value as? [Any] {
                    for element in array {
                        if let nestedDictionary = element as? [String:Any], let result = nestedDictionary[firstDescendantWithKey: target] { return result }
                    }
                }
            }
            return nil
        }
    }
}
