// Copyright © 2018 Tellus, Inc. All rights reserved.

@objc class ZLViewController : UIViewController {
    private var viewBottomConstraint: NSLayoutConstraint? // Set in setUpAccessoryView() if accessoryViewType is non-nil
    final private(set) var accessoryView: UIView?
    override var inputAccessoryView: UIView? { return (accessoryViewType != nil) ? keyboardObserver.trackingView : super.inputAccessoryView }
    private var didLoad = false

    private lazy var observers = ObserverCollection()
    private lazy var keyboardObserver: KeyboardObserver = {
        return self.observers.addKeyboardObserver(handler: { [unowned self] in self.handleKeyboardFrameChanged($0) }, animated: true, onChangePosition: { [unowned self] in self.handleKeyboardPositionChanged() })
    }()

    static var viewDidAppearNotification: Notification.Name { return Notification.Name(rawValue: "\(String(describing: type(of: self))).viewDidAppearNotification") }
    static var didDismissViewControllerNotification: Notification.Name { return Notification.Name(rawValue: "ZLViewController.didDismissViewController") }

    // MARK: Settings
    /// To be overridden by subclasses. Defaults to `white`.
    var navBarStyle: ZLNavBarStyle { return .white }
    /// To be overridden by subclasses. Defaults to `default`.
    var statusBarStyle: UIStatusBarStyle { return .default }
    /// Implement this to add an accessory view.
    var accessoryViewType: AccessoryViewType? { return nil }
    /// When enabled (the default) adjust the insets in a hacky way to make it work with e.g. `ZLAccessoryView`.
    class var useLegacyAccessoryInsets: Bool { return true }
    
    // MARK: Lifecycle
    override init(nibName: String?, bundle: Bundle?) { super.init(nibName: nibName, bundle: bundle); initialize() }
    required init?(coder: NSCoder) { super.init(coder: coder); initialize() }

    private func initialize() {
        hidesBottomBarWhenPushed = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNextViewControllerBackButtonTitleToGeneric() // Enforce consistent back button formatting
        automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !didLoad {
            didLoad = true
            // Called here instead of in viewDidLoad() because this view must be added last
            setUpAccessoryView()
        }
        guard let zlNavigationController = self.navigationController as? ZLNavigationController else { return }
        zlNavigationController.navBarStyle = navBarStyle
        zlNavigationController.statusBarStyle = statusBarStyle
    }

    deinit { observers.removeAll() }

    // MARK: General
    override func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: animated, completion: completion)
        NotificationCenter.default.post(name: ZLViewController.didDismissViewControllerNotification, object: self, userInfo: nil)
    }

    // MARK: Accessory View
    private func setUpAccessoryView() {
        // Check preconditions & unwrap accessory view
        guard let accessoryViewType = accessoryViewType, self.accessoryView == nil else { return }
        let (accessoryView, shouldObserveToKeyboardChanges): (UIView, Bool) = {
            switch accessoryViewType {
            case .standard(let buttons, let automaticKeyboardManagement): return (ZLAccessoryView(buttons: buttons), automaticKeyboardManagement)
            case .custom(let view, let automaticKeyboardManagement): return (view, automaticKeyboardManagement)
            }
        }()
        accessoryViewWillLoad(accessoryView)
        self.accessoryView = accessoryView
        accessoryViewDidLoad(accessoryView)
        if shouldObserveToKeyboardChanges {
            // Set up keyboard observer
            touch(keyboardObserver)
        }
        // Position accessory view
        view.addSubview(accessoryView, pinningEdgesToSafeArea: [ .left, .right ])
        viewBottomConstraint = view.pinToBottom(accessoryView, constant: -iPhoneXExtraMargins.bottom, useSafeAnchor: true)
    }

    private func handleKeyboardFrameChanged(_ frame: CGRect) {
        guard let viewBottomConstraint = viewBottomConstraint else { return }
        let rectInView = view.convert(frame, from: nil)
        let extraInset = type(of: self).useLegacyAccessoryInsets ? 2*iPhoneXExtraMargins.bottom : iPhoneXExtraMargins.bottom
        viewBottomConstraint.constant = (view.bounds.maxY - rectInView.minY - extraInset).constrained(toMin: -iPhoneXExtraMargins.bottom)
        view.layoutIfNeeded()
    }

    private func handleKeyboardPositionChanged() {
        guard let viewBottomConstraint = viewBottomConstraint else { return }
        let trackingViewRect = view.convert(keyboardObserver.trackingView.bounds, from: keyboardObserver.trackingView)
        let extraInset = type(of: self).useLegacyAccessoryInsets ? 2*iPhoneXExtraMargins.bottom : iPhoneXExtraMargins.bottom
        viewBottomConstraint.constant = (view.bounds.height - trackingViewRect.maxY - extraInset).constrained(toMin: -iPhoneXExtraMargins.bottom)
        view.layoutIfNeeded()
    }

    // Accessory View Lifecycle
    func accessoryViewWillLoad(_ accessoryView: UIView) { }
    func accessoryViewDidLoad(_ accessoryView: UIView) { }
}

// MARK: Accessory View Type
extension ZLViewController {

    enum AccessoryViewType {
        case standard(buttons: [ZLProminentButton], automaticKeyboardManagement: Bool)
        case custom(view: UIView, automaticKeyboardManagement: Bool)
    }
}
