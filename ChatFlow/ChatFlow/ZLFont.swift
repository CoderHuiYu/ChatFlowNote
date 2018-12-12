// Copyright © 2017 Tellus, Inc. All rights reserved.

import UIKit

enum ZLFontWeight {
    /// Equivalent to CSS weight 400.
    case regular
    /// Equivalent to CSS weight 600.
    case semibold
    /// Equivalent to CSS weight 700.
    case bold

    var systemWeight: CGFloat {
        switch self {
        case .regular: return UIFont.Weight.regular.rawValue
        case .semibold: return UIFont.Weight.semibold.rawValue
        case .bold: return UIFont.Weight.bold.rawValue
        }
    }
}

@objc enum ZLFontSize : Int, CaseIterable {
    case size8 = 8
    case size10 = 10
    case size12 = 12
    case size14 = 14
    case size17 = 17
    case size19 = 19
    case size24 = 24
    case size32 = 32
    case size40 = 40
    case size50 = 50

    var pointSize: CGFloat { return CGFloat(rawValue) }

    var lineHeight: CGFloat {
        switch self {
        case .size8: return 10
        case .size10: return 12
        case .size12: return 16
        case .size14: return 18
        case .size17: return 22
        case .size19: return 24
        case .size24: return 32
        case .size32: return 36
        case .size40: return 40
        case .size50: return 57
        }
    }
}

extension UIFont {
    private static func zillyFont(size: CGFloat, weight: UIFont.Weight, isItalic: Bool = false) -> UIFont {
        let fontName: String = {
            if weight.rawValue <= UIFont.Weight.regular.rawValue {
                return isItalic ? "OpenSans-Italic" : "OpenSans-Regular"
            } else if weight.rawValue <= UIFont.Weight.medium.rawValue {
                return isItalic ? "OpenSans-SemiBoldItalic" : "OpenSans-SemiBold"
            } else {
                return isItalic ? "OpenSans-BoldItalic" : "OpenSans-Bold"
            }
        }()
        return UIFont(name: fontName, size: size)!
    }

    // Not @objc because it doesn't give a warning when passing the system constants (e.g. UIFontSizeBold)
    class func zillyFont(size: ZLFontSize, weight: ZLFontWeight = .regular, isItalic: Bool = false) -> UIFont {
        return zillyFont(size: size.pointSize, weight: UIFont.Weight(rawValue: weight.systemWeight), isItalic: isItalic)
    }

    class func zillyFont(nonStandardSize: CGFloat, weight: ZLFontWeight = .regular, isItalic: Bool = false) -> UIFont {
        return zillyFont(size: nonStandardSize, weight: UIFont.Weight(rawValue: weight.systemWeight), isItalic: isItalic)
    }
}

// MARK: Legacy
extension UIFont {
    @objc class func objc_zillyFont(size: CGFloat) -> UIFont {
        return zillyFont(size: size, weight: UIFont.Weight.regular)
    }

    @objc class func objc_zillyFont(size: CGFloat, weight: CGFloat) -> UIFont {
        return zillyFont(size: size, weight: UIFont.Weight(rawValue: weight))
    }

    /// Tellus fonts by use
    @objc static func zillyLargeBoldTitle() -> UIFont { return UIFont.zillyFont(size: .size24, weight: .bold) }
    @objc static func zillyCellDescription() -> UIFont { return UIFont.zillyFont(size: .size12) }
    @objc static func zillyDetailLabelTitle() -> UIFont { return UIFont.zillyFont(size: .size10) }
    @objc static func zillyMediumDetailLabelTitle() -> UIFont { return UIFont.zillyFont(size: .size10, weight: .semibold) }
    @objc static func zillyDefaultFontAndSize() -> UIFont { return UIFont.zillyFont(size: .size14) }
    @objc static func zillyDefaultSemiBoldFontAndSize() -> UIFont { return UIFont.zillyFont(size: .size14, weight: .bold) }
}
