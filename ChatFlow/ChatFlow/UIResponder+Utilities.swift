// Copyright © 2017 Tellus, Inc. All rights reserved.

extension UIResponder {
    /// The responder that should become first responder when the user taps the next button (or any similar control).
    @IBOutlet var nextInput: UIResponder? {
        get { return getAssociatedValue(for: #selector(getter: UIResponder.nextInput).key) as! UIResponder? }
        set { setAssociatedValue(newValue, forKey: #selector(getter: UIResponder.nextInput).key) }
    }

    static var firstResponder: UIResponder? { return currentFirst() }

    @discardableResult
    static func resignAllFirstResponders() -> Bool {
        while let firstResponder = firstResponder {
            guard firstResponder.resignFirstResponder() else { return false }
        }
        return true
    }
}
