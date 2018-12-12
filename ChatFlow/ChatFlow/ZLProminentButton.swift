// Copyright © 2017 Tellus, Inc. All rights reserved.

// TODO: Inherit from ZLGradientButton
final class ZLProminentButton : ZLButton {
    private let _action: ActionClosure
    let style: Style
    let buttonColor: UIColor
    var gradientView: ZLGradientView?
    var isInitiallyEnabled: Bool = true { didSet { UIView.performWithoutAnimation { isEnabled = isInitiallyEnabled } } } // To prevent the button to appear enabled and change to disabled

    // TODO: Add associated colors to the .filled and .stroked cases
    enum Style { case filled, stroked, gradient(ZLGradientView.Gradient) }

    // MARK: Initialization
    init(title: String, action: @escaping ActionClosure, style: Style = .gradient(.blueToDarkBlue), color: UIColor = .zillyBlue(), isInitiallyEnabled: Bool = true) {
        (_action, self.style, self.buttonColor) = (action, style, color)
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.isInitiallyEnabled = isInitiallyEnabled
        UIView.performWithoutAnimation { isEnabled = isInitiallyEnabled } // To prevent the button to appear enabled and change to disabled
        cornerRadius = defaultCornerRadius
        constrainHeight(to: 48)
        self.title = title
        titleLabel!.font = .zillyFont(size: .size14, weight: .bold)
        titleEdgeInsets = UIEdgeInsets(uniform: 8)
        switch style {
        case .filled:
            backgroundColor = color
            setTitleColor(.zillyWhite(), for: .normal)
            gradientView = nil
        case .stroked:
            backgroundColor = .clear
            setTitleColor(color, for: .normal)
            borderColor = color
            borderWidth = 1.5
            gradientView = nil
        case .gradient(let gradient):
            backgroundColor = .zillyLightGray() 
            gradientView = ZLGradientView(gradient: gradient, direction: .leftToRight)
            gradientView!.isUserInteractionEnabled = false
            addSubview(gradientView!, pinningEdges: .all)
            sendSubviewToBack(gradientView!)
        }
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }
    
    override init(frame: CGRect) { preconditionFailure() }
    required init?(coder: NSCoder) { preconditionFailure() }
    
    // MARK: Accessors
    override var isUserInteractionEnabled: Bool { didSet { self.isEnabled = isUserInteractionEnabled } } // TODO: Get rid of this override, in favor of isEnabled

    override var isEnabled: Bool {
        didSet {
            let color: UIColor = isEnabled ? buttonColor : .zillyLightGray()
            switch style {
            case .filled:
                UIView.animate(withDuration: 0.25) { self.backgroundColor = color }
            case .stroked:
                setTitleColor(color, for: .normal)
                UIView.animate(withDuration: 0.25) { self.borderColor = color }
            case .gradient:
                let showGradient = isEnabled
                UIView.animate(withDuration: 0.25) { self.gradientView?.isHidden = !showGradient }
            }
        }
    }
    
    // MARK: Actions
    @objc private func handleTap() { _action() }
}
