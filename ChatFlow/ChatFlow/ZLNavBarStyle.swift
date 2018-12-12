// Copyright © 2018 Tellus, Inc. All rights reserved.

struct ZLNavBarStyle {
    var backgroundColor: UIColor
    var buttonColor: UIColor
    var titleColor: UIColor
    var font: UIFont
    var hasShadow: Bool
    
    // MARK: Presets
    static let white = ZLNavBarStyle(backgroundColor: .zillyWhite(), buttonColor: .zillyBlue(), titleColor: .zillyDarkestGray())
    static let whiteWithoutShadow = ZLNavBarStyle(backgroundColor: .zillyWhite(), buttonColor: .zillyBlue(), titleColor: .zillyDarkestGray(), hasShadow: false)
    static let blue = ZLNavBarStyle(backgroundColor: .zillyBlue(), buttonColor: .zillyWhite(), titleColor: .zillyWhite())
    static let black = ZLNavBarStyle(backgroundColor: UIColor(hexRGB: 0x2D2D2D), buttonColor: .zillyWhite(), titleColor: .zillyWhite())
    static let transparent = ZLNavBarStyle(backgroundColor: .clear, buttonColor: .zillyWhite(), titleColor: .zillyWhite(), hasShadow: false)
    static let transparentBlueButton = ZLNavBarStyle(backgroundColor: .clear, buttonColor: .zillyBlue(), titleColor: .zillyWhite(), hasShadow: false)
    
    // MARK: Initialization
    init(backgroundColor: UIColor, buttonColor: UIColor, titleColor: UIColor, font: UIFont = .zillyFont(size: .size14, weight: .bold), hasShadow: Bool = true) {
        self.backgroundColor = backgroundColor
        self.buttonColor = buttonColor
        self.titleColor = titleColor
        self.font = font
        self.hasShadow = hasShadow
    }
}
