// Copyright © 2017 Tellus, Inc. All rights reserved.

import UIKit

extension ZLStringEditor {
    static func titleEditor() -> ZLTrimmedStringEditor {
        let editor = ZLTrimmedStringEditor()
        editor.autocapitalizationType = .words
        return editor
    }

    static func simplePhoneOrEmailEditor() -> ZLTrimmedStringEditor {
        let editor = ZLTrimmedStringEditor()
        editor.autocapitalizationType = .none
        editor.keyboardType = .emailAddress
        return editor
    }

    static func secureTextEditor() -> ZLTrimmedStringEditor {
        let editor = ZLTrimmedStringEditor()
        editor.value = ""
        editor.autocapitalizationType = .none
        editor.isSecureTextEntry = true
        return editor
    }
}

class ZLTrimmedStringEditor : ZLStringEditor<String?> {
    var charLimit: Int?

    init(charLimit: Int? = nil) {
        super.init(initialValue: nil, equalityFunction: ==)
        self.charLimit = charLimit
    }

    override func value(fromSemanticInput input: String) -> String? {
        let trimmedInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedInput.isEmpty ? trimmedInput : nil
    }

    override func semanticInput(fromValue value: String?) -> String {
        return value ?? ""
    }

    override func shouldAllow(value: String?) -> Bool {
        guard let charLimit = charLimit, let value = value else { return true }
        return value.count <= charLimit
    }

    override func sanitize(value: String?) -> String? {
        var value = value?.trimmedNilIfEmpty
        given(value, charLimit) { value = String($0.prefix($1)) }
        return value?.trimmedNilIfEmpty // Retrim because char limit cut off might've left trailing whitespace
    }
}

class ZLNameEditor : ZLTrimmedStringEditor {

    init(placeholder: String = "") {
        super.init()
        autocapitalizationType = .words
        self.placeholder = placeholder
        charLimit = maxUserNameLength
    }

    override func shouldAllow(value: String?) -> Bool {
        return super.shouldAllow(value: value) && !(value?.contains(where: { $0.isEmoji }) ?? false)
    }

    override func sanitize(value: String?) -> String? {
        let value = value?.filter { !$0.isEmoji }
        return super.sanitize(value: value)
    }
}

class ZLCommaSeparatedListEditor : ZLStringEditor<[String]> {
    let maxElementLength: Int?

    init(placeholder: String = "", maxElementLength: Int? = nil) {
        self.maxElementLength = maxElementLength
        super.init(initialValue: [], equalityFunction: ==)
        autocapitalizationType = .words
        self.placeholder = placeholder
    }

    override func value(fromSemanticInput input: String) -> [String] {
        return input.components(separatedBy: ",").compactMap { $0.trimmedNilIfEmpty }
    }

    override func semanticInput(fromValue value: [String]) -> String {
        return value.joined(separator: ", ")
    }

    override func shouldAllow(value: [String]) -> Bool {
        if let maxElementLength = maxElementLength {
            guard !value.contains(where: { $0.count > maxElementLength }) else { return false }
        }
        return true
    }

    override func sanitize(value: [String]) -> [String] {
        // Remove empty elements, and split ones containing a separator
        var value = value.flatMap { $0.components(separatedBy: ",") }.compactMap { $0.trimmedNilIfEmpty }
        // Trim to max element length
        if let maxElementLength = maxElementLength {
            value = value.compactMap { String($0.prefix(maxElementLength)).trimmedNilIfEmpty }
        }
        return value
    }
}

extension ZLNumberEditor {

    static func currencyEditor(prefix: String = "$", alwaysShowDecimal: Bool = false, range: ClosedRange<Decimal> = 0...999_999_999.99) -> ZLNumberEditor {
        return ZLNumberEditor(prefix: prefix, maxDecimalPlaces: 2, preferredDecimalPlaces: alwaysShowDecimal ? [ 2 ] : [ 0, 2 ], range: range)
    }

    // TODO: Improve ZLNumberEditor to support NSAttributedStrings so we can display the TC glyph instead of no prefix.
    static func tellusCashEditor(range: ClosedRange<Decimal>) -> ZLNumberEditor {
        return currencyEditor(prefix: "", range: range)
    }

    static func percentageEditor(maxDecimalPlaces: Int, range: ClosedRange<Decimal>) -> ZLNumberEditor {
        return ZLNumberEditor(suffix: "%", maxDecimalPlaces: maxDecimalPlaces, range: range)
    }

    static func numberOfUnitsEditor() -> ZLNumberEditor {
        return ZLNumberEditor(maxDecimalPlaces: 0, range: 0...99) // We allow 0 and 2 but this must be handled appropriately by the View (i.e. treat 0 and 1 as "no multiple units" scenario)
    }

    static func numberOfDaysEditor() -> ZLNumberEditor {
        return ZLNumberEditor(maxDecimalPlaces: 0, range: 0...9999)
    }

    static func numberOfMonthsEditor() -> ZLNumberEditor {
        return ZLNumberEditor(maxDecimalPlaces: 0, range: 0...10000)
    }

    static func rentAmountEditor(alwaysShowDecimal: Bool = false) -> ZLNumberEditor {
        return currencyEditor(alwaysShowDecimal: alwaysShowDecimal, range: 0...1_000_000_000)
    }

    static func interestRate() -> ZLNumberEditor {
        return percentageEditor(maxDecimalPlaces: 3, range: 0...100)
    }
}
