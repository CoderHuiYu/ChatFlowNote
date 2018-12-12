// Copyright © 2017 Tellus, Inc. All rights reserved.

// MARK: General
extension String {
    func trimmed() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var trimmedNilIfEmpty: String? {
        let result = trimmed()
        return result.isEmpty ? nil : result
    }

    func deletePathExtension() -> String {
        return URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }

    /// Returns the size required to draw the string given a certain width and height constraint, wrapping as necessary.
    ///
    /// The returned size might break the constraints (typically the height constraint) if there is not enough space to fit the entire string.
    /// - Parameter isUsedToSizeView: To use the return value to size a view, set this parameter to true and the result will be rounded up to the nearest integer.
    func size(maxWidth: CGFloat = .greatestFiniteMagnitude, maxHeight: CGFloat = .greatestFiniteMagnitude, attributes: [NSAttributedString.Key:Any]? = nil, isUsedToSizeView: Bool) -> CGSize {
        let maxSize = CGSize(width: maxWidth, height: maxHeight)
        var result = self.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size
        if isUsedToSizeView { result = CGSize(width: ceil(result.width), height: ceil(result.height)) }
        return result
    }

    var alphanumericAndEmojiOnlyString: String {
        return filter { char in return char.isEmoji || char.isAlphanumeric }
    }
}

extension NSString {
    @objc var objc_alphanumericAndEmojiOnlyString: NSString {
        return (self as String).alphanumericAndEmojiOnlyString as NSString
    }
}

extension Character {
    var isEmoji: Bool { // Not *completely* exhaustive/correct atm, this gets pretty complicated
        let emojiVariantSelector: UnicodeScalar = "\u{FE0F}"
        if unicodeScalars.contains(emojiVariantSelector) { return true }
        return unicodeScalars.allMatch { scalar in
            switch scalar.value {
            case 0x200D, // Zero-width joiner
                0x20D0...0x20FF, // Combining Diacritical Marks for Symbols
                0x2139, 0x2194...0x2199, 0x21A9, 0x21AA, 0x231A, 0x231B, 0x2328, 0x23CF, 0x23E9...0x23F3, 0x23F8...0x23FA, 0x24C2,
                0x25A0...0x27BF, // Geometric shapes, misc symbols & dingbats
                0xFE00...0xFE0F, // Variation selector
                0x1F000...0x1F9FF: // Emoji & related
                    return true
            default: return false
            }
        }
    }

    var isAlphanumeric: Bool {
        let characterSet = CharacterSet.alphanumerics
        let string = String(self)
        return string.rangeOfCharacter(from: characterSet) != nil
    }
}

// MARK: Localization
extension String {
    /// Get a formatted string based on the number passed.
    /// - parameter format: `NSLocalizedString` containing one `%@` for where the conditionalized numbered string goes, e.g. `NSLocalizedString(@"You Have %@", nil)`, or simply `"%@"` (the default) without `NSLocalizedString` if there're no other words to be localized.
    /// - parameter number: The number you want to conditionalize on.
    /// - parameter zero: `NSLocalizedString` containing no placeholders (optional), e.g. `NSLocalizedString(@"No Friend", nil)`.
    /// - parameter singular: `NSLocalizedString` containing no placeholders, `e.g. NSLocalizedString(@"One Friend", nil)`.
    /// - parameter pluralFormat: `NSLocalizedString` containing one `%@` for where the conditionalized number goes, e.g. `NSLocalizedString(@"%@ Friends", nil)`.
    init(format: String = "%@", number: Decimal, zero: String? = nil, singular: String, pluralFormat: String) {
        let numberString: String
        if number == 0, let zero = zero {
            numberString = zero
        } else if abs(number) == 1 {
            numberString = singular
        } else {
            numberString = String(format: pluralFormat, number as NSNumber)
        }
        self = String(format: format, numberString)
    }

    init(format: String = "%@", number: Int, zero: String? = nil, singular: String, pluralFormat: String) {
        self.init(format: format, number: Decimal(number), zero: zero, singular: singular, pluralFormat: pluralFormat)
    }
}
