// Copyright © 2017 Tellus, Inc. All rights reserved.

import UIKit

// For this string editor, decorated input, semantic input and value are all different:
// - Decorated input can have a prefix/suffix, grouping separators and could be localized, e.g. "$5,000.70"
// - Semantic input has only 0-9 and a "." as decimal mark, e.g. "5000.70"
// - Value is the actual `Decimal` value, e.g. 5000.7
//
// This editor always keeps the semantic input valid, i.e. convertible to a valid value, or empty.
// It has validation on both the semantic and value level, e.g.:
// - Preventing extraneous leading zero's (semantic check)
// - Checking the value is out of bounds (value check)

/// A string editor that provides as-you-type formatting for entering numbers.
///
/// See ZLStringEditor for general notes on how string editors are implemented.
class ZLNumberEditor : ZLStringEditor<Decimal> {
    let prefix, suffix: String // Corner case, but should not contain any combining characters that might combine with the rest of the string
    let maxDecimalPlaces: Int
    /// Number of decimal places in the canonical form, in order of descending preference.
    let preferredDecimalPlaces: [Int]
    let range: ClosedRange<Decimal>
    let displayLocale = Locale(identifier: "en_US")
    private let semanticLocale = Locale(identifier: "en_US_POSIX") // Invariant locale
    var _emptyValue: Decimal = 0
    override var emptyValue: Decimal { return _emptyValue }

    private var allowsFractionalNumbers: Bool { return maxDecimalPlaces > 0 }

    // MARK: Initialization
    init(prefix: String = "", suffix: String = "", maxDecimalPlaces: Int, preferredDecimalPlaces: [Int] = [], range: ClosedRange<Decimal>) {
        (self.prefix, self.suffix, self.maxDecimalPlaces, self.preferredDecimalPlaces, self.range) = (prefix, suffix, maxDecimalPlaces, preferredDecimalPlaces, range)
        super.init(initialValue: 0, equalityFunction: ==)
        keyboardType = allowsFractionalNumbers ? .decimalPad : .numberPad
    }

    // MARK: Decorated <=> Semantic
    override func semanticInput(fromDecoratedInput decoratedInput: String, selection decoratedSelection: Range<String.Index>) -> (String, Range<String.Index>) {
        if decoratedInput.isEmpty { return (decoratedInput, decoratedSelection) }
        var semanticInput = ""
        var semanticSelection: (lowerBound: String.Index?, upperBound: String.Index?)
        func processMatchingIndexes(decoratedIndex: String.Index, semanticIndex: String.Index) {
            if decoratedIndex == decoratedSelection.lowerBound { semanticSelection.lowerBound = semanticIndex }
            if decoratedIndex == decoratedSelection.upperBound { semanticSelection.upperBound = semanticIndex }
        }
        walkDecoratedInput(decoratedInput) { (index, character, isSemanticallyRelevant) in
            processMatchingIndexes(decoratedIndex: index, semanticIndex: semanticInput.endIndex)
            if isSemanticallyRelevant {
                let semanticCharacter = (character == displayedDecimalMark) ? "." : character
                semanticInput.append(semanticCharacter)
            }
        }
        processMatchingIndexes(decoratedIndex: decoratedInput.endIndex, semanticIndex: semanticInput.endIndex) // Walk excludes endIndex
        return (semanticInput, semanticSelection.lowerBound! ..< semanticSelection.upperBound!)
    }

    override func decoratedInput(fromSemanticInput semanticInput: String, selection semanticSelection: Range<String.Index>) -> (String, Range<String.Index>) {
        if semanticInput.isEmpty { return (semanticInput, semanticSelection) }
        let value = self.value(fromSemanticInput: semanticInput)
        // Get formatter
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = displayLocale
        // Maintain number of decimal places from semantic input
        var charactersAfterDecimalMark: Int? // Note: nil means no decimal mark, 0 means a decimal mark but no characters after it
        if let decimalMarkIndex = semanticInput.index(of: ".") {
            charactersAfterDecimalMark = semanticInput.distance(from: semanticInput.index(after: decimalMarkIndex), to: semanticInput.endIndex)
        }
        formatter.minimumFractionDigits = charactersAfterDecimalMark ?? 0
        formatter.maximumFractionDigits = charactersAfterDecimalMark ?? 0
        // Generate decorated input
        var decoratedInput = formatter.string(from: value as NSNumber)!
        if charactersAfterDecimalMark == 0 { decoratedInput += formatter.decimalSeparator } // Had a decimal mark, but not characters after it, restore that
        decoratedInput = prefix + decoratedInput + suffix
        // Convert selection
        // The can be multiple decorated input indexes for the same semantic input index (e.g. "5|000" matches "$5|,000" or "$5,|000").
        // If the cursor is next to a grouping separator, this separator shifts right when entering a new digit (assuming we are left of the decimal point).
        // Therefore we always choose the first/leftmost index in the decorated input (but never one in the prefix/suffix).
        var decoratedSelection: (lowerBound: String.Index?, upperBound: String.Index?)
        var semanticIndex = semanticInput.startIndex
        let nonPrefixSuffixRange = self.nonPrefixSuffixRange(for: decoratedInput)
        func processMatchingIndexes(decoratedIndex: String.Index, semanticIndex: String.Index) {
            guard nonPrefixSuffixRange.lowerBound...nonPrefixSuffixRange.upperBound ~= decoratedIndex else { return } // Note: *include* end index
            if semanticIndex == semanticSelection.lowerBound && decoratedSelection.lowerBound == nil { decoratedSelection.lowerBound = decoratedIndex }
            if semanticIndex == semanticSelection.upperBound && decoratedSelection.upperBound == nil { decoratedSelection.upperBound = decoratedIndex }
        }
        walkDecoratedInput(decoratedInput) { (index, character, isSemanticallyRelevant) in
            processMatchingIndexes(decoratedIndex: index, semanticIndex: semanticIndex)
            if isSemanticallyRelevant { semanticInput.formIndex(after: &semanticIndex) }
        }
        processMatchingIndexes(decoratedIndex: decoratedInput.endIndex, semanticIndex: semanticIndex) // Walk excludes endIndex
        return (decoratedInput, decoratedSelection.lowerBound! ..< decoratedSelection.upperBound!)
    }

    override func semanticEdit(fromDecoratedEdit edit: String ) -> String {
        if edit == NSLocale.current.decimalSeparator { return "." } // Normalize localized decimal pad
        return edit
    }

    override func performSemanticEdit(_ edit: String, on input: String, selection: Range<String.Index>) -> (String, Range<String.Index>)? {
        if edit.count > 1 { // Paste
            guard input.isEmpty else { return nil } // Disallow paste if the string is not empty, too much added complexity for little gain
            let scanner = Scanner(string: edit)
            scanner.charactersToBeSkipped = CharacterSet(charactersIn: "0123456789.,").inverted
            var result: Decimal = 0
            guard scanner.scanDecimal(&result) else { return nil }
            let semanticInput = self.semanticInput(fromValue: result)
            return super.performSemanticEdit(semanticInput, on: input, selection: selection)
        } else if input.hasPrefix("0"), let indexAfterZero = input.index(input.startIndex, offsetBy: 1, limitedBy: input.endIndex),
            selection == (indexAfterZero..<indexAfterZero) && edit.count == 1 && "1"..."9" ~= edit.first! { // Insert digit for "0|.21"
            let stringWithoutZero = String(input.dropFirst())
            return super.performSemanticEdit(edit, on: stringWithoutZero, selection: stringWithoutZero.startIndex..<stringWithoutZero.startIndex)
        } else if let decimalMarkIndex = input.index(of: "."), selection == input.startIndex..<decimalMarkIndex, edit.isEmpty { // Backspace for "0|.21"
            return super.performSemanticEdit("0", on: input, selection: selection)
        } else if selection == (input.startIndex..<input.startIndex), edit == "." { // Insert decimal mark for "|50" or "|"
            return super.performSemanticEdit("0.", on: input, selection: selection)
        } else if input.hasPrefix("0."), let decimalMarkIndex = input.index(of: "."), selection == decimalMarkIndex..<input.index(after: decimalMarkIndex), edit.isEmpty { // Backspace for "0.|50"
            return super.performSemanticEdit(edit, on: input, selection: input.range(of: "0.")!)
        }
        return super.performSemanticEdit(edit, on: input, selection: selection)
    }

    // Helpers for the above
    private var displayedDecimalMark: Character {
        let decimalMark = displayLocale.decimalSeparator ?? "."
        assert(decimalMark.count == 1)
        return decimalMark.first!
    }

    private func nonPrefixSuffixRange(for input: String) -> Range<String.Index> {
        let indexAfterPrefix = input.index(input.startIndex, offsetBy: prefix.count)
        let indexBeforeSuffix = input.index(input.endIndex, offsetBy: -suffix.count)
        return indexAfterPrefix ..< indexBeforeSuffix
    }

    private func walkDecoratedInput(_ input: String, action: (_ index: String.Index, _ character: Character, _ isSemanticallyRelevant: Bool) -> Void) {
        let nonPrefixSuffixRange = self.nonPrefixSuffixRange(for: input)
        let semanticallyRelevantCharacters = CharacterSet(charactersIn: "0123456789" + String(displayedDecimalMark))
        // Map to semantic
        for (index, character) in input.indexed {
            let isSemanticallyRelevant = (nonPrefixSuffixRange ~= index) && character.unicodeScalars.count == 1 && semanticallyRelevantCharacters.contains(character.unicodeScalars.first!)
            action(index, character, isSemanticallyRelevant)
        }
    }

    // MARK: Value <=> Semantic
    override func value(fromSemanticInput input: String) -> Decimal {
        if input.isEmpty { return emptyValue }
        // This number editor always keep the semantic input valid, i.e. convertible to a valid value, or empty.
        let formatter = NumberFormatter()
        formatter.locale = semanticLocale
        formatter.generatesDecimalNumbers = true
        return formatter.number(from: input)!.decimalValue
    }

    override func semanticInput(fromValue value: Decimal) -> String { // Gives the canonical form
        let formatter = NumberFormatter()
        formatter.locale = semanticLocale
        formatter.usesGroupingSeparator = false
        formatter.minimumIntegerDigits = 1
        let decimalPlaces = (-value.exponent).constrained(toMin: 0)
        formatter.minimumFractionDigits = preferredDecimalPlaces.first { $0 >= decimalPlaces } ?? 0
        formatter.maximumFractionDigits = maxDecimalPlaces
        return formatter.string(from: value as NSNumber)!
    }

    // MARK: Validation
    override func shouldAllow(semanticInput input: String) -> Bool { // Regex: (0|([1-9][0-9]*))(.[0-9]{,%@})?
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
        guard input.rangeOfCharacter(from: allowedCharacters.inverted) == nil else { return false }
        // Decimal mark checks
        if let decimalMarkIndex = input.index(of: ".") {
            guard allowsFractionalNumbers else { return false } // Seperate from the check below because of "45."
            guard decimalMarkIndex != input.startIndex else { return false } // Reject ".34" instead of "0.34"
            // Ensure there's not another decimal mark
            guard input.count(".") <= 1 else { return false }
            // Ensure there's not too many decimal places
            let indexAfterDecimalMark = input.index(after: decimalMarkIndex)
            let charactersAfterDecimalMark = input.distance(from: indexAfterDecimalMark, to: input.endIndex)
            guard charactersAfterDecimalMark <= maxDecimalPlaces else { return false }
        }
        // Ensure no extraneous leading zero's
        if input.first == "0" {
            let nextIndex = input.index(after: input.startIndex)
            guard nextIndex == input.endIndex || input[nextIndex] == "." else { return false }
        }
        return true
    }

    override func shouldAllow(value: Decimal) -> Bool {
        return range ~= value
    }

    override func sanitize(value: Decimal) -> Decimal {
        return value.constrained(to: range)
    }
}
