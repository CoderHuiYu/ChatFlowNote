// Copyright © 2017 Tellus, Inc. All rights reserved.

class ZLAccessoryView : UIView {
    // MARK: Settings
    class var useSafeArea: Bool { return true }

    // MARK: Utilities
    private(set) var heightConstraint: NSLayoutConstraint!
    private(set) var designedHeight: CGFloat!

    private let stackView = UIStackView(axis: .horizontal, distribution: .fillEqually, spacing: 16)
    private lazy var separator: UIView = {
        let result = UIView()
        result.backgroundColor = .zillySeparator()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
        return result
    }()

    // MARK: Initialization
    override init(frame: CGRect) { isEnabled = true; super.init(frame: frame); initialize() }
    required init?(coder: NSCoder) { isEnabled = true; super.init(coder: coder); initialize() }

    convenience init(buttons: [ZLProminentButton]) {
        self.init(frame: .zero)
        setButtons(buttons)
    }

    private func initialize() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .zillyWhite()
        var heightConstant: CGFloat = 80
        if type(of: self).useSafeArea {
            addSubview(stackView, pinningEdgesToSafeArea: [ .left, .top, .right ], withInsets: UIEdgeInsets(uniform: 16))
            heightConstant += iPhoneXExtraMargins.bottom
        } else {
            addSubview(stackView, constrainedToFillWith: UIEdgeInsets(uniform: 16))
        }
        designedHeight = heightConstant
        frame = CGRect(x: 0, y: 0, width: 0, height: heightConstant) // Used so we can determine the view height by simply accessing UIView.height property.
        heightConstraint = heightAnchor.constraint(equalToConstant: heightConstant)
        heightConstraint.isActive = true
        addSubview(separator, pinningEdges: [ .left, .top, .right ])
        addRasterizedShadow(ofSize: 3)
    }

    func setButtons(_ buttons: [ZLProminentButton]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        buttons.forEach { stackView.addArrangedSubview($0) }
        layoutIfNeeded()
    }

    // MARK: Accessors
    var stackViewDistribution: UIStackView.Distribution {
        get { return stackView.distribution }
        set { stackView.distribution = newValue }
    }

    var isSeparatorHidden: Bool {
        get { return separator.isHidden }
        set { separator.isHidden = newValue }
    }

    override var isUserInteractionEnabled: Bool { didSet { self.isEnabled = isUserInteractionEnabled } } // TODO: Get rid of this override, in favor of isEnabled

    var isEnabled: Bool {
        didSet {
            let color: UIColor = isEnabled ? .zillyBlue() : .zillyLightGray() // TODO: Blue is not always the correct color!
            for button in stackView.arrangedSubviews.compactMap({ $0 as? ZLProminentButton }) {
                switch button.style {
                case .filled:
                    UIView.animate(withDuration: 0.25) { button.backgroundColor = color }
                case .stroked:
                    button.setTitleColor(color, for: .normal)
                    UIView.animate(withDuration: 0.25) { button.borderColor = color }
                case .gradient:
                    let showGradient = isEnabled
                    UIView.animate(withDuration: 0.25) { button.gradientView?.isHidden = !showGradient }
                }
            }
        }
    }

}


final class ZLDettachedAccessoryView : ZLAccessoryView {
    override class var useSafeArea: Bool { return false }
}

final class ZLOnboardingAccessoryView : ZLAccessoryView {
    override class var useSafeArea: Bool { return false }
}
