// Copyright © 2017 Tellus, Inc. All rights reserved.

extension NSLayoutConstraint {
    func with(priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}

extension UILayoutPriority {
    static var pseudoRequired: UILayoutPriority { return UILayoutPriority(rawValue: 999) }
    static var lowCompressionResistance: UILayoutPriority { return UILayoutPriority(rawValue: 740) }
    static var defaultCompressionResistance: UILayoutPriority { return UILayoutPriority(rawValue: 750) }
    static var highCompressionResistance: UILayoutPriority { return UILayoutPriority(rawValue: 760) }
    static var medium: UILayoutPriority { return UILayoutPriority(rawValue: 500) }
    static var lowHuggingPriority: UILayoutPriority { return UILayoutPriority(rawValue: 240) }
    static var defaultHuggingPriority: UILayoutPriority { return UILayoutPriority(rawValue: 250) }
    static var highHuggingPriority: UILayoutPriority { return UILayoutPriority(rawValue: 260) }
}
