// Copyright © 2018 Tellus, Inc. All rights reserved.

class ZLGradientView : UIView {
    var gradient: Gradient = .blueToDarkBlue { didSet { update() } }
    var direction: Direction = .topLeftToBottomRight { didSet { update() } }
    
    override class var layerClass: AnyClass { return CAGradientLayer.self }
    override var layer: CAGradientLayer { return super.layer as! CAGradientLayer }
    
    // MARK: Nested Types
    struct Gradient : Equatable {
        let components: [UIColor]
        let locations: [NSNumber]?
        
        // Lifecycle
        init(components: [UIColor], locations: [NSNumber]? = nil) {
            self.components = components
            self.locations = locations
        }

        // Presets
        // Named after the lightest color to the darkest
        /// Preview (direction: topLeftToBottomRight): https://i.imgur.com/IoTkLsn.png
        static let whiteToLightestGray = Gradient(components: [ .zillyBackground(), .zillyWhite() ])
        /// Preview (direction: topLeftToBottomRight): https://i.imgur.com/CNGHS5n.png
        static let lightYellowToPeach = Gradient(components: [ .zillyLightYellow(), .zillyPeach() ])
        /// Preview (direction: topLeftToBottomRight): https://i.imgur.com/RbR6DxA.png
        static let goldYellowToDarkYellow = Gradient(components: [ .zillyGoldYellow(), .zillyDarkYellow() ])
        /// Preview (direction: topLeftToBottomRight): https://i.imgur.com/UIBT6eC.png
        static let blueToDarkBlue = Gradient(components: [ .zillyBlue(), .zillyDarkBlue() ])
        /// Preview (direction: topLeftToBottomRight): https://i.imgur.com/QINOeUm.png
        static let blueToPurple = Gradient(components: [ .zillyLightBlue(), .zillyMidnightPurple() ])
        /// Preview (direction: topLeftToBottomRight): https://i.imgur.com/x0fSns5.png
        static let lightGreenToTeal = Gradient(components: [ .zillyLightGreen(), .zillyTeal() ])
        /// Preview (direction: topLeftToBottomRight): https://i.imgur.com/4QYW7qU.png
        static let redToDarkRed = Gradient(components: [ .zillyVermilionRed(), .zillyDarkRed() ])
        /// Preview (direction: topLeftToBottomRight): https://i.imgur.com/AFJl20C.png
        static let rubyToDarkPurple = Gradient(components: [ .zillyRuby(), .zillyDarkPurple() ])
        /// Preview (direction: topLeftToBottomRight): https://i.imgur.com/GCB9MTc.png
        static let spiroDiscoBallToMediumElectricBlue = Gradient(components: [ .zillySpiroDiscoBallBlue(), .zillyMediumElectricBlue() ])

        func apply(to layer: CAGradientLayer, direction: Direction) {
            layer.colors = components.map { $0.cgColor }
            let (startPoint, endPoint) = { () -> (CGPoint, CGPoint) in
                switch direction {
                case .topLeftToBottomRight: return (CGPoint(x: 0.01, y: 0), CGPoint(x: 1, y: 1))
                case .topRightToBottomLeft: return (CGPoint(x: 1, y: 0), CGPoint(x: 0, y: 1))
                case .bottomRightToTopLeft: return (CGPoint(x: 1, y: 1), CGPoint(x: 0.01, y: 0))
                case .topToBottom: return (CGPoint(x: 0.5, y: 0), CGPoint(x: 0.5, y: 1))
                case .leftToRight: return (CGPoint(x: 0, y: 0.5), CGPoint(x: 1, y: 0.5))
                case .bottomToTop: return (CGPoint(x: 0.5, y: 1), CGPoint(x: 0.5, y: 0))
                case .rightToLeft: return (CGPoint(x: 1, y: 0.5), CGPoint(x: 0, y: 0.5))
                }
            }()
            layer.startPoint = startPoint
            layer.endPoint = endPoint
            layer.locations = locations
        }
    }
    
    enum Direction { case topLeftToBottomRight, topRightToBottomLeft, bottomRightToTopLeft, topToBottom, leftToRight, bottomToTop, rightToLeft }
    
    // MARK: Lifecycle
    convenience init(gradient: Gradient, direction: Direction = .topLeftToBottomRight) {
        self.init()
        self.gradient = gradient
        self.direction = direction
        update()
    }
    
    override init(frame: CGRect) { super.init(frame: frame); update() }
    required init?(coder: NSCoder) { super.init(coder: coder); update() }
    
    // MARK: Updating
    private func update() {
        gradient.apply(to: layer, direction: direction)
    }
}

// MARK: Convenience
private extension UIColor {
    static func zillyDarkPurple() -> UIColor { return UIColor(red: 0.38, green: 0.15, blue: 0.45, alpha: 1) }
    static func zillyDarkRed() -> UIColor { return UIColor(red: 0.7, green: 0.07, blue: 0.12, alpha: 1) }
    static func zillyDarkYellow() -> UIColor { return UIColor(red: 0.8, green: 0.55, blue: 0, alpha: 1) }
    static func zillyGoldYellow() -> UIColor { return UIColor(red: 0.95, green: 0.7, blue: 0.17, alpha: 1) }
    static func zillyLightBlue() -> UIColor { return UIColor(red: 0.11, green: 0.81, blue: 0.87, alpha: 1) }
    static func zillyLightGreen() -> UIColor { return UIColor(red: 0.34, green: 0.79, blue: 0.52, alpha: 1) }
    static func zillyLightYellow() -> UIColor { return UIColor(red: 0.99, green: 0.89, blue: 0.54, alpha: 1) }
    static func zillyMidnightPurple() -> UIColor { return UIColor(red: 0.36, green: 0.14, blue: 0.48, alpha: 1) }
    static func zillyMediumElectricBlue() -> UIColor { return UIColor(red: 0, green: 0.35, blue: 0.56, alpha: 1) }
    static func zillyPeach() -> UIColor { return UIColor(red: 0.95, green: 0.51, blue: 0.51, alpha: 1) }
    static func zillyRuby() -> UIColor { return UIColor(red: 0.77, green: 0.2, blue: 0.39, alpha: 1) }
    static func zillySpiroDiscoBallBlue() -> UIColor { return UIColor(red: 0.08, green: 0.75, blue: 0.94, alpha: 1) }
    static func zillyTeal() -> UIColor { return UIColor(red: 0.1, green: 0.31, blue: 0.41, alpha: 1) }
    static func zillyVermilionRed() -> UIColor { return UIColor(red: 0.958, green: 0.29, blue: 0.35, alpha: 1) }
}
