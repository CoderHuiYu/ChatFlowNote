// Copyright © 2017 Tellus, Inc. All rights reserved.

import UIKit

extension UIColor {
    convenience init(hexRGB value: UInt) {
        let red = CGFloat((value >> 16) & 0xff) / 255
        let green = CGFloat((value >> 8) & 0xff) / 255
        let blue = CGFloat((value >> 0) & 0xff) / 255
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }

    // MARK: Official Tellus Palette
    @objc static func zillyBlue() -> UIColor { return UIColor(hexRGB: 0x18ACF8) }
    @objc static func zillyYellow() -> UIColor { return UIColor(hexRGB: 0xF3B32B) }
    @objc static func zillyPurple() -> UIColor { return UIColor(hexRGB: 0xBD4C9B) }
    @objc static func zillyGreen() -> UIColor { return UIColor(hexRGB: 0x4AA660) }
    @objc static func zillyRed() -> UIColor { return UIColor(hexRGB: 0xF94B5A) }
    @objc static func zillyDarkBlue() -> UIColor { return UIColor(hexRGB: 0x006EA6) }

    @objc static func zillyDarkestGray() -> UIColor { return UIColor(hexRGB: 0x1E1E1E) }
    @objc static func zillyDarkGray() -> UIColor { return UIColor(hexRGB: 0x5A5A5A) }
    @objc static func zillyGray() -> UIColor { return UIColor(hexRGB: 0x787878) }
    @objc static func zillyLightGray() -> UIColor { return UIColor(hexRGB: 0xD2D2D2) }
    @objc static func zillyLightestGray() -> UIColor { return UIColor(hexRGB: 0xF2F2F2) }
    @objc static func zillyDarkWhite() -> UIColor { return UIColor(hexRGB: 0xFAFAFA) }
    @objc static func zillyWhite() -> UIColor { return UIColor(hexRGB: 0xFFFFFF) }

    // MARK: Tellus Colors By Use
    @objc static func zillyBackground() -> UIColor { return UIColor.zillyLightestGray() }
    @objc static func zillyNavBarContrast() -> UIColor { return UIColor.zillyWhite() }
    @objc static func zillyShadow() -> UIColor { return UIColor(hexRGB: 0xE6E6E6) }
    @objc static func zillyDarkText() -> UIColor { return UIColor.zillyDarkestGray() }
    @objc static func zillyPlaceholderText() -> UIColor { return UIColor.zillyLightGray() }
    @objc static func zillySeparator() -> UIColor { return UIColor(hexRGB: 0xE6E6E6) }
    @objc static func zillyThickSeparator() -> UIColor { return UIColor(hexRGB: 0xBEBEBE) }
    @objc static func zillyPositiveNumber() -> UIColor { return UIColor.zillyBlue() }
    @objc static func zillyNegativeNumber() -> UIColor { return UIColor.zillyRed() }
    @objc static func zillySearchBarBackground() -> UIColor { return UIColor(hexRGB: 0xEAEBED) }
    @objc static func zillyHighlightedRowBackground() -> UIColor { return UIColor(hexRGB: 0xD9D9D9) }
}

extension UIColor {

    @objc(colorForString:)
    static func color(for text: String) -> UIColor {
        return color(for: Int(text.uppercased().unicodeScalars.first?.value ?? 0))
    }

    @objc(colorForInteger:)
    static func color(for integer: Int) -> UIColor {
        let colors = [ zillyBlue(), zillyYellow(), zillyGreen(), zillyPurple(), zillyDarkBlue() ]
        return colors[integer % colors.count]
    }
}
